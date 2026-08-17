<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Store extends Model
{
    protected $fillable = [
        'key', 'name', 'glyph', 'glyph_color', 'category_key',
        'base_url', 'currency', 'charge_currency', 'shipping_iqd', 'capture_rules',
        'active', 'sort_order', 'region',
    ];

    protected $casts = [
        'capture_rules' => 'array',
        'active' => 'boolean',
        'shipping_iqd' => 'integer',
    ];
}
