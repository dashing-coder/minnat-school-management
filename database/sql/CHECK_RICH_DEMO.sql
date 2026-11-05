-- READ ONLY. Run in phpMyAdmin's SQL tab after importing/seeding a demo database.
-- Select the correct test database first. No UPDATE/DELETE/INSERT queries here.
SELECT 'Institutions' AS entity, COUNT(*) AS total FROM institutions
UNION ALL SELECT 'Students', COUNT(*) FROM students
UNION ALL SELECT 'Guardians', COUNT(*) FROM guardians
UNION ALL SELECT 'Student attendance', COUNT(*) FROM student_attendance
UNION ALL SELECT 'Student invoices', COUNT(*) FROM student_invoices
UNION ALL SELECT 'Payments', COUNT(*) FROM student_payments
UNION ALL SELECT 'General ledger journals', COUNT(*) FROM ledger_journals
UNION ALL SELECT 'Hifz progress logs', COUNT(*) FROM hifz_progress_logs;

-- Extended sample student count: expected 24 per institution after the additive seeder.
SELECT i.code AS institution, COUNT(s.id) AS additional_students
FROM institutions i LEFT JOIN students s
  ON s.institution_id = i.id AND s.admission_no LIKE '%-EX-%'
GROUP BY i.id, i.code ORDER BY i.code;

-- Fee collection overview by institution (all sample invoices).
SELECT i.code, COUNT(inv.id) AS invoice_count,
  ROUND(COALESCE(SUM(inv.total_amount),0),2) AS billed,
  ROUND(COALESCE(SUM(inv.paid_amount),0),2) AS collected,
  ROUND(COALESCE(SUM(inv.total_amount - inv.paid_amount),0),2) AS outstanding
FROM institutions i LEFT JOIN student_invoices inv ON inv.institution_id = i.id
GROUP BY i.id, i.code ORDER BY i.code;

-- This should return ZERO rows for any unbalanced journal (including extended records).
SELECT j.institution_id, j.journal_no,
  ROUND(SUM(l.debit),2) AS total_debit,
  ROUND(SUM(l.credit),2) AS total_credit
FROM ledger_journals j JOIN ledger_lines l
 ON l.ledger_journal_id = j.id AND l.institution_id = j.institution_id
GROUP BY j.institution_id, j.id, j.journal_no
HAVING ROUND(SUM(l.debit)-SUM(l.credit),2) <> 0;

-- This should return ZERO rows for invoice/payment mismatches.
SELECT inv.institution_id, inv.invoice_no, inv.paid_amount,
  ROUND(COALESCE(SUM(a.amount),0),2) AS allocated
FROM student_invoices inv
LEFT JOIN payment_allocations a ON a.institution_id = inv.institution_id AND a.student_invoice_id = inv.id
GROUP BY inv.institution_id, inv.id, inv.invoice_no, inv.paid_amount
HAVING ROUND(inv.paid_amount - COALESCE(SUM(a.amount),0),2) <> 0;
