<?php

namespace App\Services\Otp;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;

/**
 * Sends OTP codes through the Meta WhatsApp Cloud API using an approved
 * authentication message template.
 */
class WhatsAppOtpSender implements OtpSender
{
    public function send(string $recipient, string $code): void
    {
        $token = config('services.whatsapp.token');
        $phoneId = config('services.whatsapp.phone_number_id');

        // If not configured yet, fall back to logging so local/dev flows work.
        if (empty($token) || empty($phoneId)) {
            Log::info("[WhatsApp OTP not configured] would send {$code} to {$recipient}");
            return;
        }

        $version = config('services.whatsapp.api_version', 'v21.0');
        $template = config('services.whatsapp.template', 'heama_otp');
        $lang = config('services.whatsapp.lang', 'en');

        $response = Http::withToken($token)
            ->asJson()
            ->post("https://graph.facebook.com/{$version}/{$phoneId}/messages", [
                'messaging_product' => 'whatsapp',
                'to' => $this->normalize($recipient),
                'type' => 'template',
                'template' => [
                    'name' => $template,
                    'language' => ['code' => $lang],
                    'components' => [
                        [
                            'type' => 'body',
                            'parameters' => [['type' => 'text', 'text' => $code]],
                        ],
                        // Authentication templates require the code again on the
                        // copy-code button component.
                        [
                            'type' => 'button',
                            'sub_type' => 'url',
                            'index' => '0',
                            'parameters' => [['type' => 'text', 'text' => $code]],
                        ],
                    ],
                ],
            ]);

        if ($response->failed()) {
            Log::error('WhatsApp OTP send failed', ['body' => $response->body()]);
            throw new RuntimeException('Could not send WhatsApp code.');
        }
    }

    /**
     * Meta expects E.164 WITHOUT the leading '+' (e.g. 9647504848085).
     *
     * In the app the "+964" is only a label — the customer types the LOCAL number
     * ("7504848085" or "07504848085"), so we drop the local trunk '0' and prefix
     * the country code when it isn't already there.
     */
    private function normalize(string $phone): string
    {
        $digits = preg_replace('/\D+/', '', $phone);
        if ($digits === '') {
            return '';
        }

        $cc = (string) config('services.whatsapp.country_code', '964');

        // Already international (country code + a plausible subscriber number).
        if (str_starts_with($digits, $cc) && strlen($digits) >= strlen($cc) + 8) {
            return $digits;
        }

        // Local: strip the trunk zero(s), then prefix the country code.
        return $cc.ltrim($digits, '0');
    }
}
