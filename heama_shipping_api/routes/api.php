<?php

use App\Http\Controllers\Api\AddressController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\ApprovalController;
use App\Http\Controllers\Api\AiController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CaptureController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\DeviceTokenController;
use App\Http\Controllers\Api\FavoriteController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\StockController;
use App\Http\Controllers\Api\StoreController;
use App\Http\Controllers\Api\WalletController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Heama API (v1)
|--------------------------------------------------------------------------
| Consumed by the Flutter customer app. Auth is via Sanctum bearer tokens
| issued after OTP verification (WhatsApp or email).
*/

Route::prefix('v1')->group(function () {

    // --- Public ---
    Route::get('/health', fn () => response()->json(['ok' => true, 'app' => 'heama']));
    // TEMP diagnostic: verifies the database connection the API is using. Returns
    // connected:true + the db name + a couple of row counts, or connected:false
    // with the error. Remove once you're done checking. Open in a browser:
    //   https://shipping.heama-soft.com/api/v1/dbcheck
    Route::get('/dbcheck', function () {
        try {
            $db = \Illuminate\Support\Facades\DB::connection();
            $db->getPdo(); // forces an actual connection

            return response()->json([
                'connected' => true,
                'database' => $db->getDatabaseName(),
                'host' => config('database.connections.'.config('database.default').'.host'),
                'users' => \Illuminate\Support\Facades\DB::table('users')->count(),
                'orders' => \Illuminate\Support\Facades\DB::table('orders')->count(),
                'server_time' => now()->toDateTimeString(),
            ]);
        } catch (\Throwable $e) {
            return response()->json([
                'connected' => false,
                'error' => $e->getMessage(),
            ], 500);
        }
    });
    // TEMP diagnostic: shows the fx_rates THIS server actually reads + a sample
    // TL→USD conversion, so we can confirm which database is live. Remove later.
    Route::get('/fx', function () {
        \Illuminate\Support\Facades\Cache::flush(); // drop any cached settings
        $pricing = app(\App\Services\PricingService::class);

        return response()->json([
            'database' => \Illuminate\Support\Facades\DB::connection()->getDatabaseName(),
            'rates' => \App\Models\FxRate::query()->get(['currency', 'rate_to_iqd', 'updated_at']),
            'usd_rate_to_iqd' => \App\Models\FxRate::rateFor('USD'),
            'try_rate_to_iqd' => \App\Models\FxRate::rateFor('TRY'),
            'markup_percent' => \App\Models\Setting::get('markup_percent', 15),
            'rounding_step_usd' => \App\Models\Setting::get('rounding_step_usd', 0.25),
            'rounding_step_iqd' => \App\Models\Setting::get('rounding_step', 250),
            'sample_350_TRY_to_USD' => $pricing->chargeUnit(350, 'TRY', 'USD'),
            'sample_739_TRY_to_USD' => $pricing->chargeUnit(739, 'TRY', 'USD'),
            'server_time' => now()->toDateTimeString(),
        ]);
    });
    Route::get('/stores', [StoreController::class, 'index']);
    Route::get('/products', [ProductController::class, 'index']);
    Route::get('/trending', [ProductController::class, 'trending']);
    Route::get('/products/{product:key}', [ProductController::class, 'show']);

    Route::prefix('auth')->group(function () {
        Route::post('/otp/request', [AuthController::class, 'requestOtp'])
            ->middleware('throttle:6,1');
        Route::post('/otp/verify', [AuthController::class, 'verifyOtp'])
            ->middleware('throttle:10,1');
        // Optional password login (backup to OTP).
        Route::post('/login', [AuthController::class, 'login'])
            ->middleware('throttle:10,1');
    });

    // --- Authenticated ---
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/auth/me', [AuthController::class, 'me']);
        Route::patch('/auth/profile', [AuthController::class, 'updateProfile']);
        Route::post('/auth/password', [AuthController::class, 'setPassword']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        // Permanent account deletion (App Store requirement).
        Route::delete('/auth/account', [AuthController::class, 'deleteAccount']);

        // Scrape a product URL server-side, then price it (web + mobile).
        Route::post('/scrape', [CaptureController::class, 'scrape']);
        // Capture a manually-entered product (returns it priced in IQD).
        Route::post('/capture', [CaptureController::class, 'store']);
        // AI-assisted variant extraction (selected colour + size).
        Route::post('/ai/variants', [AiController::class, 'variants'])
            ->middleware('throttle:30,1');

        // In-stock storefront (products already in the company, no shipping wait)
        Route::get('/stock', [StockController::class, 'index']);
        Route::post('/stock/{itemId}/add', [StockController::class, 'addToCart']);

        // Cart
        Route::get('/cart', [CartController::class, 'index']);
        Route::post('/cart/items', [CartController::class, 'addItem']);
        Route::patch('/cart/items/{item}', [CartController::class, 'updateItem']);
        Route::delete('/cart/items/{item}', [CartController::class, 'removeItem']);

        // Favourites
        Route::get('/favorites', [FavoriteController::class, 'index']);
        Route::post('/favorites', [FavoriteController::class, 'store']);
        Route::delete('/favorites/{key}', [FavoriteController::class, 'destroy']);

        // Addresses
        Route::get('/addresses', [AddressController::class, 'index']);
        Route::post('/addresses', [AddressController::class, 'store']);
        Route::patch('/addresses/{address}', [AddressController::class, 'update']);
        Route::delete('/addresses/{address}', [AddressController::class, 'destroy']);

        // Orders
        Route::get('/orders', [OrderController::class, 'index']);
        Route::post('/orders', [OrderController::class, 'store']);
        Route::get('/orders/{order:code}', [OrderController::class, 'show']);
        Route::post('/orders/{order:code}/cancel', [OrderController::class, 'cancel']);
        // Cancel ONE item of a still-'placed' order (refunds price + shipping).
        Route::post('/orders/{order:code}/items/{itemId}/cancel', [OrderController::class, 'cancelItem']);

        // Wallet
        Route::get('/wallet', [WalletController::class, 'show']);
        Route::post('/wallet/exchange', [WalletController::class, 'exchange']);

        // Push notifications (FCM device tokens)
        Route::post('/device-tokens', [DeviceTokenController::class, 'store']);
        Route::delete('/device-tokens', [DeviceTokenController::class, 'destroy']);

        // Shipping-fee approvals (admin re-priced an item; the customer answers)
        Route::get('/approvals', [ApprovalController::class, 'index']);
        Route::post('/approvals/{id}/accept', [ApprovalController::class, 'accept']);
        Route::post('/approvals/{id}/reject', [ApprovalController::class, 'reject']);

        // Admin dashboard (gated on is_admin inside the controller)
        Route::get('/admin/notifications', [AdminController::class, 'notifications']);
        Route::post('/admin/notifications/{notification}/read', [AdminController::class, 'markRead']);
    });
});
