# Complete relational table catalog

New Laravel domain tables: **105**. Each domain table is institution scoped.

| Module | Table | Sample rows |
|---|---|---:|
| academic | `academic_departments` | 3 |
| academic | `academic_terms` | 3 |
| academic | `academic_calendar_events` | 3 |
| sis | `guardians` | 3 |
| sis | `students` | 3 |
| admission | `admission_cycles` | 3 |
| hr | `employees` | 3 |
| hr | `payroll_runs` | 3 |
| exams | `grading_scales` | 3 |
| finance | `chart_of_accounts` | 9 |
| finance | `payment_methods` | 3 |
| finance | `ledger_journals` | 6 |
| finance | `financial_period_closings` | 3 |
| scholarship | `scholarships` | 3 |
| communication | `notices` | 3 |
| communication | `direct_messages` | 3 |
| communication | `notification_templates` | 3 |
| library | `library_books` | 3 |
| transport | `vehicles` | 3 |
| hostel | `hostels` | 3 |
| inventory | `suppliers` | 3 |
| inventory | `inventory_items` | 3 |
| inventory | `fixed_assets` | 3 |
| donations | `donors` | 3 |
| donations | `donation_funds` | 3 |
| certificates | `certificate_templates` | 3 |
| campus | `visitor_logs` | 3 |
| campus | `campus_events` | 3 |
| campus | `room_bookings` | 3 |
| integrations | `integration_connections` | 3 |
| analytics | `report_exports` | 3 |
| academic | `academic_programs` | 3 |
| academic | `subjects` | 3 |
| sis | `student_guardians` | 3 |
| sis | `student_documents` | 3 |
| lifecycle | `student_transfers` | 3 |
| welfare | `student_health_records` | 3 |
| welfare | `student_incidents` | 3 |
| attendance | `student_leave_requests` | 3 |
| hr | `staff_attendance` | 3 |
| hr | `staff_leave_requests` | 3 |
| hr | `payslips` | 3 |
| hr | `staff_appraisals` | 3 |
| exams | `grading_bands` | 3 |
| finance | `fee_heads` | 3 |
| finance | `student_invoices` | 3 |
| finance | `ledger_lines` | 12 |
| finance | `bank_accounts` | 3 |
| finance | `expenses` | 3 |
| scholarship | `scholarship_awards` | 3 |
| communication | `notification_deliveries` | 3 |
| communication | `parent_meetings` | 3 |
| library | `library_copies` | 3 |
| transport | `transport_routes` | 3 |
| hostel | `hostel_rooms` | 3 |
| hostel | `meal_plans` | 3 |
| inventory | `stock_movements` | 3 |
| inventory | `purchase_orders` | 3 |
| inventory | `asset_assignments` | 3 |
| hifz | `hifz_groups` | 1 |
| donations | `donations` | 3 |
| donations | `fund_expenses` | 3 |
| welfare | `welfare_cases` | 3 |
| certificates | `issued_certificates` | 3 |
| integrations | `integration_logs` | 3 |
| lifecycle | `alumni_profiles` | 3 |
| academic | `class_levels` | 3 |
| hr | `payslip_items` | 3 |
| finance | `student_invoice_lines` | 3 |
| finance | `student_payments` | 3 |
| finance | `bank_reconciliations` | 3 |
| library | `library_loans` | 3 |
| transport | `transport_stops` | 3 |
| hostel | `hostel_beds` | 3 |
| inventory | `purchase_order_lines` | 3 |
| hifz | `hifz_enrollments` | 1 |
| academic | `class_sections` | 3 |
| academic | `class_subjects` | 3 |
| admission | `admission_applications` | 3 |
| exams | `examinations` | 3 |
| finance | `fee_plans` | 3 |
| finance | `payment_allocations` | 3 |
| finance | `payment_refunds` | 3 |
| transport | `student_transport_assignments` | 3 |
| hostel | `hostel_allocations` | 3 |
| hifz | `hifz_progress_logs` | 1 |
| hifz | `hifz_assessments` | 1 |
| academic | `course_offerings` | 3 |
| academic | `class_routines` | 3 |
| academic | `lesson_plans` | 3 |
| lms | `assignments` | 3 |
| lifecycle | `enrollments` | 3 |
| admission | `admission_offers` | 3 |
| attendance | `attendance_sessions` | 3 |
| academic | `teacher_assignments` | 3 |
| exams | `exam_papers` | 3 |
| exams | `published_results` | 3 |
| finance | `fee_plan_lines` | 3 |
| hostel | `hostel_leave_requests` | 3 |
| lms | `lms_resources` | 3 |
| lifecycle | `student_promotions` | 3 |
| lms | `assignment_submissions` | 3 |
| attendance | `student_attendance` | 3 |
| exams | `exam_marks` | 3 |
| exams | `exam_recheck_requests` | 3 |

## Existing Phase 1 core tables

institutions, campuses, institution_memberships, membership_campuses, institution_roles, sms_permissions, institution_role_permissions, membership_roles, platform_admin_users, institution_module_settings, academic_sessions, sms_audit_logs, sms_idempotency_records, sms_outbox_events, plus normal Laravel users table.

## Tenant integrity

Each tenant-owned domain table has UNIQUE(institution_id,id). All domain foreign-key references to tenant-owned tables use composite (institution_id, *_id), preventing a record from linking to a different institution. Global user references are intentionally non-tenant scoped and **must** also be checked against institution_memberships in Laravel authorization.
