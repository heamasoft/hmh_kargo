<?php

namespace Database\Seeders;

use App\Models\Setting;
use Illuminate\Database\Seeder;

class SettingSeeder extends Seeder
{
    public function run(): void
    {
        $defaults = [
            'markup_percent' => 15,       // added on top of converted price
            'service_fee_percent' => 10,  // Heama fee on items subtotal
            'shipping_flat_iqd' => 9000,  // flat shipping estimate
            'rounding_step' => 250,       // round IQD prices up to this step
        ];

        foreach ($defaults as $key => $value) {
            Setting::updateOrCreate(['key' => $key], ['value' => (string) $value]);
        }
    }
}
