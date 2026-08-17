<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\FavoriteResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    /** GET /favorites — the user's saved products. */
    public function index(Request $request): JsonResponse
    {
        $favorites = $request->user()->favorites()->latest()->get();

        return response()->json(['data' => FavoriteResource::collection($favorites)->resolve()]);
    }

    /** POST /favorites — save (upsert) a product. */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'id' => ['required', 'string', 'max:191'],
            'name' => ['nullable', 'string', 'max:255'],
            'store' => ['nullable', 'string', 'max:120'],
            'store_id' => ['nullable', 'integer'],
            'source_url' => ['nullable', 'string', 'max:1024'],
            'iqd_price' => ['nullable', 'integer', 'min:0'],
            'image_url' => ['nullable', 'string', 'max:1024'],
        ]);

        $favorite = $request->user()->favorites()->updateOrCreate(
            ['item_key' => $data['id']],
            [
                'name' => $data['name'] ?? '',
                'store' => $data['store'] ?? '',
                'store_id' => $data['store_id'] ?? null,
                'source_url' => $data['source_url'] ?? null,
                'iqd_price' => $data['iqd_price'] ?? 0,
                'image_url' => $data['image_url'] ?? null,
            ],
        );

        return response()->json(['data' => (new FavoriteResource($favorite))->resolve($request)], 201);
    }

    /** DELETE /favorites/{key} — remove a saved product by its item key. */
    public function destroy(Request $request, string $key): JsonResponse
    {
        $request->user()->favorites()->where('item_key', $key)->delete();

        return response()->json(['ok' => true]);
    }
}
