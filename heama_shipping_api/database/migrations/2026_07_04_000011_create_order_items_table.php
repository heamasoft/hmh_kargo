<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Immutable snapshot of the cart items at the moment the order was placed.
        Schema::create('order_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained()->cascadeOnDelete();
            $table->foreignId('store_id')->nullable()->constrained();
            $table->string('store_name')->nullable();
            $table->string('source_url', 1024);
            $table->string('title');
            $table->string('image_url', 1024)->nullable();
            $table->decimal('source_price', 12, 2);
            $table->string('source_currency', 3)->default('USD');
            $table->bigInteger('iqd_price');
            $table->string('color')->nullable();
            $table->string('size')->nullable();
            $table->unsignedInteger('qty')->default(1);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('order_items');
    }
};
