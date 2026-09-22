<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Turns a link shared from the Trendyol APP into something the shop can use.
 *
 * Trendyol's share button gives a `ty.gl/...` short link. It redirects through
 * Adjust (`*.adj.st`) and ends in an `intent://` hand-off to the Trendyol app,
 * which a WebView refuses — so loading it directly dead-ends. The Adjust hop
 * carries the real web page in its `adjust_redirect` parameter, though, so we
 * stop there and read that instead.
 *
 * Two kinds come out of the app:
 *  - a PRODUCT (`…-p-<id>`) — handed back as a URL for the normal capture;
 *  - a COLLECTION (`/koleksiyonlar/…`) — Trendyol has no cart sharing, so
 *    shoppers share a collection instead. Its page embeds every product in a
 *    `"products":[…]` array server-side, so the items are read here directly,
 *    no browser needed.
 *
 * A collection stores the product, not the size the shopper had in mind, so
 * items come back with the sizes Trendyol offers and none chosen.
 *
 * Trendyol geo-gates visitors outside Turkey to a country picker; the Turkey
 * cookies below are the same ones the app's WebView uses to stay on the
 * Turkish storefront, priced in TL.
 */
class TrendyolLinkResolver
{
    private const UA = 'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 '
        .'(KHTML, like Gecko) Chrome/125.0.0.0 Mobile Safari/537.36';

    private const TURKEY_COOKIES = 'storefrontId=1; countryCode=TR; language=tr; '
        .'LanguageType=tr; int_locale=tr-TR';

    private const WEB = 'https://www.trendyol.com';

    /**
     * Why the last [resolve] gave up, in a few plain words — returned with a
     * failed /resolve so the reason shows up in the app's own log instead of
     * having to be guessed (Trendyol blocking the server looks, from outside,
     * exactly like a link it can't read).
     */
    public ?string $lastReason = null;

    /** HTTP status of the last page fetched by [get]. */
    private ?int $lastStatus = null;

    /** True when this is a Trendyol app link or a collection page. */
    public function handles(string $url): bool
    {
        $host = strtolower((string) parse_url($url, PHP_URL_HOST));
        $path = strtolower((string) parse_url($url, PHP_URL_PATH));

        return $host === 'ty.gl'
            || (str_ends_with($host, 'trendyol.com') && str_contains($path, '/koleksiyonlar/'));
    }

    /**
     * @return array{kind:string, url:string, title:?string, items?:array}|null
     *         null when the link can't be followed to a product or collection.
     */
    public function resolve(string $url): ?array
    {
        $this->lastReason = null;
        if (! $this->handles($url)) {
            $this->lastReason = 'not a Trendyol link';

            return null;
        }

        try {
            $web = $this->webUrlFor($url);
            if ($web === null) {
                // webUrlFor has already said which hop failed.
                return null;
            }

            $path = (string) parse_url($web, PHP_URL_PATH);

            if (preg_match('~-p-\d+~', $path)) {
                return ['kind' => 'product', 'url' => $web, 'title' => null];
            }

            if (str_contains($path, '/koleksiyonlar/')) {
                $html = $this->get($web);
                $products = $html === null ? null : $this->productsIn($html);

                if ($products === null) {
                    if ($html === null) {
                        $this->lastReason = 'collection page refused: HTTP '.($this->lastStatus ?? '?');
                    } else {
                        // Usually a country picker or a bot check instead of the page.
                        $title = preg_match('~<title>([^<]{0,90})~i', $html, $t) ? trim($t[1]) : '?';
                        $this->lastReason = 'no products on the collection page ('
                            .strlen($html).' bytes, title "'.html_entity_decode($title).'")';
                    }

                    // Trendyol refuses data-centre IPs (HTTP 403 from the live
                    // server) but serves the shopper's phone normally — so hand
                    // the page over for the app to read in its WebView.
                    return [
                        'kind' => 'collection',
                        'url' => $web,
                        'title' => null,
                        'items' => [],
                        'read_on_device' => true,
                    ];
                }

                return [
                    'kind' => 'collection',
                    'url' => $web,
                    'title' => $this->collectionName($html),
                    'items' => array_values(array_filter(array_map(
                        fn ($p) => $this->item($p),
                        $products,
                    ))),
                ];
            }

            $this->lastReason = 'link leads to neither a product nor a collection: '.$path;

            return null;
        } catch (\Throwable $e) {
            Log::info('Trendyol link resolve failed', ['url' => $url, 'error' => $e->getMessage()]);
            $this->lastReason = 'error: '.mb_substr($e->getMessage(), 0, 160);

            return null;
        }
    }

    /**
     * The trendyol.com page a link points at. A `ty.gl` link is read one hop at
     * a time — never followed to the end, where it becomes an app `intent://`.
     */
    private function webUrlFor(string $url): ?string
    {
        $host = strtolower((string) parse_url($url, PHP_URL_HOST));
        if (str_ends_with($host, 'trendyol.com')) {
            return $url;
        }

        $next = $url;
        for ($hop = 0; $hop < 4; $hop++) {
            $response = Http::withHeaders(['User-Agent' => self::UA])
                ->withOptions(['allow_redirects' => false])
                ->timeout(15)
                ->get($next);

            $location = $response->header('Location');
            if ($location === '') {
                $this->lastReason = 'hop '.($hop + 1).' ('.parse_url($next, PHP_URL_HOST)
                    .') gave HTTP '.$response->status().' with no redirect';

                return null;
            }

            $web = $this->webUrlInRedirect($location);
            if ($web !== null) {
                return $web;
            }

            // Not there yet (e.g. ty.gl → adj.st) — take the next hop.
            if (! preg_match('~^https?://~i', $location)) {
                $this->lastReason = 'hop '.($hop + 1).' went to an app link with no web page: '
                    .mb_substr($location, 0, 60);

                return null;
            }
            $next = $location;
        }

        $this->lastReason = 'too many redirects before reaching trendyol.com';

        return null;
    }

