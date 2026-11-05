<?php

namespace App\Support;

use Illuminate\Database\Query\Builder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

final class SmsAccess
{
    public static function has(string $permission): bool
    {
        return in_array($permission, request()->attributes->get('sms_permissions', []), true);
    }

    public static function institutionId(): int
    {
        $id = request()->attributes->get('sms_institution_id');
        abort_unless(is_int($id), 403);
        return $id;
    }

    public static function membership(): object
    {
        $membership = request()->attributes->get('sms_membership');
        abort_unless($membership, 403);
        return $membership;
    }

    /**
     * Institution-scoped read query. For campus-restricted memberships, apply
     * an additional relation-scoped filter. Records without a vetted campus
     * association are DENIED by default until a per-module access policy is
     * implemented. This intentionally favors confidentiality over visibility.
     */
    public static function scopedQuery(string $table): Builder
    {
        $id = self::institutionId();
        $query = DB::table($table)->where($table.'.institution_id', $id);
        $membership = self::membership();
        if ((int) $membership->can_access_all_campuses === 1) {
            return $query;
        }
        $campuses = DB::table('membership_campuses')
            ->where('institution_id', $id)
            ->where('membership_id', $membership->id)
            ->pluck('campus_id')->all();
        if (!$campuses) return $query->whereRaw('1=0');
        if (Schema::hasColumn($table, 'campus_id')) {
            return $query->whereIn($table.'.campus_id', $campuses);
        }
        // Prioritize direct student scope: student-attendance, invoices,
        // documents and most student-linked records become campus-specific.
        $related = [
            'student_id' => ['students', 'campus_id'],
            'employee_id' => ['employees', 'campus_id'],
            'class_section_id' => ['class_sections', 'campus_id'],
            'admission_cycle_id' => ['admission_cycles', 'campus_id'],
        ];
        foreach ($related as $column => [$parent, $parentCampusColumn]) {
            if (Schema::hasColumn($table, $column)) {
                return $query->whereIn($table.'.'.$column, DB::table($parent)
                    ->select('id')->where('institution_id', $id)
                    ->whereIn($parentCampusColumn, $campuses));
            }
        }
        if ($table === 'guardians') {
            return $query->whereIn('guardians.id', DB::table('student_guardians as sg')
                ->join('students as s', function ($join) {
                    $join->on('s.id', '=', 'sg.student_id')
                        ->on('s.institution_id', '=', 'sg.institution_id');
                })->where('sg.institution_id', $id)
                ->whereIn('s.campus_id', $campuses)->select('sg.guardian_id'));
        }
        // Secondary foreign-key routes for commonly used operational records.
        $indirect = [
            'attendance_session_id' => ['attendance_sessions', 'class_section_id', 'class_sections'],
            'student_invoice_id' => ['student_invoices', 'student_id', 'students'],
            'student_payment_id' => ['student_payments', 'student_id', 'students'],
            'hifz_enrollment_id' => ['hifz_enrollments', 'student_id', 'students'],
            'exam_mark_id' => ['exam_marks', 'student_id', 'students'],
            'hostel_allocation_id' => ['hostel_allocations', 'student_id', 'students'],
        ];
        foreach ($indirect as $column => [$parent, $link, $root]) {
            if (!Schema::hasColumn($table, $column)) continue;
            return $query->whereIn($table.'.'.$column,
                DB::table($parent.' as p')->join($root.' as r', function ($join) use ($link) {
                    $join->on('r.id', '=', 'p.'.$link)
                        ->on('r.institution_id', '=', 'p.institution_id');
                })->select('p.id')->where('p.institution_id', $id)
                    ->whereIn('r.campus_id', $campuses));
        }
        // The corresponding record may be institution-wide, but the current
        // schema does not encode a campus sharing policy. Do not assume access.
        return $query->whereRaw('1=0');
    }

    public static function allowedCampuses(): \Illuminate\Support\Collection
    {
        $q = DB::table('campuses')->where('institution_id', self::institutionId());
        $membership = self::membership();
        if ((int) $membership->can_access_all_campuses !== 1) {
            $ids = DB::table('membership_campuses')->where('institution_id', self::institutionId())
                ->where('membership_id', $membership->id)->pluck('campus_id')->all();
            $q->whereIn('id', $ids);
        }
        return $q->orderBy('name')->get();
    }

    public static function require(string $permission): void
    {
        abort_unless(self::has($permission), 403, 'Your institution role does not permit this action.');
    }
}
