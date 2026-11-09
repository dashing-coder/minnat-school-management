<?php
/**
 * CampusSphere dependency-free, read-only offline QA of bundled demo fixtures.
 * Usage: php scripts/qa_demo_fixture.php [--json]
 * No Laravel bootstrap, network, database connection, migrations, or writes.
 */
declare(strict_types=1);

$root = dirname(__DIR__);
$fixture = $root.'/database/seeders/data/sms_demo_fixtures.json';
$results = [];
$recordCount = 0;
$add = static function (string $id, bool $pass, string $details) use (&$results): void {
    $results[] = ['check' => $id, 'status' => $pass ? 'PASS' : 'FAIL', 'detail' => $details];
};
try {
    $data = json_decode((string)file_get_contents($fixture), true, 512, JSON_THROW_ON_ERROR);
    if (!is_array($data)) throw new RuntimeException('Fixture root is not an object');
} catch (Throwable $e) {
    fwrite(STDERR, 'Cannot read fixtures: '.$e->getMessage().PHP_EOL);
    exit(2);
}
$lookup = static function (string $table, int $id) use (&$data): ?array {
    foreach ($data[$table] ?? [] as $row) if (isset($row['id']) && (int)$row['id'] === $id) return $row;
    return null;
};
$sum = static function (array $rows, string $field): int {
    $total = 0;
    foreach ($rows as $row) {
        $value = (string)($row[$field] ?? '0');
        if (!preg_match('/^\d{1,12}(?:\.\d{1,2})?$/D', $value)) throw new InvalidArgumentException('Invalid demo money: '.$value);
        [$whole,$fraction] = array_pad(explode('.',$value,2),2,'');
        $total += ((int)$whole)*100 + ((int)str_pad($fraction,2,'0'));
    }
    return $total;
};
$idsOK = true; $duplicateTables = [];
foreach ($data as $table => $rows) {
    if (!is_array($rows)) { $idsOK = false; continue; }
    $recordCount += count($rows);
    $ids = [];
    foreach ($rows as $row) {
        if (!isset($row['id'])) continue;
        $id = (int)$row['id'];
        if (isset($ids[$id]) || $id <= 0) { $idsOK=false; $duplicateTables[]=$table; }
        $ids[$id] = true;
    }
}
$add('UNIQUE_RECORD_IDS', $idsOK, 'Duplicate IDs in '.implode(',',array_unique($duplicateTables)));
$add('DEMO_ADMIN_IDENTITY', count(array_filter($data['users'] ?? [], static fn($u) => ($u['email']??null)==='admin.school@example.test')) === 1,
    'School demonstration administrator record must exist exactly once');
