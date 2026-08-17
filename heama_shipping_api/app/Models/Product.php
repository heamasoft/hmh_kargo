<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Product extends Model
{
    protected $fillable = [
        'key', 'store_id', 'name', 'category', 'source_url', 'image_url',
        'source_price', 'source_currency', 'old_price', 'rating', 'reviews',
        'gradient', 'colors', 'sizes', 'trending', 'sort_order', 'active',
    ];

    protected $casts = [
        'source_price' => 'decimal:2',
        'old_price' => 'decimal:2',
        'rating' => 'decimal:1',
        'gradient' => 'array',
        'colors' => 'array',
        'sizes' => 'array',
        'trending' => 'boolean',
        'active' => 'boolean',
    ];

    public function store(): BelongsTo
    {
        return $this->belongsTo(Store::class);
    }
}
