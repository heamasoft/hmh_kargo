<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\OrderItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * In-stock storefront: products the company already holds (order_items whose
 * admin step is 'stock'). They ship with no international wait, so the customer
 * can buy them at the stored all-in price and get normal local delivery.
 *
 * The list is split into Shein and Other stores for the app's two sections.
 */
class StockController extends Controller
{
    /** GET /stock?lang=en|ar|ku — available stock, grouped {shein:[...], other:[...]}. */
    public function index(Request $request): JsonResponse
    {
        // Hide stock units already sitting in THIS customer's cart, so they don't
        // show as available again until removed from the cart.
        $inCart = DB::table('cart_items')
            ->join('carts', 'carts.id', '=', 'cart_items.cart_id')
            ->where('carts.user_id', $request->user()->id)
            ->whereNotNull('cart_items.stock_item_id')
            ->pluck('cart_items.stock_item_id')
            ->all();

        $rows = DB::table('order_items')
            ->where('step', 'stock')
            ->when($inCart, fn ($q) => $q->whereNotIn('id', $inCart))
            ->orderByDesc('updated_at')
            ->get([
                'id', 'store_id', 'store_name', 'source_url', 'title', 'image_url',
                'charge_currency', 'iqd_price', 'cust_usd', 'shipping',
                'color', 'size', 'sku',
            ]);

        // Titles/colours are shown exactly as captured from the store (no
        // translation) so they match the original product page.
        $items = $rows->map(fn ($r) => $this->present($r));

        return response()->json([
            'shein' => $items->where('is_shein', true)->values(),
            'other' => $items->where('is_shein', false)->values(),
        ]);
    }

    /** POST /stock/{itemId}/add — add a stock item to the cart (server-priced). */
    public function addToCart(Request $request, int $itemId): JsonResponse
    {
        $item = OrderItem::query()->where('id', $itemId)->where('step', 'stock')->first();
        if (! $item) {
            return response()->json(['message' => 'This item is no longer available.'], 422);
        }

        $currency = strtoupper($item->charge_currency ?: 'IQD');
        $price = $this->allInPrice($item);

        $cart = Cart::firstOrCreate(['user_id' => $request->user()->id]);

        // Don't add the same stock unit twice (it's a single physical piece).
        $dup = $cart->items()->where('stock_item_id', $item->id)->exists();
        if ($dup) {
            return response()->json(['message' => 'This item is already in your cart.'], 422);
        }

        // Shein-alone rule (same as normal items): a Shein item can't share the
        // cart with any non-Shein item, and vice versa — whether stock or not.
        $newShein = $this->isShein($item->source_url, $item->store_name);
        foreach ($cart->items()->get(['source_url']) as $ex) {
            if ($this->isShein($ex->source_url, null) !== $newShein) {
                return response()->json([
                    'message' => 'Shein items must be ordered on their own. Check out or empty your cart before mixing stores.',
                ], 422);
            }
        }

        $cart->items()->create([
            'store_id' => $item->store_id,
            'source_url' => $item->source_url,
            'title' => $item->title,
            'image_url' => $item->image_url,
            'source_price' => $item->source_price ?? $price,
            'source_currency' => strtoupper($item->source_currency ?: $currency),
            'charge_currency' => $currency,
            'iqd_price' => $price,          // all-in unit price (item + its shipping)
            'color' => $item->color,
            'size' => $item->size,
            'sku' => $item->sku,
            'qty' => 1,                     // one physical unit
            'stock_item_id' => $item->id,   // marks this as a stock purchase
        ]);

        return response()->json(['ok' => true], 201);
    }

    /** The customer's all-in price (item + its shipping), in charge_currency. */
    private function allInPrice(object $item): float
    {
        if ($item->cust_usd !== null) {
            return round((float) $item->cust_usd, 2);
        }

        return round((float) $item->iqd_price + (float) ($item->shipping ?? 0), 2);
    }

    /** True if a product belongs to Shein (by URL host or store name). */
    private function isShein(?string $url, ?string $storeName): bool
    {
        $hay = strtolower(($url ?? '').' '.($storeName ?? ''));

        return str_contains($hay, 'shein') || strtolower(trim((string) $storeName)) === 'ar';
    }

    private function present(object $r, array $tr = []): array
    {
        $currency = strtoupper($r->charge_currency ?: 'IQD');
        $isShein = $this->isShein($r->source_url, $r->store_name);

        $title = $tr[trim((string) $r->title)] ?? $r->title;
        $color = $r->color !== null ? ($tr[trim((string) $r->color)] ?? $r->color) : null;

        return [
            'item_id' => (int) $r->id,
            'title' => $title,
            'image_url' => $r->image_url,
            'source_url' => $r->source_url,
            'store' => $r->store_name,
            'store_id' => $r->store_id !== null ? (int) $r->store_id : null,
            'currency' => $currency,
            'price' => $this->allInPrice($r),
            'color' => $color,
            'size' => $r->size,
            'sku' => $r->sku,
            'is_shein' => $isShein,
        ];
    }
}
