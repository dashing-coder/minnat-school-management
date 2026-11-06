-- CampusSphere ERP read-only operational checks (MariaDB 10.4 / MySQL 8).
-- Run SELECT only. Review independently before using on a production copy.
-- 1. Current tenant / sample status
SELECT i.id,i.code,i.name,i.status,
       (SELECT COUNT(*) FROM students s WHERE s.institution_id=i.id) AS students,
       (SELECT COUNT(*) FROM student_invoices v WHERE v.institution_id=i.id) AS invoices,
       (SELECT COUNT(*) FROM ledger_journals j WHERE j.institution_id=i.id) AS journals
FROM institutions i ORDER BY i.id;

-- 2. Individual posted journals with missing/imbalanced entries (should return 0 rows)
SELECT j.institution_id,j.id,j.journal_no,
       COUNT(l.id) AS line_count, COALESCE(SUM(l.debit),0) AS debit_total,
       COALESCE(SUM(l.credit),0) AS credit_total
FROM ledger_journals j LEFT JOIN ledger_lines l
  ON l.institution_id=j.institution_id AND l.ledger_journal_id=j.id
WHERE j.status='posted'
GROUP BY j.institution_id,j.id,j.journal_no
HAVING COUNT(l.id)<2 OR ABS(COALESCE(SUM(l.debit),0)-COALESCE(SUM(l.credit),0))>0.009;

-- 3. Duplicated journal source references (must return 0 rows before uniqueness migration)
SELECT institution_id,source_type,source_reference,COUNT(*) AS duplicate_count
FROM ledger_journals WHERE source_reference IS NOT NULL
GROUP BY institution_id,source_type,source_reference HAVING COUNT(*)>1;

-- 4. Invoice total vs itemized lines (should return 0 rows)
SELECT i.institution_id,i.id,i.invoice_no,i.total_amount,
       COALESCE(SUM(l.amount),0) AS itemized_amount
FROM student_invoices i LEFT JOIN student_invoice_lines l
  ON l.institution_id=i.institution_id AND l.student_invoice_id=i.id
GROUP BY i.institution_id,i.id,i.invoice_no,i.total_amount
HAVING ABS(i.total_amount-COALESCE(SUM(l.amount),0))>0.009;

-- 5. Invoice paid vs allocation minus approved refunds (should return 0 rows)
SELECT i.institution_id,i.id,i.invoice_no,i.paid_amount,
 COALESCE(a.allocated,0) AS allocated,COALESCE(r.refunded,0) AS refunded
FROM student_invoices i
LEFT JOIN (
  SELECT institution_id,student_invoice_id,SUM(amount) AS allocated FROM payment_allocations
  GROUP BY institution_id,student_invoice_id
) a ON a.institution_id=i.institution_id AND a.student_invoice_id=i.id
LEFT JOIN (
 SELECT p.institution_id,p.student_invoice_id,SUM(r.amount) AS refunded
 FROM payment_refunds r JOIN student_payments p
 ON p.institution_id=r.institution_id AND p.id=r.student_payment_id
 WHERE r.status IN ('approved','processed')
 GROUP BY p.institution_id,p.student_invoice_id
) r ON r.institution_id=i.institution_id AND r.student_invoice_id=i.id
WHERE ABS(i.paid_amount-(COALESCE(a.allocated,0)-COALESCE(r.refunded,0)))>0.009;

-- 6. Exam marks beyond their valid paper maximum (should return 0 rows)
SELECT m.institution_id,m.id,m.student_id,m.marks,p.full_marks
FROM exam_marks m JOIN exam_papers p ON p.institution_id=m.institution_id AND p.id=m.exam_paper_id
WHERE m.marks<0 OR m.marks>p.full_marks;

-- 7. Broken payroll arithmetic (should return 0 rows)
SELECT institution_id,id,employee_id,gross_amount,deduction_amount,net_amount
FROM payslips WHERE ABS(gross_amount-deduction_amount-net_amount)>0.009;

-- 8. Hostel double allocation (should return 0 rows)
SELECT institution_id,hostel_bed_id,COUNT(*) AS active_count
FROM hostel_allocations WHERE status='active'
GROUP BY institution_id,hostel_bed_id HAVING COUNT(*)>1;
