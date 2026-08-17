<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Append-only ledger. Wallet balance = sum of these rows; every top-up,
        // order debit, and refund is recorded for a full audit trail.
        Schema::create('wallet_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('type'); // topup | debit | refund | adjustment
            $table->bigInteger('amount_iqd'); // positive credit, negative debit
            $table->bigInteger('balance_after');
            $table->foreignId('order_id')->nullable();
            $table->string('note')->nullable();
            $table->foreignId('admin_id')->nullable(); // who performed a manual top-up
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wallet_transactions');
    }
};
