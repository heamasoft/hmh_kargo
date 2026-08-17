<?php

namespace App\Services;

/**
 * Sends push notifications through Firebase Cloud Messaging (HTTP v1).
 *
 * Self-contained on purpose — plain PHP + curl + openssl, no Google SDK — so
 * this exact class can also be copied into the admin console (drop the
 * namespace line there). It authenticates with the Firebase service-account
 * JSON file (Project settings → Service accounts → Generate new private key),
 * which must live OUTSIDE public_html and NEVER ship inside the app.
 *
 * Usage:
 *   $fcm = new FcmSender('/home/uXXX/firebase-service-account.json');
 *   $fcm->sendToTokens($tokens, 'Shipping updated', 'Order HM-20055 needs your answer', [
 *       'type' => 'approval', 'order_code' => 'HM-20055',
 *   ]);
 */
class FcmSender
{
    private array $sa;          // decoded service-account JSON
    private ?string $accessToken = null;
    private int $tokenExpires = 0;

    public function __construct(string $serviceAccountPath)
    {
        $raw = @file_get_contents($serviceAccountPath);
        $this->sa = $raw ? (json_decode($raw, true) ?: []) : [];
    }

    public function ready(): bool
    {
        return isset($this->sa['client_email'], $this->sa['private_key'], $this->sa['project_id']);
    }

    /**
     * Pushes one notification to many device tokens.
     * Returns the number of successful sends; dead tokens are reported in
     * $invalidTokens so the caller can delete them from device_tokens.
     */
    public function sendToTokens(array $tokens, string $title, string $body, array $data = [], ?array &$invalidTokens = null): int
    {
        $invalidTokens = [];
        if (! $this->ready() || $tokens === []) {
            return 0;
        }
        $sent = 0;
        foreach (array_unique($tokens) as $token) {
            $result = $this->sendToToken($token, $title, $body, $data);
            if ($result === true) {
                $sent++;
            } elseif ($result === 'invalid') {
                $invalidTokens[] = $token;
            }
        }

        return $sent;
    }

    /** @return bool|string true, false (transient failure) or 'invalid' (dead token) */
    private function sendToToken(string $token, string $title, string $body, array $data)
    {
        $access = $this->accessToken();
        if ($access === null) {
            return false;
        }

        // FCM v1 requires every data value to be a string.
        $data = array_map(fn ($v) => (string) $v, $data);

        $payload = [
            'message' => [
                'token' => $token,
                'notification' => ['title' => $title, 'body' => $body],
                'data' => $data,
                'android' => ['priority' => 'HIGH'],
            ],
        ];

        $url = 'https://fcm.googleapis.com/v1/projects/'.$this->sa['project_id'].'/messages:send';
        [$status, $response] = $this->postJson($url, $payload, ['Authorization: Bearer '.$access]);

        if ($status === 200) {
            return true;
        }
        // 404 UNREGISTERED / 400 invalid-argument → token is dead, forget it.
        if ($status === 404 || (is_string($response) && str_contains($response, 'UNREGISTERED'))) {
            return 'invalid';
        }

        return false;
    }

    /** OAuth2 access token from a service-account JWT (cached ~50 min). */
    private function accessToken(): ?string
    {
        if ($this->accessToken !== null && time() < $this->tokenExpires - 60) {
            return $this->accessToken;
        }

        $now = time();
        $header = $this->b64(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
        $claims = $this->b64(json_encode([
            'iss' => $this->sa['client_email'],
            'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
            'aud' => 'https://oauth2.googleapis.com/token',
            'iat' => $now,
            'exp' => $now + 3600,
        ]));
        $signature = '';
        if (! openssl_sign("$header.$claims", $signature, $this->sa['private_key'], 'sha256WithRSAEncryption')) {
            return null;
        }
        $jwt = "$header.$claims.".$this->b64($signature);

        $ch = curl_init('https://oauth2.googleapis.com/token');
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => http_build_query([
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt,
            ]),
            CURLOPT_TIMEOUT => 15,
        ]);
        $res = curl_exec($ch);
        curl_close($ch);

        $json = is_string($res) ? json_decode($res, true) : null;
        if (! isset($json['access_token'])) {
            return null;
        }
        $this->accessToken = $json['access_token'];
        $this->tokenExpires = $now + (int) ($json['expires_in'] ?? 3600);

        return $this->accessToken;
    }

    /** @return array{0:int,1:?string} [http status, response body] */
    private function postJson(string $url, array $payload, array $headers): array
    {
        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($payload),
            CURLOPT_HTTPHEADER => array_merge(['Content-Type: application/json'], $headers),
            CURLOPT_TIMEOUT => 15,
        ]);
        $res = curl_exec($ch);
        $status = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        return [$status, is_string($res) ? $res : null];
    }

    private function b64(string $s): string
    {
        return rtrim(strtr(base64_encode($s), '+/', '-_'), '=');
    }
}
