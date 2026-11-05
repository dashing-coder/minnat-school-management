<?php

declare(strict_types=1);

namespace App\Http\Middleware\Sms;

use App\Models\Institution;
use App\Support\Sms\InstitutionContext;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

final class ResolveInstitutionContext
{
    public function handle(Request $request, Closure $next): Response
    {
        // Do not treat a client-supplied tenant slug as proof of access.
        $slug = $request->route('institution');
        abort_unless(is_string($slug) && $slug !== '', 404);

        $institution = Institution::query()
            ->where('slug', $slug)
            ->where('status', 'active')
            ->firstOrFail();

        $user = $request->user();
        abort_unless($user !== null, 401);

        $membership = DB::table('institution_memberships')
            ->where('institution_id', $institution->id)
            ->where('user_id', $user->getAuthIdentifier())
            ->where('status', 'active')
            ->first(['id', 'can_access_all_campuses']);

        abort_if($membership === null, 403, 'No active membership in this institution.');

        app(InstitutionContext::class)->set(
            (int) $institution->id,
            (int) $membership->id,
            (int) $user->getAuthIdentifier(),
            (bool) $membership->can_access_all_campuses
        );

        return $next($request);
    }
}
