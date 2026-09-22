<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Discount coupons: an admin creates a code with a percentage and an expiry;
 * each customer may use each code once (the unique key on redemptions).
 * Mirrored in database/sql/2026_09_22_coupons.sql for phpMyAdmin.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('coupons', function (Blueprint $t) {
            $t->id();
            $t->string('code', 40)->unique();
            $t->decimal('percent', 5, 2);
            $t->timestamp('expires_at')->nullable();
            $t->boolean('is_active')->default(true);
            $t->unsignedBigInteger('created_by')->nullable();
            $t->timestamps();
        });

        Schema::create('coupon_redemptions', function (Blueprint $t) {
            $t->id();
            $t->foreignId('coupon_id')->constrained('coupons')->cascadeOnDelete();
            $t->unsignedBigInteger('user_id');
            $t->unsignedBigInteger('order_id')->nullable();
            $t->timestamps();
            $t->unique(['coupon_id', 'user_id']); // one use per customer
        });

        Schema::table('orders', function (Blueprint $t) {
            $t->decimal('discount_iqd', 14, 2)->default(0)->after('service_fee_iqd');
            $t->decimal('discount_percent', 5, 2)->default(0)->after('discount_iqd');
            $t->string('coupon_code', 40)->nullable()->after('discount_percent');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $t) {
            $t->dropColumn(['discount_iqd', 'discount_percent', 'coupon_code']);
        });
        Schema::dropIfExists('coupon_redemptions');
        Schema::dropIfExists('coupons');
    }
};
