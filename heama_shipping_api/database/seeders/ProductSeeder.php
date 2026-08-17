<?php

namespace Database\Seeders;

use App\Models\Product;
use App\Models\Store;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $shein = Store::where('key', 'shein')->value('id');

        $colors = [
            ['name' => 'Lavender', 'hex' => '#C9B6E8'],
            ['name' => 'Rose', 'hex' => '#F0C8D8'],
            ['name' => 'Sage', 'hex' => '#BCD3C4'],
            ['name' => 'Sand', 'hex' => '#E8D9B0'],
            ['name' => 'Black', 'hex' => '#1A1A1A'],
        ];
        $sizes = ['S', 'M', 'L', 'XL', 'XXL'];

        $products = [
            ['key' => 'top', 'name' => "Ribbed Knit Short Sleeve Summer Top", 'category' => 'tops', 'price' => 7.80, 'old' => 12.00, 'seed' => 'heama-top', 'grad' => ['#C9B6E8', '#E9C7D6'], 'reviews' => '2,318', 'trending' => true, 'sort' => 1],
            ['key' => 'dress', 'name' => 'Floral Print Belted Midi Dress', 'category' => 'dresses', 'price' => 13.50, 'old' => 22.00, 'seed' => 'hm-dress', 'grad' => ['#F0C8D8', '#E9C7D6'], 'reviews' => '1,904', 'trending' => true, 'sort' => 2],
            ['key' => 'blouse', 'name' => 'Puff Sleeve Square Neck Blouse', 'category' => 'tops', 'price' => 9.20, 'old' => 15.00, 'seed' => 'hm-blouse', 'grad' => ['#CFE0F5', '#B9D0EF'], 'reviews' => '873', 'trending' => true, 'sort' => 3],
            ['key' => 'jeans', 'name' => 'High Waist Wide Leg Jeans', 'category' => 'bottoms', 'price' => 16.00, 'old' => 26.00, 'seed' => 'hm-jeans', 'grad' => ['#B9C4DD', '#9FB0CF'], 'reviews' => '4,120', 'trending' => true, 'sort' => 4],
            ['key' => 'cardigan', 'name' => 'Knit Button Front Cardigan', 'category' => 'tops', 'price' => 11.40, 'old' => 19.00, 'seed' => 'hm-cardi', 'grad' => ['#E8D9B0', '#DDC99A'], 'reviews' => '612', 'trending' => false, 'sort' => 5],
            ['key' => 'skirt', 'name' => 'Pleated High Waist Mini Skirt', 'category' => 'bottoms', 'price' => 8.50, 'old' => 14.00, 'seed' => 'hm-skirt', 'grad' => ['#BCD3C4', '#9FC7B0'], 'reviews' => '2,004', 'trending' => false, 'sort' => 6],
        ];

        foreach ($products as $p) {
            Product::updateOrCreate(['key' => $p['key']], [
                'store_id' => $shein,
                'name' => $p['name'],
                'category' => $p['category'],
                'source_url' => "https://www.shein.com/{$p['key']}-p-000.html",
                'image_url' => "https://picsum.photos/seed/{$p['seed']}/640/700",
                'source_price' => $p['price'],
                'source_currency' => 'USD',
                'old_price' => $p['old'],
                'rating' => 4.6,
                'reviews' => $p['reviews'],
                'gradient' => $p['grad'],
                'colors' => $colors,
                'sizes' => $sizes,
                'trending' => $p['trending'],
                'sort_order' => $p['sort'],
                'active' => true,
            ]);
        }
    }
}
