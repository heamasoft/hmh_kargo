<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Governorate (محافظة). City stays as the district/city within it, and
        // `street` holds the home address (عنوان).
        Schema::table('addresses', function (Blueprint $table) {
            $table->string('governorate')->nullable()->after('recipient_name');
        });
    }

    public function down(): void
    {
        Schema::table('addresses', function (Blueprint $table) {
            $table->dropColumn('governorate');
        });
    }
};
