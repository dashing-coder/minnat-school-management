# Authorization Blueprint (Draft)

No roles are automatically assigned by the starter. The `SmsPermissionSeeder` initializes permission *definitions* only. An authorized onboarding workflow must create institution roles and assign only suitable permissions to them.

| Permission / Role | Institution admin | Principal | Teacher | Accountant | Student | Guardian |
|---|---|---|---|---|---|---|
| Institution settings | Admin-only | Usually no | No | No | No | No |
| Manage campuses & memberships | Yes | Delegated | No | No | No | No |
| Student records | Authorized all | Authorized all | Assigned classes | Limited fee data | Own | Linked children |
| Attendance write | Delegate | Review | Assigned classes | No | No | No |
| Exam mark entry | No default | Oversight | Assigned subjects | No | No | No |
| Results approval/publication | Delegated | Yes | No | No | No | No |
| Collect fees | Delegated | Review | No | Yes | No | No |
| Approve refunds | Separate approver | Optional | No | **Not by default** | No | No |
| Post/reconcile GL | Delegated finance | Oversight | No | Yes | No | No |
| Payroll approval | Delegated | Optional | No | No by default | No | No |
| Audit log viewing | Limited | Limited | No | Limited finance | No | No |

**Important:** Table indicates target access *conceptually*, not exact seeded role grants. Student and guardian visibility requires **record-level** policies even when permission `students.view` is granted. Likewise, teachers need classroom/subject assignment checks and campus filters. Different institutions may customize delegation through separate roles.

## Permission catalog in starter

`dashboard.view`, `institutions.manage`, `campuses.view`, `campuses.manage`, `memberships.view`, `memberships.manage`, `roles.manage`, `students.view`, `students.create`, `students.update`, `students.export`, `admissions.view`, `admissions.manage`, `academics.manage`, `attendance.view`, `attendance.record`, `attendance.approve_correction`, `exams.view`, `marks.enter`, `results.approve`, `results.publish`, `fees.view`, `fees.collect`, `fees.adjust`, `refunds.request`, `refunds.approve`, `accounting.post`, `accounting.reconcile`, `hr.view`, `payroll.process`, `payroll.approve`, `hifz.progress.record`, `library.manage`, `hostel.manage`, `inventory.manage`, `donations.manage`, `reports.export`, `audit.view`.

New endpoints must explicitly declare required permissions. A disabled module should also block access even if a user has a stale permission. The starter has not yet implemented that module enablement guard.