$tenantCodes = array_column($data['institutions'] ?? [], 'code'); sort($tenantCodes);
$add('THREE_INSTITUTIONS', $tenantCodes === ['COLDEMO','MADDEMO','SCHDEMO'], implode(', ', $tenantCodes));
$tenants = array_column($data['institutions'] ?? [], 'id');
$badTenant = [];
foreach ($data as $table => $rows) foreach ($rows as $row) {
    if (!isset($row['institution_id'])) continue;
    if (!in_array((int)$row['institution_id'], array_map('intval',$tenants),true)) $badTenant[]=$table;
}
$add('TENANT_KEYS_VALID', !$badTenant, 'Unrecognized institution reference in: '.implode(',',array_unique($badTenant)));
$studentViolations = [];
foreach ($data['students'] ?? [] as $row) {
    $campus = $lookup('campuses',(int)$row['campus_id']);
    if (!$campus || (int)$row['institution_id'] !== (int)$campus['institution_id']) $studentViolations[]=$row['id'];
}
$add('STUDENT_CAMPUS_ISOLATION', !$studentViolations, 'Incorrect student IDs: '.implode(',',$studentViolations));
$invoiceProblems = [];
foreach ($data['student_invoices'] ?? [] as $invoice) {
    $tenant = (int)$invoice['institution_id']; $id=(int)$invoice['id'];
    $student=$lookup('students',(int)$invoice['student_id']);
    $lines = array_values(array_filter($data['student_invoice_lines'] ?? [],static fn($r)=> (int)$r['student_invoice_id']===$id));
    $alloc = array_values(array_filter($data['payment_allocations'] ?? [],static fn($r)=> (int)$r['student_invoice_id']===$id));
    $paidRefunds = [];
    foreach ($data['payment_refunds'] ?? [] as $r) {
        if (!in_array($r['status'],['approved','processed'],true)) continue;
        $p=$lookup('student_payments',(int)$r['student_payment_id']);
        if ($p && (int)$p['student_invoice_id']===$id) $paidRefunds[]=$r;
    }
    if (!$student || (int)$student['institution_id']!==$tenant ||
        $sum($lines,'amount')!==$sum([$invoice],'total_amount') ||
        $sum($alloc,'amount')-$sum($paidRefunds,'amount')!==$sum([$invoice],'paid_amount')) $invoiceProblems[]=$id;
}
$add('INVOICES_AND_ALLOCATIONS', !$invoiceProblems, 'Mismatched invoice IDs: '.implode(',',$invoiceProblems));
$invalidPayments = [];
foreach ($data['student_payments'] ?? [] as $p) {
    $s=$lookup('students',(int)$p['student_id']); $inv=$lookup('student_invoices',(int)$p['student_invoice_id']);
    if (!in_array($p['status'],['posted'],true) || !$s || !$inv ||
      (int)$s['institution_id'] !== (int)$p['institution_id'] ||
      (int)$inv['institution_id'] !== (int)$p['institution_id'] ||
      (int)$inv['student_id'] !== (int)$s['id']) $invalidPayments[]=$p['id'];
}
$add('POSTED_PAYMENT_REFS', !$invalidPayments, 'Problem payment IDs: '.implode(',',$invalidPayments));
$badJournals=[]; $sourceKeys=[];
foreach ($data['ledger_journals'] ?? [] as $journal) {
    $lines = array_values(array_filter($data['ledger_lines'] ?? [],static fn($r)=> (int)$r['ledger_journal_id']===(int)$journal['id']));
    $key=$journal['institution_id'].'|'.$journal['source_type'].'|'.($journal['source_reference'] ?? '');
    if ((count($lines)<2) || $sum($lines,'debit')!==$sum($lines,'credit') ||
       (isset($sourceKeys[$key]) && ($journal['source_reference']??null)!==null)) $badJournals[]=$journal['id'];
    foreach ($lines as $line) if ((int)$line['institution_id'] !== (int)$journal['institution_id']) $badJournals[]=$journal['id'];
    $sourceKeys[$key]=true;
}
$add('BALANCED_POSTED_JOURNALS', !$badJournals, 'Problem journal IDs: '.implode(',',array_unique($badJournals)));
$badPayslips=[];
foreach ($data['payslips'] ?? [] as $slip) {
    $items = array_values(array_filter($data['payslip_items'] ?? [],static fn($it)=> (int)$it['payslip_id']===(int)$slip['id']));
    $earnings=array_values(array_filter($items,static fn($it)=>$it['item_type']==='earning'));
    $deductions=array_values(array_filter($items,static fn($it)=>$it['item_type']==='deduction'));
    $gross=$sum($earnings,'amount'); $deduct=$sum($deductions,'amount');
    if ($gross!==$sum([$slip],'gross_amount') || $deduct!==$sum([$slip],'deduction_amount') ||
       $gross-$deduct!==$sum([$slip],'net_amount')) $badPayslips[]=$slip['id'];
    foreach ($deductions as $item) {
        $account=$lookup('chart_of_accounts',(int)($item['liability_account_id']??0));
        if (!$account || (int)$account['institution_id'] !== (int)$slip['institution_id'] || $account['account_type']!=='liability')
            $badPayslips[]=$slip['id'];
    }
}
$add('PAYROLL_ITEM_RECONCILIATION', !$badPayslips, 'Problem payslip IDs: '.implode(',',array_unique($badPayslips)));
$badAttendance=[];
foreach ($data['student_attendance'] ?? [] as $a) {
    $student=$lookup('students',(int)$a['student_id']);
    $session=$lookup('attendance_sessions',(int)$a['attendance_session_id']);
    if (!$student || !$session || (int)$student['institution_id'] !== (int)$a['institution_id'] ||
        (int)$session['institution_id'] !== (int)$a['institution_id']) $badAttendance[]=$a['id'];
}
$add('ATTENDANCE_TENANT_LINKS', !$badAttendance, 'Problem attendance IDs: '.implode(',',$badAttendance));
$badMarks=[];
foreach ($data['exam_marks'] ?? [] as $mark) {
    $paper=$lookup('exam_papers',(int)$mark['exam_paper_id']);
    if (!$paper || (int)$mark['institution_id'] !== (int)$paper['institution_id'] ||
        (float)$mark['marks']<0 || (float)$mark['marks']>(float)$paper['full_marks']) $badMarks[]=$mark['id'];
}
$add('EXAM_MARK_LIMITS', !$badMarks, 'Problem mark IDs: '.implode(',',$badMarks));
$badBeds=[]; $occupied=[];
foreach ($data['hostel_allocations'] ?? [] as $alloc) {
    if ($alloc['status']!=='active') continue;
    $key=$alloc['institution_id'].':'.$alloc['hostel_bed_id'];
    if (isset($occupied[$key])) $badBeds[]=$alloc['hostel_bed_id'];
    $occupied[$key]=1;
}
$add('HOSTEL_BED_UNIQUENESS', !$badBeds, 'Double-booked bed IDs: '.implode(',',$badBeds));
$allPassed = !in_array('FAIL',array_column($results,'status'),true);
$report=['dataset'=>'bundled fixtures, not current MySQL data','fixture_rows'=>$recordCount,
    'fixture_tables'=>count($data),'checks'=>$results,'passed'=>count(array_filter($results,fn($r)=>$r['status']==='PASS')),
    'failed'=>count(array_filter($results,fn($r)=>$r['status']==='FAIL')),'status'=>$allPassed?'PASS':'FAIL'];
if (in_array('--json',$argv,true)) echo json_encode($report,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES).PHP_EOL;
else { foreach ($results as $r) echo '['.$r['status'].'] '.$r['check'].' — '.$r['detail'].PHP_EOL;
    echo 'Fixture records: '.$recordCount.'; '.count($data).' tables; result: '.$report['status'].PHP_EOL; }
exit($allPassed?0:1);
