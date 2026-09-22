<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Home-page ads (admin-uploaded images). Mirrored in
 * database/sql/2026_09_23_ads.sql for phpMyAdmin.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ads', function (Blueprint $t) {
            $t->id();
            $t->string('image_path', 255);
            $t->string('link_url', 1024)->nullable();
            $t->unsignedInteger('sort')->default(0);
            $t->boolean('is_active')->default(true);
            $t->unsignedBigInteger('created_by')->nullable();
            $t->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ads');
    }
};
