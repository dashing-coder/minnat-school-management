<?php

declare(strict_types=1);
namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

/** Read-only regression checks; no DB and no Laravel startup needed. */
final class SmsDemoFixtureQualityTest extends TestCase
{
    private static array $fixtures;
    public static function setUpBeforeClass(): void
    {
        self::$fixtures = json_decode((string)file_get_contents(dirname(__DIR__,2).'/database/seeders/data/sms_demo_fixtures.json'), true, 512, JSON_THROW_ON_ERROR);
    }
    public function test_school_admin_email_has_one_demo_account(): void
    {
        $accounts = array_filter(self::$fixtures['users'], fn($r) => $r['email']==='admin.school@example.test');
        self::assertCount(1, $accounts);
    }
    public function test_each_fee_payment_has_posted_state_and_tenant_matching_invoice(): void
    {
        $invoiceIds = array_column(self::$fixtures['student_invoices'],null,'id');
        foreach (self::$fixtures['student_payments'] as $payment) {
            self::assertSame('posted',$payment['status']);
            self::assertSame($invoiceIds[$payment['student_invoice_id']]['institution_id'],$payment['institution_id']);
        }
    }
    public function test_each_payroll_net_matches_earning_and_deduction_items(): void
    {
        foreach (self::$fixtures['payslips'] as $slip) {
            $items = array_values(array_filter(self::$fixtures['payslip_items'],fn($r) => $r['payslip_id']===$slip['id']));
            $earn = array_sum(array_map(fn($r)=>(int)round((float)$r['amount']*100),array_filter($items,fn($r)=>$r['item_type']==='earning')));
            $deduct = array_sum(array_map(fn($r)=>(int)round((float)$r['amount']*100),array_filter($items,fn($r)=>$r['item_type']==='deduction')));
            self::assertSame((int)round((float)$slip['gross_amount']*100),$earn);
            self::assertSame((int)round((float)$slip['deduction_amount']*100),$deduct);
            self::assertSame((int)round((float)$slip['net_amount']*100),$earn-$deduct);
        }
    }
    public function test_exam_marks_do_not_exceed_maximum_paper_marks(): void
    {
        $papers = array_column(self::$fixtures['exam_papers'],null,'id');
        foreach (self::$fixtures['exam_marks'] as $mark) {
            $paper=$papers[$mark['exam_paper_id']];
            self::assertSame($paper['institution_id'],$mark['institution_id']);
            self::assertGreaterThanOrEqual(0,(float)$mark['marks']);
            self::assertLessThanOrEqual((float)$paper['full_marks'],(float)$mark['marks']);
        }
    }
}
