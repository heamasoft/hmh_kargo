<?php

namespace App\Http\Resources;

use App\Services\PricingService;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\CartItem */
class CartItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        // What this line adds for carriage: the admin's own figure where they
        // set one, otherwise the flat per-unit rate ($2 for Türkiye, 0 for the
        // international side, 0 for stock already here). Shown inside the cart
        // card and summed into the cart's Shipping total.
        $pricing = app(PricingService::class);
        $shippingUnit = $this->shippingUnit($pricing);
        $shipping = $this->shippingTotal($pricing);

        return [
            'id' => $this->id,
            'store_id' => $this->store_id,
            // One of our stores answers for itself; a hand-added item carries
            // the shop's name on the line, so the cart still says where it is
            // from rather than showing a blank.
            'store' => $this->store?->name ?? $this->store_name,
            'store_key' => $this->store?->key,
            'source_url' => $this->source_url,
            'title' => $this->title,
            'image_url' => $this->image_url,
            // What the shop itself asks, in the shop's own currency — the cart
            // shows it beside what we charge, so a shopper can see where the
            // dollar figure came from and an admin can check it at a glance.
            'source_price' => (float) $this->source_price,
            'source_currency' => $this->source_currency,
            'charge_currency' => $this->charge_currency ?: 'IQD',
            // Real amount in charge_currency (IQD dinars / USD dollars).
            'iqd_price' => (float) $this->iqd_price,
            // Per unit, and for the line. The app edits the per-unit figure.
            'shipping_unit' => (float) $shippingUnit,
            'shipping' => (float) $shipping,
            // True once an admin has set this line's shipping by hand, so the
            // app can show it as theirs rather than as the standard rate.
            'shipping_set' => $this->shipping_override !== null,
            'color' => $this->color,
            'size' => $this->size,
            'sku' => $this->sku,
            'note' => $this->note,
            'qty' => (int) $this->qty,
            'line_total_iqd' => (float) $this->lineTotalIqd(),
            // Everything this line costs: the goods plus their carriage.
            'line_all_in' => round((float) $this->lineTotalIqd() + $shipping, 2),
            // In-stock item (already in the company; ships free, ready to deliver).
            'is_stock' => $this->stock_item_id !== null,
        ];
    }
}
