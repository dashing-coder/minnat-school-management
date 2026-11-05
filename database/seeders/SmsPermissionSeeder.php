<?php

declare(strict_types=1);

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SmsPermissionSeeder extends Seeder
{
    public function run(): void
    {
        // Permission catalog only: NEVER auto-grant all privileges to new users.
        $catalog = [
            'dashboard.view' => ['dashboard', 'View dashboard'],
            'institutions.manage' => ['institutions', 'Manage institution settings'],
            'campuses.view' => ['campuses', 'View authorized campuses'],
            'campuses.manage' => ['campuses', 'Manage campuses'],
            'memberships.view' => ['security', 'View institution memberships'],
            'memberships.manage' => ['security', 'Manage institution memberships'],
            'roles.manage' => ['security', 'Manage role assignments'],
            'students.view' => ['students', 'View authorized student records'],
            'students.create' => ['students', 'Create student records'],
            'students.update' => ['students', 'Update authorized student records'],
            'students.export' => ['students', 'Export authorized student records'],
            'admissions.view' => ['admissions', 'View admissions'],
            'admissions.manage' => ['admissions', 'Manage admissions'],
            'academics.manage' => ['academics', 'Manage curriculum and classes'],
            'attendance.view' => ['attendance', 'View attendance'],
            'attendance.record' => ['attendance', 'Record assigned attendance'],
            'attendance.approve_correction' => ['attendance', 'Approve attendance corrections'],
            'exams.view' => ['examinations', 'View examinations'],
            'marks.enter' => ['examinations', 'Enter assigned subject marks'],
            'results.approve' => ['examinations', 'Approve examination results'],
            'results.publish' => ['examinations', 'Publish examination results'],
            'fees.view' => ['finance', 'View fee information'],
            'fees.collect' => ['finance', 'Collect approved fees'],
            'fees.adjust' => ['finance', 'Manage authorized fee adjustments'],
            'refunds.request' => ['finance', 'Request refund'],
            'refunds.approve' => ['finance', 'Approve refund'],
            'accounting.post' => ['finance', 'Post journal transactions'],
            'accounting.reconcile' => ['finance', 'Reconcile accounts'],
            'hr.view' => ['hr', 'View authorized staff data'],
            'payroll.process' => ['hr', 'Process payroll'],
            'payroll.approve' => ['hr', 'Approve payroll'],
            'hifz.progress.record' => ['hifz', 'Record assigned Hifz progress'],
            'library.manage' => ['library', 'Manage library'],
            'hostel.manage' => ['hostel', 'Manage hostel operations'],
            'inventory.manage' => ['inventory', 'Manage institutional inventory'],
            'donations.manage' => ['donations', 'Manage donations and restricted funds'],
            'reports.export' => ['reports', 'Export authorized reports'],
            'audit.view' => ['security', 'View authorized audit logs'],
        ];

        $rows = [];
        foreach ($catalog as $key => [$module, $label]) {
            $rows[] = [
                'key' => $key,
                'module' => $module,
                'label' => $label,
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }
        DB::table('sms_permissions')->upsert($rows, ['key'], ['module', 'label', 'updated_at']);
    }
}
