<?php

namespace App\Services\Otp;

use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use RuntimeException;

/**
 * Sends OTP codes by email through the configured SMTP mailer (Hostinger).
 */
class EmailOtpSender implements OtpSender
{
    public function send(string $recipient, string $code): void
    {
        // Without SMTP configured, log instead of failing (local/dev).
        if (config('mail.default') === 'log' || empty(config('mail.mailers.smtp.host'))) {
            Log::info("[Email OTP not configured] would send {$code} to {$recipient}");
            return;
        }

        try {
            Mail::send('emails.otp', ['code' => $code], function ($message) use ($recipient) {
                $message->to($recipient)->subject('Your Heama verification code');
            });
        } catch (\Throwable $e) {
            Log::error('Email OTP send failed', ['error' => $e->getMessage()]);
            throw new RuntimeException('Could not send email code.');
        }
    }
}
