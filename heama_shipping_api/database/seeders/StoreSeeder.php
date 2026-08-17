<?php

namespace Database\Seeders;

use App\Models\Store;
use Illuminate\Database\Seeder;

class StoreSeeder extends Seeder
{
    public function run(): void
    {
        // Generic capture rules: try Open Graph / JSON-LD first (works on most
        // storefronts), with per-site overrides added later as we tune them.
        $generic = [
            'strategy' => 'og+jsonld',
            'title' => ["meta[property='og:title']@content", 'h1'],
            'image' => ["meta[property='og:image']@content"],
            'price' => [
                "meta[property='product:price:amount']@content",
                "[itemprop='price']@content",
            ],
            'currency' => [
                "meta[property='product:price:currency']@content",
                "[itemprop='priceCurrency']@content",
            ],
        ];

        $stores = [
            ['key' => 'shein', 'name' => 'Shein', 'glyph' => 'SH', 'glyph_color' => '#000000', 'category_key' => 'catFashion', 'base_url' => 'https://www.shein.com', 'currency' => 'USD', 'region' => 'international', 'sort_order' => 1],
            ['key' => 'temu', 'name' => 'Temu', 'glyph' => 'TM', 'glyph_color' => '#FF6A00', 'category_key' => 'catEverything', 'base_url' => 'https://www.temu.com', 'currency' => 'USD', 'region' => 'international', 'sort_order' => 2],
            ['key' => 'zara', 'name' => 'Zara', 'glyph' => 'ZA', 'glyph_color' => '#1A1A1A', 'category_key' => 'catApparel', 'base_url' => 'https://www.zara.com', 'currency' => 'USD', 'region' => 'international', 'sort_order' => 3],
            ['key' => 'aliexpress', 'name' => 'AliExpress', 'glyph' => 'AE', 'glyph_color' => '#E62E2E', 'category_key' => 'catGadgets', 'base_url' => 'https://www.aliexpress.com', 'currency' => 'USD', 'region' => 'international', 'sort_order' => 4],
            ['key' => 'hm', 'name' => 'H&M', 'glyph' => 'HM', 'glyph_color' => '#0530AD', 'category_key' => 'catApparel', 'base_url' => 'https://www2.hm.com', 'currency' => 'USD', 'region' => 'international', 'sort_order' => 5],
            ['key' => 'amazon', 'name' => 'Amazon', 'glyph' => 'AZ', 'glyph_color' => '#232F3E', 'category_key' => 'catEverything', 'base_url' => 'https://www.amazon.com', 'currency' => 'USD', 'region' => 'international', 'sort_order' => 6],
            ['key' => 'trendyol', 'name' => 'Trendyol', 'glyph' => 'TR', 'glyph_color' => '#FF6000', 'category_key' => 'catFashion', 'base_url' => 'https://www.trendyol.com', 'currency' => 'TRY', 'region' => 'turkiye', 'sort_order' => 7],
            ['key' => 'hepsiburada', 'name' => 'Hepsiburada', 'glyph' => 'HB', 'glyph_color' => '#F27A1A', 'category_key' => 'catTech', 'base_url' => 'https://www.hepsiburada.com', 'currency' => 'TRY', 'region' => 'turkiye', 'sort_order' => 8],
            ['key' => 'lcwaikiki', 'name' => 'LC Waikiki', 'glyph' => 'LC', 'glyph_color' => '#2B2B2B', 'category_key' => 'catApparel', 'base_url' => 'https://www.lcwaikiki.com', 'currency' => 'TRY', 'region' => 'turkiye', 'sort_order' => 9],
        ];

        foreach ($stores as $store) {
            Store::updateOrCreate(
                ['key' => $store['key']],
                array_merge($store, [
                    'capture_rules' => $generic,
                    'active' => true,
                    // Customer is charged in IQD for Shein, USD for every other store.
                    'charge_currency' => $store['key'] === 'shein' ? 'IQD' : 'USD',
                ]),
            );
        }
    }
}
