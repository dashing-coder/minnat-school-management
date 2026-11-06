> **2026-11-06 update:** This matrix describes the earlier baseline. See `docs/release/SCM_FIXES_AND_REMAINING_WORK.md` for the current staging patch, including 30 guided workflows and remaining release blockers.

# CampusSphere ERP — 18-phase delivery and verification matrix

**Version:** Expanded Laravel source development release — 2026-11-05.

**Status convention:** `Expanded source` = some application workflows implemented, **not** fully tested and accepted. `Pending` = substantial requirements outstanding. **No phase is represented as fully verified or production-ready.**

| Phase | Area | Scope available in ZIP | Still required for full sign-off |
|---|---|---|---|
| 01 | Architecture, schema, authentication, RBAC | Laravel project, 120-table migration model, institution middleware, local-only role management | Live schema and security verification, hardened production provisioning |
| 02 | Student Information System | Directory, create/update, guardian records and 50 master edit forms | Secure uploads, advanced family linking UI, data lifecycle/privacy tests |
| 03 | Admissions | Application, offer, acceptance workflows; merit data registers | Public application portal, eligibility rules, fee collection, notifications |
| 04 | Academic & Curriculum | Programs/sections/subjects, editable master data, checked timetable creation | Full automatic routine planning, syllabus tracking, LMS delivery |
| 05 | Attendance & Leave | Attendance recording, leave requests and reviews | Device synchronization, notifications, staff biometric import |
| 06 | Exams & Results | Exam master setup, marks entry, grade bands, result calculation/publishing | Moderation, rechecks, CGPA/credit logic, board-specific exports |
| 07 | Fees & Accounting | Invoice+GL, payment+GL, refund request/approval+GL, bank balance comparison, fee report | Fee plan billing engine, statement reconciliation, formal closing, gateway settlement and audit |
| 08 | HR & Payroll | Employee register, draft basic payroll, separate approval, leave | Benefits/tax/deduction engine, disbursement journal, payslip delivery |
| 09 | Portal & Communication | Basic parent/student portal, notices/messages registers | Dedicated teacher experiences, SMS/email/WhatsApp/push delivery and consent |
| 10 | Hifz/Madrasha/College | Hifz logs and assessments, school/college academic models | Specialized completion/certification, college credits and prerequisites |
| 11 | Library & Inventory | Library issue/return, stock in/out, catalog and asset registers | RFID, purchasing posting, fines, asset depreciation controls |
| 12 | Hostel & Transport | Bed allocation, meal/vehicle/stop records, transport assignment | Live GPS, room checkout, automatic boarding billing and meal reconciliation |
| 13 | Scholarships/Donations | Scholarship masters, donations with ledger references, fund views | Restricted-fund budget controls, award approval workflow, donor self-service |
| 14 | Certificates/Welfare/Campus | Certificate issue + token verification; campus event and welfare registers | Rich certificates, secure welfare case management, gate-pass enforcement |
| 15 | Integrations & Mobile | API/integration table foundation | Live payment/SMS/biometric integrations, native apps, scheduled jobs |
| 16 | Security, Migration & QA | PHP lint, offline validation, 100 test-case checklist, read-only `sms:qa` | Run all tests against live Laravel/MySQL, tenant security, vulnerability, load and recovery testing |
| 17 | Pilot & User Acceptance | Installation and workflow documentation | Customer-staff UAT and bug-resolution evidence |
| 18 | Go-live | Deployment guide and Laravel starter | Production deployment, secure infrastructure, monitoring, backup restore drills, approvals |

## Release counts

- ERP modules in navigation: **20**
- Master tables with explicitly approved generic create/edit: **50**
- Guided workflows (explicit operations): **27**
- Operational read-only reports: **8**
- Database tables in migration model: **120** (1 users + 14 core + 105 domain)
- Fictional sample records in fixture JSON: **602**
- PHP files passing `php -l`: see `qa/OFFLINE_EXPANDED_VALIDATION.json`

## Unverified items

No complete application end-to-end tests, real device/payment integrations, live MySQL migration tests, user acceptance testing, or production deployment were performed by this release process. It should not be described as 18/18 complete.
