<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Translates short product strings (titles, colours) into the app's language.
 *
 * Product titles are scraped in the store's language (Turkish for Trendyol,
 * Arabic for Shein…). This turns them into English / Arabic / Kurdish for the
 * customer. Results are cached forever per (text, language) — a title never
 * changes — so each phrase is only ever sent to the model once.
 *
 * Reuses the same LLM providers as AiVariantService (Groq → Gemini → Anthropic).
 * Best-effort: on any failure the ORIGINAL text is returned unchanged.
 */
class TranslationService
{
    private const LANGS = [
        'en' => 'English',
        'ar' => 'Arabic',
        'ku' => 'Kurdish (Sorani)',
    ];

    /**
     * Translate many strings at once.
     *
     * @param  string[]  $texts
     * @return array<string,string>  original => translated
     */
    public function translateMany(array $texts, string $lang): array
    {
        $lang = strtolower(substr($lang, 0, 2));
        $texts = array_values(array_unique(array_filter(array_map('trim', $texts), fn ($t) => $t !== '')));
        if ($texts === [] || ! isset(self::LANGS[$lang])) {
            return [];
        }

        $out = [];
        $todo = [];
        foreach ($texts as $t) {
            $cached = Cache::get($this->key($t, $lang));
            if ($cached !== null) {
                $out[$t] = $cached;
            } else {
                $todo[] = $t;
            }
        }

        if ($todo !== []) {
            $fresh = $this->viaModel($todo, self::LANGS[$lang]);
            foreach ($todo as $i => $t) {
                $translated = $fresh[$i] ?? $t;
                $translated = $translated !== '' ? $translated : $t;
                Cache::forever($this->key($t, $lang), $translated);
                $out[$t] = $translated;
            }
        }

        return $out;
    }

    private function key(string $text, string $lang): string
    {
        return 'tr:'.$lang.':'.md5($text);
    }

    /**
     * One model call that translates the whole batch. Returns a list parallel to
     * $texts, or [] on failure (caller falls back to the originals).
     *
     * @param  string[]  $texts
     * @return string[]
     */
    private function viaModel(array $texts, string $language): array
    {
        $system = "You are a translator for an online shopping app. Translate each product "
            . "string in the JSON array into {$language}. Keep it natural, concise and "
            . "shopper-friendly. Keep brand names, model codes and sizes as-is. Do NOT add "
            . "quotes or extra words. Return ONLY a JSON object of the form "
            . '{"items":["...","..."]} with the translations in the SAME ORDER and SAME COUNT '
            . "as the input.";
        $user = json_encode(['items' => array_values($texts)], JSON_UNESCAPED_UNICODE);

        $content = null;
        if (config('services.groq.key')) {
            $content = $this->groq($system, $user);
        } elseif (config('services.gemini.key')) {
            $content = $this->gemini($system, $user);
        }

        if ($content === null) {
            return [];
        }

        $parsed = json_decode(trim(preg_replace('/^```(?:json)?|```$/m', '', $content)), true);
        $items = is_array($parsed) ? ($parsed['items'] ?? null) : null;
        if (! is_array($items) || count($items) !== count($texts)) {
            return [];
        }

        return array_map(fn ($s) => trim((string) $s), $items);
    }

    private function groq(string $system, string $user): ?string
    {
        try {
            $resp = Http::withToken(config('services.groq.key'))
                ->timeout(25)
                ->post('https://api.groq.com/openai/v1/chat/completions', [
                    'model' => config('services.groq.model', 'llama-3.1-8b-instant'),
                    'temperature' => 0,
                    'max_tokens' => 1500,
                    'response_format' => ['type' => 'json_object'],
                    'messages' => [
                        ['role' => 'system', 'content' => $system],
                        ['role' => 'user', 'content' => $user],
                    ],
                ]);

            return $resp->ok() ? (string) $resp->json('choices.0.message.content', '') : null;
        } catch (\Throwable $e) {
            Log::warning('Translate (Groq) failed: '.$e->getMessage());

            return null;
        }
    }

    private function gemini(string $system, string $user): ?string
    {
        $key = config('services.gemini.key');
        $model = config('services.gemini.model', 'gemini-2.0-flash');
        $headers = ['content-type' => 'application/json'];
        if (str_starts_with((string) $key, 'AQ.')) {
            $headers['Authorization'] = 'Bearer '.$key;
        } else {
            $headers['x-goog-api-key'] = $key;
        }

        try {
            $resp = Http::withHeaders($headers)
                ->timeout(25)
                ->post("https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent", [
                    'system_instruction' => ['parts' => [['text' => $system]]],
                    'contents' => [['role' => 'user', 'parts' => [['text' => $user]]]],
                    'generationConfig' => ['temperature' => 0, 'responseMimeType' => 'application/json'],
                ]);

            return $resp->ok() ? (string) $resp->json('candidates.0.content.parts.0.text', '') : null;
        } catch (\Throwable $e) {
            Log::warning('Translate (Gemini) failed: '.$e->getMessage());

            return null;
        }
    }
}
