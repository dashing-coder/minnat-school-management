<?php
namespace App\Http\Controllers;

use App\Support\SmsAccess;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

final class AttendanceController
{
    public function create(Request $request)
    {
        SmsAccess::require('attendance.record');
        $sessions = SmsAccess::scopedQuery('attendance_sessions')
            ->where('status', 'open')->orderByDesc('attendance_on')->limit(80)->get();
        $sessionId = $request->integer('attendance_session_id');
        $selectedSession = null;
        $students = collect();
        $search = trim((string) $request->query('search', ''));
        $search = mb_substr($search, 0, 80);
        if ($sessionId > 0) {
            $selectedSession = SmsAccess::scopedQuery('attendance_sessions')
                ->where('status', 'open')->where('id', $sessionId)->first();
            abort_unless($selectedSession, 404, 'Attendance session is closed or inaccessible.');
            $students = SmsAccess::scopedQuery('students')
                ->join('enrollments as e', function ($join) {
                    $join->on('e.student_id', '=', 'students.id')
                        ->on('e.institution_id', '=', 'students.institution_id');
                })
                ->where('e.class_section_id', $selectedSession->class_section_id)
                ->where('e.status', 'active')
                ->where('students.status', 'active')
                ->when($search !== '', function ($query) use ($search) {
                    $query->where(function ($sub) use ($search) {
                        $sub->where('students.name', 'like', '%'.$search.'%')
                            ->orWhere('students.admission_no', 'like', '%'.$search.'%');
                    });
                })
                ->distinct()->select('students.id', 'students.name', 'students.admission_no')
                ->orderBy('students.name')->limit(100)->get();
        }
        return view('attendance.mark', compact('sessions','sessionId','selectedSession','students','search'));
    }

    public function store(Request $request)
    {
        SmsAccess::require('attendance.record');
        $validated = $request->validate([
            'attendance_session_id' => ['required','integer'],
            'student_id' => ['required','integer'],
            'status' => ['required', Rule::in(['present','absent','late','excused'])],
            'minutes_late' => ['nullable','integer','min:0','max:1440'],
        ]);
        $session = SmsAccess::scopedQuery('attendance_sessions')->where('id', $validated['attendance_session_id'])->first();
        abort_unless($session && $session->status === 'open', 422, 'Attendance session is closed or inaccessible.');
        $student = SmsAccess::scopedQuery('students')->where('id', $validated['student_id'])->first();
        abort_unless($student && $student->status === 'active', 422, 'Active student not found.');
        $enrolled = SmsAccess::scopedQuery('enrollments')->where('student_id', $student->id)
            ->where('class_section_id', $session->class_section_id)->where('status', 'active')->exists();
        abort_unless($enrolled, 422, 'Student is not actively enrolled in this class section.');
        DB::transaction(function () use ($request, $validated) {
            $where = [
                'institution_id' => SmsAccess::institutionId(),
                'attendance_session_id' => $validated['attendance_session_id'],
                'student_id' => $validated['student_id'],
            ];
            $row = DB::table('student_attendance')->where($where)->lockForUpdate()->first();
            $values = [
                'status' => $validated['status'],
                'minutes_late' => $validated['status'] === 'late' ? (int)($validated['minutes_late'] ?? 0) : 0,
                'updated_at' => now(),
            ];
            if ($row) DB::table('student_attendance')->where('id', $row->id)->update($values);
            else DB::table('student_attendance')->insert(array_merge($where, $values, ['created_at' => now()]));
            DB::table('sms_audit_logs')->insert([
                'institution_id' => SmsAccess::institutionId(),
                'actor_user_id' => $request->user()->id,
                'action' => 'attendance.record',
                'resource_type' => 'student_attendance',
                'resource_id' => (string) $validated['student_id'],
                'created_at' => now(),
            ]);
        });
        return redirect()->route('attendance.mark', ['attendance_session_id' => $validated['attendance_session_id']])
            ->with('success', 'Attendance saved.');
    }
}
