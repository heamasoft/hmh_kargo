<?php

namespace App\Services;

use App\Models\User;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use Illuminate\Support\Facades\DB;
use RuntimeException;

/**
 * Single source of truth for wallet balance changes. The customer has one
 * balance per currency (IQD and USD), each holding the REAL amount (IQD = dinars,
 * USD = dollars) in decimal(14,2). Every credit/debit writes a ledger row and
 * updates the matching cached balance atomically.
 */
class WalletService
{
    /** Balance column for a currency. */
    private function column(string $currency): string
    {
        return strtoupper($currency) === 'USD' ? 'balance_usd' : 'balance_iqd';
    }

    private function walletFor(User $user): Wallet
    {
        return Wallet::firstOrCreate(['user_id' => $user->id]);
    }

    /** Balance for one currency (real amount). */
    public function balance(User $user, string $currency = 'IQD'): float
    {
        return (float) $this->walletFor($user)->{$this->column($currency)};
    }

    /** Both balances, for the app. */
    public function balances(User $user): array
    {
        $w = $this->walletFor($user);

        return [
            'IQD' => (float) $w->balance_iqd,
            'USD' => (float) $w->balance_usd,
        ];
    }

    /**
     * The ledger is the source of truth: a balance is just the sum of its
     * currency's transactions. This recomputes both balances from the ledger and
     * corrects the cached wallet row if it has drifted (e.g. after a data change).
     * Returns the corrected balances. Safe to call on every wallet read.
     */
    public function reconcile(User $user): array
    {
        $wallet = $this->walletFor($user);

        $sums = WalletTransaction::where('user_id', $user->id)
            ->selectRaw("UPPER(COALESCE(NULLIF(currency, ''), 'IQD')) as cur, SUM(amount_iqd) as total")
            ->groupBy('cur')
            ->pluck('total', 'cur');

        $iqd = round((float) ($sums['IQD'] ?? 0), 2);
        $usd = round((float) ($sums['USD'] ?? 0), 2);

        // Only write when it actually drifted (tolerate float noise).
        if (abs((float) $wallet->balance_iqd - $iqd) > 0.001
            || abs((float) $wallet->balance_usd - $usd) > 0.001) {
            $wallet->update(['balance_iqd' => $iqd, 'balance_usd' => $usd]);
        }

        return ['IQD' => $iqd, 'USD' => $usd];
    }

    /**
     * Moves money between a customer's own IQD and USD balances at the system FX
     * rate. Debits the source (blocked if the balance is too low) and credits the
     * target with the converted amount — both as 'exchange' ledger rows, so the
     * balances stay reconcilable. Returns the updated balances.
     */
    public function exchange(User $user, string $from, string $to, float $amount): array
    {
        $from = strtoupper($from);
        $to = strtoupper($to);
        if ($from === $to) {
            throw new RuntimeException('Choose two different currencies.');
        }
        if ($amount <= 0) {
            throw new RuntimeException('Amount must be greater than zero.');
        }

        $pricing = app(PricingService::class);
        $converted = $pricing->convert($amount, $from, $to);
        // Target precision: USD keeps cents, IQD is whole dinars.
        $converted = $to === 'USD' ? round($converted, 2) : round($converted);
        if ($converted <= 0) {
            throw new RuntimeException('Amount is too small to exchange.');
        }

        return DB::transaction(function () use ($user, $from, $to, $amount, $converted) {
            // Source: block if the balance can't cover it.
            $this->debit($user, $amount, $from, type: 'exchange', note: "Exchange to {$to}", allowNegative: false);
            // Target: credit the converted amount.
            $this->credit($user, $converted, $to, type: 'exchange', note: "Exchange from {$from}");

            return $this->balances($user);
        });
    }

    /** Credits a wallet (top-up / refund). Returns the new balance. */
    public function credit(User $user, float $amount, string $currency = 'IQD', string $type = 'topup', ?string $note = null, ?int $adminId = null, ?int $orderId = null): float
    {
        if ($amount <= 0) {
            throw new RuntimeException('Credit amount must be positive.');
        }

        return $this->apply($user, $amount, $currency, $type, $note, $adminId, $orderId);
    }

    /**
     * Debits a wallet (order payment). By default the balance may go negative
     * (customers can order on credit); pass $allowNegative=false to block it.
     *
     * $creditFloor caps how far negative the balance may go: the debit is blocked
     * if it would drop the balance below -$creditFloor. Pass the customer's
     * credit limit for this currency (0 = no credit allowed). Null = no cap.
     */
    public function debit(User $user, float $amount, string $currency = 'IQD', string $type = 'debit', ?string $note = null, ?int $orderId = null, bool $allowNegative = true, ?float $creditFloor = null): float
    {
        if ($amount <= 0) {
            throw new RuntimeException('Debit amount must be positive.');
        }

        return $this->apply($user, -$amount, $currency, $type, $note, null, $orderId, $allowNegative, $creditFloor);
    }

    /** Applies a signed delta to one currency inside a transaction with a row lock. */
    private function apply(User $user, float $delta, string $currency, string $type, ?string $note, ?int $adminId, ?int $orderId, bool $allowNegative = true, ?float $creditFloor = null): float
    {
        $currency = strtoupper($currency);
        $col = $this->column($currency);

        return DB::transaction(function () use ($user, $delta, $currency, $col, $type, $note, $adminId, $orderId, $allowNegative, $creditFloor) {
            $wallet = Wallet::where('user_id', $user->id)->lockForUpdate()->first()
                ?? Wallet::create(['user_id' => $user->id]);

            $newBalance = round((float) $wallet->{$col} + $delta, 2);
            if (! $allowNegative && $newBalance < 0) {
                throw new InsufficientBalanceException();
            }
            // Credit limit: never let the balance fall below -creditFloor.
            if ($creditFloor !== null && $newBalance < -abs($creditFloor) - 0.001) {
                throw new InsufficientBalanceException(
                    abs($creditFloor) > 0
                        ? 'This order is over your available balance and credit limit.'
                        : 'Not enough balance for this order. Please top up your wallet.'
                );
            }

            $wallet->update([$col => $newBalance]);

            WalletTransaction::create([
                'user_id' => $user->id,
                'type' => $type,
                'currency' => $currency,
                'amount_iqd' => $delta,      // minor units of $currency (legacy column name)
                'balance_after' => $newBalance,
                'order_id' => $orderId,
                'note' => $note,
                'admin_id' => $adminId,
            ]);

            return $newBalance;
        });
    }
}

/** Thrown when a debit would take a wallet below zero (or past its credit limit). */
class InsufficientBalanceException extends RuntimeException
{
    public function __construct(string $message = 'Insufficient wallet balance.')
    {
        parent::__construct($message);
    }
}
