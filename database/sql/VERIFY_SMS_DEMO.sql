-- SQL verification queries. Run AFTER installing and seeding your demo database.
SELECT i.id, i.name, i.type, COUNT(DISTINCT s.id) AS students,
  COUNT(DISTINCT e.id) AS employees
FROM institutions i
LEFT JOIN students s ON s.institution_id=i.id
LEFT JOIN employees e ON e.institution_id=i.id
GROUP BY i.id, i.name, i.type ORDER BY i.id;

SELECT i.name AS institution, inv.invoice_no, inv.total_amount, inv.paid_amount,
       (inv.total_amount - inv.paid_amount) AS outstanding
FROM student_invoices inv JOIN institutions i ON i.id=inv.institution_id
ORDER BY i.id;

SELECT i.name AS institution, j.journal_no, COUNT(l.id) AS lines,
       SUM(l.debit) AS total_debit, SUM(l.credit) AS total_credit,
       IF(SUM(l.debit)=SUM(l.credit), 'BALANCED', 'ERROR') AS journal_status
FROM ledger_journals j
JOIN institutions i ON i.id=j.institution_id
JOIN ledger_lines l ON l.institution_id=j.institution_id AND l.ledger_journal_id=j.id
GROUP BY i.name, j.journal_no ORDER BY i.name, j.journal_no;

SELECT i.name AS institution, s.name AS student, hp.sabaq, hp.sabqi,
       hp.manzil, hp.accuracy_percent
FROM hifz_progress_logs hp
JOIN hifz_enrollments he ON he.id=hp.hifz_enrollment_id AND he.institution_id=hp.institution_id
JOIN students s ON s.id=he.student_id AND s.institution_id=hp.institution_id
JOIN institutions i ON i.id=s.institution_id;
