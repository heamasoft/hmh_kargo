<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Multi-currency support. The customer is charged in IQD (Shein, manual) or USD
 * (all other stores, e.g. Trendyol). Money columns named *_iqd now hold the
 * amount in the *minor unit of the row's currency* — IQD = dinars (as before),
 * USD = cents — disambiguated by the new currency marker columns.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('stores', function (Blueprint $table) {
            $table->string('charge_currency', 3)->nullable()->after('currency');
        });
        Schema::table('wallets', function (Blueprint $table) {
            // USD balance in cents (IQD balance stays in balance_iqd).
            $table->bigInteger('balance_usd')->default(0)->after('balance_iqd');
        });
        Schema::table('wallet_transactions', function (Blueprint $table) {
            // amount_iqd / balance_after hold minor units of this currency.
            $table->string('currency', 3)->default('IQD')->after('type');
        });
        Schema::table('cart_items', function (Blueprint $table) {
            // iqd_price holds the all-in unit price in minor units of charge_currency.
            $table->string('charge_currency', 3)->default('IQD')->after('source_currency');
        });
        Schema::table('order_items', function (Blueprint $table) {
            $table->string('charge_currency', 3)->default('IQD')->after('source_currency');
        });
        Schema::table('orders', function (Blueprint $table) {
            // *_iqd totals hold minor units of this currency.
            $table->string('currency', 3)->default('IQD')->after('total_iqd');
        });

        // Charge currency per store: Shein (and manual) in IQD, everything else USD.
        DB::table('stores')->update(['charge_currency' => 'USD']);
        DB::table('stores')->where('key', 'shein')->update(['charge_currency' => 'IQD']);
    }

    public function down(): void
    {
        Schema::table('stores', fn (Blueprint $t) => $t->dropColumn('charge_currency'));
        Schema::table('wallets', fn (Blueprint $t) => $t->dropColumn('balance_usd'));
        Schema::table('wallet_transactions', fn (Blueprint $t) => $t->dropColumn('currency'));
        Schema::table('cart_items', fn (Blueprint $t) => $t->dropColumn('charge_currency'));
        Schema::table('order_items', fn (Blueprint $t) => $t->dropColumn('charge_currency'));
        Schema::table('orders', fn (Blueprint $t) => $t->dropColumn('currency'));
    }
};
