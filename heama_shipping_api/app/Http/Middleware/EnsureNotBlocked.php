<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Refuses every signed-in request from a blocked (deactivated) account — the
 * admin can block someone who is still logged in, and their old token must
 * stop working at once. The token is revoked so the app signs out.
 */
class EnsureNotBlocked
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        if ($user && $user->isBlocked()) {
            $user->currentAccessToken()?->delete();

            return response()->json([
                'message' => 'This account has been deactivated. Contact us to reactivate it.',
                'blocked' => true,
            ], 403);
        }

        return $next($request);
    }
}
