<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\Cart;
use App\Models\User;
use App\Models\Wallet;
use App\Services\Otp\OtpService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function __construct(private readonly OtpService $otp) {}

    /** POST /auth/otp/request — send a code over WhatsApp or email. */
    public function requestOtp(Request $request): JsonResponse
    {
        $data = $request->validate([
            'identifier' => ['required', 'string', 'max:255'],
            'channel' => ['required', Rule::in(['whatsapp', 'email'])],
            'purpose' => ['sometimes', Rule::in(['login', 'register', 'reset'])],
        ]);

        if ($data['channel'] === 'email') {
            $request->validate(['identifier' => ['email']]);
        }

        // A password reset targets an EXISTING account. Refuse unknown numbers so
        // the app can prompt the user to register instead of silently creating one.
        if (($data['purpose'] ?? 'login') === 'reset') {
            $column = $data['channel'] === 'email' ? 'email' : 'phone';
            $normalized = $data['channel'] === 'email'
                ? strtolower(trim($data['identifier']))
                : preg_replace('/\D+/', '', $data['identifier']);

            if (! User::where($column, $normalized)->exists()) {
                return response()->json([
                    'message' => 'This number is not registered yet.',
                    'not_registered' => true,
                ], 404);
            }
        }

        // Don't send a code to a deactivated account — it couldn't use it.
        $blocked = $this->blockedUserFor($data['identifier'], $data['channel']);
        if ($blocked) {
            return $this->blockedResponse();
        }

        $ttl = $this->otp->request(
            $data['identifier'],
            $data['channel'],
            $data['purpose'] ?? 'login',
        );

        return response()->json([
            'message' => 'Code sent.',
            'expires_in' => $ttl,
        ]);
    }

    /** POST /auth/otp/verify — verify the code, create/login the user, return a token. */
    public function verifyOtp(Request $request): JsonResponse
    {
        $data = $request->validate([
            'identifier' => ['required', 'string', 'max:255'],
            'channel' => ['required', Rule::in(['whatsapp', 'email'])],
            'code' => ['required', 'string'],
            'name' => ['sometimes', 'string', 'max:120'],
            'city' => ['sometimes', 'string', 'max:120'],
        ]);

        if ($this->blockedUserFor($data['identifier'], $data['channel'])) {
            return $this->blockedResponse();
        }

        $this->otp->verify($data['identifier'], $data['channel'], $data['code']);

        $user = $this->findOrCreateUser($data);

        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => new UserResource($user->load('wallet')),
        ]);
    }

    /** POST /auth/login — optional phone + password login (backup to OTP). */
    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'phone' => ['required', 'string', 'max:40'],
            'password' => ['required', 'string'],
        ]);

        $phone = preg_replace('/\D+/', '', $data['phone']);
        $user = User::where('phone', $phone)->first();

        if (! $user || $user->password === null || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'password' => ['Incorrect phone number or password.'],
            ]);
        }

        if ($user->isBlocked()) {
            return $this->blockedResponse();
        }

        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => new UserResource($user->load('wallet')),
        ]);
    }

    /** POST /auth/password — set or change the current user's password. */
    public function setPassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'password' => ['required', 'string', 'min:6'],
        ]);

        // The User model casts 'password' => 'hashed', so this stores a hash.
        $request->user()->update(['password' => $data['password']]);

        return response()->json(['message' => 'Password set.']);
    }

    /** GET /auth/me — current authenticated user. */
    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'user' => new UserResource($request->user()->load('wallet')),
        ]);
    }

    /** PATCH /auth/profile — update name / city / email. */
    public function updateProfile(Request $request): JsonResponse
    {
        $user = $request->user();
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:120'],
            'city' => ['sometimes', 'string', 'max:120'],
            'email' => ['sometimes', 'email', Rule::unique('users')->ignore($user->id)],
        ]);
        $user->fill($data)->save();

        return response()->json(['user' => new UserResource($user->load('wallet'))]);
    }

    /** POST /auth/logout — revoke the current token. */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out.']);
    }

    /**
     * DELETE /auth/account — permanently delete the signed-in user's account.
     *
     * Required by the App Store: an app that lets users create an account must
     * let them delete it in-app. We remove all personal data (login tokens,
     * cart, addresses, favourites, device tokens, OTP codes) and anonymise the
     * user record. Completed order/transaction records are kept (detached from
     * identity) for legal/accounting purposes, as stated in the Privacy Policy.
     * The original phone/email are freed so the person can register again.
     */
    public function deleteAccount(Request $request): JsonResponse
    {
        $user = $request->user();

        // "Delete" DEACTIVATES: the account is blocked (customer_status.blocked_at,
        // the same flag the admin dashboard uses) and nothing is erased — orders,
        // wallet, addresses and the phone stay on record, and the admin can
        // reactivate it by clearing blocked_at. A blocked account can't log in
        // again, by code or password (see User::isBlocked()).
        DB::transaction(function () use ($user) {
            // Sign the user out everywhere and stop push notifications.
            $user->tokens()->delete();
            try {
                DB::table('device_tokens')->where('user_id', $user->id)->delete();
            } catch (\Throwable $e) { /* table may not exist — ignore */ }

            $user->block('Deactivated by the customer ("Delete account" in the app)');
        });

        return response()->json(['message' => 'Your account has been deactivated.']);
    }

    /** The existing account behind a phone / email, if it is blocked. */
    private function blockedUserFor(string $identifier, string $channel): ?User
    {
        $column = $channel === 'email' ? 'email' : 'phone';
        $normalized = $channel === 'email'
            ? strtolower(trim($identifier))
            : preg_replace('/\D+/', '', $identifier);
        $user = User::where($column, $normalized)->first();

        return $user && $user->isBlocked() ? $user : null;
    }

    private function blockedResponse(): JsonResponse
    {
        return response()->json([
            'message' => 'This account has been deactivated. Contact us to reactivate it.',
            'blocked' => true,
        ], 403);
    }

    private function findOrCreateUser(array $data): User
    {
        $channel = $data['channel'];
        $normalized = $channel === 'email'
            ? strtolower(trim($data['identifier']))
            : preg_replace('/\D+/', '', $data['identifier']);

        $column = $channel === 'email' ? 'email' : 'phone';

        return DB::transaction(function () use ($column, $normalized, $data, $channel) {
            $user = User::where($column, $normalized)->first();

            if (! $user) {
                $user = User::create([
                    'name' => $data['name'] ?? 'Heama user',
                    'city' => $data['city'] ?? null,
                    $column => $normalized,
                ]);
                Wallet::firstOrCreate(['user_id' => $user->id]);
                Cart::firstOrCreate(['user_id' => $user->id]);
            } else {
                // Fill any newly-provided profile fields on an existing user.
                $user->fill(array_filter([
                    'name' => $data['name'] ?? null,
                    'city' => $data['city'] ?? null,
                ]));
            }

            $user->{$channel === 'email' ? 'email_verified_at' : 'phone_verified_at'} = now();
            $user->save();

            return $user;
        });
    }
}
