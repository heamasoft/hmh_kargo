<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Services\PricingService;
use App\Services\WalletService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Throwable;

/**
 * Shipping-fee approvals.
 *
 * The admin console re-prices a single order item's shipping while the item is
 * still Pending; the customer must answer before the admin may buy it. Both
 * apps share one database, so we read/write `item_approvals` directly and
 * mirror the answer onto `order_items.approval`.
 *
 * ACCEPT → the admin may buy the item at the new price.
 * REJECT → the item comes OUT of the order for the customer: the row STAYS in
 * order_items with approval='rejected' (so the admin keeps the history) but is
 * hidden from the app, what was paid (price × qty + the ORIGINAL shipping) is
 * refunded to the wallet and the order's totals are recomputed. If it was the
 * last active item, the whole order is cancelled.
 */
class ApprovalController extends Controller
{
    /** GET /approvals?status=pending|accepted|rejected|all — this user's requests. */
    public function index(Request $request): JsonResponse
    {
        $status = (string) $request->query('status', 'pending');

        $rows = DB::table('item_approvals as a')
            ->join('order_items as oi', 'oi.id', '=', 'a.item_id')
            ->join('orders as o', 'o.id', '=', 'a.order_id')
            ->where('a.user_id', $request->user()->id)
            ->when($status !== 'all', fn ($q) => $q->where('a.status', $status))
            ->orderByDesc('a.requested_at')
            ->get([
                'a.id', 'a.item_id', 'a.order_id', 'a.currency', 'a.status', 'a.note',
                'a.old_shipping', 'a.new_shipping', 'a.requested_at', 'a.responded_at',
                'oi.title', 'oi.image_url', 'oi.sku', 'oi.iqd_price',
                'o.code as order_code',
            ]);

        $data = $rows->map(function ($r) {
            $price = (float) $r->iqd_price;
            $new = (float) $r->new_shipping;

            return [
                'id' => (int) $r->id,
                'item_id' => (int) $r->item_id,
                'order_id' => (int) $r->order_id,
                'order_code' => $r->order_code,
                'title' => $r->title,
                'image_url' => $r->image_url,
                'sku' => $r->sku,
                'currency' => strtoupper($r->currency ?: 'USD'),
                'item_price' => $price,
                'old_shipping' => $r->old_shipping !== null ? (float) $r->old_shipping : null,
                'new_shipping' => $new,
                'new_total' => $price + $new,
                'status' => $r->status,
                'note' => $r->note,
                'requested_at' => $r->requested_at,
                'responded_at' => $r->responded_at,
            ];
        })->values();

        return response()->json(['data' => $data]);
    }

    /** POST /approvals/{id}/accept */
    public function accept(Request $request, int $id): JsonResponse
    {
        return $this->respond($request, $id, 'accepted');
    }

    /** POST /approvals/{id}/reject */
    public function reject(Request $request, int $id): JsonResponse
    {
        return $this->respond($request, $id, 'rejected');
    }

    /**
     * One-shot answer. Only a PENDING row owned by this user is actionable.
     * Everything runs in ONE transaction so the approval, the item, the order
     * totals and the wallet always stay consistent.
     */
    private function respond(Request $request, int $id, string $status): JsonResponse
    {
        $user = $request->user();

        try {
            return $this->respondInTransaction($id, $user, $status);
        } catch (Throwable $e) {
            // Nothing was committed (the transaction rolled back). Report the
            // real cause so the app shows it instead of a generic network error.
            Log::error('Approval respond failed', [
                'approval_id' => $id,
                'status' => $status,
                'error' => $e->getMessage(),
                'file' => $e->getFile().':'.$e->getLine(),
            ]);

            return response()->json([
                'message' => 'Could not process the answer: '.$e->getMessage(),
            ], 422);
        }
    }

