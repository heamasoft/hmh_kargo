<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\OrderItem */
class OrderItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'store' => $this->store_name,
            'source_url' => $this->source_url,
            'title' => $this->title,
            'image_url' => $this->image_url,
            'charge_currency' => $this->charge_currency ?: 'IQD',
            // Real amount in charge_currency (IQD dinars / USD dollars).
            'iqd_price' => (float) $this->iqd_price,
            // This item's own shipping fee (admin may re-price it per item).
            'shipping' => $this->shipping !== null ? (float) $this->shipping : null,
            // Admin's per-item stage (buying/bought/zakho_office/delivery…) and
            // the derived customer status for this single item.
            'step' => $this->step,
            'status' => \App\Models\Order::STATUSES[\App\Models\Order::STEP_STAGE[strtolower(trim((string) $this->step))] ?? 0] ?? 'placed',
            'approval' => $this->approval,
            // The customer may cancel this item only while it is still pending
            // (stage 0 — the admin hasn't started buying it yet).
            'can_cancel' => (\App\Models\Order::STEP_STAGE[strtolower(trim((string) $this->step))] ?? 0) === 0,
            'color' => $this->color,
            'size' => $this->size,
            'sku' => $this->sku,
            'note' => $this->note,
            'qty' => (int) $this->qty,
        ];
    }
}
