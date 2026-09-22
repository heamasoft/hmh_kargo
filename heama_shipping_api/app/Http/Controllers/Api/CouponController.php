<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Coupon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CouponController extends Controller
{
    /**
     * POST /coupons/check — can the signed-in customer use this code? Answers
     * with its percentage for the cart to preview; the discount itself is only
     * taken (and the one use spent) when the order is placed.
     */
    public function check(Request $request): JsonResponse
    {
        $data = $request->validate([
            'code' => ['required', 'string', 'max:40'],
            // Admin checking out for a customer: judge the customer's use.
            'customer_id' => ['nullable', 'integer', 'exists:users,id'],
        ]);

        $user = $request->user();
        if (! empty($data['customer_id'])) {
            abort_unless($user->is_admin, 403);
            $user = \App\Models\User::findOrFail($data['customer_id']);
        }

        $coupon = Coupon::usableBy($data['code'], $user);

        return response()->json(['data' => $this->present($coupon)]);
    }

    /** GET /admin/coupons — every coupon, newest first, with its use count. */
    public function index(Request $request): JsonResponse
    {
        abort_unless($request->user()->is_admin, 403);

        return response()->json([
            'data' => Coupon::latest()->get()->map(fn (Coupon $c) => $this->present($c, true))->values(),
        ]);
    }

    /** POST /admin/coupons — create a code. */
    public function store(Request $request): JsonResponse
    {
        // TEMPORARY: name the cause of a server error in the reply (admins
        // only), to diagnose the first live run. Remove once it works.
        try {
            return $this->storeCoupon($request);
        } catch (\Illuminate\Validation\ValidationException|\Symfony\Component\HttpKernel\Exception\HttpException $e) {
            throw $e;
        } catch (\Throwable $e) {
            report($e);

            return response()->json([
                'message' => 'Server Error',
                'debug' => get_class($e).': '.$e->getMessage()
                    .' @ '.basename($e->getFile()).':'.$e->getLine(),
            ], 500);
        }
    }

    private function storeCoupon(Request $request): JsonResponse
    {
        abort_unless($request->user()->is_admin, 403);

        $data = $request->validate([
            'code' => ['required', 'string', 'max:40', 'regex:/^[A-Za-z0-9_-]+$/'],
            'percent' => ['required', 'numeric', 'min:1', 'max:100'],
            'expires_at' => ['nullable', 'date', 'after:now'],
        ], [
            'code.regex' => 'Use letters, numbers, - or _ only (no spaces).',
        ]);

        $code = Coupon::normalize($data['code']);
        if (Coupon::where('code', $code)->exists()) {
            return response()->json(['message' => 'A coupon with this code already exists.'], 422);
        }

        $coupon = Coupon::create([
            'code' => $code,
            'percent' => $data['percent'],
            // A date alone means "through the end of that day".
            'expires_at' => isset($data['expires_at'])
                ? \Illuminate\Support\Carbon::parse($data['expires_at'])->endOfDay()
                : null,
            'is_active' => true,
            'created_by' => $request->user()->id,
        ]);

        return response()->json(['data' => $this->present($coupon, true)], 201);
    }

    /** PATCH /admin/coupons/{coupon} — switch a code on or off. */
    public function update(Request $request, Coupon $coupon): JsonResponse
    {
        abort_unless($request->user()->is_admin, 403);

        $data = $request->validate(['is_active' => ['required', 'boolean']]);
        $coupon->update(['is_active' => $data['is_active']]);

        return response()->json(['data' => $this->present($coupon, true)]);
    }

    private function present(Coupon $c, bool $admin = false): array
    {
        return [
            'id' => $c->id,
            'code' => $c->code,
            'percent' => (float) $c->percent,
            'expires_at' => $c->expires_at?->toIso8601String(),
        ] + ($admin ? [
            'is_active' => (bool) $c->is_active,
            'expired' => $c->isExpired(),
            'times_used' => $c->timesUsed(),
        ] : []);
    }
}
