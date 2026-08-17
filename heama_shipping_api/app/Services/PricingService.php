<?php

namespace App\Services;

use App\Models\FxRate;
use App\Models\Setting;
use App\Models\Store;

/**
 * Converts a captured foreign price into the all-in price the customer pays, in
 * the store's charge currency (Shein & manual = IQD, everything else = USD), and
 * computes order-level shipping + service fee.
 *
 * Money is the REAL amount in the currency's major unit: IQD = dinars (whole),
 * USD = dollars (2 decimals), stored in decimal(14,2) columns. FX uses IQD as
 * the bridge, so no USD rate is needed as long as USD and TRY both have an IQD
 * rate.
 */
class PricingService
{
    /**
     * The currency a store charges the customer in, from `stores.charge_currency`:
     * Shein (USD webview price) is charged in IQD, every other store (TL webview
     * price) is charged in USD. Unknown / unset store → USD.
     *
     * The captured `source_price` is then converted into THIS currency and stored
     * as the real amount (IQD dinars / USD dollars).
     */
    public function chargeCurrencyFor(?Store $store): string
    {
        $c = $store?->charge_currency;

        return $c ? strtoupper($c) : 'USD';
    }

    /**
     * True when a store ships free AND has no Heama service fee. Driven by the
     * `free_stores` setting (comma-separated store keys, default "shein"), so it
     * can be changed without a deploy.
     */
    public function isFreeStore(?Store $store): bool
    {
        $key = $store?->key;
        if ($key === null || $key === '') {
            return false;
        }
        $free = array_filter(array_map('trim', explode(',', (string) Setting::get('free_stores', 'shein'))));
        $key = strtolower($key);
        foreach ($free as $f) {
            if (strtolower($f) === $key) {
                return true;
            }
        }

        return false;
    }

    /** Converts an amount between currencies via IQD as the bridge (major units). */
    public function convert(float $amount, string $from, string $to): float
    {
        $from = strtoupper($from);
        $to = strtoupper($to);
        if ($from === $to) {
            return $amount;
        }
        $rFrom = $from === 'IQD' ? 1.0 : FxRate::rateFor($from);
        $rTo = $to === 'IQD' ? 1.0 : FxRate::rateFor($to);
        if ($rFrom <= 0 || $rTo <= 0) {
            return 0.0; // unknown rate — caller rejects the capture
        }

        return $amount * $rFrom / $rTo;
    }

    /**
     * Rounds an amount UP to a clean step and returns the REAL amount:
     *  - USD to the nearest `rounding_step_usd` (e.g. $0.50: 10.01→10.50, 10.51→11.00)
     *  - IQD to the nearest `rounding_step` dinars (e.g. 250: 10,001→10,250)
     *
     * A tiny epsilon is subtracted before ceil() so an amount ALREADY exactly on
     * a step (e.g. 10.50 or 10,250) doesn't get bumped up by floating-point noise.
     */
    public function roundUp(float $amount, string $currency): float
    {
        $currency = strtoupper($currency);
        if ($currency === 'USD') {
            $step = (float) Setting::get('rounding_step_usd', 0.25);
            $rounded = $step > 0 ? ceil($amount / $step - 1e-9) * $step : $amount;

            return round($rounded, 2); // dollars
        }
        // IQD: round up to the nearest step of dinars (no subunit).
        $step = (int) Setting::get('rounding_step', 250);

        return $step > 0 ? (float) (ceil($amount / $step - 1e-9) * $step) : round($amount);
    }

    /** All-in unit price the customer pays, in $chargeCurrency (real amount). */
    public function chargeUnit(float $sourcePrice, string $sourceCurrency, string $chargeCurrency): float
    {
        if ($sourcePrice <= 0) {
            return 0.0;
        }
        $converted = $this->convert($sourcePrice, $sourceCurrency, $chargeCurrency);
        if ($converted <= 0) {
            return 0.0;
        }
        $markup = (float) Setting::get('markup_percent', 15) / 100;

        return $this->roundUp($converted * (1 + $markup), $chargeCurrency);
    }

