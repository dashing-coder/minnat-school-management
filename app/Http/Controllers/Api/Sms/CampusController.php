<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\Sms;

use App\Http\Controllers\Controller;
use App\Models\Campus;
use App\Support\Sms\InstitutionContext;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

final class CampusController extends Controller
{
    public function index(InstitutionContext $context): JsonResponse
    {
        $query = Campus::query()
            ->where('institution_id', $context->institutionId())
            ->where('is_active', true);

        if (!$context->allCampuses()) {
            $allowedCampusIds = DB::table('membership_campuses')
                ->where('institution_id', $context->institutionId())
                ->where('membership_id', $context->membershipId())
                ->select('campus_id');

            $query->whereIn('id', $allowedCampusIds);
        }

        return response()->json(['data' => $query
            ->orderBy('name')
            ->get(['id', 'code', 'name', 'is_main'])]);
    }
}
