<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Turns a link shared from the Shein APP into the normal product URL.
 *
 * Shein's app share button gives an `onelink.shein.com/...` URL. That page
 * carries only an og:title and og:image — no price, no variants — and then
 * hands off by JavaScript to `api-shein.shein.com/h5/sharejump/appjump`,
 * whose only job is to fire `sheinlink://applink/goods/...` and open the app.
 *
 * The jump page does, however, embed a `shareInfo = {...}` JSON blob holding
 * the goods id and category, and builds the web product URL from it:
 *
 *     '/' + cleanedTitle + '-p-' + id + '-cat-' + catId + '.html'
 *
 * Neither share hop is captcha-protected, so we can read that blob server-side
 * and rebuild the URL. The product page itself we must NOT fetch — Shein
 * bounces server requests to /risk/challenge — but the app's WebView loads it
 * fine, and its scraper then reads price, colours and sizes as usual.
 */
class ShareLinkResolver
{
    private const UA = 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 '
        .'(KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';

    /**
     * Fallback storefront, as the jump page's own MOBILE_INDEX_URL. Prefer the
     * store's configured base_url when there is one: the WebView already holds a
     * session and currency cookies for that host, and landing on a cold one
     * earns a /risk/challenge captcha instead of the product.
     */
    private const MOBILE_INDEX_URL = 'https://m.shein.com';

    /**
     * Keeps the rebuilt URL storable — `source_url` is validated at 1024 chars,
     * and Shein titles run to several hundred characters that percent-encode to
     * three bytes each.
     */
    private const MAX_URL_LENGTH = 900;

    /** True when this looks like an app share link rather than a product page. */
    public function isShareLink(string $url): bool
    {
        $host = strtolower((string) parse_url($url, PHP_URL_HOST));
        $path = strtolower((string) parse_url($url, PHP_URL_PATH));

        return $host === 'onelink.shein.com'
            || $host === 'shein.top'
            || ($host === 'api-shein.shein.com' && str_contains($path, 'sharejump'));
    }

    /**
     * @param  string|null  $storeBaseUrl  the store's configured base_url, whose
     *                                     host the client is already browsing.
     * @return array{url:string, goods_id:?string, cat_id:?string, title:?string, image:?string}|null
     *                                     null when the link isn't a share link, or couldn't be resolved.
     */
    public function resolve(string $url, ?string $storeBaseUrl = null): ?array
    {
        if (! $this->isShareLink($url)) {
            return null;
        }

        try {
            $jumpUrl = $this->jumpUrlFor($url);
            if ($jumpUrl === null) {
                return null;
            }

            $html = $this->get($jumpUrl);
            if ($html === null) {
                return null;
            }

            $share = $this->shareInfo($html);
            if ($share === null) {
                return null;
            }

            $title = $this->str($share['title'] ?? null) ?: $this->str($share['shareTitle'] ?? null);
            $image = $this->str($share['img_url'] ?? null) ?: $this->str($share['shareImg'] ?? null);
            $index = $this->indexUrl($storeBaseUrl);

            // A shared CART points at a group of items, not one product, and has
            // its own landing page. Check this BEFORE the goods id, which a cart
            // share has no reason to carry.
            if ($this->isCartShare($share)) {
                $cartPath = $this->cartPath($share, $url);

                return $cartPath === null ? null : [
                    'kind' => 'cart',
                    'url' => $index.$cartPath,
                    'goods_id' => null,
                    'cat_id' => null,
                    'title' => $title,
                    'image' => $image,
                ];
            }

            // The jump page uses `id` for the goods id; `goodsId` appears on some
            // share types, so take whichever is filled.
            $goodsId = $this->str($share['goodsId'] ?? null) ?: $this->str($share['id'] ?? null);
            $catId = $this->str($share['cat_id'] ?? null) ?: $this->str($share['catId'] ?? null);
            if ($goodsId === null || $catId === null) {
                return null;
            }

            return [
                'kind' => 'product',
                'url' => $index.$this->goodsPath((string) $title, $goodsId, $catId, $index),
                'goods_id' => $goodsId,
                'cat_id' => $catId,
                'title' => $title,
                'image' => $image,
            ];
        } catch (\Throwable $e) {
            Log::info('Share link resolve failed', ['url' => $url, 'error' => $e->getMessage()]);

            return null;
        }
    }

    /**
     * The `appjump` URL that holds the shareInfo blob. An onelink page only
     * links to it, so that one needs fetching first.
     */
    private function jumpUrlFor(string $url): ?string
    {
        if (strtolower((string) parse_url($url, PHP_URL_HOST)) === 'api-shein.shein.com') {
            return $url;
        }

        $html = $this->get($url);
        if ($html === null) {
            return null;
        }

        if (! preg_match('~https://api-shein\.shein\.com/h5/sharejump/appjump\?[^"\'\s<>]+~i', $html, $m)) {
            return null;
        }

        return html_entity_decode($m[0], ENT_QUOTES | ENT_HTML5);
    }

