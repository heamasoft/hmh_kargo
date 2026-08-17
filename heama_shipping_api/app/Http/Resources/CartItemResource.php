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
        // This line's shipping: $2/unit × qty for non-Shein, 0 for Shein — shown
        // inside each cart card and summed into the cart's Shipping total.
        // Stock items ship free (their stored price already includes it).
        $pricing = app(PricingService::class);
        $shipping = $this->stock_item_id
            ? 0.0
            : $pricing->shippingForItem(
                $this->store,
                strtoupper($this->charge_currency ?: 'IQD'),
                (int) $this->qty,
            );

        return [
            'id' => $this->id,
            'store_id' => $this->store_id,
            'store' => $this->store?->name,
            'store_key' => $this->store?->key,
            'source_url' => $this->source_url,
            'title' => $this->title,
            'image_url' => $this->image_url,
            'source_price' => (float) $this->source_price,
            'source_currency' => $this->source_currency,
            'charge_currency' => $this->charge_currency ?: 'IQD',
            // Real amount in charge_currency (IQD dinars / USD dollars).
            'iqd_price' => (float) $this->iqd_price,
            'shipping' => (float) $shipping,
            'color' => $this->color,
            'size' => $this->size,
            'sku' => $this->sku,
            'note' => $this->note,
            'qty' => (int) $this->qty,
            'line_total_iqd' => (float) $this->lineTotalIqd(),
            // In-stock item (already in the company; ships free, ready to deliver).
            'is_stock' => $this->stock_item_id !== null,
        ];
    }
}
