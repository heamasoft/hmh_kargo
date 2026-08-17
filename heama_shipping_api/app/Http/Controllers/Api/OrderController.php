<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\OrderResource;
use App\Models\AdminNotification;
use App\Models\Cart;
use App\Models\Order;
use App\Services\InsufficientBalanceException;
use App\Services\PricingService;
use App\Services\WalletService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class OrderController extends Controller
{
    public function __construct(
        private readonly PricingService $pricing,
        private readonly WalletService $wallet,
    ) {}

    /** GET /orders — the user's orders, newest first. */
    public function index(Request $request): JsonResponse
    {
        $orders = $request->user()->orders()
            ->withCount('items')
            ->with('items')
            ->latest('placed_at')
            ->get();

        return response()->json(['data' => OrderResource::collection($orders)->resolve()]);
    }

    /** GET /orders/{order} — full order with items + tracking events. */
    public function show(Request $request, Order $order): JsonResponse
    {
        abort_unless($order->user_id === $request->user()->id, 403);
        $order->load(['items', 'events' => fn ($q) => $q->orderBy('happened_at')]);

        return response()->json(['data' => (new OrderResource($order))->resolve($request)]);
    }

    /** POST /orders — place an order from the cart, paid from the wallet. */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'payment_method' => ['required', Rule::in(['wallet', 'cod'])],
            'address' => ['required', 'array'],
            'address.recipient_name' => ['required', 'string', 'max:120'],
            'address.governorate' => ['nullable', 'string', 'max:120'],
            'address.city' => ['required', 'string', 'max:120'],
            'address.street' => ['required', 'string', 'max:255'],
            'address.phone' => ['required', 'string', 'max:40'],
        ]);

        $user = $request->user();
        $cart = Cart::with('items.store')->where('user_id', $user->id)->first();

        if (! $cart || $cart->items->isEmpty()) {
            return response()->json(['message' => 'Your cart is empty.'], 422);
        }

        // A cart can mix currencies (IQD Shein + USD Trendyol). Each currency
        // becomes its own single-currency order, paid from its matching wallet.
        $groups = $cart->items->groupBy(fn ($i) => strtoupper($i->charge_currency ?: 'IQD'));

        try {
            $orders = DB::transaction(function () use ($user, $cart, $groups, $data) {
                $made = [];
                foreach ($groups as $currency => $items) {
                    $itemsTotal = (float) $items->sum(fn ($i) => (float) $i->iqd_price * (int) $i->qty);
                    $breakdown = $this->pricing->breakdown(
                        $itemsTotal,
                        $this->pricing->shippingForItems($items, $currency),
                        $currency,
                        $this->pricing->serviceFeeForItems($items, $itemsTotal, $currency),
                    );

                    $order = Order::create([
                        'code' => 'PENDING',
                        'user_id' => $user->id,
                        'status' => 'placed',
                        'currency' => $currency,
                        // *_iqd columns hold minor units of $currency.
                        'items_total_iqd' => $breakdown['items_total'],
                        'shipping_iqd' => $breakdown['shipping'],
                        'service_fee_iqd' => $breakdown['service_fee'],
                        'total_iqd' => $breakdown['total'],
                        'payment_method' => $data['payment_method'],
                        'address' => $data['address'],
                        'placed_at' => now(),
                    ]);
                    $order->update(['code' => 'HM-'.(20000 + $order->id)]);

                    foreach ($items as $item) {
                        // A stock item is a single unit already in the company:
                        // its price is all-in (shipping included) and it must
                        // still be available. Claim it (step 'stock' → 'sold') and
                        // abort the whole order if someone bought it first.
                        if ($item->stock_item_id) {
                            $claimed = \App\Models\OrderItem::query()
                                ->where('id', $item->stock_item_id)
                                ->where('step', 'stock')
                                ->update(['step' => 'sold', 'updated_at' => now()]);
                            if ($claimed === 0) {
                                throw \Illuminate\Validation\ValidationException::withMessages([
                                    'cart' => ['"'.$item->title.'" was just sold and is no longer available. Please remove it from your cart.'],
                                ]);
                            }
                        }

                        $order->items()->create([
                            'store_id' => $item->store_id,
                            'store_name' => $item->store?->name,
                            'source_url' => $item->source_url,
                            'title' => $item->title,
                            'image_url' => $item->image_url,
                            'source_price' => $item->source_price,
                            'source_currency' => $item->source_currency,
                            'charge_currency' => $currency,
                            'iqd_price' => $item->iqd_price,
                            // Stock items ship free (their price already includes
                            // it). Normal items carry $2/unit — the admin re-prices.
                            'shipping' => $item->stock_item_id
                                ? 0.0
                                : $this->pricing->shippingForItem($item->store, $currency, (int) $item->qty),
                            'color' => $item->color,
                            'size' => $item->size,
                            'sku' => $item->sku,
                            'note' => $item->note,
                            'qty' => $item->qty,
                            'stock_item_id' => $item->stock_item_id,
                        ]);
                    }

                    // Both wallet and cash-on-delivery draw the amount down from
                    // the matching balance now. COD may push it negative — that
                    // negative is what the customer settles in cash on arrival, so
                    // COD ignores the credit limit. A WALLET order, however, is
                    // blocked if it would take the balance past the customer's
                    // credit limit for this currency (limit 0 = no negative).
                    $isCod = $data['payment_method'] === 'cod';
                    $creditFloor = $isCod
                        ? null
                        : (float) ($currency === 'USD'
                            ? $user->credit_limit_usd
                            : $user->credit_limit_iqd);

                    $this->wallet->debit(
                        $user,
                        (float) $order->total_iqd,
                        $currency,
                        type: $isCod ? 'cod' : 'debit',
                        note: "Order {$order->code}",
                        orderId: $order->id,
                        creditFloor: $creditFloor,
                    );

                    $order->events()->create([
                        'status' => 'placed',
                        'note' => 'Order placed',
                        'happened_at' => now(),
                    ]);

                    $made[] = $order;
                }

                $cart->items()->delete();

                return $made;
            });
        } catch (InsufficientBalanceException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        foreach ($orders as $order) {
            $order->load(['items', 'events']);
        }

        return response()->json([
            'data' => OrderResource::collection($orders)->resolve($request),
            'wallet' => $this->wallet->balances($user),
        ], 201);
    }

    /**
     * POST /orders/{order}/items/{itemId}/cancel — cancel ONE item while it is
     * still pending (before the admin starts buying THIS item). The item's price
     * + its shipping are refunded to the matching wallet, the order totals are
     * recomputed from the remaining items, and any open shipping approval for
     * the item is closed. The LAST item can't be cancelled this way — cancel
     * the whole order instead.
     */
    public function cancelItem(Request $request, Order $order, int $itemId): JsonResponse
    {
        abort_unless($order->user_id === $request->user()->id, 403);

        if ($order->status === 'cancelled') {
            return response()->json(['message' => 'This order is already cancelled.'], 422);
        }

        $item = $order->activeItems()->with('store')->find($itemId);
        if (! $item) {
            return response()->json(['message' => 'Item not found.'], 404);
        }

        // Only while THIS item is still pending (stage 0). Once the admin moves
        // it to buying/bought/… the customer can no longer cancel it.
        $stage = Order::STEP_STAGE[strtolower(trim((string) $item->step))] ?? 0;
        if ($stage > 0) {
            return response()->json([
                'message' => 'This item can no longer be cancelled — we have already started processing it.',
            ], 422);
        }

        if ($order->activeItems()->count() <= 1) {
            return response()->json([
                'message' => 'This is the only item — cancel the whole order instead.',
            ], 422);
        }

        $user = $request->user();
        $currency = strtoupper($order->currency ?: 'IQD');
        // If the admin re-priced this item's shipping and the answer is still
        // pending, order_items.shipping already holds the NEW price — refund the
        // ORIGINAL one the customer actually paid (the approval's old_shipping).
        $pendingOld = DB::table('item_approvals')
            ->where('item_id', $item->id)->where('status', 'pending')
            ->value('old_shipping');
        $paidShipping = $pendingOld !== null ? (float) $pendingOld : (float) ($item->shipping ?? 0);
        $refund = round((float) $item->iqd_price * (int) $item->qty + $paidShipping, 2);

        DB::transaction(function () use ($order, $item, $user, $currency, $refund) {
            // Close any open shipping approval on this item so the admin side
            // isn't left waiting on an answer for a cancelled item.
            DB::table('item_approvals')
                ->where('item_id', $item->id)->where('status', 'pending')
                ->update(['status' => 'superseded', 'responded_at' => now()]);

            $title = $item->title;
            $item->delete();

            // Recompute the order from what's left (per-item shipping included;
            // rejected/hidden lines don't count).
            $remaining = $order->activeItems()->with('store')->get();
            $itemsTotal = (float) $remaining->sum(fn ($i) => (float) $i->iqd_price * (int) $i->qty);
            $shipping = round((float) $remaining->sum(fn ($i) => (float) ($i->shipping ?? 0)), 2);
            $fee = $this->pricing->serviceFeeForItems($remaining, $itemsTotal, $currency);
            $order->update([
                'items_total_iqd' => $itemsTotal,
                'shipping_iqd' => $shipping,
                'service_fee_iqd' => $fee,
                'total_iqd' => $itemsTotal + $shipping + $fee,
            ]);

            if ($refund > 0) {
                $this->wallet->credit(
                    $user,
                    $refund,
                    $currency,
                    type: 'refund',
                    note: "Cancelled item from {$order->code}",
                    orderId: $order->id,
                );
            }

            $order->events()->create([
                'status' => $order->status,
                'note' => 'Item cancelled: '.mb_substr($title, 0, 80),
                'happened_at' => now(),
            ]);
        });

        $order->load(['items', 'events']);

        return response()->json([
            'data' => (new OrderResource($order))->resolve($request),
            'wallet' => $this->wallet->balances($user),
        ]);
    }

    /**
     * POST /orders/{order}/cancel — customer cancels an order.
     * Only allowed while the order is still 'placed' (before we purchase the
     * items). Wallet-paid orders are refunded; COD orders never charged the
     * wallet. Writes an admin alert so the dashboard sees the cancellation.
     */
    public function cancel(Request $request, Order $order): JsonResponse
    {
        abort_unless($order->user_id === $request->user()->id, 403);

        // Cancellation closes the moment the admin starts buying ANY item — the
        // order's derived status leaves 'placed'. (orders.status stays 'placed'
        // in the DB; the admin drives per-item steps, so we check the derived
        // status, not the raw column.)
        if ($order->derivedStatus() !== 'placed') {
            return response()->json([
                'message' => 'This order can no longer be cancelled — we have already started processing it.',
            ], 422);
        }

        $user = $request->user();
        $currency = strtoupper($order->currency ?: 'IQD');
        $amountLabel = $currency === 'USD'
            ? '$'.number_format((float) $order->total_iqd, 2)
            : number_format((float) $order->total_iqd).' IQD';

        DB::transaction(function () use ($order, $user, $currency, $amountLabel) {
            $order->update(['status' => 'cancelled']);

            $order->events()->create([
                'status' => 'cancelled',
                'note' => 'Order cancelled by customer',
                'happened_at' => now(),
            ]);

            // Both methods drew from the wallet, so a cancel always refunds it.
            $this->wallet->credit(
                $user,
                (float) $order->total_iqd,
                $currency,
                type: 'refund',
                note: "Refund for cancelled {$order->code}",
                orderId: $order->id,
            );

            // Alert the admin dashboard.
            AdminNotification::create([
                'type' => 'order_cancelled',
                'order_id' => $order->id,
                'user_id' => $user->id,
                'order_code' => $order->code,
                'title' => "Order {$order->code} cancelled",
                'body' => ($user->name ?: 'A customer').' cancelled '.$order->code
                    .' · '.$amountLabel.' · '
                    .($order->payment_method === 'cod' ? 'COD' : 'wallet').' (refunded)',
            ]);
        });

        $order->load(['items', 'events']);

        return response()->json([
            'data' => (new OrderResource($order))->resolve($request),
            'wallet' => $this->wallet->balances($user),
        ]);
    }
}
