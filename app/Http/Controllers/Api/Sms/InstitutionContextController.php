<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\Sms;

use App\Http\Controllers\Controller;
use App\Models\Institution;
use App\Support\Sms\InstitutionContext;
use Illuminate\Http\JsonResponse;

final class InstitutionContextController extends Controller
{
    public function show(InstitutionContext $context): JsonResponse
    {
        $institution = Institution::query()->findOrFail($context->institutionId());

        return response()->json(['data' => [
            'institution' => [
                'id' => $institution->id,
                'code' => $institution->code,
                'name' => $institution->name,
                'type' => $institution->type,
                'locale' => $institution->locale,
                'timezone' => $institution->timezone,
                'currency' => $institution->currency,
            ],
            'membership_id' => $context->membershipId(),
            'all_campuses' => $context->allCampuses(),
        ]]);
    }
}
