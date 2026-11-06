<?php

declare(strict_types=1);

use App\Http\Controllers\Api\Sms\CampusController;
use App\Http\Controllers\Api\Sms\InstitutionContextController;
use App\Http\Middleware\Sms\RequireInstitutionPermission;
use App\Http\Middleware\Sms\ResolveInstitutionContext;
use Illuminate\Support\Facades\Route;

// Registered from bootstrap/app.php under /api with the web session middleware; same-origin only.
Route::middleware(['auth', ResolveInstitutionContext::class])
    ->prefix('v1/institutions/{institution}')
    ->group(function (): void {
        Route::get('/context', [InstitutionContextController::class, 'show'])
            ->middleware(RequireInstitutionPermission::class . ':dashboard.view');

        Route::get('/campuses', [CampusController::class, 'index'])
            ->middleware(RequireInstitutionPermission::class . ':campuses.view');
    });
