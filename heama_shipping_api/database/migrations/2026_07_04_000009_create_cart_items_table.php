<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // A captured product. We snapshot the scraped data so the line is stable
        // even if the source page changes or disappears.
        Schema::create('cart_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cart_id')->constrained()->cascadeOnDelete();
            $table->foreignId('store_id')->nullable()->constrained();
            $table->string('source_url', 1024);
            $table->string('title');
            $table->string('image_url', 1024)->nullable();
            $table->decimal('source_price', 12, 2);
            $table->string('source_currency', 3)->default('USD');
            $table->bigInteger('iqd_price'); // computed all-in unit price
            $table->string('color')->nullable();
            $table->string('size')->nullable();
            $table->unsignedInteger('qty')->default(1);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cart_items');
    }
};
