<?php

declare(strict_types=1);

namespace Tests\Unit;

use App\Support\SmsTablePolicy;
use App\Support\SmsWorkflowCatalog;
use PHPUnit\Framework\TestCase;
use ReflectionClass;

final class SmsPrivacyPolicyTest extends TestCase
{
    public function test_sensitive_tables_are_not_on_the_export_allowlist(): void
    {
        $ref = new ReflectionClass(SmsTablePolicy::class);
        $exports=$ref->getReflectionConstant('EXPORTS')->getValue();
        foreach (['student_health_records','student_incidents','welfare_cases','guardians',
            'staff_appraisals','payslips','ledger_lines','bank_accounts','sms_audit_logs',
            'integration_connections'] as $table) {
            self::assertArrayNotHasKey($table,$exports);
        }
    }

    public function test_student_export_columns_cannot_include_sensitive_profile_fields(): void
    {
        $exports=(new ReflectionClass(SmsTablePolicy::class))->getReflectionConstant('EXPORTS')->getValue();
        self::assertSame(['id','admission_no','name','campus_id','status'],$exports['students']);
    }

    public function test_new_finance_and_payroll_workflows_have_explicit_permissions(): void
    {
        foreach (['fee-plan-bill','payroll-post-liability','payroll-record-disbursement'] as $slug) {
            $item=SmsWorkflowCatalog::find($slug);
            self::assertNotNull($item);
            self::assertNotEmpty($item['permission']);
        }
    }
}
