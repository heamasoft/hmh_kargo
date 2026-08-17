<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique(); // HM-20418
            $table->foreignId('user_id')->constrained();
            // placed -> purchased -> warehouse -> in_transit -> arrived -> out_for_delivery -> delivered
            $table->string('status')->default('placed');
            $table->bigInteger('items_total_iqd');
            $table->bigInteger('shipping_iqd')->default(0);
            $table->bigInteger('service_fee_iqd')->default(0);
            $table->bigInteger('total_iqd');
            $table->string('payment_method')->default('wallet');
            $table->json('address')->nullable(); // snapshot of delivery address
            $table->timestamp('placed_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
