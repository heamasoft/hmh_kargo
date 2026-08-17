<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Order extends Model
{
    protected $fillable = [
        'code', 'user_id', 'status', 'currency', 'items_total_iqd', 'shipping_iqd',
        'service_fee_iqd', 'total_iqd', 'payment_method', 'address', 'placed_at',
    ];

    protected $casts = [
        'address' => 'array',
        'items_total_iqd' => 'decimal:2',
        'shipping_iqd' => 'decimal:2',
        'service_fee_iqd' => 'decimal:2',
        'total_iqd' => 'decimal:2',
        'placed_at' => 'datetime',
    ];

    /**
     * The customer-facing journey. The admin never writes orders.status; it sets
     * a per-item `order_items.step`, and we derive the order's stage from its
     * items (see [derivedStatus]). This list is the display pipeline and its
     * order defines "how far along" each stage is.
     */
    public const STATUSES = [
        'placed', 'buying', 'bought', 'zakho_office', 'delivery', 'delivered',
    ];

    /**
     * Maps an admin item step (order_items.step / order_workflow.step) onto a
     * stage index in [STATUSES]. Tolerant of the vocabulary both sides have used
     * over time. 'cancelled' and 'returned' are handled separately (not stages).
     */
    public const STEP_STAGE = [
        // 0 — placed / pending (nothing done yet)
        'pending' => 0, 'new' => 0, 'new_order' => 0, 'order' => 0, 'placed' => 0, 'received' => 0,
        // 1 — buying
        'buying' => 1, 'buy' => 1,
        // 2 — bought (purchased, sitting in the Turkey/abroad warehouse)
        'bought' => 2, 'purchased' => 2, 'turkey' => 2, 'turkish' => 2, 'warehouse' => 2, 'abroad' => 2,
        // 3 — Zakho office (arrived to the local office)
        'company' => 3, 'zakho' => 3, 'office' => 3, 'zakho_office' => 3, 'local' => 3, 'arrived' => 3,
        // 4 — out for delivery
        'delivery' => 4, 'out_for_delivery' => 4, 'shipping' => 4, 'shipped' => 4, 'courier' => 4,
        // 5 — delivered
        'delivered' => 5, 'done' => 5, 'completed' => 5,
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    /**
     * Items the customer still owns: a rejected shipping line (approval) or an
     * admin-cancelled item (step) stays in the table for the admin's history but
     * is refunded and hidden from the app.
     */
    public function activeItems(): HasMany
    {
        return $this->hasMany(OrderItem::class)
            ->where(fn ($q) => $q->whereNull('approval')->orWhere('approval', '<>', 'rejected'))
            ->where(fn ($q) => $q->whereNull('step')->orWhereNotIn('step', ['cancelled', 'canceled']));
    }

    /**
     * The customer-facing status, derived from the items (the admin drives
     * per-item steps, not orders.status):
     *  - an explicitly cancelled order, or one with no active items left, is
     *    'cancelled';
     *  - otherwise the order sits at its SLOWEST active item's stage, so it only
     *    reads 'delivered' once every item is delivered.
     *
     * @param  \Illuminate\Support\Collection|null  $items  pre-loaded active items (avoids a query)
     */
    public function derivedStatus($items = null): string
    {
        if ($this->status === 'cancelled') {
            return 'cancelled';
        }

        $items ??= $this->activeItems()->get();
        if ($items->isEmpty()) {
            return 'cancelled';
        }

        // Slowest item wins: the minimum stage across all active items.
        $minStage = 5;
        foreach ($items as $item) {
            $key = strtolower(trim((string) $item->step));
            $stage = self::STEP_STAGE[$key] ?? 0;
            $minStage = min($minStage, $stage);
        }

        return self::STATUSES[$minStage] ?? 'placed';
    }

    public function events(): HasMany
    {
        return $this->hasMany(OrderEvent::class);
    }
}
