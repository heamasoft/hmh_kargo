<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Optional per-item note from the customer (special requirement for the
        // order). Snapshotted onto the order item too, so the admin always sees it.
        Schema::table('cart_items', function (Blueprint $table) {
            $table->string('note', 500)->nullable()->after('size');
        });
        Schema::table('order_items', function (Blueprint $table) {
            $table->string('note', 500)->nullable()->after('size');
        });
    }

    public function down(): void
    {
        Schema::table('cart_items', function (Blueprint $table) {
            $table->dropColumn('note');
        });
        Schema::table('order_items', function (Blueprint $table) {
            $table->dropColumn('note');
        });
    }
};
