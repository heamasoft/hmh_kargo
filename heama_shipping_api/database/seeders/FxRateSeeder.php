<?php

namespace Database\Seeders;

use App\Models\FxRate;
use Illuminate\Database\Seeder;

class FxRateSeeder extends Seeder
{
    public function run(): void
    {
        // Demo rates (IQD per 1 unit). Update these from the admin panel.
        $rates = [
            'USD' => 1500.0,
            'TRY' => 40.0,
            'EUR' => 1600.0,
        ];

        foreach ($rates as $currency => $rate) {
            FxRate::updateOrCreate(
                ['currency' => $currency],
                ['rate_to_iqd' => $rate, 'updated_at' => now(), 'created_at' => now()],
            );
        }
    }
}
