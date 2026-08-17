<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AdminNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Endpoints for the admin dashboard. Gated on the user's `is_admin` flag.
 */
class AdminController extends Controller
{
    /** GET /admin/notifications — the alert feed (newest first) + unread count. */
    public function notifications(Request $request): JsonResponse
    {
        abort_unless($request->user()->is_admin, 403);

        $items = AdminNotification::latest()->limit(100)->get();

        return response()->json([
            'unread' => AdminNotification::whereNull('read_at')->count(),
            'data' => $items,
        ]);
    }

    /** POST /admin/notifications/{notification}/read — dismiss one alert. */
    public function markRead(Request $request, AdminNotification $notification): JsonResponse
    {
        abort_unless($request->user()->is_admin, 403);

        $notification->update(['read_at' => now()]);

        return response()->json(['ok' => true]);
    }
}
