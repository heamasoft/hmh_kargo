<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * FCM device tokens. The app registers its token after login; the admin
 * console reads this table to know which phones to push to. A token is unique
 * per install, so registering re-assigns it to whoever is logged in.
 */
class DeviceTokenController extends Controller
{
    /** POST /device-tokens {token, platform} */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'token' => ['required', 'string', 'max:255'],
            'platform' => ['nullable', 'string', 'max:16'],
        ]);

        DB::table('device_tokens')->updateOrInsert(
            ['token' => $data['token']],
            [
                'user_id' => $request->user()->id,
                'platform' => $data['platform'] ?? 'android',
                'updated_at' => now(),
                'created_at' => now(),
            ],
        );

        return response()->json(['ok' => true]);
    }

    /** DELETE /device-tokens {token} — logout: this phone stops getting pushes. */
    public function destroy(Request $request): JsonResponse
    {
        $data = $request->validate([
            'token' => ['required', 'string', 'max:255'],
        ]);

        DB::table('device_tokens')
            ->where('token', $data['token'])
            ->where('user_id', $request->user()->id)
            ->delete();

        return response()->json(['ok' => true]);
    }
}
