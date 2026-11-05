<?php
namespace App\Http\Controllers;

use App\Support\ModuleCatalog;
use App\Support\SmsAccess;

final class DashboardController {
    public function index() {
        if (!SmsAccess::has('dashboard.view')) return redirect()->route('portal');

        // A dashboard.view role must not implicitly receive HR, student, admissions
        // or financial records; each metric is separately permission-checked.
        $definitions = [
            'students' => ['label' => 'Students', 'permission' => 'students.view'],
            'employees' => ['label' => 'Teachers & Staff', 'permission' => 'hr.view'],
            'admission_applications' => ['label' => 'Applications', 'permission' => 'admissions.view'],
            'student_invoices' => ['label' => 'Fee Invoices', 'permission' => 'fees.view'],
        ];
        $metrics = [];
        foreach ($definitions as $table => $definition) {
            if (!SmsAccess::has($definition['permission'])) continue;
            $metrics[] = [
                'label' => $definition['label'],
                'value' => SmsAccess::scopedQuery($table)->count(),
            ];
        }
        $modules = collect(ModuleCatalog::all())
            ->filter(fn($module) => SmsAccess::has($module['permission']))->all();
        $canFinance = SmsAccess::has('fees.view');
        $canStudents = SmsAccess::has('students.view');
        $canAcademics = SmsAccess::has('academics.manage');

        $students = $canStudents
            ? SmsAccess::scopedQuery('students')->orderByDesc('id')->limit(5)->get()
            : collect();
        $notices = SmsAccess::scopedQuery('notices')->orderByDesc('id')->limit(4)->get();
        $totalFees = $canFinance
            ? SmsAccess::scopedQuery('student_invoices')->sum('total_amount') : 0;
        $paidFees = $canFinance
            ? SmsAccess::scopedQuery('student_invoices')->sum('paid_amount') : 0;

        return view('dashboard', compact('metrics', 'modules', 'students', 'notices',
            'totalFees', 'paidFees', 'canFinance', 'canStudents', 'canAcademics'));
    }
}
