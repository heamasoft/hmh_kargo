<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\AiVariantService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AiController extends Controller
{
    public function __construct(private readonly AiVariantService $ai) {}

    /**
     * POST /ai/variants — AI-read the selected colour + size from a page's
     * variant text. Returns nulls if AI is unavailable; the app then keeps its
     * own heuristic result.
     */
    public function variants(Request $request): JsonResponse
    {
        $data = $request->validate([
            'store' => ['nullable', 'string', 'max:60'],
            'url' => ['nullable', 'string', 'max:1024'],
            'context' => ['required', 'string', 'max:8000'],
        ]);

        $result = $this->ai->extract(
            $data['store'] ?? '',
            $data['url'] ?? '',
            $data['context'],
        );

        return response()->json([
            'available' => $result !== null,
            'size' => $result['size'] ?? '',
            'color' => $result['color'] ?? '',
            'size_options' => $result['size_options'] ?? [],
            'color_options' => $result['color_options'] ?? [],
        ]);
    }
}
