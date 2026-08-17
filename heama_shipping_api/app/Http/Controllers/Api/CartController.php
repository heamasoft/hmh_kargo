<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\CartItemResource;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Setting;
use App\Models\Store;
use App\Models\User;
use App\Services\PricingService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CartController extends Controller
{
    public function __construct(private readonly PricingService $pricing) {}

    /** GET /cart */
    public function index(Request $request): JsonResponse
    {
        return response()->json($this->cartPayload($request->user()));
    }

    /** POST /cart/items — persist a captured product into the cart. */
    public function addItem(Request $request): JsonResponse
    {
        $data = $request->validate([
            'store_id' => ['nullable', 'integer', 'exists:stores,id'],
            'source_url' => ['required', 'string', 'max:1024'],
            'title' => ['required', 'string', 'max:255'],
            'image_url' => ['nullable', 'string', 'max:1024'],
            'source_price' => ['required', 'numeric', 'min:0'],
            'source_currency' => ['required', 'string', 'size:3'],
            'charge_currency' => ['nullable', 'string', 'size:3'],
            'charge_amount' => ['nullable', 'numeric', 'min:0'],
            'iqd_price' => ['nullable', 'numeric', 'min:0'],
            'color' => ['nullable', 'string', 'max:60'],
            'size' => ['nullable', 'string', 'max:60'],
            'sku' => ['nullable', 'string', 'max:120'],
            'note' => ['nullable', 'string', 'max:500'],
            'qty' => ['nullable', 'integer', 'min:1', 'max:99'],
        ]);

        // charge_amount is the all-in unit price in minor units of charge_currency.
        // Fall back to the legacy iqd_price (IQD) for older clients.
        $chargeCurrency = strtoupper($data['charge_currency'] ?? 'IQD');
        $chargeAmount = $data['charge_amount'] ?? $data['iqd_price'] ?? 0;

        $cart = $this->cartFor($request->user());

        // Cart mixing rule: "exclusive" stores (Shein only) must be ordered on
        // their OWN — a cart holding an exclusive item can contain only that store,
        // and an exclusive item can't join a cart with anything else. All other
        // stores — including Trendyol — may be freely mixed together.
        $existing = $cart->items()->with('store')->first();
        if ($existing) {
            $newStore = isset($data['store_id']) ? Store::find($data['store_id']) : null;
            $newGroup = $this->cartGroup($newStore?->key);
            $curGroup = $this->cartGroup($existing->store?->key);
            if ($newGroup !== $curGroup) {
                // Name the exclusive store that forces its own order.
                $blocker = str_starts_with($curGroup, 'x:')
                    ? ($existing->store?->name)
                    : ($newStore?->name ?? $existing->store?->name);

                return response()->json([
                    'message' => ($blocker ?: 'This store').' must be ordered on its own. Check out or empty your cart before mixing stores.',
                ], 422);
            }
        }

        $cart->items()->create([
            'store_id' => $data['store_id'] ?? null,
            'source_url' => $data['source_url'],
            'title' => $data['title'],
            'image_url' => $data['image_url'] ?? null,
            'source_price' => $data['source_price'],
            'source_currency' => strtoupper($data['source_currency']),
            'charge_currency' => $chargeCurrency,
            'iqd_price' => $chargeAmount,
            'color' => $data['color'] ?? null,
            'size' => $data['size'] ?? null,
            'sku' => $data['sku'] ?? null,
            'note' => $data['note'] ?? null,
            'qty' => $data['qty'] ?? 1,
        ]);

        return response()->json($this->cartPayload($request->user()), 201);
    }

    /** PATCH /cart/items/{item} — change quantity / variant. */
    public function updateItem(Request $request, CartItem $item): JsonResponse
    {
        $this->authorizeItem($request->user(), $item);

        $data = $request->validate([
            'qty' => ['nullable', 'integer', 'min:1', 'max:99'],
            'color' => ['nullable', 'string', 'max:60'],
            'size' => ['nullable', 'string', 'max:60'],
            'note' => ['nullable', 'string', 'max:500'],
        ]);
        $item->update(array_filter($data, fn ($v) => $v !== null));

        return response()->json($this->cartPayload($request->user()));
    }

    /** DELETE /cart/items/{item} */
    public function removeItem(Request $request, CartItem $item): JsonResponse
    {
        $this->authorizeItem($request->user(), $item);
        $item->delete();

        return response()->json($this->cartPayload($request->user()));
    }

    /**
     * The "mixing group" a store belongs to. Exclusive stores (Shein — from the
     * `exclusive_stores` setting) each get their own group so they can't mix with
     * anything; every other store (incl. Trendyol) shares the "mixed" group.
     */
    private function cartGroup(?string $storeKey): string
    {
        $key = strtolower((string) $storeKey);
        if ($key === '') {
            return 'mixed';
        }
        $exclusive = array_filter(array_map('trim', explode(',', (string) Setting::get('exclusive_stores', 'shein'))));
        foreach ($exclusive as $e) {
            if (strtolower($e) === $key) {
                return 'x:'.$key;
            }
        }

        return 'mixed';
    }

    private function cartFor(User $user): Cart
    {
        return Cart::firstOrCreate(['user_id' => $user->id]);
    }

    private function authorizeItem(User $user, CartItem $item): void
    {
        abort_unless($item->cart->user_id === $user->id, 403);
    }

    /**
     * Full cart response: items + one pricing breakdown per currency (a cart can
     * mix an IQD store and a USD store; each is checked out as its own order).
     */
    private function cartPayload(User $user): array
    {
        $cart = $this->cartFor($user)->load('items.store');

        $totals = [];
        foreach ($cart->items->groupBy(fn ($i) => strtoupper($i->charge_currency ?: 'IQD')) as $currency => $items) {
            $itemsTotal = (float) $items->sum(fn ($i) => (float) $i->iqd_price * (int) $i->qty);
            $totals[] = $this->pricing->breakdown(
                $itemsTotal,
                $this->pricing->shippingForItems($items, $currency),
                $currency,
                $this->pricing->serviceFeeForItems($items, $itemsTotal, $currency),
            );
        }

        return [
            'items' => CartItemResource::collection($cart->items)->resolve(),
            'count' => (int) $cart->items->sum('qty'),
            // Array of per-currency breakdowns: [{currency, items_total, shipping, service_fee, total}, ...]
            'totals' => $totals,
        ];
    }
}
