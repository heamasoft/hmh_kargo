<?php

namespace App\Http\Resources;

use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Order */
class OrderResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $active = $this->activeOnly();
        // Derived from the items' admin steps (slowest item wins).
        $status = $this->derivedStatus($active);

        return [
            'code' => $this->code,
            'status' => $status,
            // Currency of this order; the *_iqd amounts are real amounts in it.
            'currency' => $this->currency ?: 'IQD',
            'items_total_iqd' => (float) $this->items_total_iqd,
            'shipping_iqd' => (float) $this->shipping_iqd,
            'service_fee_iqd' => (float) $this->service_fee_iqd,
            'total_iqd' => (float) $this->total_iqd,
            'payment_method' => $this->payment_method,
            // Payment state the app renders as a badge:
            //  - 'paid'     : settled from the wallet at checkout
            //  - 'cod'      : cash on delivery (also drawn from the balance)
            //  - 'refunded' : cancelled order, money returned to the wallet
            'payment_status' => $this->paymentStatus($status),
            // Cancellable only until the admin starts buying anything.
            'can_cancel' => $status === 'placed',
            'address' => $this->address,
            'placed_at' => $this->placed_at,
            // Rejected / admin-cancelled lines stay in the DB but are hidden here.
            'item_count' => (int) $active->sum('qty'),
            // The canonical status pipeline, so the app can render the journey.
            'status_flow' => Order::STATUSES,
            'items' => $this->whenLoaded('items',
                fn () => OrderItemResource::collection($active->values())),
            'events' => OrderEventResource::collection($this->whenLoaded('events')),
        ];
    }

    /** Loaded items minus the hidden ones (rejected shipping / admin-cancelled). */
    private function activeOnly()
    {
        return $this->items->reject(function ($i) {
            return $i->approval === 'rejected'
                || in_array(strtolower((string) $i->step), ['cancelled', 'canceled'], true);
        });
    }

    private function paymentStatus(string $status): string
    {
        if ($status === 'cancelled') {
            return 'refunded'; // both wallet and COD draw from the balance
        }

        return $this->payment_method === 'cod' ? 'cod' : 'paid';
    }
}
