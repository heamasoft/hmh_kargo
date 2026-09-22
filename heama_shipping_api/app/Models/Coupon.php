<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

/**
 * A discount code: [percent] off an order's items total, until [expires_at],
 * usable once per customer (coupon_redemptions has a unique coupon+user key).
 */
class Coupon extends Model
{
    protected $fillable = ['code', 'percent', 'expires_at', 'is_active', 'created_by'];

    protected $casts = [
        'percent' => 'float',
        'expires_at' => 'datetime',
        'is_active' => 'boolean',
    ];

    /** Codes are matched without regard to case or surrounding spaces. */
    public static function normalize(string $code): string
    {
        return strtoupper(trim($code));
    }

    public function isExpired(): bool
    {
        return $this->expires_at !== null && $this->expires_at->isPast();
    }

    public function usedBy(int $userId): bool
    {
        return DB::table('coupon_redemptions')
            ->where('coupon_id', $this->id)->where('user_id', $userId)->exists();
    }

    public function timesUsed(): int
    {
        return DB::table('coupon_redemptions')->where('coupon_id', $this->id)->count();
    }

    /**
     * The coupon behind [code] if [user] may use it now; otherwise a 422 whose
     * message says why (unknown, switched off, expired, already used).
     */
    public static function usableBy(string $code, User $user): self
    {
        $coupon = static::where('code', static::normalize($code))->first();

        $fail = fn (string $m) => throw ValidationException::withMessages(['coupon_code' => [$m]]);

        if (! $coupon) {
            $fail('This coupon code is not valid.');
        }
        if (! $coupon->is_active) {
            $fail('This coupon is no longer available.');
        }
        if ($coupon->isExpired()) {
            $fail('This coupon has expired.');
        }
        if ($coupon->usedBy($user->id)) {
            $fail('You have already used this coupon.');
        }

        return $coupon;
    }

    /** The discount on [itemsTotal] in [currency]: whole dinars, or cents. */
    public function discountOn(float $itemsTotal, string $currency): float
    {
        $d = $itemsTotal * $this->percent / 100;

        return strtoupper($currency) === 'USD' ? round($d, 2) : round($d);
    }
}
