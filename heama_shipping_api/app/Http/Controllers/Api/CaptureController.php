<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Store;
use App\Services\PricingService;
use App\Services\ScraperService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CaptureController extends Controller
{
    public function __construct(
        private readonly PricingService $pricing,
        private readonly ScraperService $scraper,
    ) {}

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

    /** Matches a URL's host to a known store (by base_url host). */
    private function storeForUrl(string $url): ?Store
    {
        $host = strtolower((string) parse_url($url, PHP_URL_HOST));
        if ($host === '') {
            return null;
        }
        foreach (Store::all() as $store) {
            $storeHost = strtolower((string) parse_url($store->base_url, PHP_URL_HOST));
            $bare = preg_replace('/^www\./', '', $storeHost);
            if ($bare !== '' && str_contains($host, $bare)) {
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
            'iqd_price' => $this->pricing->toIqd((float) $data['source_price'], $currency),
            'color' => $data['color'] ?? null,
            'size' => $data['size'] ?? null,
        ]);
    }
}
