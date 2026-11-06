-- CAMPUSSPHERE ERP READ-ONLY DATABASE CHECKS
-- Created 2026-11-06 from the supplied scm-system.sql.
-- ALL statements are SELECT. Use only on the correct, intended database.
-- The script avoids showing password hashes, keys, user addresses and medical details.

-- 01: Database identity and engine.
SELECT DATABASE() AS database_name, VERSION() AS server_version;

-- 02: Confirm table inventory; engine row counts are approximations (not exact).
SELECT COUNT(*) AS table_count FROM information_schema.tables
WHERE table_schema=DATABASE() AND table_type='BASE TABLE';

-- 03: Correct major counts. These are exact and safely aggregate only.
SELECT
  (SELECT COUNT(*) FROM institutions) AS institutions,
  (SELECT COUNT(*) FROM campuses) AS campuses,
  (SELECT COUNT(*) FROM users) AS users,
  (SELECT COUNT(*) FROM institution_memberships) AS memberships,
  (SELECT COUNT(*) FROM sms_permissions) AS permission_catalog,
  (SELECT COUNT(*) FROM students) AS students,
  (SELECT COUNT(*) FROM guardians) AS guardians,
  (SELECT COUNT(*) FROM enrollments) AS enrollments,
  (SELECT COUNT(*) FROM admission_applications) AS admissions,
  (SELECT COUNT(*) FROM employees) AS employees,
  (SELECT COUNT(*) FROM attendance_sessions) AS attendance_sessions,
  (SELECT COUNT(*) FROM student_attendance) AS student_attendance,
  (SELECT COUNT(*) FROM exam_marks) AS exam_marks,
  (SELECT COUNT(*) FROM published_results) AS published_results,
  (SELECT COUNT(*) FROM student_invoices) AS invoices,
  (SELECT COUNT(*) FROM student_payments) AS student_payments,
  (SELECT COUNT(*) FROM ledger_journals) AS ledger_journals,
  (SELECT COUNT(*) FROM ledger_lines) AS ledger_lines,
  (SELECT COUNT(*) FROM payslips) AS payslips,
  (SELECT COUNT(*) FROM hifz_progress_logs) AS hifz_progress_logs,
  (SELECT COUNT(*) FROM library_loans) AS library_loans;

-- 04: Active institution overview; does not show person details.
SELECT id, code, name, type, status
FROM institutions ORDER BY id;

-- 05: Per-institution sample-data counts.
SELECT i.id, i.code, i.status,
       (SELECT COUNT(*) FROM students s WHERE s.institution_id=i.id) AS students,
       (SELECT COUNT(*) FROM employees e WHERE e.institution_id=i.id) AS employees,
       (SELECT COUNT(*) FROM student_invoices inv WHERE inv.institution_id=i.id) AS invoices,
       (SELECT COUNT(*) FROM ledger_journals j WHERE j.institution_id=i.id) AS journals
FROM institutions i ORDER BY i.id;

-- 06: RBAC diagnostics (aggregated; no user emails disclosed).
SELECT i.code, r.`key` AS role_key, COUNT(DISTINCT p.permission_id) AS assigned_permissions,
       COUNT(DISTINCT mr.membership_id) AS assigned_memberships
FROM institution_roles r
JOIN institutions i ON i.id=r.institution_id
LEFT JOIN institution_role_permissions p ON p.role_id=r.id
LEFT JOIN membership_roles mr ON mr.role_id=r.id AND mr.institution_id=r.institution_id
GROUP BY i.code, r.id, r.`key`
ORDER BY i.code, role_key;

-- 07: Active memberships which lack any assigned roles.
SELECT m.institution_id, m.id AS membership_id
FROM institution_memberships m
LEFT JOIN membership_roles mr ON mr.institution_id=m.institution_id AND mr.membership_id=m.id
WHERE m.status='active'
GROUP BY m.institution_id, m.id HAVING COUNT(mr.role_id)=0;

