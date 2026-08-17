<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Uses an LLM to read a product page's variant section and return the SELECTED
 * colour + size, plus the clean option lists. A best-effort assist for the app's
 * own heuristics — it strips badges ("L 3 left" -> "L"), handles English/Arabic/
 * Turkish, and picks the highlighted option.
 *
 * Provider: prefers Google Gemini (free tier); falls back to Anthropic if only
 * that key is set. Returns null on any failure so the caller keeps its heuristics.
 */
class AiVariantService
{
    public function extract(string $store, string $url, string $context): ?array
    {
        if (trim($context) === '') {
            return null;
        }

        $system = "You read the variant section of a shopping product page (Shein or Trendyol; "
            . "the text may be English, Arabic, or Turkish) and return the SELECTED colour and size.\n"
            . "- Option labels may carry stock/discount badges like '3 left', 'Almost sold out', '-20%' — strip those.\n"
            . "- An option marked [SELECTED] is the one the shopper chose. Return its clean value in `size`/`color`.\n"
            . "- If nothing is marked [SELECTED], return an empty string for that field, but still return the full option lists.\n"
            . "- Clean each option to just its value (e.g. 'L', 'XL', '2XL', 'CN36', '3-6 Years', 'One Size', 'White', 'Siyah').\n"
            . "- Never invent options that aren't in the input.";

        $user = "STORE: {$store}\nURL: {$url}\n{$context}";

        if (config('services.groq.key')) {
            return $this->viaGroq($system, $user);
        }
        if (config('services.gemini.key')) {
            return $this->viaGemini($system, $user);
        }
        if (config('services.anthropic.key')) {
            return $this->viaAnthropic($system, $user);
        }
        return null;
    }

    /** Groq (free tier, OpenAI-compatible chat completions). */
    private function viaGroq(string $system, string $user): ?array
    {
        $key = config('services.groq.key');
        $model = config('services.groq.model', 'llama-3.1-8b-instant');

        try {
            $resp = Http::withToken($key)
                ->timeout(25)
                ->post('https://api.groq.com/openai/v1/chat/completions', [
                    'model' => $model,
                    'temperature' => 0,
                    'max_tokens' => 600,
                    'response_format' => ['type' => 'json_object'],
                    'messages' => [
                        [
                            'role' => 'system',
                            'content' => $system
                                . "\nRespond with ONLY a JSON object of the form "
                                . '{"size":"","color":"","size_options":[],"color_options":[]}.',
                        ],
                        ['role' => 'user', 'content' => $user],
                    ],
                ]);
        } catch (\Throwable $e) {
            Log::warning('Groq request failed: '.$e->getMessage());
            return null;
        }

        if (! $resp->ok()) {
            Log::warning('Groq HTTP '.$resp->status().': '.$resp->body());
            return null;
        }

        return $this->parse($resp->json('choices.0.message.content', ''));
    }

    /** Google Gemini (free tier). */
    private function viaGemini(string $system, string $user): ?array
    {
        $key = config('services.gemini.key');
        $model = config('services.gemini.model', 'gemini-2.0-flash');
        $url = "https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent";

        $schema = [
            'type' => 'OBJECT',
            'properties' => [
                'size' => ['type' => 'STRING'],
                'color' => ['type' => 'STRING'],
                'size_options' => ['type' => 'ARRAY', 'items' => ['type' => 'STRING']],
                'color_options' => ['type' => 'ARRAY', 'items' => ['type' => 'STRING']],
            ],
            'required' => ['size', 'color', 'size_options', 'color_options'],
        ];

        // Classic keys (AIza…) authenticate with the x-goog-api-key header; the
        // newer "auth keys" (AQ.…) are Bearer tokens.
        $headers = ['content-type' => 'application/json'];
        if (str_starts_with($key, 'AQ.')) {
            $headers['Authorization'] = 'Bearer '.$key;
        } else {
            $headers['x-goog-api-key'] = $key;
        }

        try {
            $resp = Http::withHeaders($headers)
                ->timeout(25)
                ->post($url, [
                    'system_instruction' => ['parts' => [['text' => $system]]],
                    'contents' => [['role' => 'user', 'parts' => [['text' => $user]]]],
                    'generationConfig' => [
                        'temperature' => 0,
                        'maxOutputTokens' => 600,
                        'responseMimeType' => 'application/json',
                        'responseSchema' => $schema,
                    ],
                ]);
        } catch (\Throwable $e) {
            Log::warning('Gemini request failed: '.$e->getMessage());
            return null;
        }

        if (! $resp->ok()) {
            Log::warning('Gemini HTTP '.$resp->status().': '.$resp->body());
            return null;
        }

        $text = $resp->json('candidates.0.content.parts.0.text', '');
        return $this->parse($text);
    }

    /** Anthropic (Claude) — used only if no Gemini key is configured. */
    private function viaAnthropic(string $system, string $user): ?array
    {
        $key = config('services.anthropic.key');
        $model = config('services.anthropic.model', 'claude-opus-4-8');

        $schema = [
            'type' => 'object',
            'properties' => [
                'size' => ['type' => 'string'],
                'color' => ['type' => 'string'],
                'size_options' => ['type' => 'array', 'items' => ['type' => 'string']],
                'color_options' => ['type' => 'array', 'items' => ['type' => 'string']],
            ],
            'required' => ['size', 'color', 'size_options', 'color_options'],
            'additionalProperties' => false,
        ];

        try {
            $resp = Http::withHeaders([
                'x-api-key' => $key,
                'anthropic-version' => '2023-06-01',
                'content-type' => 'application/json',
            ])->timeout(25)->post('https://api.anthropic.com/v1/messages', [
                'model' => $model,
                'max_tokens' => 600,
                'system' => $system,
                'output_config' => ['format' => ['type' => 'json_schema', 'schema' => $schema]],
                'messages' => [['role' => 'user', 'content' => $user]],
            ]);
        } catch (\Throwable $e) {
            Log::warning('Anthropic request failed: '.$e->getMessage());
            return null;
        }

        if (! $resp->ok()) {
            Log::warning('Anthropic HTTP '.$resp->status().': '.$resp->body());
            return null;
        }

        $text = '';
        foreach (($resp->json('content') ?? []) as $block) {
            if (($block['type'] ?? '') === 'text') {
                $text = (string) ($block['text'] ?? '');
                break;
            }
        }
        return $this->parse($text);
    }

    /** Parse the model's JSON reply into a clean, normalised array. */
    private function parse(?string $text): ?array
    {
        $text = trim(preg_replace('/^```(?:json)?|```$/m', '', (string) $text));
        $parsed = json_decode($text, true);
        if (! is_array($parsed)) {
            return null;
        }

        $clean = fn ($v) => array_values(array_filter(array_map(
            fn ($s) => trim((string) $s),
            is_array($v) ? $v : []
        ), fn ($s) => $s !== '' && mb_strlen($s) <= 40));

        return [
            'size' => trim((string) ($parsed['size'] ?? '')),
            'color' => trim((string) ($parsed['color'] ?? '')),
            'size_options' => $clean($parsed['size_options'] ?? []),
            'color_options' => $clean($parsed['color_options'] ?? []),
        ];
    }
}
