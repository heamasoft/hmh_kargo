<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * A home-page ad: an image an admin uploaded, optionally opening [link_url]
 * when tapped. The file lives in public/uploads/ads (see AdController).
 */
class Ad extends Model
{
    protected $fillable = ['image_path', 'link_url', 'sort', 'is_active', 'created_by'];

    protected $casts = [
        'is_active' => 'boolean',
        'sort' => 'integer',
    ];

    /**
     * The image's web address — served by the API itself (AdController@image),
     * not as a static file: on the live host Laravel's public/ folder is not
     * the web root, so /uploads/ads/… answered 404 and the ad showed no image.
     */
    public function imageUrl(): string
    {
        return url('/api/v1/ads/image/'.basename($this->image_path));
    }
}
