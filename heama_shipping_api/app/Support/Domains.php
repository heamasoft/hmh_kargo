<?php

namespace App\Support;

/**
 * Host comparison for matching a pasted URL to a configured store.
 *
 * Stores are configured with one storefront URL, but the same shop serves many
 * hosts: Shein alone answers on `ar.shein.com`, `m.shein.com`, `www.shein.com`
 * and `onelink.shein.com` for app share links. Comparing full hosts means a
 * store configured as `ar.shein.com` fails to match any of the others, and the
 * URL falls through to the "unknown store" defaults — wrong charge currency,
 * and the store's free-shipping rule skipped.
 *
 * Comparing the registrable domain instead makes every one of those hosts match
 * the one Shein row, while still keeping different shops apart.
 */
final class Domains
{
    /**
     * Second-level labels that are part of a public suffix rather than a name,
     * so `shein.co.uk` keeps three labels while `m.shein.com` keeps two.
     */
    private const PUBLIC_SECOND_LEVEL = ['co', 'com', 'net', 'org', 'gov', 'edu', 'ac'];

    /** The host of a URL, lowercased; '' when there isn't one. */
    public static function hostOf(string $url): string
    {
        return strtolower((string) parse_url($url, PHP_URL_HOST));
    }

    /**
     * The registrable part of a host: `m.shein.com` and `onelink.shein.com` both
     * reduce to `shein.com`. Hosts with fewer than two labels come back as-is.
     */
    public static function registrable(string $host): string
    {
        $host = strtolower(trim($host));
        $parts = array_values(array_filter(explode('.', $host), fn ($p) => $p !== ''));
        $count = count($parts);

        if ($count < 2) {
            return $host;
        }

        // `shein.co.uk` — a two-letter TLD after a public second level takes
        // three labels; `shein.com` takes two.
        if ($count >= 3
            && in_array($parts[$count - 2], self::PUBLIC_SECOND_LEVEL, true)
            && strlen($parts[$count - 1]) === 2) {
            return implode('.', array_slice($parts, -3));
        }

        return implode('.', array_slice($parts, -2));
    }

    /** True when both URLs belong to the same shop. */
    public static function sameSite(string $urlA, string $urlB): bool
    {
        $a = self::registrable(self::hostOf($urlA));
        $b = self::registrable(self::hostOf($urlB));

        return $a !== '' && $a === $b;
    }
}
