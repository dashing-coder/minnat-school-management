<?php

declare(strict_types=1);

use App\Http\Controllers\Api\Sms\CampusController;
use App\Http\Controllers\Api\Sms\InstitutionContextController;
use App\Http\Middleware\Sms\RequireInstitutionPermission;
use App\Http\Middleware\Sms\ResolveInstitutionContext;
use Illuminate\Support\Facades\Route;

// This file is included from routes/api.php, which already has the /api prefix.
Route::middleware(['auth:sanctum', ResolveInstitutionContext::class])
    ->prefix('v1/institutions/{institution}')
    ->group(function (): void {
        Route::get('/context', [InstitutionContextController::class, 'show'])
            ->middleware(RequireInstitutionPermission::class . ':dashboard.view');

        Route::get('/campuses', [CampusController::class, 'index'])
            ->middleware(RequireInstitutionPermission::class . ':campuses.view');
    });
