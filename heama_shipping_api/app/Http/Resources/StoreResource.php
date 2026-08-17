<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class StoreResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'key' => $this->key,
            'name' => $this->name,
            'glyph' => $this->glyph,
            'glyph_color' => $this->glyph_color,
            'category_key' => $this->category_key,
            'base_url' => $this->base_url,
            'currency' => $this->currency,
            'region' => $this->region,
        ];
    }
}
