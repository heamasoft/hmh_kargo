<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\AddressResource;
use App\Models\AdminNotification;
use App\Models\User;
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

    /**
     * GET /admin/customers?q= — customers an admin can check out for, by name
     * or phone, each with their saved addresses (default first) so the order
     * goes to the customer's own door.
     */
    public function customers(Request $request): JsonResponse
    {
        abort_unless($request->user()->is_admin, 403);

        $q = trim((string) $request->query('q', ''));

        $users = User::query()
            ->where('is_admin', false)
            ->when($q !== '', function ($query) use ($q) {
                $like = '%'.str_replace(['%', '_'], ['\%', '\_'], $q).'%';
                $query->where(fn ($w) => $w->where('name', 'like', $like)
                    ->orWhere('phone', 'like', $like));
            })
            ->with(['addresses' => fn ($a) => $a->orderByDesc('is_default')->orderByDesc('id')])
            ->orderBy('name')
            ->limit(50)
            ->get();

        return response()->json([
            'data' => $users->map(fn (User $u) => [
                'id' => $u->id,
                'name' => $u->name,
                'phone' => $u->phone,
                'city' => $u->city,
                'addresses' => AddressResource::collection($u->addresses)->resolve($request),
            ])->values(),
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
