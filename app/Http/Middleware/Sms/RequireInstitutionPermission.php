<?php

declare(strict_types=1);

namespace App\Http\Middleware\Sms;

use App\Support\Sms\InstitutionContext;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

final class RequireInstitutionPermission
{
    public function handle(Request $request, Closure $next, string $permission): Response
    {
        $context = app(InstitutionContext::class);

        $allowed = DB::table('membership_roles as mr')
            ->join('institution_role_permissions as rp', 'rp.role_id', '=', 'mr.role_id')
            ->join('sms_permissions as p', 'p.id', '=', 'rp.permission_id')
            ->where('mr.institution_id', $context->institutionId())
            ->where('mr.membership_id', $context->membershipId())
            ->where('p.key', $permission)
            ->exists();

        abort_unless($allowed, 403, 'Required institution permission is missing.');

        return $next($request);
    }
}
