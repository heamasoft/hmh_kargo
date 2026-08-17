<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\AddressResource;
use App\Models\Address;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AddressController extends Controller
{
    /** GET /addresses — the user's saved addresses (default first). */
    public function index(Request $request): JsonResponse
    {
        $addresses = $request->user()->addresses()
            ->orderByDesc('is_default')
            ->latest()
            ->get();

        return response()->json(['data' => AddressResource::collection($addresses)->resolve()]);
    }

    /** POST /addresses — add a new address. */
    public function store(Request $request): JsonResponse
    {
        $data = $this->validated($request);
        $user = $request->user();

        $address = DB::transaction(function () use ($user, $data) {
            // First address is default; or honour an explicit default flag.
            $makeDefault = ($data['is_default'] ?? false) || $user->addresses()->count() === 0;
            if ($makeDefault) {
                $user->addresses()->update(['is_default' => false]);
            }
            $data['is_default'] = $makeDefault;

            return $user->addresses()->create($data);
        });

        return response()->json(['data' => (new AddressResource($address))->resolve($request)], 201);
    }

    /** PATCH /addresses/{address} — edit an address. */
    public function update(Request $request, Address $address): JsonResponse
    {
        $this->authorizeAddress($request, $address);
        $data = $this->validated($request);

        DB::transaction(function () use ($request, $address, $data) {
            if ($data['is_default'] ?? false) {
                $request->user()->addresses()->where('id', '!=', $address->id)
                    ->update(['is_default' => false]);
            }
            $address->update($data);
        });

        return response()->json(['data' => (new AddressResource($address->fresh()))->resolve($request)]);
    }

    /** DELETE /addresses/{address}. */
    public function destroy(Request $request, Address $address): JsonResponse
    {
        $this->authorizeAddress($request, $address);
        $wasDefault = $address->is_default;
        $address->delete();

        // Promote another address to default if we removed the default one.
        if ($wasDefault) {
            $next = $request->user()->addresses()->latest()->first();
            $next?->update(['is_default' => true]);
        }

        return response()->json(['data' => AddressResource::collection(
            $request->user()->addresses()->orderByDesc('is_default')->latest()->get()
        )->resolve()]);
    }

    private function validated(Request $request): array
    {
        return $request->validate([
            'recipient_name' => ['required', 'string', 'max:120'],
            'governorate' => ['required', 'string', 'max:120'],
            'city' => ['required', 'string', 'max:120'],
            'street' => ['required', 'string', 'max:255'],
            'phone' => ['required', 'string', 'max:40'],
            'note' => ['nullable', 'string', 'max:255'],
            'is_default' => ['nullable', 'boolean'],
        ]);
    }

    private function authorizeAddress(Request $request, Address $address): void
    {
        abort_unless($address->user_id === $request->user()->id, 403);
    }
}
