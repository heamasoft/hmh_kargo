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

    /** The image's public web address. */
    public function imageUrl(): string
    {
        return url($this->image_path);
    }
}
