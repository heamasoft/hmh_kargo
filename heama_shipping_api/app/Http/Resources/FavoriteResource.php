<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Favorite */
class FavoriteResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        // Shaped to match the app's FavoriteItem (id == item_key).
        return [
            'id' => $this->item_key,
            'name' => $this->name,
            'store' => $this->store,
            'store_id' => $this->store_id,
            'source_url' => $this->source_url,
            'iqd_price' => (int) $this->iqd_price,
            'image_url' => $this->image_url,
        ];
    }
}
