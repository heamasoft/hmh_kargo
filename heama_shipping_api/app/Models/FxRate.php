<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FxRate extends Model
{
    public $timestamps = false;

    protected $fillable = ['currency', 'rate_to_iqd', 'updated_at', 'created_at'];

    protected $casts = [
        'rate_to_iqd' => 'decimal:4',
        'updated_at' => 'datetime',
        'created_at' => 'datetime',
    ];

    /** IQD value of 1 unit of the given currency (0 if unknown). */
    public static function rateFor(string $currency): float
    {
        return (float) (static::where('currency', strtoupper($currency))->value('rate_to_iqd') ?? 0);
    }
}