    private function respondInTransaction(int $id, $user, string $status): JsonResponse
    {
        return DB::transaction(function () use ($id, $user, $status) {
            $a = DB::table('item_approvals')->where('id', $id)->lockForUpdate()->first();

            if (! $a || (int) $a->user_id !== (int) $user->id) {
                return response()->json(['message' => 'Approval not found.'], 404);
            }
            if ($a->status !== 'pending') {
                return response()->json(['message' => 'This request was already answered.'], 422);
            }

            DB::table('item_approvals')->where('id', $id)
                ->update(['status' => $status, 'responded_at' => now()]);

            if ($status === 'accepted') {
                // Mirror so the admin's Confirm button unlocks.
                DB::table('order_items')->where('id', $a->item_id)
                    ->update(['approval' => 'accepted', 'updated_at' => now()]);

                // Charge the customer the DIFFERENCE between the new and old
                // shipping (the admin already wrote the new price into
                // order_items.shipping). Higher new price → debit the extra;
                // lower → refund it. Then recompute the order's totals so the
                // balance and the order agree.
                $item = OrderItem::query()->find($a->item_id);
                if ($item) {
                    $order = Order::query()->find($item->order_id);
                    $currency = strtoupper($a->currency ?: ($order?->currency ?: 'USD'));
                    $old = $a->old_shipping !== null ? (float) $a->old_shipping : (float) ($item->shipping ?? 0);
                    $new = (float) ($a->new_shipping ?? $item->shipping ?? 0);
                    $diff = round($new - $old, 2);

                    if ($order) {
                        if ($diff > 0) {
                            app(WalletService::class)->debit(
                                $user, $diff, $currency,
                                type: 'debit',
                                note: "Shipping increase accepted — {$order->code}",
                                orderId: $order->id,
                            );
                        } elseif ($diff < 0) {
                            app(WalletService::class)->credit(
                                $user, -$diff, $currency,
                                type: 'refund',
                                note: "Shipping decrease — {$order->code}",
                                orderId: $order->id,
                            );
                        }

                        $this->recomputeOrder($order, $currency);
                    }
                }

                return response()->json([
                    'message' => 'Shipping price accepted.',
                    'data' => ['id' => $id, 'status' => 'accepted'],
                ]);
            }

            // REJECTED → keep the row (approval='rejected') so the admin sees
            // the history, but hide it from the app and refund what was paid
            // for it (price × qty + the ORIGINAL shipping — never the new one).
            $item = OrderItem::query()->find($a->item_id);
            if ($item) {
                $order = Order::query()->find($item->order_id);
                $currency = strtoupper($a->currency ?: ($order?->currency ?: 'USD'));
                // The admin already wrote the NEW price into order_items.shipping,
                // so the shipping the customer actually PAID is the approval's
                // old_shipping (fall back to the item column when absent).
                $paidShipping = $a->old_shipping !== null
                    ? (float) $a->old_shipping
                    : (float) ($item->shipping ?? 0);
                $refund = round((float) $item->iqd_price * (int) $item->qty + $paidShipping, 2);
                $title = $item->title;
                $item->update(['approval' => 'rejected']);

                if ($order) {
                    $remaining = $order->activeItems()->with('store')->get();

                    if ($remaining->isEmpty()) {
                        // Nothing left — the whole order is cancelled.
                        $order->update(['status' => 'cancelled']);
                        $order->events()->create([
                            'status' => 'cancelled',
                            'note' => 'Order cancelled — item rejected after shipping change',
                            'happened_at' => now(),
                        ]);
                    } else {
                        $this->recomputeOrder($order, $currency, $remaining);
                        $order->events()->create([
                            'status' => $order->status,
                            'note' => 'Item removed (shipping rejected): '.mb_substr($title, 0, 70),
                            'happened_at' => now(),
                        ]);
                    }

                    if ($refund > 0) {
                        app(WalletService::class)->credit(
                            $user,
                            $refund,
                            $currency,
                            type: 'refund',
                            note: "Rejected shipping — item removed from {$order->code}",
                            orderId: $order->id,
                        );
                    }
                }
            }

            return response()->json([
                'message' => 'Shipping price rejected — the item was removed and refunded.',
                'data' => ['id' => $id, 'status' => 'rejected'],
            ]);
        });
    }

    /**
     * Recomputes an order's stored totals from its active items (per-item
     * shipping included). Pass $items to reuse an already-loaded collection.
     */
    private function recomputeOrder(Order $order, string $currency, $items = null): void
    {
        $items ??= $order->activeItems()->with('store')->get();
        $itemsTotal = (float) $items->sum(fn ($i) => (float) $i->iqd_price * (int) $i->qty);
        $shipping = round((float) $items->sum(fn ($i) => (float) ($i->shipping ?? 0)), 2);
        $fee = app(PricingService::class)->serviceFeeForItems($items, $itemsTotal, $currency);

        $order->update([
            'items_total_iqd' => $itemsTotal,
            'shipping_iqd' => $shipping,
            'service_fee_iqd' => $fee,
            'total_iqd' => $itemsTotal + $shipping + $fee,
        ]);
    }
}
