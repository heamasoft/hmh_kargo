<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'phone' => $this->phone,
            'email' => $this->email,
            'city' => $this->city,
            'is_admin' => (bool) $this->is_admin,
            'wallet_balance_iqd' => $this->balanceIqd(),
            'created_at' => $this->created_at,
        ];
    }
}
