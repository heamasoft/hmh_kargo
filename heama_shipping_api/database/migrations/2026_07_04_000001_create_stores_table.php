<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('stores', function (Blueprint $table) {
            $table->id();
            $table->string('key')->unique();          // shein, temu, trendyol...
            $table->string('name');
            $table->string('glyph', 4)->nullable();    // "SH" monogram
            $table->string('glyph_color', 9)->nullable();
            $table->string('category_key')->nullable();
            $table->string('base_url');
            $table->string('currency', 3)->default('USD');
            // Per-site scrape selectors (title/price/image/variant), versioned
            // so a broken store can be fixed without an app release.
            $table->json('capture_rules')->nullable();
            $table->boolean('active')->default(true);
            $table->unsignedInteger('sort_order')->default(0);
            $table->string('region')->default('international'); // international | turkiye
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('stores');
    }
};
