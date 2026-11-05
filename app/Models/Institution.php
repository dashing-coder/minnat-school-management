<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Institution extends Model
{
    use SoftDeletes;

    protected $fillable = ['code', 'slug', 'name', 'type', 'status', 'timezone', 'locale', 'currency'];

    public function campuses(): HasMany
    {
        return $this->hasMany(Campus::class);
    }
}
