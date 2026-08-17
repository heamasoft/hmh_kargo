<?php

namespace App\Services\Otp;

use App\Models\OtpCode;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

/**
 * Issues and verifies one-time codes over WhatsApp or email.
 *
 * Codes are stored hashed with a short TTL. A resend cooldown throttles abuse,
 * and a max-attempts cap prevents brute forcing.
 */
class OtpService
{
    /**
     * Generate a code, persist it (hashed), and dispatch it over the channel.
     *
     * @param  string  $channel  whatsapp|email
     * @return int seconds until the code expires
     */
    public function request(string $identifier, string $channel, string $purpose = 'login'): int
    {
        $identifier = $this->normalize($identifier, $channel);
        $cooldown = (int) config('services.otp.resend_cooldown', 60);

        // Throttle resends.
        $recent = OtpCode::where('identifier', $identifier)
            ->where('channel', $channel)
            ->whereNull('consumed_at')
            ->latest()
            ->first();

        if ($recent && $recent->created_at->gt(now()->subSeconds($cooldown))) {
            $wait = $cooldown - now()->diffInSeconds($recent->created_at);
            throw ValidationException::withMessages([
                'identifier' => ["Please wait {$wait}s before requesting another code."],
            ]);
        }

        // Invalidate any outstanding codes for this identifier.
        OtpCode::where('identifier', $identifier)
            ->whereNull('consumed_at')
            ->update(['consumed_at' => now()]);

        $length = (int) config('services.otp.length', 4);
        $ttl = (int) config('services.otp.ttl_seconds', 300);
        $code = $this->randomCode($length);

        OtpCode::create([
            'identifier' => $identifier,
            'channel' => $channel,
            'code_hash' => Hash::make($code),
            'purpose' => $purpose,
            'expires_at' => Carbon::now()->addSeconds($ttl),
        ]);

        $this->senderFor($channel)->send($identifier, $code);

        return $ttl;
    }

    /**
     * Verify a submitted code. Marks it consumed on success.
     *
     * @throws ValidationException when the code is wrong/expired/exhausted
     */
    public function verify(string $identifier, string $channel, string $code): void
    {
        $identifier = $this->normalize($identifier, $channel);

        // Demo bypass (dev only). Disabled unless OTP_DEMO_CODE is a NON-EMPTY
        // value — a blank env is an empty string (not null), so guard on filled()
        // to make sure blank truly turns the bypass OFF.
        $demo = config('services.otp.demo_code');
        if (filled($demo) && hash_equals((string) $demo, $code)) {
            OtpCode::where('identifier', $identifier)->whereNull('consumed_at')
                ->update(['consumed_at' => now()]);
            return;
        }

        $otp = OtpCode::where('identifier', $identifier)
            ->where('channel', $channel)
            ->whereNull('consumed_at')
            ->latest()
            ->first();

        if (! $otp) {
            $this->fail('No active code. Please request a new one.');
        }

        if ($otp->isExpired()) {
            $this->fail('This code has expired. Please request a new one.');
        }

        $max = (int) config('services.otp.max_attempts', 5);
        if ($otp->attempts >= $max) {
            $this->fail('Too many attempts. Please request a new code.');
        }

        if (! Hash::check($code, $otp->code_hash)) {
            $otp->increment('attempts');
            $this->fail('That code is incorrect.');
        }

        $otp->update(['consumed_at' => now()]);
    }

    private function senderFor(string $channel): OtpSender
    {
        return match ($channel) {
            'whatsapp' => app(WhatsAppOtpSender::class),
            'email' => app(EmailOtpSender::class),
            default => throw ValidationException::withMessages([
                'channel' => ['Unsupported channel.'],
            ]),
        };
    }

    private function normalize(string $identifier, string $channel): string
    {
        if ($channel === 'email') {
            return strtolower(trim($identifier));
        }
        // whatsapp: keep digits only
        return preg_replace('/\D+/', '', $identifier);
    }

    private function randomCode(int $length): string
    {
        $max = (10 ** $length) - 1;
        return str_pad((string) random_int(0, $max), $length, '0', STR_PAD_LEFT);
    }

    private function fail(string $message): never
    {
        throw ValidationException::withMessages(['code' => [$message]]);
    }
}