    /** Pulls and decodes the `shareInfo = { ... }` object embedded in the page. */
    private function shareInfo(string $html): ?array
    {
        $at = strpos($html, 'shareInfo');
        if ($at === false) {
            return null;
        }
        $open = strpos($html, '{', $at);
        if ($open === false) {
            return null;
        }

        $raw = $this->jsonObjectAt($html, $open);
        if ($raw === null) {
            return null;
        }

        $data = json_decode($raw, true);

        return is_array($data) ? $data : null;
    }

    /**
     * Returns the balanced `{...}` starting at $start. String contents are
     * skipped so a brace inside a product title can't end the object early.
     */
    private function jsonObjectAt(string $html, int $start): ?string
    {
        $len = strlen($html);
        $depth = 0;
        $inString = false;
        $escaped = false;

        for ($i = $start; $i < $len; $i++) {
            $ch = $html[$i];

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
            } elseif ($ch === '{') {
                $depth++;
            } elseif ($ch === '}') {
                $depth--;
                if ($depth === 0) {
                    return substr($html, $start, $i - $start + 1);
                }
            }
        }

        return null;
    }

    /**
     * Rebuilds the product path exactly as the jump page's getGoodsUrl() does:
     * strip a set of punctuation, whitespace and CJK from the title, replace the
     * first slash with a dash, then append `-p-<id>-cat-<catId>.html`.
     *
     * The name is percent-encoded (Shein's page leaves that to the browser) and
     * trimmed if the URL would grow past what we can store.
     */
    /**
     * True when the link shares a CART rather than a product. `share_type` is
     * the reliable signal — a product share reads "goods". The deep link is a
     * secondary check for share types we haven't seen.
     */
    private function isCartShare(array $share): bool
    {
        $type = strtolower($this->str($share['share_type'] ?? null) ?? '');
        if ($type !== '') {
            return str_contains($type, 'cart') || str_contains($type, 'bag');
        }

        $deep = strtolower($this->str($share['deepLink'] ?? null) ?? '');

        return $deep !== '' && str_contains($deep, 'cart');
    }

    /**
     * Rebuilds the shared-cart landing path exactly as the jump page's
     * toCartPage() does. Returns null when the group id is missing, since the
     * page is meaningless without it.
     */
    private function cartPath(array $share, string $originalUrl): ?string
    {
        $groupId = $this->str($share['id'] ?? null) ?: $this->str($share['groupIdToken'] ?? null);
        if ($groupId === null) {
            return null;
        }

        // `shc` rides on the share link itself; shareInfo echoes it on some types.
        parse_str((string) parse_url($originalUrl, PHP_URL_QUERY), $query);
        $shc = $this->str($query['shc'] ?? null) ?: $this->str($share['shareCode'] ?? null);

        $params = array_filter([
            'shc' => $shc,
            'group_id' => $groupId,
            'local_country' => $this->str($share['localcountry'] ?? null),
            'url_from' => $this->str($share['url_from'] ?? null),
            'cart_share' => $this->str($share['cart_share'] ?? null),
        ], fn ($v) => $v !== null);

        return '/cart/share/landing?'.http_build_query($params);
    }

    /** scheme://host of the store's base_url, or Shein's own mobile storefront. */
    private function indexUrl(?string $storeBaseUrl): string
    {
        $parts = $storeBaseUrl === null ? false : parse_url($storeBaseUrl);
        if (! is_array($parts) || empty($parts['host'])) {
            return self::MOBILE_INDEX_URL;
        }

        return ($parts['scheme'] ?? 'https').'://'.$parts['host'];
    }

    private function goodsPath(string $title, string $goodsId, string $catId, string $indexUrl): string
    {
        $name = preg_replace('/[><#@$\s\'"%+&]|[\x{4e00}-\x{9fa5}]/u', '', $title) ?? '';

        $slash = strpos($name, '/');
        if ($slash !== false) {
            $name = substr_replace($name, '-', $slash, 1);
        }

        $suffix = '-p-'.$goodsId.'-cat-'.$catId.'.html';
        $budget = self::MAX_URL_LENGTH - strlen($indexUrl) - strlen($suffix) - 1;

        $encoded = rawurlencode($name);
        while ($name !== '' && strlen($encoded) > $budget) {
            // Trim whole characters, not bytes — cutting mid-sequence would
            // leave a broken UTF-8 tail in the slug.
            $name = mb_substr($name, 0, max(0, mb_strlen($name) - 8));
            $encoded = rawurlencode($name);
        }

        return '/'.$encoded.$suffix;
    }

    private function get(string $url): ?string
    {
        $response = Http::withHeaders([
            'User-Agent' => self::UA,
            'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language' => 'en-US,en;q=0.9',
        ])->timeout(15)->get($url);

        return $response->failed() ? null : $response->body();
    }

    /** Normalises a JSON value to a non-empty string, or null. */
    private function str($value): ?string
    {
        if ($value === null || is_array($value)) {
            return null;
        }
        $s = trim((string) $value);

        return $s === '' ? null : $s;
    }
}
