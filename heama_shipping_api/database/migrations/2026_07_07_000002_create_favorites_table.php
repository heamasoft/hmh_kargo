<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Saved (hearted) products per user. `item_key` is the app's stable id
        // (catalog product key, or a hash for items captured from a store).
        Schema::create('favorites', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('item_key');
            $table->string('name')->nullable();
            $table->string('store')->nullable();
            $table->unsignedBigInteger('store_id')->nullable();
            $table->string('source_url', 1024)->nullable();
            $table->bigInteger('iqd_price')->default(0);
            $table->string('image_url', 1024)->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'item_key']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('favorites');
    }
};
