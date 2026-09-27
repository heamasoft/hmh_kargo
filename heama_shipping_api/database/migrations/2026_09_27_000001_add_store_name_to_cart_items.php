<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * A cart line from a shop we don't carry had nowhere to say which shop it was:
 * only store_id, which is null for exactly those items. The order it became
 * then carried no store name either, so the admin buying it had the link and
 * nothing else. Cart lines now hold the name too, as order lines already did.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cart_items', function (Blueprint $table) {
            $table->string('store_name', 120)->nullable()->after('store_id');
        });
    }

    public function down(): void
    {
        Schema::table('cart_items', function (Blueprint $table) {
            $table->dropColumn('store_name');
        });
    }
};
