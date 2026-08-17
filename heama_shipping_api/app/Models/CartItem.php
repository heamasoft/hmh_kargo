<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CartItem extends Model
{
    protected $fillable = [
        'cart_id', 'store_id', 'source_url', 'title', 'image_url',
        'source_price', 'source_currency', 'charge_currency', 'iqd_price',
        'color', 'size', 'sku', 'note', 'qty', 'stock_item_id',
    ];

    protected $casts = [
        'source_price' => 'decimal:2',
        'iqd_price' => 'decimal:2',
        'qty' => 'integer',
    ];

    public function cart(): BelongsTo
    {
        return $this->belongsTo(Cart::class);
    }

    public function store(): BelongsTo
    {
        return $this->belongsTo(Store::class);
    }

    public function lineTotalIqd(): float
    {
        return (float) $this->iqd_price * $this->qty;
    }
}
