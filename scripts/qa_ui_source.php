<?php
/** CampusSphere source-level QA; does not require Laravel or access a database. */
$root = dirname(__DIR__);
$checks = [
    'layout_skip_link' => str_contains(file_get_contents($root.'/resources/views/layouts/app.blade.php'), 'href="#main-content"'),
    'layout_main_landmark' => str_contains(file_get_contents($root.'/resources/views/layouts/app.blade.php'), 'id="main-content"'),
    'navigation_keyboard_support' => str_contains(file_get_contents($root.'/public/js/erp-ui.js'), "event.key === 'Escape'"),
    'nav_module_filter' => str_contains(file_get_contents($root.'/public/js/erp-ui.js'), 'data-nav-module'),
    'attendance_filters_enrollment' => str_contains(file_get_contents($root.'/app/Http/Controllers/AttendanceController.php'), "->where('e.class_section_id'"),
    'attendance_permissions' => str_contains(file_get_contents($root.'/app/Http/Controllers/AttendanceController.php'), "SmsAccess::require('attendance.record')"),
    'test_db_protection' => str_contains(file_get_contents($root.'/tests/TestCase.php'), 'REFUSING TO RUN TESTS'),
    'csrf_attendance' => str_contains(file_get_contents($root.'/resources/views/attendance/mark.blade.php'), '@csrf'),
    'csrf_student' => str_contains(file_get_contents($root.'/resources/views/students/form.blade.php'), '@csrf'),
    'feature_journey_test' => is_file($root.'/tests/Feature/Sms/StudentAttendanceJourneyTest.php'),
];
foreach ($checks as $name => $ok) echo ($ok?'PASS':'FAIL')."  {$name}\n";
exit(in_array(false,$checks,true) ? 1 : 0);
