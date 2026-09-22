<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Store;
use App\Services\PricingService;
use App\Services\ScraperService;
use App\Services\ShareLinkResolver;
use App\Services\TrendyolLinkResolver;
use App\Support\Domains;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CaptureController extends Controller
{
    public function __construct(
        private readonly PricingService $pricing,
        private readonly ScraperService $scraper,
        private readonly ShareLinkResolver $shareLinks,
        private readonly TrendyolLinkResolver $trendyolLinks,
    ) {}

    /**
     * POST /resolve — turns a link shared from a store's APP into the normal
     * product URL, which the client then loads in its WebView and scrapes.
     *
     * A share link carries no price or variants, so pasting one used to capture
     * a title and photo at best. Anything we can't resolve comes back unchanged
     * with `share: false`, so the caller can just load what the user pasted.
     */
    public function resolve(Request $request): JsonResponse
    {
        $data = $request->validate([
            'url' => ['required', 'url', 'max:1024'],
        ]);

        // Trendyol: a shared product comes back as a URL to capture as usual; a
        // shared collection (Trendyol's stand-in for sharing a cart) comes back
        // with its items already read, so the client needs no browser for it.
        if ($this->trendyolLinks->handles($data['url'])) {
            $ty = $this->trendyolLinks->resolve($data['url']);
            if ($ty === null) {
                return response()->json([
                    'share' => false,
                    'url' => $data['url'],
                    // Why it failed, for the app's debug log — a blocked server
                    // and an unreadable link look identical without it. Its mere
                    // presence also confirms this code is the one deployed.
                    'reason' => $this->trendyolLinks->lastReason,
                    'resolver' => 'trendyol-2',
                ]);
            }

            return response()->json([
                'share' => true,
                'kind' => $ty['kind'],
                'store_key' => 'trendyol',
                'url' => $ty['url'],
                'source_url' => $data['url'],
                'title' => $ty['title'] ?? '',
                'items' => $ty['items'] ?? [],
                // Trendyol refused the server; the app reads `url` itself.
                'read_on_device' => $ty['read_on_device'] ?? false,
                'reason' => $this->trendyolLinks->lastReason,
                'resolver' => 'trendyol-3',
            ]);
        }

        // Build the product URL on the host the client is already browsing — a
        // share link's own host (onelink.shein.com) still matches the store.
        $store = $this->storeForUrl($data['url']);
        $resolved = $this->shareLinks->resolve($data['url'], $store?->base_url);

        if ($resolved === null) {
            return response()->json([
                'share' => false,
                'url' => $data['url'],
            ]);
        }

        return response()->json([
            'share' => true,
            // 'product' → one item's page; 'cart' → a shared cart of many items.
            'kind' => $resolved['kind'] ?? 'product',
            'url' => $resolved['url'],
            'source_url' => $data['url'],
            'sku' => $resolved['goods_id'],
            'title' => $resolved['title'] ?? '',
            'image_url' => $resolved['image'] ?? '',
        ]);
    }

    /**
     * POST /scrape — fetch a product URL server-side, extract its details, and
     * price it in IQD. Works for both web and native clients.
     */
    public function scrape(Request $request): JsonResponse
    {
        $data = $request->validate([
            'url' => ['required', 'url', 'max:1024'],
        ]);

        $store = $this->storeForUrl($data['url']);
        $scraped = $this->scraper->fetch($data['url']);

        // A known store's currency is authoritative (Trendyol=TRY, Shein=USD) so
        // TL prices convert correctly regardless of what the page/client reports.
        $currency = $store && $store->currency
            ? strtoupper($store->currency)
            : strtoupper($scraped['currency'] ?? 'USD');
        $price = $scraped['price'] ?? 0.0;
        // Charge currency: Shein/manual = IQD, everything else = USD.
        $chargeCurrency = $this->pricing->chargeCurrencyFor($store);
        $chargeAmount = $price > 0 ? $this->pricing->chargeUnit($price, $currency, $chargeCurrency) : 0;

        return response()->json([
            'store' => $store ? ['id' => $store->id, 'key' => $store->key, 'name' => $store->name] : null,
            'source_url' => $data['url'],
            'title' => $scraped['title'] ?? '',
            'image_url' => $scraped['image'] ?? '',
            'source_price' => $price,
            'source_currency' => $currency,
            'charge_currency' => $chargeCurrency,
            'charge_amount' => $chargeAmount, // all-in unit price, minor units of charge_currency
            'iqd_price' => $price > 0 ? $this->pricing->toIqd($price, $currency) : 0, // IQD-equivalent (reference)
            // false → the client should ask the user to fill the details in.
            'auto' => $price > 0,
        ]);
    }

    /**
     * Matches a URL to a known store by registrable domain.
     *
     * A shop answers on more hosts than the one row configures: Shein is set up
     * as `ar.shein.com` but also serves `m.shein.com`, `www.shein.com` and
     * `onelink.shein.com` for app share links. Comparing whole hosts missed all
     * but the configured one, so those URLs fell through to the unknown-store
     * defaults — charged in USD instead of IQD, with the free-store rule skipped.
     */
    private function storeForUrl(string $url): ?Store
    {
        $domain = Domains::registrable(Domains::hostOf($url));
        if ($domain === '') {
            return null;
        }

        foreach (Store::all() as $store) {
            $storeDomain = Domains::registrable(Domains::hostOf((string) $store->base_url));
            if ($storeDomain !== '' && $storeDomain === $domain) {
                return $store;
            }
        }

        return null;
    }

    /**
     * POST /capture — takes a scraped product and returns it priced in IQD.
     * This is a preview; persisting happens via POST /cart/items.
     */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'store_key' => ['nullable', 'string', 'max:60'],
            'source_url' => ['required', 'string', 'max:1024'],
            'title' => ['required', 'string', 'max:255'],
            'image_url' => ['nullable', 'string', 'max:1024'],
            'source_price' => ['required', 'numeric', 'min:0'],
            'source_currency' => ['nullable', 'string', 'size:3'],
            'color' => ['nullable', 'string', 'max:60'],
            'size' => ['nullable', 'string', 'max:60'],
        ]);

        $store = isset($data['store_key'])
            ? Store::where('key', $data['store_key'])->first()
            : null;

        // Known store's currency wins (Trendyol=TRY, Shein=USD) so TL prices
        // convert correctly even if the client sent a default of USD.
        $currency = $store && $store->currency
            ? strtoupper($store->currency)
            : strtoupper($data['source_currency'] ?? 'USD');
        $chargeCurrency = $this->pricing->chargeCurrencyFor($store);
        $chargeAmount = $this->pricing->chargeUnit((float) $data['source_price'], $currency, $chargeCurrency);

        if ($chargeAmount <= 0) {
            return response()->json([
                'message' => "No exchange rate configured for $currency.",
            ], 422);
        }

        return response()->json([
            'store' => $store ? [
                'id' => $store->id,
                'key' => $store->key,
                'name' => $store->name,
            ] : null,
            'source_url' => $data['source_url'],
            'title' => $data['title'],
            'image_url' => $data['image_url'] ?? null,
            'source_price' => (float) $data['source_price'],
            'source_currency' => $currency,
            'charge_currency' => $chargeCurrency,
            'charge_amount' => $chargeAmount,
            // Shipping added per unit at checkout, in charge_currency (0 for
            // free-shipping stores like Shein) — shown next to the price.
            'shipping_unit' => $this->pricing->shippingForItem($store, $chargeCurrency, 1),
            'iqd_price' => $this->pricing->toIqd((float) $data['source_price'], $currency),
            'color' => $data['color'] ?? null,
            'size' => $data['size'] ?? null,
        ]);
    }
}
