<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Shipping was never stored on a cart line — it was worked out from the flat
 * per-unit rate every time the cart was read. That rate is a guess made before
 * anyone has weighed the parcel: a scarf and a winter coat both came out at $2.
 *
 * An admin can now put the real figure on the line. Null means "use the rate",
 * so every existing line and every new capture keeps behaving as it did, and
 * the amount is PER UNIT — two of the same coat ship for twice this — which is
 * what the order carries, one order per unit.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cart_items', function (Blueprint $table) {
            $table->decimal('shipping_override', 14, 2)->nullable()->after('iqd_price');
        });
    }

    public function down(): void
    {
        Schema::table('cart_items', function (Blueprint $table) {
            $table->dropColumn('shipping_override');
        });
    }
};
