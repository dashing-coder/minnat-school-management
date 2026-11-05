<?php
namespace Tests\Unit;
use App\Support\EditableRegisters;
use App\Support\ModuleCatalog;
use App\Support\SmsWorkflowCatalog;
use PHPUnit\Framework\TestCase;

final class WorkflowCatalogTest extends TestCase
{
    public function test_workflows_are_declared_and_bound_to_existing_modules(): void
    {
        self::assertGreaterThanOrEqual(20,count(SmsWorkflowCatalog::ITEMS));
        foreach(SmsWorkflowCatalog::ITEMS as $slug=>$flow) {
            self::assertNotNull(ModuleCatalog::find($flow['module']),$slug);
            self::assertNotEmpty($flow['permission'],$slug);
            self::assertNotEmpty($flow['fields'],$slug);
            self::assertMatchesRegularExpression('/^[a-z-]+$/',$slug);
        }
    }
    public function test_crud_allowlist_excludes_financial_transactions(): void
    {
        self::assertGreaterThanOrEqual(40,count(EditableRegisters::FIELDS));
        foreach(['ledger_journals','ledger_lines','student_payments','payment_refunds','published_results','sms_audit_logs'] as $table) {
            self::assertNull(EditableRegisters::fields($table));
        }
    }
}