    /**
     * Pulls the trendyol.com web URL out of a redirect target: either the URL
     * itself, Adjust's `adjust_redirect`, or an intent's browser fallback.
     */
    public function webUrlInRedirect(string $location): ?string
    {
        $host = strtolower((string) parse_url($location, PHP_URL_HOST));
        if (str_ends_with($host, 'trendyol.com')) {
            return $this->clean($location);
        }

        parse_str((string) parse_url($location, PHP_URL_QUERY), $query);
        if (! empty($query['adjust_redirect']) && is_string($query['adjust_redirect'])) {
            return $this->clean($query['adjust_redirect']);
        }

        if (preg_match('~S\.browser_fallback_url=([^;]+)~', $location, $m)) {
            return $this->clean(rawurldecode($m[1]));
        }

        return null;
    }

    /** Drops Adjust/UTM tracking so the stored link is the plain page. */
    private function clean(string $url): string
    {
        $parts = parse_url($url);
        parse_str($parts['query'] ?? '', $query);
        $query = array_filter(
            $query,
            fn ($k) => ! preg_match('/^(adjust_|utm_|link_)/', (string) $k),
            ARRAY_FILTER_USE_KEY,
        );

        return self::WEB.($parts['path'] ?? '/').($query ? '?'.http_build_query($query) : '');
    }

    /** Decodes the `"products":[…]` array embedded in a collection page. */
    public function productsIn(string $html): ?array
    {
        $at = strpos($html, '"products":[');
        if ($at === false) {
            return null;
        }

        $raw = $this->balancedAt($html, $at + strlen('"products":'), '[', ']');
        if ($raw === null) {
            return null;
        }

        $data = json_decode($raw, true);

        return is_array($data) ? $data : null;
    }

    /** One shop row from a Trendyol product object, or null if it lacks a price. */
    public function item(array $p): ?array
    {
        $price = $p['sanitizedPrice']['finalPrice']['value'] ?? null;
        if (! is_numeric($price) || (float) $price <= 0) {
            return null;
        }

        $path = (string) ($p['url'] ?? '');

        return [
            'title' => trim((string) ($p['name'] ?? '')),
            'brand' => $p['brand']['name'] ?? null,
            'image' => $p['imageUrl'] ?? ($p['images'][0] ?? ''),
            'price' => (float) $price,
            'currency' => $this->currency((string) ($p['sanitizedPrice']['currency'] ?? '')),
            'url' => $path === '' ? '' : self::WEB.$path,
            'sku' => isset($p['id']) ? (string) $p['id'] : null,
            'in_stock' => (bool) ($p['inStock'] ?? true),
            'sizes' => $this->sizes($p),
        ];
    }

    /** Every size value Trendyol lists across the product's listings. */
    private function sizes(array $p): array
    {
        $values = [];
        foreach ($p['merchantListings'] ?? [] as $listing) {
            foreach ($listing['variants'] ?? [] as $variant) {
                foreach ($variant['variantAttributes'] ?? [] as $attr) {
                    $v = trim((string) ($attr['attributeValue'] ?? $attr['value'] ?? ''));
                    if ($v !== '') {
                        $values[$v] = true;
                    }
                }
            }
        }

        return array_keys($values);
    }

    /** Trendyol writes lira as "TL"; the rest of the system speaks ISO "TRY". */
    private function currency(string $c): string
    {
        $c = strtoupper(trim($c));

        return ($c === '' || $c === 'TL') ? 'TRY' : $c;
    }

    private function collectionName(string $html): ?string
    {
        return preg_match('~"collectionName":"([^"]{1,120})"~', $html, $m)
            ? json_decode('"'.$m[1].'"')
            : null;
    }

    /**
     * Returns the balanced $open…$close run starting at $start, skipping string
     * contents so a bracket inside a product name can't end it early.
     */
    private function balancedAt(string $s, int $start, string $open, string $close): ?string
    {
        $len = strlen($s);
        if ($start >= $len || $s[$start] !== $open) {
            return null;
        }
        $depth = 0;
        $inString = false;
        $escaped = false;

        for ($i = $start; $i < $len; $i++) {
            $ch = $s[$i];
            if ($inString) {
                if ($escaped) {
                    $escaped = false;
                } elseif ($ch === '\\') {
                    $escaped = true;
                } elseif ($ch === '"') {
                    $inString = false;
                }

                continue;
            }
            if ($ch === '"') {
                $inString = true;
            } elseif ($ch === $open) {
                $depth++;
            } elseif ($ch === $close) {
                $depth--;
                if ($depth === 0) {
                    return substr($s, $start, $i - $start + 1);
                }
            }
        }

        return null;
    }

    private function get(string $url): ?string
    {
        $response = Http::withHeaders([
            'User-Agent' => self::UA,
            'Accept' => 'text/html,application/xhtml+xml',
            'Accept-Language' => 'tr-TR,tr;q=0.9',
            'Cookie' => self::TURKEY_COOKIES,
        ])->timeout(15)->get($url);

        $this->lastStatus = $response->status();

        return $response->failed() ? null : $response->body();
    }
}
