<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Favorite extends Model
{
    protected $fillable = [
        'user_id', 'item_key', 'name', 'store', 'store_id',
        'source_url', 'iqd_price', 'image_url',
    ];

    protected $casts = [
        'iqd_price' => 'integer',
        'store_id' => 'integer',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