    /** Back-compat: all-in unit price in IQD dinars. */
    public function toIqd(float $sourcePrice, string $currency): float
    {
        return $this->chargeUnit($sourcePrice, $currency, 'IQD');
    }

    /**
     * Flat shipping to Iraq in $currency (real amount), read from settings so it
     * can be changed without a deploy: USD orders (every store except Shein) use
     * `shipping_usd` (default $2); IQD orders use `shipping_flat_iqd` (default 9000).
     */
    public function shipping(float $itemsTotal, string $currency = 'IQD'): float
    {
        return strtoupper($currency) === 'USD'
            ? round((float) Setting::get('shipping_usd', 2), 2)
            : (float) Setting::get('shipping_flat_iqd', 9000);
    }

    /**
     * Shipping for ONE item line, in $currency (real amount): 0 for free-shipping
     * stores (Shein), otherwise the flat PER-UNIT rate ($2 `shipping_usd` / IQD
     * `shipping_flat_iqd`) MULTIPLIED by the quantity — 2 pieces ship for $4,
     * 3 for $6. Stored on each order item so the admin can re-price it later.
     */
    public function shippingForItem(?Store $store, string $currency = 'IQD', int $qty = 1): float
    {
        if ($this->isFreeStore($store)) {
            return 0.0;
        }

        return round($this->shipping(0.0, $currency) * max(1, $qty), 2);
    }

    /**
     * Shipping for a set of items = the SUM of each line's qty-aware shipping,
     * so the order total always equals what the per-item breakdown shows.
     */
    public function shippingForItems($items, string $currency = 'IQD'): float
    {
        if ($items === null || count($items) === 0) {
            return $this->shipping(0.0, $currency); // no context — one flat estimate
        }

        $total = 0.0;
        foreach ($items as $item) {
            // Stock items ship free — their stored price already includes it.
            if (! empty($item->stock_item_id)) {
                continue;
            }
            $total += $this->shippingForItem($item->store ?? null, $currency, (int) ($item->qty ?? 1));
        }

        return round($total, 2);
    }

    /** Heama service fee as a percentage of the items subtotal (same currency). */
    public function serviceFee(float $itemsTotal, string $currency = 'IQD'): float
    {
        $pct = (float) Setting::get('service_fee_percent', 10) / 100;
        $fee = $itemsTotal * $pct;

        // USD keeps cents; IQD is whole dinars.
        return strtoupper($currency) === 'USD' ? round($fee, 2) : round($fee);
    }

    /**
     * Service fee for a set of items. Waived (0) when every item comes from a
     * free store (e.g. Shein); otherwise the standard percentage fee.
     */
    public function serviceFeeForItems($items, float $itemsTotal, string $currency = 'IQD'): float
    {
        if ($items !== null && count($items) > 0) {
            $allFree = true;
            foreach ($items as $item) {
                if (! $this->isFreeStore($item->store ?? null)) {
                    $allFree = false;
                    break;
                }
            }
            if ($allFree) {
                return 0.0;
            }
        }

        return $this->serviceFee($itemsTotal, $currency);
    }

    /**
     * Full breakdown for a subtotal, all real amounts in $currency.
     *
     * @return array{currency:string, items_total:float, shipping:float, service_fee:float, total:float}
     */
    public function breakdown(float $itemsTotal, ?float $shipping = null, string $currency = 'IQD', ?float $serviceFee = null): array
    {
        $currency = strtoupper($currency);
        $shipping ??= $this->shipping($itemsTotal, $currency);
        $fee = $serviceFee ?? $this->serviceFee($itemsTotal, $currency);

        return [
            'currency' => $currency,
            'items_total' => $itemsTotal,
            'shipping' => $shipping,
            'service_fee' => $fee,
            'total' => $itemsTotal + $shipping + $fee,
        ];
    }
}
