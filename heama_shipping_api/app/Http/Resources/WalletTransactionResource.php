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
            // Real amount in currency (IQD dinars / USD dollars), read from
            // whichever column holds it — the admin CMS keeps dollars in
            // amount_usd, so reading amount_iqd alone shows those rows as 0.
            'amount_iqd' => $this->resource->amount(),
            'balance_after' => $this->resource->balanceAfter(),
            'note' => $this->note,
            'created_at' => $this->created_at,
        ];
    }
}
