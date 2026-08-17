<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Address */
class AddressResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'recipient_name' => $this->recipient_name,
            'governorate' => $this->governorate,
            'city' => $this->city,
            'street' => $this->street,
            'phone' => $this->phone,
            'note' => $this->note,
            'is_default' => (bool) $this->is_default,
        ];
    }
}
