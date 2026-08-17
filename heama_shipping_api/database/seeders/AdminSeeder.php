<?php

namespace Database\Seeders;

use App\Models\Cart;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        $email = env('ADMIN_EMAIL', 'admin@heama-soft.com');
        $password = env('ADMIN_PASSWORD', 'password');

        $admin = User::updateOrCreate(
            ['email' => $email],
            [
                'name' => 'Heama Admin',
                'is_admin' => true,
                'password' => Hash::make($password),
                'email_verified_at' => now(),
            ],
        );

        Wallet::firstOrCreate(['user_id' => $admin->id]);
        Cart::firstOrCreate(['user_id' => $admin->id]);
    }
}
