<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProductResource;
use App\Models\OrderItem;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class ProductController extends Controller
{
    /**
     * GET /products — curated catalog for browsing.
     * Filters: ?trending=1, ?store=shein, ?category=tops
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = Product::query()->with('store')->where('active', true);

        if ($request->boolean('trending')) {
            $query->where('trending', true);
        }
        if ($storeKey = $request->query('store')) {
            $query->whereHas('store', fn ($q) => $q->where('key', $storeKey));
        }
        if ($category = $request->query('category')) {
            if ($category !== 'all') {
                $query->where('category', $category);
            }
        }

        return ProductResource::collection(
            $query->orderBy('sort_order')->get()
        );
    }

    /** GET /products/{product:key} — single product detail. */
    public function show(Product $product): ProductResource
    {
        return new ProductResource($product->load('store'));
    }

    /**
     * GET /trending — real popularity: the most-ordered products across all
     * orders, grouped by their source URL and ranked by total quantity ordered.
     * Returns product-shaped items so the app can show and open them directly.
     */
    public function trending(): JsonResponse
    {
        $rows = OrderItem::query()
            ->whereNotNull('source_url')
            ->where('source_url', '!=', '')
            ->selectRaw('source_url,
                MAX(title) as title,
                MAX(image_url) as image_url,
                MAX(store_id) as store_id,
                MAX(store_name) as store_name,
                MAX(iqd_price) as iqd_price,
                MAX(source_price) as source_price,
                MAX(source_currency) as source_currency,
                SUM(qty) as ordered_qty')
            ->groupBy('source_url')
            ->orderByDesc('ordered_qty')
            ->limit(30)
            ->get();

        $data = $rows->map(fn ($r) => [
            'key' => 'ord-'.substr(md5((string) $r->source_url), 0, 16),
            'store_id' => $r->store_id ? (int) $r->store_id : null,
            'store' => $r->store_name ?: 'Shein',
            'name' => $r->title ?: '',
            'category' => null,
            'source_url' => $r->source_url,
            'image_url' => $r->image_url ?: '',
            'source_price' => (float) $r->source_price,
            'source_currency' => $r->source_currency ?: 'USD',
            'usd' => '',
            'old_usd' => null,
            'iqd_price' => (int) $r->iqd_price,
            'rating' => 4.7,
            'reviews' => '',
            'gradient' => ['#C9B6E8', '#E9C7D6'],
            'colors' => [],
            'sizes' => [],
            'trending' => true,
        ])->all();

        return response()->json(['data' => $data]);
    }
}
