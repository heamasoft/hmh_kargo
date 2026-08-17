<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Per-store shipping fee in IQD. Null → use the global flat rate. Lets
        // Trendyol (Türkiye) ship at a different price than Shein (China).
        Schema::table('stores', function (Blueprint $table) {
            $table->unsignedInteger('shipping_iqd')->nullable()->after('currency');
        });
    }

    public function down(): void
    {
        Schema::table('stores', function (Blueprint $table) {
            $table->dropColumn('shipping_iqd');
        });
    }
};
