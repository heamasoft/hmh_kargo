<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\WalletTransaction */
class WalletTransactionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'type' => $this->type,
            'currency' => $this->currency ?: 'IQD',
            // Real amount in currency (IQD dinars / USD dollars).
            'amount_iqd' => (float) $this->amount_iqd,
            'balance_after' => (float) $this->balance_after,
            'note' => $this->note,
            'created_at' => $this->created_at,
        ];
    }
}
