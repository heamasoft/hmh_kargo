<?php

namespace App\Models;

use App\Services\PricingService;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CartItem extends Model
{
    protected $fillable = [
        'cart_id', 'store_id', 'store_name', 'source_url', 'title', 'image_url',
        'source_price', 'source_currency', 'charge_currency', 'iqd_price',
        'shipping_override',
        'color', 'size', 'sku', 'note', 'qty', 'stock_item_id',
    ];

    protected $casts = [
        'source_price' => 'decimal:2',
        'iqd_price' => 'decimal:2',
        'shipping_override' => 'decimal:2',
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

    /**
     * What bringing ONE of these costs the customer, in this line's charge
     * currency. Each unit becomes its own order and carries this figure.
     */
    public function shippingUnit(?PricingService $pricing = null): float
    {
        // An admin's own number stands, whatever the rule would say: they set
        // it because they know what this parcel actually costs to bring.
        if ($this->shipping_override !== null) {
            return (float) $this->shipping_override;
        }
        // A stock item is already in the country — its price covers carriage.
        if ($this->stock_item_id) {
            return 0.0;
        }
        $pricing ??= app(PricingService::class);

        return $pricing->shippingForItem($this->store, strtoupper($this->charge_currency ?: 'IQD'), 1);
    }

    /** Shipping for the whole line: one unit's, times the quantity. */
    public function shippingTotal(?PricingService $pricing = null): float
    {
        return round($this->shippingUnit($pricing) * max(1, (int) $this->qty), 2);
    }

    public function lineTotalIqd(): float
    {
        return (float) $this->iqd_price * $this->qty;
    }
}
