@extends('layouts.app')
@section('title','Mark Attendance')
@section('content')
<div class="page-title-row"><div><div class="eyebrow">ATTENDANCE / RECORD ENTRY</div><h1>Mark Student Attendance</h1><p>Select an open class session, then choose a student enrolled in that section. No database IDs to memorize.</p></div><a class="btn btn-outline" href="{{ route('module.home','attendance') }}">← Attendance Module</a></div>
<div class="form-panel">
  <h2 class="form-section-title">1. Select an attendance session</h2>
  <form method="get" action="{{ route('attendance.mark') }}" class="attendance-filter">
    <div class="form-grid">
      <div class="field"><label for="attendance-session-filter">Open class session</label>
        <select id="attendance-session-filter" name="attendance_session_id" required>
          <option value="">Choose session</option>
          @foreach($sessions as $s)<option value="{{ $s->id }}" @selected($sessionId===$s->id)>{{ $s->attendance_on }} · Section #{{ $s->class_section_id }} · {{ $s->period_code }}</option>@endforeach
        </select>
        @if($sessions->isEmpty())<p class="field-help">No open attendance sessions found. Create an attendance session in the Attendance module first.</p>@endif
      </div>
      <div class="field"><label for="attendance-student-search">Find student (optional)</label>
        <input id="attendance-student-search" name="search" type="search" maxlength="80" value="{{ $search }}" placeholder="Name or admission number">
        <p class="field-help">Only active students enrolled in this section will appear.</p>
      </div>
    </div>
    <div class="form-action-bar"><button type="submit" class="btn btn-outline">Show eligible students</button></div>
  </form>
  @if($selectedSession)
    <h2 class="form-section-title">2. Record attendance</h2>
    <form method="post" action="{{ route('attendance.store') }}" data-prevent-double-submit="true">
      @csrf
      <input type="hidden" name="attendance_session_id" value="{{ $selectedSession->id }}">
      <div class="form-grid">
        <div class="field"><label for="attendance-student">Student <span aria-hidden="true">*</span></label>
          <select id="attendance-student" name="student_id" required @error('student_id') aria-invalid="true" aria-describedby="error-student_id" @enderror>
            <option value="">Choose enrolled student</option>
            @foreach($students as $student)<option value="{{ $student->id }}" @selected((string)old('student_id')===(string)$student->id)>{{ $student->name }} · {{ $student->admission_no }}</option>@endforeach
          </select>
          @error('student_id')<small class="field-error" id="error-student_id">{{ $message }}</small>@enderror
          @if($students->isEmpty())<p class="field-help" role="status">No matching active enrollments in this class. Check the student's enrollment or clear your search.</p>@elseif($students->count()===100)<p class="field-help">Showing the first 100 students. Narrow your search to find other students.</p>@endif
        </div>
        <div class="field"><label for="attendance-status">Status</label><select id="attendance-status" name="status" required>
          @foreach(['present'=>'Present','absent'=>'Absent','late'=>'Late','excused'=>'Excused'] as $value=>$label)<option value="{{ $value }}" @selected(old('status','present')===$value)>{{ $label }}</option>@endforeach
        </select></div>
        <div class="field"><label for="minutes-late">Minutes late (only when status is Late)</label><input id="minutes-late" name="minutes_late" type="number" min="0" max="1440" value="{{ old('minutes_late',0) }}"></div>
      </div>
      <div class="form-footer"><span>Existing attendance is updated; each submission is audited.</span><button class="btn btn-primary" type="submit" @disabled($students->isEmpty())>Save Attendance →</button></div>
    </form>
  @else
    <div class="info-hint" role="status">Choose a session and select “Show eligible students” to continue.</div>
  @endif
</div>
@endsection
