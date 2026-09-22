<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\HasApiTokens;

#[Fillable(['name', 'phone', 'email', 'city', 'password', 'is_admin'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'phone_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_admin' => 'boolean',
        ];
    }

    public function wallet(): HasOne
    {
        return $this->hasOne(Wallet::class);
    }

    public function cart(): HasOne
    {
        return $this->hasOne(Cart::class);
    }

    public function addresses(): HasMany
    {
        return $this->hasMany(Address::class);
    }

    public function favorites(): HasMany
    {
        return $this->hasMany(Favorite::class);
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    public function walletTransactions(): HasMany
    {
        return $this->hasMany(WalletTransaction::class);
    }

    /**
     * Every way an Iraqi mobile number is written, so a login matches however it
     * was typed or stored. The app shows "+964" and the hint "750 123 4567", so
     * people type 7501234567 — while accounts are stored as 07501234567 (and
     * some as 9647501234567). Comparing the raw digits made correct numbers
     * fail with "Incorrect phone number or password".
     *
     * @return list<string>
     */
    public static function phoneVariants(string $raw): array
    {
        $d = preg_replace('/\D+/', '', $raw);
        if (str_starts_with($d, '00964')) {
            $d = substr($d, 5);
        } elseif (str_starts_with($d, '964')) {
            $d = substr($d, 3);
        }
        $local = ltrim($d, '0'); // 7501234567
        if ($local === '') {
            return [$d];
        }

        return array_values(array_unique([$d, $local, '0'.$local, '964'.$local]));
    }

    /** The one way new numbers are saved: 07501234567, like existing ones. */
    public static function canonicalPhone(string $raw): string
    {
        $d = preg_replace('/\D+/', '', $raw);
        if (str_starts_with($d, '00964')) {
            $d = substr($d, 5);
        } elseif (str_starts_with($d, '964')) {
            $d = substr($d, 3);
        }
        $local = ltrim($d, '0');

        return $local === '' ? $d : '0'.$local;
    }

    public static function findByPhone(string $raw): ?self
    {
        return static::whereIn('phone', static::phoneVariants($raw))->first();
    }

    /**
     * Blocked (deactivated) accounts can't log in or use the API. The flag is
     * customer_status.blocked_at — shared with the admin dashboard, which sets
     * and clears it; no row means active.
     */
    public function isBlocked(): bool
    {
        try {
            return DB::table('customer_status')
                ->where('user_id', $this->id)
                ->whereNotNull('blocked_at')
                ->exists();
        } catch (\Throwable $e) {
            return false; // table missing — nobody is blocked
        }
    }

    /** Blocks the account, keeping any verified_at and appending [note]. */
    public function block(string $note): void
    {
        $row = DB::table('customer_status')->where('user_id', $this->id)->first();
        $line = now()->toDateTimeString().' — '.$note;
        $values = [
            'blocked_at' => now(),
            'note' => trim(($row->note ?? '')."\n".$line),
            'updated_at' => now(),
        ];

        if ($row) {
            DB::table('customer_status')->where('user_id', $this->id)->update($values);
        } else {
            DB::table('customer_status')->insert(['user_id' => $this->id] + $values);
        }
    }

    /** Convenience: current wallet balance in IQD (0 if no wallet yet). */
    public function balanceIqd(): int
    {
        return (int) ($this->wallet?->balance_iqd ?? 0);
    }
}
