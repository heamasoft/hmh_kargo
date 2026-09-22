<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Ad;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

/**
 * Home-page ads. Images are saved straight under public/uploads/ads, so they
 * are served as plain files with no `storage:link` needed on the host.
 */
class AdController extends Controller
{
    private const DIR = 'uploads/ads';

    /** GET /ads — the active ads, in display order (public). */
    public function index(): JsonResponse
    {
        $ads = Ad::where('is_active', true)->orderBy('sort')->orderByDesc('id')->get();

        return response()->json(['data' => $ads->map(fn (Ad $a) => $this->present($a))->values()]);
    }

    /** GET /admin/ads — every ad, on or off. */
    public function adminIndex(Request $request): JsonResponse
    {
        abort_unless($request->user()->is_admin, 403);

        $ads = Ad::orderBy('sort')->orderByDesc('id')->get();

        return response()->json(['data' => $ads->map(fn (Ad $a) => $this->present($a, true))->values()]);
    }

    /** POST /admin/ads — upload an image (multipart `image`, optional `link_url`). */
    public function store(Request $request): JsonResponse
    {
        abort_unless($request->user()->is_admin, 403);

        $data = $request->validate([
            'image' => ['required', 'image', 'mimes:jpg,jpeg,png,webp', 'max:5120'],
            'link_url' => ['nullable', 'url', 'max:1024'],
        ], [
            'image.max' => 'The image must be 5 MB or smaller.',
        ]);

        $file = $request->file('image');
        $name = Str::random(24).'.'.strtolower($file->getClientOriginalExtension() ?: 'jpg');
        $dir = public_path(self::DIR);
        if (! is_dir($dir)) {
            mkdir($dir, 0755, true);
        }
        $file->move($dir, $name);

        $ad = Ad::create([
            'image_path' => self::DIR.'/'.$name,
            'link_url' => $data['link_url'] ?? null,
            'sort' => (int) Ad::max('sort') + 1,
            'is_active' => true,
            'created_by' => $request->user()->id,
        ]);

        return response()->json(['data' => $this->present($ad, true)], 201);
    }

    /** PATCH /admin/ads/{ad} — switch an ad on or off. */
    public function update(Request $request, Ad $ad): JsonResponse
    {
        abort_unless($request->user()->is_admin, 403);

        $data = $request->validate(['is_active' => ['required', 'boolean']]);
        $ad->update(['is_active' => $data['is_active']]);

        return response()->json(['data' => $this->present($ad, true)]);
    }

    /** DELETE /admin/ads/{ad} — remove the ad and its image file. */
    public function destroy(Request $request, Ad $ad): JsonResponse
    {
        abort_unless($request->user()->is_admin, 403);

        $path = public_path($ad->image_path);
        if (is_file($path)) {
            @unlink($path);
        }
        $ad->delete();

        return response()->json(['ok' => true]);
    }

    private function present(Ad $a, bool $admin = false): array
    {
        return [
            'id' => $a->id,
            'image_url' => $a->imageUrl(),
            'link_url' => $a->link_url,
        ] + ($admin ? ['is_active' => (bool) $a->is_active] : []);
    }
}
