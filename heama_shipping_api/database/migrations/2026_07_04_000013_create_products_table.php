<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Curated/featured products shown in the app (home trending + storefront
        // grid) for browsing and demos. Real shopping still happens via WebView
        // capture; this is the catalog the app renders until then.
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->string('key')->unique();          // stable slug, e.g. "top"
            $table->foreignId('store_id')->nullable()->constrained();
            $table->string('name');
            $table->string('category')->nullable();    // tops | dresses | bottoms...
            $table->string('source_url', 1024)->nullable();
            $table->string('image_url', 1024)->nullable();
            $table->decimal('source_price', 12, 2);
            $table->string('source_currency', 3)->default('USD');
            $table->decimal('old_price', 12, 2)->nullable();
            $table->decimal('rating', 3, 1)->default(4.6);
            $table->string('reviews')->nullable();
            $table->json('gradient')->nullable();      // 2 hex fallback colors
            $table->json('colors')->nullable();        // [{name,hex}, ...]
            $table->json('sizes')->nullable();         // ["S","M",...]
            $table->boolean('trending')->default(false);
            $table->unsignedInteger('sort_order')->default(0);
            $table->boolean('active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
