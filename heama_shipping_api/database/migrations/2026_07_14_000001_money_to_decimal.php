<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * Store money as the REAL amount in decimal(14,2) instead of integer minor units.
 *
 * Before: USD was stored in cents (a $6.25 order held 625). Now every money
 * column holds the actual amount in its currency's major unit — USD 6.25,
 * IQD 59500.00 — so the database reads naturally.
 *
 * Existing USD rows are divided by 100 (cents → dollars); IQD rows keep their
 * value (dinars have no subunit). The row's currency marker (`orders.currency`,
 * `*_items.charge_currency`, `wallet_transactions.currency`) tells us which is which.
 */
return new class extends Migration
{
    /** table => money columns to convert. */
    private array $money = [
        'cart_items' => ['iqd_price'],
        'order_items' => ['iqd_price'],
        'orders' => ['items_total_iqd', 'shipping_iqd', 'service_fee_iqd', 'total_iqd'],
        'wallets' => ['balance_iqd', 'balance_usd'],
        'wallet_transactions' => ['amount_iqd', 'balance_after'],
    ];

    public function up(): void
    {
        // 1) Widen every money column to decimal(14,2) (keeps the current numeric
        //    value: 625 -> 625.00, 59500 -> 59500.00).
        foreach ($this->money as $table => $columns) {
            foreach ($columns as $col) {
                DB::statement("ALTER TABLE `$table` MODIFY `$col` DECIMAL(14,2) NOT NULL DEFAULT 0");
            }
        }

        // 2) Convert existing USD amounts from cents to dollars. IQD rows are left
        //    as-is (dinars are already the real amount).
        DB::statement("UPDATE `orders` SET
            items_total_iqd = items_total_iqd/100,
            shipping_iqd    = shipping_iqd/100,
            service_fee_iqd = service_fee_iqd/100,
            total_iqd       = total_iqd/100
            WHERE currency = 'USD'");
        DB::statement("UPDATE `order_items` SET iqd_price = iqd_price/100 WHERE charge_currency = 'USD'");
        DB::statement("UPDATE `cart_items`  SET iqd_price = iqd_price/100 WHERE charge_currency = 'USD'");
        DB::statement("UPDATE `wallet_transactions` SET
            amount_iqd    = amount_iqd/100,
            balance_after = balance_after/100
            WHERE currency = 'USD'");
        // The USD balance column is always USD, so always convert it.
        DB::statement('UPDATE `wallets` SET balance_usd = balance_usd/100');
    }

    public function down(): void
    {
        // Reverse: USD dollars -> cents, then narrow back to bigint.
        DB::statement("UPDATE `orders` SET
            items_total_iqd = items_total_iqd*100,
            shipping_iqd    = shipping_iqd*100,
            service_fee_iqd = service_fee_iqd*100,
            total_iqd       = total_iqd*100
            WHERE currency = 'USD'");
        DB::statement("UPDATE `order_items` SET iqd_price = iqd_price*100 WHERE charge_currency = 'USD'");
        DB::statement("UPDATE `cart_items`  SET iqd_price = iqd_price*100 WHERE charge_currency = 'USD'");
        DB::statement("UPDATE `wallet_transactions` SET
            amount_iqd    = amount_iqd*100,
            balance_after = balance_after*100
            WHERE currency = 'USD'");
        DB::statement('UPDATE `wallets` SET balance_usd = balance_usd*100');

        foreach ($this->money as $table => $columns) {
            foreach ($columns as $col) {
                DB::statement("ALTER TABLE `$table` MODIFY `$col` BIGINT NOT NULL DEFAULT 0");
            }
        }
    }
};
