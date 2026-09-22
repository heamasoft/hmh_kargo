<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/** Optional logo per store for the app's store tiles. See database/sql/2026_09_23_store_logos.sql. */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('stores', function (Blueprint $t) {
            $t->string('logo_url', 1024)->nullable()->after('glyph_color');
        });
    }

    public function down(): void
    {
        Schema::table('stores', function (Blueprint $t) {
            $t->dropColumn('logo_url');
        });
    }
};
