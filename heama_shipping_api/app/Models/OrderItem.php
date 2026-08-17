<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class OrderItem extends Model
{
    protected $fillable = [
        'order_id', 'store_id', 'store_name', 'source_url', 'title', 'image_url',
        'source_price', 'source_currency', 'charge_currency', 'iqd_price',
        'shipping', 'color', 'size', 'sku', 'note', 'qty', 'approval', 'step', 'stock_item_id',
    ];

    protected $casts = [
        'source_price' => 'decimal:2',
        'iqd_price' => 'decimal:2',
        'shipping' => 'decimal:2',
        'qty' => 'integer',
    ];

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }

    /** The catalogue store this line was captured from (null for manual links). */
    public function store(): BelongsTo
    {
        return $this->belongsTo(Store::class);
    }
}
