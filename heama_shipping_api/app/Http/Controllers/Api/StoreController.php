<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\StoreResource;
use App\Models\Store;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class StoreController extends Controller
{
    /** GET /stores — active storefronts for the app, grouped-ready. */
    public function index(): AnonymousResourceCollection
    {
        $stores = Store::where('active', true)
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get();

        return StoreResource::collection($stores);
    }
}