-- 08: Unbalanced posted journals or journals with fewer than two lines.
SELECT j.institution_id, j.id AS journal_id, j.journal_no,
       COUNT(l.id) AS line_count,
       COALESCE(SUM(l.debit),0) AS debits,
       COALESCE(SUM(l.credit),0) AS credits
FROM ledger_journals j
LEFT JOIN ledger_lines l ON l.institution_id=j.institution_id AND l.ledger_journal_id=j.id
WHERE j.status='posted'
GROUP BY j.institution_id, j.id, j.journal_no
HAVING COUNT(l.id)<2 OR ABS(COALESCE(SUM(l.debit-l.credit),0))>0.009;

-- 09: Duplicate source references that could cause double posting.
SELECT institution_id, source_type, source_reference, COUNT(*) AS journal_count
FROM ledger_journals
WHERE source_reference IS NOT NULL AND source_reference<>''
GROUP BY institution_id, source_type, source_reference HAVING COUNT(*)>1;

-- 10: Invoice total and payment boundary anomalies.
SELECT institution_id, id AS invoice_id, invoice_no, total_amount, paid_amount, status
FROM student_invoices
WHERE total_amount < 0 OR paid_amount < 0 OR paid_amount > total_amount;

-- 11: Payments that are not balanced by their recorded allocations.
SELECT p.institution_id, p.id AS payment_id, p.amount,
       COALESCE(SUM(a.amount),0) AS allocated
FROM student_payments p
LEFT JOIN payment_allocations a
  ON a.institution_id=p.institution_id AND a.student_payment_id=p.id
WHERE p.status='posted'
GROUP BY p.institution_id,p.id,p.amount
HAVING ABS(p.amount-COALESCE(SUM(a.amount),0))>0.009;

-- 12: Cross-institution student/guardian links (should return zero rows).
SELECT sg.institution_id, sg.id AS link_id
FROM student_guardians sg
JOIN students s ON s.id=sg.student_id
JOIN guardians g ON g.id=sg.guardian_id
WHERE s.institution_id<>sg.institution_id OR g.institution_id<>sg.institution_id;

-- 13: Duplicated active student enrollments by academic session.
SELECT institution_id, student_id, academic_session_id, COUNT(*) AS active_enrollments
FROM enrollments WHERE status='active'
GROUP BY institution_id, student_id, academic_session_id HAVING COUNT(*)>1;

-- 14: Student exam marks above full marks or below zero.
SELECT m.institution_id,m.id AS mark_id,m.marks,p.full_marks
FROM exam_marks m
JOIN exam_papers p ON p.id=m.exam_paper_id AND p.institution_id=m.institution_id
WHERE m.marks<0 OR m.marks>p.full_marks;

-- 15: Published exams without any result rows.
SELECT e.institution_id,e.id AS examination_id,e.name
FROM examinations e
LEFT JOIN published_results p ON p.institution_id=e.institution_id AND p.examination_id=e.id
WHERE e.status='published'
GROUP BY e.institution_id,e.id,e.name HAVING COUNT(p.id)=0;

-- 16: Inventory stock below zero.
SELECT i.institution_id,i.id AS item_id,i.sku,
       COALESCE(SUM(m.quantity),0) AS stock_balance
FROM inventory_items i
LEFT JOIN stock_movements m ON m.institution_id=i.institution_id AND m.inventory_item_id=i.id
GROUP BY i.institution_id,i.id,i.sku
HAVING COALESCE(SUM(m.quantity),0)<0;

-- 17: Multiple active hostel assignments to the same physical bed.
SELECT institution_id,hostel_bed_id,COUNT(*) AS active_allocations
FROM hostel_allocations WHERE status='active'
GROUP BY institution_id,hostel_bed_id HAVING COUNT(*)>1;

-- 18: Check whether optional database sessions table exists.
SELECT COUNT(*) AS has_sessions_table
FROM information_schema.tables
WHERE table_schema=DATABASE() AND table_name='sessions';
