<?php

namespace App\Http\Resources;

use App\Services\PricingService;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Product */
class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $pricing = app(PricingService::class);
        // Catalogue products are Shein → charged in IQD, which is always whole.
        $iqd = (int) $pricing->toIqd((float) $this->source_price, $this->source_currency);

        return [
            'key' => $this->key,
            'store_id' => $this->store_id,
            'store' => $this->store?->name ?? 'Shein',
            'name' => $this->name,
            'category' => $this->category,
            'source_url' => $this->source_url,
            'image_url' => $this->image_url,
            'source_price' => (float) $this->source_price,
            'source_currency' => $this->source_currency,
            'usd' => '$'.number_format((float) $this->source_price, 2),
            'old_usd' => $this->old_price ? '$'.number_format((float) $this->old_price, 2) : null,
            // Catalogue products (Shein) are charged in IQD.
            'charge_currency' => 'IQD',
            'charge_amount' => $iqd,
            'iqd_price' => $iqd,
            'rating' => (float) $this->rating,
            'reviews' => $this->reviews,
            'gradient' => $this->gradient ?? ['#C9B6E8', '#E9C7D6'],
            'colors' => $this->colors ?? [],
            'sizes' => $this->sizes ?? [],
            'trending' => (bool) $this->trending,
        ];
    }
}
