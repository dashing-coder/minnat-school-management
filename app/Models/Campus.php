<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Campus extends Model
{
    protected $fillable = ['institution_id', 'code', 'name', 'is_main', 'is_active', 'address'];

    protected $casts = ['is_main' => 'boolean', 'is_active' => 'boolean'];

    public function institution(): BelongsTo
    {
        return $this->belongsTo(Institution::class);
    }
}
