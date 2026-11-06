<?php
namespace App\Providers;

use App\Support\Sms\InstitutionContext;
use Illuminate\Support\ServiceProvider;

final class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        // One context instance per request/job lifecycle, never global across tenants.
        // Without a scoped binding, middleware and controller resolve distinct
        // instances and protected API permission checks fail (or lose context).
        $this->app->scoped(InstitutionContext::class,fn()=>new InstitutionContext());
    }

    public function boot(): void {}
}
