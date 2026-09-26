<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WalletTransaction extends Model
{
    protected $fillable = [
        'user_id', 'type', 'currency', 'amount_iqd', 'balance_after', 'order_id', 'order_code',
        'note', 'admin_id', 'amount_usd', 'balance_usd_after',
    ];

    protected $casts = [
        'amount_iqd' => 'decimal:2',
        'balance_after' => 'decimal:2',
        'amount_usd' => 'decimal:2',
        'balance_usd_after' => 'decimal:2',
    ];

    /**
     * The row's real amount, in its own currency.
     *
     * Two systems write this table. The admin CMS keeps dollars in amount_usd
     * and leaves amount_iqd at 0; the app used to put every amount in
     * amount_iqd whatever the currency said. Reading both means a row counts
     * once, for the right amount, whichever system wrote it — without that, a
     * dollar refund from the CMS reads as zero.
     */
    public function amount(): float
    {
        return $this->isUsd() && abs((float) $this->amount_usd) > 0.0001
            ? (float) $this->amount_usd
            : (float) $this->amount_iqd;
    }

    /** The balance this row left behind, from whichever column holds it. */
    public function balanceAfter(): float
    {
        return $this->isUsd() && abs((float) $this->amount_usd) > 0.0001
            ? (float) $this->balance_usd_after
            : (float) $this->balance_after;
    }

    public function isUsd(): bool
    {
        return strtoupper(trim((string) $this->currency)) === 'USD';
    }

    /**
     * SQL for the amount, for sums that must agree with amount() above.
     * Both systems' rows are covered: dollars from amount_usd when it holds
     * the value, everything else from amount_iqd.
     */
    public static function amountSql(string $table = 'wallet_transactions'): string
    {
        return "CASE WHEN UPPER(COALESCE(NULLIF(`{$table}`.`currency`, ''), 'IQD')) = 'USD'"
            ." AND COALESCE(`{$table}`.`amount_usd`, 0) <> 0"
            ." THEN `{$table}`.`amount_usd` ELSE `{$table}`.`amount_iqd` END";
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }
}
