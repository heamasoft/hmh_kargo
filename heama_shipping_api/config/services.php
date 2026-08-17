<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'key' => env('POSTMARK_API_KEY'),
    ],

    'resend' => [
        'key' => env('RESEND_API_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    // Meta WhatsApp Cloud API — used to deliver login OTP codes.
    'whatsapp' => [
        'token' => env('WHATSAPP_TOKEN'),
        'phone_number_id' => env('WHATSAPP_PHONE_NUMBER_ID'),
        'template' => env('WHATSAPP_OTP_TEMPLATE', 'heama_otp'),
        'lang' => env('WHATSAPP_OTP_LANG', 'en'),
        'api_version' => env('WHATSAPP_API_VERSION', 'v21.0'),
        // Country code prefixed to LOCAL numbers before sending (Iraq = 964).
        'country_code' => env('WHATSAPP_COUNTRY_CODE', '964'),
    ],

    // AI variant reader — reads a product page's variant text and returns the
    // selected colour/size when the app's own heuristics come up short. Provider
    // priority: Groq -> Gemini -> Anthropic. If none is configured the app just
    // uses its heuristics.
    // Free Groq key (no card): https://console.groq.com/keys
    'groq' => [
        'key' => env('GROQ_API_KEY'),
        'model' => env('GROQ_MODEL', 'llama-3.1-8b-instant'),
    ],

    'gemini' => [
        'key' => env('GEMINI_API_KEY'),
        'model' => env('GEMINI_MODEL', 'gemini-2.0-flash'),
    ],

    'anthropic' => [
        'key' => env('ANTHROPIC_API_KEY'),
        'model' => env('ANTHROPIC_MODEL', 'claude-opus-4-8'),
    ],

    // OTP behaviour knobs.
    'otp' => [
        'length' => (int) env('OTP_LENGTH', 4),
        'ttl_seconds' => (int) env('OTP_TTL_SECONDS', 300),
        'resend_cooldown' => (int) env('OTP_RESEND_COOLDOWN', 60),
        'max_attempts' => (int) env('OTP_MAX_ATTEMPTS', 5),
        // Demo bypass code (matches the Flutter prototype). Leave null in prod.
        'demo_code' => env('OTP_DEMO_CODE'),
    ],

];
