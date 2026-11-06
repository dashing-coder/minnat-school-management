<?php
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
        then: function (): void {
            // Same-origin JSON API: session authentication and the web CSRF/session stack.
            // Do not claim bearer-token API support until Sanctum is installed/configured.
            \Illuminate\Support\Facades\Route::middleware('web')
                ->prefix('api')->group(base_path('routes/sms_api.php'));
            \Illuminate\Support\Facades\Route::middleware('api')
                ->prefix('api')->group(base_path('routes/sms_webhooks.php'));
        }
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias(['sms.institution' => \App\Http\Middleware\EnsureCurrentInstitution::class]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {})
    ->create();
