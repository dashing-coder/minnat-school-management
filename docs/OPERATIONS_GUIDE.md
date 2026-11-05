# Guided ERP operations — local development manual

Log in as an authorized account and select your school, college or madrasha. Your chosen institution is stored in a server-side Laravel session. Use the left navigation to open any of the 20 modules. Each module displays authorized data registers, links to new guided workflows, and available operational reports.

## Example end-to-end workflows

**Admissions → student lifecycle**

1. Create academic session, campus and class levels under Institutions/Academics.
2. Open Admissions → Register admission application, then Approve admission offer.
3. Create a student in Student Directory, then Confirm admission against student ID.
4. Open Academic Lifecycle → Enroll student. Choose the same campus as the student's profile.
5. Student promotion creates a separate enrollment history rather than overwriting prior enrollment records.

**Academic timetable → attendance → examination**

1. Create subjects, class sections, class-subject records and teacher assignments.
2. Academics → Schedule conflict-free lesson; class, room (same campus) and teacher overlap checks apply.
3. Create an attendance session (read-only in the baseline; session setup may require custom administration), then Attendance → Mark student.
4. Define exam/papers/grading bands under editable registers; Exams → Enter examination mark.
5. Exams → Calculate and publish results requires complete marks for eligible enrolled students. Published exams are locked.

**Fees → general ledger → bank comparison**

1. Create institution-specific chart-of-accounts asset/income accounts, fee head linked to an income account, and payment methods. You may need the local demo reference repair if upgrading legacy fixtures.
2. Fees → Issue fee invoice & journal. Uses the selected receivables asset account and the fee head's revenue account.
3. Fees → Collect payment & journal. Invoice outstanding balance is locked, duplicate reference numbers rejected, and payment is posted to the same invoice receivables account.
4. Fees → Request fee refund. A **different** authorized approver completes Approve and post refund; the posting accounts are derived from original journals.
5. Finance reports provide Fee Aging and Trial Balance; bank comparison reports ledger-vs-statement variance, not a complete bank transaction matching system.

**HR & payroll**

1. Create employee salary profiles under HR master records.
2. HR → Generate draft payroll, then a **different** authorized payroll approver approves it.
3. These payslips reflect basic salary only. No bank payment or salary-tax posting has occurred.

**Library / Residential / Inventory / Hifz**

- Library: create book and physical copy, issue a copy, then return an open loan.
- Hostel: create hostel, room and vacant bed; allocate only to a student on that campus.
- Transport: configure vehicle, route and stop; assign student to a stop on the same route.
- Inventory: create stock item and record stock in/out; negative stock and duplicate item references are blocked.
- Hifz: create group and enrollment, then record Sabaq, Sabqi, Manzil, completed Juz and accuracy.

**Certificates:** after issuing a certificate, retrieve its verification token only through an appropriately secured administrative process. The public path `/verify/certificate/{token}` exposes limited document metadata and does not authenticate student identity.

## Security requirements

- Only appropriate users should have data-view and write permissions. A module link does not grant edit authorization.
- Generic master-data edits do **not** allow modifying payments, ledger entries, published marks, refunds or audit logs.
- Multi-institution isolation is enforced by tenant-scoped queries; access for campus-restricted users is deliberately fail-closed on ambiguous relations.
- Local demonstration user provisioning is disabled outside `APP_ENV=local|testing`. It is not a substitute for production invitation/email-verification flows.
- No external notification, bank settlement or online payment is simulated as a successful production transaction.

**Required verification:** `php artisan migrate:status`, `php artisan route:list`, `php artisan sms:qa`, `php artisan test`, and hands-on end-to-end tests with multiple institutions and roles.
