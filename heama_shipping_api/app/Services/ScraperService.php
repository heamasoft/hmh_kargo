<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Fetches a product page server-side and extracts title/image/price/currency.
 * Servers aren't bound by browser same-origin rules, so this works for both the
 * web and native apps. It reads Open Graph meta tags first, then JSON-LD Product
 * data — the structured info most storefronts embed for SEO.
 */
class ScraperService
{
    /**
     * The Shein storefront the app browses: the Arabic-English site, shipping
     * to the UAE, priced in dollars. Mirrors lib/utils/store_region.dart — read
     * from the same shop as the shopper, or the page answers with another
     * storefront's listing, which carries another title and another price.
     */
    private const SHEIN_SITE = 'ar-en';
    private const SHEIN_COUNTRY = 'AE';
    private const SHEIN_CURRENCY = 'USD';

    /**
     * @return array{title:?string, image:?string, price:?float, currency:?string}
     */
    public function fetch(string $url): array
    {
        try {
            $url = $this->pinStorefront($url);
            $host = strtolower((string) parse_url($url, PHP_URL_HOST));

            $request = Http::withHeaders([
                'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
                    .'(KHTML, like Gecko) Chrome/124.0 Safari/537.36',
                'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                'Accept-Language' => 'en-US,en;q=0.9',
            ])->timeout(15);

            // The storefront in the address is not enough on its own: Shein
            // keeps the shopper's currency in a cookie, as the app's browser
            // does when it opens the store.
            if (str_contains($host, 'shein.')) {
                $request = $request->withCookies(['currency' => self::SHEIN_CURRENCY], $host);
            }

            $response = $request->get($url);

            if ($response->failed()) {
                return $this->empty();
            }

            return $this->parse($response->body());
        } catch (\Throwable $e) {
            Log::info('Scrape failed', ['url' => $url, 'error' => $e->getMessage()]);
            return $this->empty();
        }
    }

    /**
     * Puts a Shein link on the storefront the app browses, as the app does
     * before it opens one: the site segment in the path, and the country and
     * currency in the address. Everything else is left exactly as it came.
     */
    private function pinStorefront(string $url): string
    {
        $parts = parse_url($url);
        $host = strtolower($parts['host'] ?? '');
        // Share links name no product yet — they are resolved before this.
        if (! str_contains($host, 'shein.') || str_starts_with($host, 'onelink.')) {
            return $url;
        }

        $segments = array_values(array_filter(explode('/', $parts['path'] ?? ''), fn ($s) => $s !== ''));
        // A storefront segment is a short code — "ar-en", "us", "de" — where a
        // product's is its whole name. Swap one, add one where there is none.
        if (! empty($segments) && preg_match('/^[a-z]{2}(-[a-z]{2})?$/i', $segments[0])) {
            $segments[0] = self::SHEIN_SITE;
        } else {
            array_unshift($segments, self::SHEIN_SITE);
        }

        parse_str($parts['query'] ?? '', $query);
        $query['countryCode'] = self::SHEIN_COUNTRY;
        $query['currency'] = self::SHEIN_CURRENCY;

        return ($parts['scheme'] ?? 'https').'://'.$parts['host']
            .'/'.implode('/', $segments)
            .'?'.http_build_query($query);
    }

    private function parse(string $html): array
    {
        $meta = $this->metaTags($html);

        $title = $meta['og:title'] ?? $this->documentTitle($html);
        $image = $meta['og:image'] ?? $meta['twitter:image'] ?? null;
        $price = $meta['product:price:amount'] ?? $meta['og:price:amount'] ?? null;
        $currency = $meta['product:price:currency'] ?? $meta['og:price:currency'] ?? null;

        if (! $price) {
            $ld = $this->jsonLd($html);
            $title = $title ?: $ld['title'];
            $image = $image ?: $ld['image'];
            $price = $price ?: $ld['price'];
            $currency = $currency ?: $ld['currency'];
        }

        return [
            'title' => $title ? trim(html_entity_decode($title)) : null,
            'image' => $image ?: null,
            'price' => $this->toFloat($price),
            'currency' => $currency ? strtoupper(trim($currency)) : null,
        ];
    }

    /** Builds a map of meta property/name => content. */
    private function metaTags(string $html): array
    {
        $map = [];
        if (! preg_match_all('/<meta\b[^>]*>/i', $html, $tags)) {
            return $map;
        }
        foreach ($tags[0] as $tag) {
            $key = $this->attr($tag, 'property') ?? $this->attr($tag, 'name');
            $content = $this->attr($tag, 'content');
            if ($key && $content !== null) {
                $map[strtolower($key)] = $content;
            }
        }
        return $map;
    }

    private function attr(string $tag, string $name): ?string
    {
        if (preg_match('/\b'.preg_quote($name, '/').'\s*=\s*"([^"]*)"/i', $tag, $m)) {
            return $m[1];
        }
        if (preg_match("/\\b".preg_quote($name, '/')."\\s*=\\s*'([^']*)'/i", $tag, $m)) {
            return $m[1];
        }
        return null;
    }

    private function documentTitle(string $html): ?string
    {
        return preg_match('/<title\b[^>]*>(.*?)<\/title>/is', $html, $m) ? trim($m[1]) : null;
    }

    /** Extracts title/image/price/currency from JSON-LD Product blocks. */
    private function jsonLd(string $html): array
    {
        $out = ['title' => null, 'image' => null, 'price' => null, 'currency' => null];
        if (! preg_match_all('/<script[^>]*type=["\']application\/ld\+json["\'][^>]*>(.*?)<\/script>/is', $html, $blocks)) {
            return $out;
        }

        foreach ($blocks[1] as $json) {
            $data = json_decode(trim($json), true);
            if (! is_array($data)) {
                continue;
            }
            // Could be a single object, a list, or a @graph container.
            $candidates = isset($data['@graph']) && is_array($data['@graph'])
                ? $data['@graph']
                : (array_is_list($data) ? $data : [$data]);

            foreach ($candidates as $node) {
                if (! is_array($node)) {
                    continue;
                }
                $type = $node['@type'] ?? null;
                $isProduct = $type === 'Product'
                    || (is_array($type) && in_array('Product', $type, true));
                if (! $isProduct) {
                    continue;
                }

                $out['title'] ??= $node['name'] ?? null;
                if (! $out['image'] && isset($node['image'])) {
                    $img = $node['image'];
                    $out['image'] = is_string($img) ? $img : ($img['url'] ?? ($img[0] ?? null));
                }
                $offers = $node['offers'] ?? null;
                if ($offers) {
                    $offer = array_is_list($offers) ? ($offers[0] ?? []) : $offers;
                    $out['price'] ??= $offer['price'] ?? ($offer['lowPrice'] ?? null);
                    $out['currency'] ??= $offer['priceCurrency'] ?? null;
                }
                if ($out['price']) {
                    return $out;
                }
            }
        }
        return $out;
    }

    private function toFloat($value): ?float
    {
        if ($value === null) {
            return null;
        }
        $cleaned = preg_replace('/[^0-9.]/', '', (string) $value);
        return $cleaned === '' ? null : (float) $cleaned;
    }

    private function empty(): array
    {
        return ['title' => null, 'image' => null, 'price' => null, 'currency' => null];
    }
}
