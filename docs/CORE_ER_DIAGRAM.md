# Core ER Diagram — Laravel/MySQL

The diagram highlights major relationships; the complete schema has 105 additional domain tables. Each tenant-owned relationship uses institution_id as part of its foreign key.

```mermaid
erDiagram
    institutions ||--o{ campuses : has
    institutions ||--o{ academic_sessions : uses
    institutions ||--o{ institution_memberships : grants
    users ||--o{ institution_memberships : joins
    institution_memberships ||--o{ membership_roles : holds
    institution_roles ||--o{ membership_roles : assigns
    campuses ||--o{ students : enrolls
    students ||--o{ student_guardians : has
    guardians ||--o{ student_guardians : links
    students ||--o{ enrollments : has
    academic_sessions ||--o{ enrollments : contains
    class_sections ||--o{ enrollments : groups
    students ||--o{ student_attendance : records
    students ||--o{ exam_marks : receives
    students ||--o{ student_invoices : billed
    student_invoices ||--o{ student_invoice_lines : details
    student_invoices ||--o{ student_payments : paid
    student_payments ||--o{ payment_allocations : allocates
    ledger_journals ||--|{ ledger_lines : balances
    chart_of_accounts ||--o{ ledger_lines : classifies
    employees ||--o{ payslips : earns
    students ||--o{ hifz_enrollments : memorizes
    hifz_enrollments ||--o{ hifz_progress_logs : reports
    students ||--o{ hostel_allocations : boards
    donors ||--o{ donations : contributes
    donation_funds ||--o{ donations : designates
```

**Important:** Foreign keys alone are not sufficient to enforce approvals, accounting balance, result publication, fee calculation, historical retention, or authorization. Those need Laravel application services and automated tests.
