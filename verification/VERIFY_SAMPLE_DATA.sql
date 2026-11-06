-- Run in phpMyAdmin after seeding. READ ONLY.
SELECT i.code AS institution, i.name, COUNT(DISTINCT s.id) AS students
FROM institutions i LEFT JOIN students s ON s.institution_id=i.id
GROUP BY i.id, i.code, i.name ORDER BY i.code;
SELECT 'students' AS metric, COUNT(*) AS records FROM students
UNION ALL SELECT 'guardians', COUNT(*) FROM guardians
UNION ALL SELECT 'enrollments', COUNT(*) FROM enrollments
UNION ALL SELECT 'student_attendance', COUNT(*) FROM student_attendance
UNION ALL SELECT 'admission_applications', COUNT(*) FROM admission_applications
UNION ALL SELECT 'examinations', COUNT(*) FROM examinations
UNION ALL SELECT 'exam_marks', COUNT(*) FROM exam_marks
UNION ALL SELECT 'student_invoices', COUNT(*) FROM student_invoices
UNION ALL SELECT 'student_payments', COUNT(*) FROM student_payments
UNION ALL SELECT 'ledger_journals', COUNT(*) FROM ledger_journals
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'hifz_progress_logs', COUNT(*) FROM hifz_progress_logs;
-- Should return no rows:
SELECT j.id, j.institution_id, SUM(l.debit) AS total_debit, SUM(l.credit) AS total_credit
FROM ledger_journals j JOIN ledger_lines l
 ON l.ledger_journal_id=j.id AND l.institution_id=j.institution_id
GROUP BY j.id,j.institution_id HAVING ABS(SUM(l.debit)-SUM(l.credit))>0.009;
-- Check school demo admin role and active membership:
SELECT u.email, i.code, m.status, r.`key` AS role
FROM users u JOIN institution_memberships m ON m.user_id=u.id
JOIN institutions i ON i.id=m.institution_id
LEFT JOIN membership_roles mr ON mr.membership_id=m.id AND mr.institution_id=i.id
LEFT JOIN institution_roles r ON r.id=mr.role_id AND r.institution_id=i.id
WHERE u.email='admin.school@example.test';
