-- CampusSphere School, College & Madrasha ERP — rich fictional sample database
-- STRICTLY for NEW EMPTY MySQL 8 demo databases, NOT your existing scm-system database.
-- Contains 120 CREATE TABLE definitions and 2,325 fictional sample records.
-- WARNING: Does not populate Laravel migrations table. For Laravel, prefer migrate + seeders.
-- SQL-imported login hashes use unknown random passwords. Reset locally through Laravel if needed.
-- School / College / Madrasha ERP — MySQL 8 schema + fictional sample data
-- LOCAL DEMO ONLY. Do not import into production or a nonempty database.
-- Create an EMPTY utf8mb4 database first, then import this file into that database.
-- This import is an alternative to Laravel `php artisan migrate` + `db:seed`.
-- Importing *both* will fail: NEVER run both setup methods on the same database.
-- WARNING: Laravel migration history table is deliberately not populated by raw SQL.
-- To use Laravel, prefer migrations + seeders instead of this raw import.
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 1;


CREATE TABLE `users` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `email_verified_at` TIMESTAMP NULL DEFAULT NULL,
  `password` VARCHAR(255) NOT NULL,
  `remember_token` VARCHAR(100) NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`), UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `institutions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, `code` VARCHAR(32) NOT NULL,
  `slug` VARCHAR(100) NOT NULL, `name` VARCHAR(200) NOT NULL,
  `type` ENUM('school','college','madrasha','mixed') NOT NULL,
  `status` ENUM('draft','active','suspended') NOT NULL DEFAULT 'draft',
  `timezone` VARCHAR(64) NOT NULL DEFAULT 'Asia/Dhaka',
  `locale` VARCHAR(8) NOT NULL DEFAULT 'bn',
  `currency` CHAR(3) NOT NULL DEFAULT 'BDT',
  `created_at` TIMESTAMP NULL DEFAULT NULL, `updated_at` TIMESTAMP NULL DEFAULT NULL,
  `deleted_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`), UNIQUE KEY `institutions_code_unique` (`code`),
  UNIQUE KEY `institutions_slug_unique` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `campuses` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `code` VARCHAR(32) NOT NULL, `name` VARCHAR(160) NOT NULL,
  `is_main` TINYINT(1) NOT NULL DEFAULT 0, `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `address` TEXT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL, `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`), UNIQUE KEY `campuses_tenant_code` (`institution_id`,`code`),
  UNIQUE KEY `campuses_tenant_id` (`institution_id`,`id`),
  CONSTRAINT `campuses_inst_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `institution_memberships` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `status` ENUM('invited','active','suspended','revoked') NOT NULL DEFAULT 'invited',
  `can_access_all_campuses` TINYINT(1) NOT NULL DEFAULT 0,
  `joined_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL, `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`), UNIQUE KEY `im_tenant_user` (`institution_id`,`user_id`),
  UNIQUE KEY `im_tenant_id` (`institution_id`,`id`),
  CONSTRAINT `im_institution_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `im_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `membership_campuses` (
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `membership_id` BIGINT UNSIGNED NOT NULL,
  `campus_id` BIGINT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`institution_id`,`membership_id`,`campus_id`),
  CONSTRAINT `mc_membership_fk` FOREIGN KEY (`institution_id`,`membership_id`) REFERENCES `institution_memberships`(`institution_id`,`id`) ON DELETE CASCADE,
  CONSTRAINT `mc_campus_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses`(`institution_id`,`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `institution_roles` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `key` VARCHAR(80) NOT NULL, `name` VARCHAR(120) NOT NULL,
  `is_system` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NULL DEFAULT NULL, `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`), UNIQUE KEY `ir_tenant_key` (`institution_id`,`key`),
  UNIQUE KEY `ir_tenant_id` (`institution_id`,`id`),
  CONSTRAINT `ir_institution_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `sms_permissions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `key` VARCHAR(120) NOT NULL, `module` VARCHAR(80) NOT NULL,
  `label` VARCHAR(160) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL, `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`), UNIQUE KEY `sms_perm_key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `institution_role_permissions` (
  `role_id` BIGINT UNSIGNED NOT NULL, `permission_id` BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (`role_id`,`permission_id`),
  CONSTRAINT `irp_role_fk` FOREIGN KEY (`role_id`) REFERENCES `institution_roles`(`id`) ON DELETE CASCADE,
  CONSTRAINT `irp_perm_fk` FOREIGN KEY (`permission_id`) REFERENCES `sms_permissions`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `membership_roles` (
  `institution_id` BIGINT UNSIGNED NOT NULL, `membership_id` BIGINT UNSIGNED NOT NULL,
  `role_id` BIGINT UNSIGNED NOT NULL, `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`institution_id`,`membership_id`,`role_id`),
  CONSTRAINT `mr_membership_fk` FOREIGN KEY (`institution_id`,`membership_id`) REFERENCES `institution_memberships`(`institution_id`,`id`) ON DELETE CASCADE,
  CONSTRAINT `mr_role_fk` FOREIGN KEY (`institution_id`,`role_id`) REFERENCES `institution_roles`(`institution_id`,`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `platform_admin_users` (
  `user_id` BIGINT UNSIGNED NOT NULL,
  `granted_by_user_id` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `pau_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `pau_grant_fk` FOREIGN KEY (`granted_by_user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `institution_module_settings` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `module_key` VARCHAR(80) NOT NULL, `enabled` TINYINT(1) NOT NULL DEFAULT 0,
  `options` JSON NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL, `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`), UNIQUE KEY `ims_tenant_module` (`institution_id`,`module_key`),
  CONSTRAINT `ims_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `academic_sessions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `code` VARCHAR(32) NOT NULL, `name` VARCHAR(100) NOT NULL,
  `starts_on` DATE NOT NULL, `ends_on` DATE NOT NULL,
  `status` ENUM('planned','active','closed') NOT NULL DEFAULT 'planned',
  `created_at` TIMESTAMP NULL DEFAULT NULL, `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`), UNIQUE KEY `as_tenant_code` (`institution_id`,`code`),
  UNIQUE KEY `as_tenant_id` (`institution_id`,`id`),
  CONSTRAINT `as_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `sms_audit_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NULL, `actor_user_id` BIGINT UNSIGNED NULL,
  `action` VARCHAR(100) NOT NULL, `resource_type` VARCHAR(120) NOT NULL,
  `resource_id` VARCHAR(80) NULL, `before_data` JSON NULL, `after_data` JSON NULL,
  `metadata` JSON NULL, `ip_address` VARCHAR(45) NULL, `request_id` VARCHAR(40) NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`), KEY `audit_tenant_date` (`institution_id`,`created_at`),
  KEY `audit_resource` (`resource_type`,`resource_id`),
  CONSTRAINT `audit_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `audit_actor_fk` FOREIGN KEY (`actor_user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `sms_idempotency_records` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `operation` VARCHAR(60) NOT NULL, `idempotency_key` VARCHAR(160) NOT NULL,
  `request_sha256` CHAR(64) NOT NULL,
  `status` ENUM('processing','completed','failed') NOT NULL DEFAULT 'processing',
  `response_status` SMALLINT UNSIGNED NULL, `response_body` JSON NULL,
  `expires_at` TIMESTAMP NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL, `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`), UNIQUE KEY `sms_idempotency_unique` (`institution_id`,`operation`,`idempotency_key`),
  KEY `sms_idem_expiry` (`status`,`expires_at`),
  CONSTRAINT `idempotency_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `sms_outbox_events` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL, `event_type` VARCHAR(120) NOT NULL,
  `aggregate_type` VARCHAR(100) NOT NULL, `aggregate_id` VARCHAR(80) NOT NULL,
  `payload` JSON NOT NULL,
  `status` ENUM('pending','processing','completed','failed') NOT NULL DEFAULT 'pending',
  `attempts` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `available_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `processed_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL, `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`), KEY `sms_outbox_status` (`status`,`available_at`),
  KEY `sms_outbox_aggregate_idx` (`institution_id`,`aggregate_type`,`aggregate_id`),
  CONSTRAINT `outbox_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `academic_departments` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `campus_id` BIGINT UNSIGNED NOT NULL,
  `code` VARCHAR(32) NOT NULL,
  `name` VARCHAR(160) NOT NULL,
  `category` VARCHAR(40) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `academic_departments_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `academic_departments_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `academic_departments_campus_id_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `academic_terms` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `academic_session_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `starts_on` DATE NOT NULL,
  `ends_on` DATE NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `academic_terms_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `academic_terms_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `academic_terms_academic_session_id_fk` FOREIGN KEY (`institution_id`,`academic_session_id`) REFERENCES `academic_sessions`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `academic_calendar_events` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `academic_session_id` BIGINT UNSIGNED NOT NULL,
  `title` VARCHAR(180) NOT NULL,
  `event_type` VARCHAR(40) NOT NULL,
  `starts_at` DATETIME NOT NULL,
  `ends_at` DATETIME NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `academic_calendar_events_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `academic_calendar_events_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `academic_calendar_events_academic_session_id_fk` FOREIGN KEY (`institution_id`,`academic_session_id`) REFERENCES `academic_sessions`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `guardians` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NULL,
  `name` VARCHAR(180) NOT NULL,
  `relation` VARCHAR(40) NOT NULL,
  `phone` VARCHAR(32) NOT NULL,
  `email` VARCHAR(180) NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `guardians_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `guardians_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `guardians_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `students` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NULL,
  `campus_id` BIGINT UNSIGNED NOT NULL,
  `admission_no` VARCHAR(40) NOT NULL,
  `name` VARCHAR(180) NOT NULL,
  `gender` VARCHAR(20) NULL,
  `birth_date` DATE NULL,
  `blood_group` VARCHAR(8) NULL,
  `status` VARCHAR(32) NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `students_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `students_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `students_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `students_campus_id_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `admission_cycles` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `academic_session_id` BIGINT UNSIGNED NOT NULL,
  `campus_id` BIGINT UNSIGNED NOT NULL,
  `title` VARCHAR(150) NOT NULL,
  `opens_on` DATE NOT NULL,
  `closes_on` DATE NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admission_cycles_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `admission_cycles_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `admission_cycles_academic_session_id_fk` FOREIGN KEY (`institution_id`,`academic_session_id`) REFERENCES `academic_sessions`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `admission_cycles_campus_id_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `employees` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NULL,
  `campus_id` BIGINT UNSIGNED NOT NULL,
  `employee_no` VARCHAR(40) NOT NULL,
  `name` VARCHAR(180) NOT NULL,
  `designation` VARCHAR(100) NOT NULL,
  `joined_on` DATE NOT NULL,
  `basic_salary` DECIMAL(14,2) NOT NULL DEFAULT 0,
  `status` VARCHAR(24) NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `employees_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `employees_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `employees_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `employees_campus_id_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `payroll_runs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `period_start` DATE NOT NULL,
  `period_end` DATE NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'draft',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payroll_runs_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `payroll_runs_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `grading_scales` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `code` VARCHAR(32) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `grading_scales_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `grading_scales_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `chart_of_accounts` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `code` VARCHAR(32) NOT NULL,
  `name` VARCHAR(140) NOT NULL,
  `account_type` VARCHAR(40) NOT NULL,
  `parent_account_id` BIGINT UNSIGNED NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chart_of_accounts_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `chart_of_accounts_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `chart_of_accounts_parent_account_id_fk` FOREIGN KEY (`institution_id`,`parent_account_id`) REFERENCES `chart_of_accounts`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `payment_methods` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `code` VARCHAR(32) NOT NULL,
  `name` VARCHAR(120) NOT NULL,
  `method_type` VARCHAR(40) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payment_methods_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `payment_methods_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `ledger_journals` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `journal_no` VARCHAR(50) NOT NULL,
  `posted_on` DATE NOT NULL,
  `source_type` VARCHAR(60) NOT NULL,
  `source_reference` VARCHAR(70) NULL,
  `description` VARCHAR(220) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'posted',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ledger_journals_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `ledger_journals_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `financial_period_closings` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `academic_session_id` BIGINT UNSIGNED NOT NULL,
  `closed_on` DATE NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'draft',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `financial_period_closings_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `financial_period_closings_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `financial_period_closings_academic_session_id_fk` FOREIGN KEY (`institution_id`,`academic_session_id`) REFERENCES `academic_sessions`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `scholarships` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(160) NOT NULL,
  `criteria` TEXT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `scholarships_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `scholarships_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `notices` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `title` VARCHAR(180) NOT NULL,
  `body` TEXT NOT NULL,
  `audience` VARCHAR(50) NOT NULL,
  `published_at` DATETIME NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `notices_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `notices_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `direct_messages` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `sender_user_id` BIGINT UNSIGNED NOT NULL,
  `recipient_user_id` BIGINT UNSIGNED NOT NULL,
  `body` TEXT NOT NULL,
  `read_at` DATETIME NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `direct_messages_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `direct_messages_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `direct_messages_sender_user_id_fk` FOREIGN KEY (`sender_user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `direct_messages_recipient_user_id_fk` FOREIGN KEY (`recipient_user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `notification_templates` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `code` VARCHAR(50) NOT NULL,
  `channel` VARCHAR(32) NOT NULL,
  `body` TEXT NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `notification_templates_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `notification_templates_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `library_books` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `isbn` VARCHAR(32) NULL,
  `title` VARCHAR(220) NOT NULL,
  `author` VARCHAR(160) NOT NULL,
  `category` VARCHAR(80) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `library_books_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `library_books_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `vehicles` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `vehicle_code` VARCHAR(40) NOT NULL,
  `plate_number` VARCHAR(60) NOT NULL,
  `seats` INT UNSIGNED NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `vehicles_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `vehicles_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `hostels` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `campus_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(140) NOT NULL,
  `category` VARCHAR(40) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hostels_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `hostels_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `hostels_campus_id_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `suppliers` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(180) NOT NULL,
  `phone` VARCHAR(40) NULL,
  `address` TEXT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `suppliers_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `suppliers_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `inventory_items` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `sku` VARCHAR(60) NOT NULL,
  `name` VARCHAR(180) NOT NULL,
  `unit` VARCHAR(32) NOT NULL,
  `reorder_level` INT UNSIGNED NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `inventory_items_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `inventory_items_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `fixed_assets` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `asset_tag` VARCHAR(60) NOT NULL,
  `name` VARCHAR(160) NOT NULL,
  `category` VARCHAR(100) NOT NULL,
  `purchased_on` DATE NOT NULL,
  `purchase_cost` DECIMAL(14,2) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `fixed_assets_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `fixed_assets_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `donors` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(160) NOT NULL,
  `phone` VARCHAR(40) NULL,
  `email` VARCHAR(160) NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `donors_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `donors_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `donation_funds` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `code` VARCHAR(40) NOT NULL,
  `name` VARCHAR(180) NOT NULL,
  `is_restricted` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `donation_funds_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `donation_funds_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `certificate_templates` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `code` VARCHAR(50) NOT NULL,
  `name` VARCHAR(150) NOT NULL,
  `template_html` TEXT NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `certificate_templates_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `certificate_templates_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `visitor_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `campus_id` BIGINT UNSIGNED NOT NULL,
  `visitor_name` VARCHAR(180) NOT NULL,
  `purpose` VARCHAR(150) NOT NULL,
  `checked_in_at` DATETIME NOT NULL,
  `checked_out_at` DATETIME NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `visitor_logs_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `visitor_logs_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `visitor_logs_campus_id_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `campus_events` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `campus_id` BIGINT UNSIGNED NOT NULL,
  `title` VARCHAR(180) NOT NULL,
  `starts_at` DATETIME NOT NULL,
  `ends_at` DATETIME NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `campus_events_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `campus_events_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `campus_events_campus_id_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `room_bookings` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `campus_id` BIGINT UNSIGNED NOT NULL,
  `booked_by_user_id` BIGINT UNSIGNED NULL,
  `room_name` VARCHAR(100) NOT NULL,
  `starts_at` DATETIME NOT NULL,
  `ends_at` DATETIME NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `room_bookings_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `room_bookings_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `room_bookings_campus_id_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `room_bookings_booked_by_user_id_fk` FOREIGN KEY (`booked_by_user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `integration_connections` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `provider` VARCHAR(100) NOT NULL,
  `category` VARCHAR(60) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'disabled',
  `configuration` JSON NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `integration_connections_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `integration_connections_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `report_exports` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `report_key` VARCHAR(100) NOT NULL,
  `requested_at` DATETIME NOT NULL,
  `status` VARCHAR(32) NOT NULL DEFAULT 'pending',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `report_exports_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `report_exports_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `report_exports_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `academic_programs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `department_id` BIGINT UNSIGNED NOT NULL,
  `code` VARCHAR(32) NOT NULL,
  `name` VARCHAR(140) NOT NULL,
  `level` VARCHAR(40) NOT NULL,
  `required_credits` DECIMAL(8,2) NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `academic_programs_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `academic_programs_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `academic_programs_department_id_fk` FOREIGN KEY (`institution_id`,`department_id`) REFERENCES `academic_departments`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `subjects` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `department_id` BIGINT UNSIGNED NULL,
  `code` VARCHAR(32) NOT NULL,
  `name` VARCHAR(140) NOT NULL,
  `credit_hours` DECIMAL(6,2) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `subjects_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `subjects_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `subjects_department_id_fk` FOREIGN KEY (`institution_id`,`department_id`) REFERENCES `academic_departments`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `student_guardians` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `guardian_id` BIGINT UNSIGNED NOT NULL,
  `relationship` VARCHAR(32) NOT NULL,
  `is_primary` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_guardians_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `student_guardians_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_guardians_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_guardians_guardian_id_fk` FOREIGN KEY (`institution_id`,`guardian_id`) REFERENCES `guardians`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `student_documents` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `document_type` VARCHAR(60) NOT NULL,
  `file_path` VARCHAR(255) NULL,
  `verification_status` VARCHAR(32) NOT NULL DEFAULT 'pending',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_documents_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `student_documents_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_documents_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `student_transfers` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `from_campus_id` BIGINT UNSIGNED NOT NULL,
  `to_campus_id` BIGINT UNSIGNED NULL,
  `transferred_on` DATE NOT NULL,
  `reason` TEXT NOT NULL,
  `status` VARCHAR(32) NOT NULL DEFAULT 'requested',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_transfers_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `student_transfers_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_transfers_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_transfers_from_campus_id_fk` FOREIGN KEY (`institution_id`,`from_campus_id`) REFERENCES `campuses`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_transfers_to_campus_id_fk` FOREIGN KEY (`institution_id`,`to_campus_id`) REFERENCES `campuses`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `student_health_records` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `allergies` TEXT NULL,
  `medical_notes` TEXT NULL,
  `emergency_contact` VARCHAR(32) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_health_records_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `student_health_records_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_health_records_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `student_incidents` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `occurred_on` DATE NOT NULL,
  `category` VARCHAR(60) NOT NULL,
  `details` TEXT NOT NULL,
  `status` VARCHAR(32) NOT NULL DEFAULT 'open',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_incidents_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `student_incidents_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_incidents_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `student_leave_requests` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `starts_on` DATE NOT NULL,
  `ends_on` DATE NOT NULL,
  `reason` TEXT NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'pending',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_leave_requests_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `student_leave_requests_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_leave_requests_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `staff_attendance` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `employee_id` BIGINT UNSIGNED NOT NULL,
  `attendance_on` DATE NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'present',
  `check_in_at` DATETIME NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `staff_attendance_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `staff_attendance_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `staff_attendance_employee_id_fk` FOREIGN KEY (`institution_id`,`employee_id`) REFERENCES `employees`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `staff_leave_requests` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `employee_id` BIGINT UNSIGNED NOT NULL,
  `starts_on` DATE NOT NULL,
  `ends_on` DATE NOT NULL,
  `reason` TEXT NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'pending',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `staff_leave_requests_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `staff_leave_requests_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `staff_leave_requests_employee_id_fk` FOREIGN KEY (`institution_id`,`employee_id`) REFERENCES `employees`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `payslips` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `payroll_run_id` BIGINT UNSIGNED NOT NULL,
  `employee_id` BIGINT UNSIGNED NOT NULL,
  `gross_amount` DECIMAL(14,2) NOT NULL,
  `deduction_amount` DECIMAL(14,2) NOT NULL DEFAULT 0,
  `net_amount` DECIMAL(14,2) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'draft',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payslips_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `payslips_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `payslips_payroll_run_id_fk` FOREIGN KEY (`institution_id`,`payroll_run_id`) REFERENCES `payroll_runs`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `payslips_employee_id_fk` FOREIGN KEY (`institution_id`,`employee_id`) REFERENCES `employees`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `staff_appraisals` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `employee_id` BIGINT UNSIGNED NOT NULL,
  `reviewed_on` DATE NOT NULL,
  `score` DECIMAL(5,2) NOT NULL,
  `remarks` TEXT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `staff_appraisals_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `staff_appraisals_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `staff_appraisals_employee_id_fk` FOREIGN KEY (`institution_id`,`employee_id`) REFERENCES `employees`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `grading_bands` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `grading_scale_id` BIGINT UNSIGNED NOT NULL,
  `min_percent` DECIMAL(5,2) NOT NULL,
  `max_percent` DECIMAL(5,2) NOT NULL,
  `letter_grade` VARCHAR(8) NOT NULL,
  `grade_point` DECIMAL(4,2) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `grading_bands_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `grading_bands_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `grading_bands_grading_scale_id_fk` FOREIGN KEY (`institution_id`,`grading_scale_id`) REFERENCES `grading_scales`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `fee_heads` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `code` VARCHAR(32) NOT NULL,
  `name` VARCHAR(120) NOT NULL,
  `revenue_account_id` BIGINT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `fee_heads_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `fee_heads_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fee_heads_revenue_account_id_fk` FOREIGN KEY (`institution_id`,`revenue_account_id`) REFERENCES `chart_of_accounts`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `student_invoices` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `invoice_no` VARCHAR(50) NOT NULL,
  `issued_on` DATE NOT NULL,
  `due_on` DATE NOT NULL,
  `total_amount` DECIMAL(14,2) NOT NULL,
  `paid_amount` DECIMAL(14,2) NOT NULL DEFAULT 0,
  `status` VARCHAR(24) NOT NULL DEFAULT 'unpaid',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_invoices_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `student_invoices_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_invoices_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `ledger_lines` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `ledger_journal_id` BIGINT UNSIGNED NOT NULL,
  `account_id` BIGINT UNSIGNED NOT NULL,
  `debit` DECIMAL(14,2) NOT NULL DEFAULT 0,
  `credit` DECIMAL(14,2) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ledger_lines_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `ledger_lines_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `ledger_lines_ledger_journal_id_fk` FOREIGN KEY (`institution_id`,`ledger_journal_id`) REFERENCES `ledger_journals`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `ledger_lines_account_id_fk` FOREIGN KEY (`institution_id`,`account_id`) REFERENCES `chart_of_accounts`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `bank_accounts` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `account_id` BIGINT UNSIGNED NOT NULL,
  `bank_name` VARCHAR(140) NOT NULL,
  `account_mask` VARCHAR(24) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `bank_accounts_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `bank_accounts_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `bank_accounts_account_id_fk` FOREIGN KEY (`institution_id`,`account_id`) REFERENCES `chart_of_accounts`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `expenses` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `expense_no` VARCHAR(50) NOT NULL,
  `description` VARCHAR(200) NOT NULL,
  `expense_on` DATE NOT NULL,
  `amount` DECIMAL(14,2) NOT NULL,
  `account_id` BIGINT UNSIGNED NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'draft',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `expenses_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `expenses_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `expenses_account_id_fk` FOREIGN KEY (`institution_id`,`account_id`) REFERENCES `chart_of_accounts`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `scholarship_awards` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `scholarship_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `amount` DECIMAL(14,2) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'approved',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `scholarship_awards_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `scholarship_awards_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `scholarship_awards_scholarship_id_fk` FOREIGN KEY (`institution_id`,`scholarship_id`) REFERENCES `scholarships`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `scholarship_awards_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `notification_deliveries` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `notification_template_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NULL,
  `recipient` VARCHAR(160) NOT NULL,
  `channel` VARCHAR(32) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'queued',
  `sent_at` DATETIME NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `notification_deliveries_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `notification_deliveries_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `notification_deliveries_notification_template_id_fk` FOREIGN KEY (`institution_id`,`notification_template_id`) REFERENCES `notification_templates`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `notification_deliveries_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `parent_meetings` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `employee_id` BIGINT UNSIGNED NOT NULL,
  `scheduled_at` DATETIME NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'requested',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `parent_meetings_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `parent_meetings_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `parent_meetings_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `parent_meetings_employee_id_fk` FOREIGN KEY (`institution_id`,`employee_id`) REFERENCES `employees`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `library_copies` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `library_book_id` BIGINT UNSIGNED NOT NULL,
  `barcode` VARCHAR(64) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'available',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `library_copies_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `library_copies_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `library_copies_library_book_id_fk` FOREIGN KEY (`institution_id`,`library_book_id`) REFERENCES `library_books`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `transport_routes` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `vehicle_id` BIGINT UNSIGNED NOT NULL,
  `employee_id` BIGINT UNSIGNED NULL,
  `route_name` VARCHAR(150) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transport_routes_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `transport_routes_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `transport_routes_vehicle_id_fk` FOREIGN KEY (`institution_id`,`vehicle_id`) REFERENCES `vehicles`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `transport_routes_employee_id_fk` FOREIGN KEY (`institution_id`,`employee_id`) REFERENCES `employees`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `hostel_rooms` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `hostel_id` BIGINT UNSIGNED NOT NULL,
  `room_code` VARCHAR(40) NOT NULL,
  `capacity` INT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hostel_rooms_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `hostel_rooms_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `hostel_rooms_hostel_id_fk` FOREIGN KEY (`institution_id`,`hostel_id`) REFERENCES `hostels`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `meal_plans` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `hostel_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(120) NOT NULL,
  `monthly_rate` DECIMAL(14,2) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `meal_plans_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `meal_plans_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `meal_plans_hostel_id_fk` FOREIGN KEY (`institution_id`,`hostel_id`) REFERENCES `hostels`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `stock_movements` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `inventory_item_id` BIGINT UNSIGNED NOT NULL,
  `quantity` INT NOT NULL,
  `movement_type` VARCHAR(30) NOT NULL,
  `reference_no` VARCHAR(70) NOT NULL,
  `moved_on` DATE NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stock_movements_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `stock_movements_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `stock_movements_inventory_item_id_fk` FOREIGN KEY (`institution_id`,`inventory_item_id`) REFERENCES `inventory_items`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `purchase_orders` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `supplier_id` BIGINT UNSIGNED NOT NULL,
  `po_number` VARCHAR(60) NOT NULL,
  `ordered_on` DATE NOT NULL,
  `total_amount` DECIMAL(14,2) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'draft',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `purchase_orders_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `purchase_orders_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `purchase_orders_supplier_id_fk` FOREIGN KEY (`institution_id`,`supplier_id`) REFERENCES `suppliers`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `asset_assignments` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `fixed_asset_id` BIGINT UNSIGNED NOT NULL,
  `employee_id` BIGINT UNSIGNED NOT NULL,
  `assigned_on` DATE NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `asset_assignments_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `asset_assignments_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `asset_assignments_fixed_asset_id_fk` FOREIGN KEY (`institution_id`,`fixed_asset_id`) REFERENCES `fixed_assets`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `asset_assignments_employee_id_fk` FOREIGN KEY (`institution_id`,`employee_id`) REFERENCES `employees`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `hifz_groups` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(150) NOT NULL,
  `employee_id` BIGINT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hifz_groups_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `hifz_groups_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `hifz_groups_employee_id_fk` FOREIGN KEY (`institution_id`,`employee_id`) REFERENCES `employees`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `donations` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `donor_id` BIGINT UNSIGNED NOT NULL,
  `donation_fund_id` BIGINT UNSIGNED NOT NULL,
  `receipt_no` VARCHAR(60) NOT NULL,
  `amount` DECIMAL(14,2) NOT NULL,
  `received_on` DATE NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `donations_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `donations_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `donations_donor_id_fk` FOREIGN KEY (`institution_id`,`donor_id`) REFERENCES `donors`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `donations_donation_fund_id_fk` FOREIGN KEY (`institution_id`,`donation_fund_id`) REFERENCES `donation_funds`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `fund_expenses` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `donation_fund_id` BIGINT UNSIGNED NOT NULL,
  `approved_by_user_id` BIGINT UNSIGNED NULL,
  `description` VARCHAR(190) NOT NULL,
  `amount` DECIMAL(14,2) NOT NULL,
  `spent_on` DATE NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'approved',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `fund_expenses_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `fund_expenses_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fund_expenses_donation_fund_id_fk` FOREIGN KEY (`institution_id`,`donation_fund_id`) REFERENCES `donation_funds`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `fund_expenses_approved_by_user_id_fk` FOREIGN KEY (`approved_by_user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `welfare_cases` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `category` VARCHAR(70) NOT NULL,
  `details` TEXT NOT NULL,
  `opened_on` DATE NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'open',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `welfare_cases_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `welfare_cases_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `welfare_cases_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `issued_certificates` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `certificate_template_id` BIGINT UNSIGNED NOT NULL,
  `certificate_no` VARCHAR(65) NOT NULL,
  `issued_on` DATE NOT NULL,
  `verification_token` VARCHAR(100) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'issued',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `issued_certificates_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `issued_certificates_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `issued_certificates_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `issued_certificates_certificate_template_id_fk` FOREIGN KEY (`institution_id`,`certificate_template_id`) REFERENCES `certificate_templates`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `integration_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `integration_connection_id` BIGINT UNSIGNED NOT NULL,
  `event_name` VARCHAR(140) NOT NULL,
  `status` VARCHAR(32) NOT NULL,
  `logged_at` DATETIME NOT NULL,
  `external_reference` VARCHAR(140) NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `integration_logs_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `integration_logs_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `integration_logs_integration_connection_id_fk` FOREIGN KEY (`institution_id`,`integration_connection_id`) REFERENCES `integration_connections`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `alumni_profiles` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `graduation_year` INT UNSIGNED NOT NULL,
  `notes` TEXT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `alumni_profiles_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `alumni_profiles_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `alumni_profiles_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `class_levels` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `program_id` BIGINT UNSIGNED NULL,
  `code` VARCHAR(32) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `sequence` INT UNSIGNED NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `class_levels_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `class_levels_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `class_levels_program_id_fk` FOREIGN KEY (`institution_id`,`program_id`) REFERENCES `academic_programs`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `payslip_items` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `payslip_id` BIGINT UNSIGNED NOT NULL,
  `item_type` VARCHAR(32) NOT NULL,
  `description` VARCHAR(140) NOT NULL,
  `amount` DECIMAL(14,2) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payslip_items_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `payslip_items_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `payslip_items_payslip_id_fk` FOREIGN KEY (`institution_id`,`payslip_id`) REFERENCES `payslips`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `student_invoice_lines` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_invoice_id` BIGINT UNSIGNED NOT NULL,
  `fee_head_id` BIGINT UNSIGNED NOT NULL,
  `description` VARCHAR(180) NOT NULL,
  `amount` DECIMAL(14,2) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_invoice_lines_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `student_invoice_lines_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_invoice_lines_student_invoice_id_fk` FOREIGN KEY (`institution_id`,`student_invoice_id`) REFERENCES `student_invoices`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_invoice_lines_fee_head_id_fk` FOREIGN KEY (`institution_id`,`fee_head_id`) REFERENCES `fee_heads`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `student_payments` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `student_invoice_id` BIGINT UNSIGNED NOT NULL,
  `payment_method_id` BIGINT UNSIGNED NOT NULL,
  `amount` DECIMAL(14,2) NOT NULL,
  `paid_on` DATE NOT NULL,
  `reference_no` VARCHAR(100) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'posted',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_payments_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `student_payments_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_payments_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_payments_student_invoice_id_fk` FOREIGN KEY (`institution_id`,`student_invoice_id`) REFERENCES `student_invoices`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_payments_payment_method_id_fk` FOREIGN KEY (`institution_id`,`payment_method_id`) REFERENCES `payment_methods`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `bank_reconciliations` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `bank_account_id` BIGINT UNSIGNED NOT NULL,
  `statement_on` DATE NOT NULL,
  `statement_balance` DECIMAL(14,2) NOT NULL,
  `ledger_balance` DECIMAL(14,2) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'pending',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `bank_reconciliations_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `bank_reconciliations_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `bank_reconciliations_bank_account_id_fk` FOREIGN KEY (`institution_id`,`bank_account_id`) REFERENCES `bank_accounts`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `library_loans` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `library_copy_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `issued_on` DATE NOT NULL,
  `due_on` DATE NOT NULL,
  `returned_on` DATE NULL,
  `fine_amount` DECIMAL(14,2) NOT NULL DEFAULT 0,
  `status` VARCHAR(24) NOT NULL DEFAULT 'issued',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `library_loans_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `library_loans_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `library_loans_library_copy_id_fk` FOREIGN KEY (`institution_id`,`library_copy_id`) REFERENCES `library_copies`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `library_loans_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `transport_stops` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `transport_route_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(140) NOT NULL,
  `stop_order` INT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transport_stops_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `transport_stops_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `transport_stops_transport_route_id_fk` FOREIGN KEY (`institution_id`,`transport_route_id`) REFERENCES `transport_routes`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `hostel_beds` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `hostel_room_id` BIGINT UNSIGNED NOT NULL,
  `bed_code` VARCHAR(40) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'available',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hostel_beds_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `hostel_beds_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `hostel_beds_hostel_room_id_fk` FOREIGN KEY (`institution_id`,`hostel_room_id`) REFERENCES `hostel_rooms`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `purchase_order_lines` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `purchase_order_id` BIGINT UNSIGNED NOT NULL,
  `inventory_item_id` BIGINT UNSIGNED NOT NULL,
  `quantity` INT UNSIGNED NOT NULL,
  `unit_price` DECIMAL(14,2) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `purchase_order_lines_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `purchase_order_lines_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `purchase_order_lines_purchase_order_id_fk` FOREIGN KEY (`institution_id`,`purchase_order_id`) REFERENCES `purchase_orders`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `purchase_order_lines_inventory_item_id_fk` FOREIGN KEY (`institution_id`,`inventory_item_id`) REFERENCES `inventory_items`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `hifz_enrollments` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `hifz_group_id` BIGINT UNSIGNED NOT NULL,
  `started_on` DATE NOT NULL,
  `target_juz` INT UNSIGNED NOT NULL DEFAULT 30,
  `status` VARCHAR(24) NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hifz_enrollments_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `hifz_enrollments_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `hifz_enrollments_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `hifz_enrollments_hifz_group_id_fk` FOREIGN KEY (`institution_id`,`hifz_group_id`) REFERENCES `hifz_groups`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `class_sections` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `campus_id` BIGINT UNSIGNED NOT NULL,
  `class_level_id` BIGINT UNSIGNED NOT NULL,
  `code` VARCHAR(32) NOT NULL,
  `name` VARCHAR(80) NOT NULL,
  `shift` VARCHAR(32) NOT NULL DEFAULT 'day',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `class_sections_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `class_sections_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `class_sections_campus_id_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `class_sections_class_level_id_fk` FOREIGN KEY (`institution_id`,`class_level_id`) REFERENCES `class_levels`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `class_subjects` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `class_level_id` BIGINT UNSIGNED NOT NULL,
  `subject_id` BIGINT UNSIGNED NOT NULL,
  `academic_session_id` BIGINT UNSIGNED NOT NULL,
  `is_compulsory` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `class_subjects_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `class_subjects_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `class_subjects_class_level_id_fk` FOREIGN KEY (`institution_id`,`class_level_id`) REFERENCES `class_levels`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `class_subjects_subject_id_fk` FOREIGN KEY (`institution_id`,`subject_id`) REFERENCES `subjects`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `class_subjects_academic_session_id_fk` FOREIGN KEY (`institution_id`,`academic_session_id`) REFERENCES `academic_sessions`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `admission_applications` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `admission_cycle_id` BIGINT UNSIGNED NOT NULL,
  `class_level_id` BIGINT UNSIGNED NOT NULL,
  `application_no` VARCHAR(50) NOT NULL,
  `applicant_name` VARCHAR(180) NOT NULL,
  `guardian_phone` VARCHAR(32) NOT NULL,
  `score` DECIMAL(7,2) NULL,
  `status` VARCHAR(32) NOT NULL DEFAULT 'submitted',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admission_applications_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `admission_applications_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `admission_applications_admission_cycle_id_fk` FOREIGN KEY (`institution_id`,`admission_cycle_id`) REFERENCES `admission_cycles`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `admission_applications_class_level_id_fk` FOREIGN KEY (`institution_id`,`class_level_id`) REFERENCES `class_levels`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `examinations` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `academic_session_id` BIGINT UNSIGNED NOT NULL,
  `class_level_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(140) NOT NULL,
  `exam_type` VARCHAR(60) NOT NULL,
  `starts_on` DATE NOT NULL,
  `ends_on` DATE NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'draft',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `examinations_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `examinations_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `examinations_academic_session_id_fk` FOREIGN KEY (`institution_id`,`academic_session_id`) REFERENCES `academic_sessions`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `examinations_class_level_id_fk` FOREIGN KEY (`institution_id`,`class_level_id`) REFERENCES `class_levels`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `fee_plans` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `class_level_id` BIGINT UNSIGNED NOT NULL,
  `academic_session_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(140) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `fee_plans_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `fee_plans_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fee_plans_class_level_id_fk` FOREIGN KEY (`institution_id`,`class_level_id`) REFERENCES `class_levels`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `fee_plans_academic_session_id_fk` FOREIGN KEY (`institution_id`,`academic_session_id`) REFERENCES `academic_sessions`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `payment_allocations` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_payment_id` BIGINT UNSIGNED NOT NULL,
  `student_invoice_id` BIGINT UNSIGNED NOT NULL,
  `amount` DECIMAL(14,2) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payment_allocations_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `payment_allocations_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `payment_allocations_student_payment_id_fk` FOREIGN KEY (`institution_id`,`student_payment_id`) REFERENCES `student_payments`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `payment_allocations_student_invoice_id_fk` FOREIGN KEY (`institution_id`,`student_invoice_id`) REFERENCES `student_invoices`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `payment_refunds` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_payment_id` BIGINT UNSIGNED NOT NULL,
  `amount` DECIMAL(14,2) NOT NULL,
  `reason` TEXT NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'requested',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payment_refunds_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `payment_refunds_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `payment_refunds_student_payment_id_fk` FOREIGN KEY (`institution_id`,`student_payment_id`) REFERENCES `student_payments`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `student_transport_assignments` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `transport_route_id` BIGINT UNSIGNED NOT NULL,
  `transport_stop_id` BIGINT UNSIGNED NOT NULL,
  `starts_on` DATE NOT NULL,
  `monthly_fee` DECIMAL(14,2) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_transport_assignments_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `student_transport_assignments_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_transport_assignments_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_transport_assignments_transport_route_id_fk` FOREIGN KEY (`institution_id`,`transport_route_id`) REFERENCES `transport_routes`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_transport_assignments_transport_stop_id_fk` FOREIGN KEY (`institution_id`,`transport_stop_id`) REFERENCES `transport_stops`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `hostel_allocations` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `hostel_bed_id` BIGINT UNSIGNED NOT NULL,
  `check_in_on` DATE NOT NULL,
  `monthly_fee` DECIMAL(14,2) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hostel_allocations_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `hostel_allocations_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `hostel_allocations_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `hostel_allocations_hostel_bed_id_fk` FOREIGN KEY (`institution_id`,`hostel_bed_id`) REFERENCES `hostel_beds`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `hifz_progress_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `hifz_enrollment_id` BIGINT UNSIGNED NOT NULL,
  `logged_on` DATE NOT NULL,
  `sabaq` VARCHAR(150) NOT NULL,
  `sabqi` VARCHAR(150) NOT NULL,
  `manzil` VARCHAR(150) NOT NULL,
  `juz_completed` INT UNSIGNED NOT NULL DEFAULT 0,
  `accuracy_percent` DECIMAL(5,2) NOT NULL,
  `notes` TEXT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hifz_progress_logs_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `hifz_progress_logs_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `hifz_progress_logs_hifz_enrollment_id_fk` FOREIGN KEY (`institution_id`,`hifz_enrollment_id`) REFERENCES `hifz_enrollments`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `hifz_assessments` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `hifz_enrollment_id` BIGINT UNSIGNED NOT NULL,
  `assessed_on` DATE NOT NULL,
  `score` DECIMAL(5,2) NOT NULL,
  `remarks` TEXT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hifz_assessments_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `hifz_assessments_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `hifz_assessments_hifz_enrollment_id_fk` FOREIGN KEY (`institution_id`,`hifz_enrollment_id`) REFERENCES `hifz_enrollments`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `course_offerings` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `academic_term_id` BIGINT UNSIGNED NOT NULL,
  `class_section_id` BIGINT UNSIGNED NOT NULL,
  `subject_id` BIGINT UNSIGNED NOT NULL,
  `capacity` INT UNSIGNED NOT NULL DEFAULT 30,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `course_offerings_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `course_offerings_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `course_offerings_academic_term_id_fk` FOREIGN KEY (`institution_id`,`academic_term_id`) REFERENCES `academic_terms`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `course_offerings_class_section_id_fk` FOREIGN KEY (`institution_id`,`class_section_id`) REFERENCES `class_sections`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `course_offerings_subject_id_fk` FOREIGN KEY (`institution_id`,`subject_id`) REFERENCES `subjects`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `class_routines` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `class_section_id` BIGINT UNSIGNED NOT NULL,
  `class_subject_id` BIGINT UNSIGNED NOT NULL,
  `day_of_week` VARCHAR(12) NOT NULL,
  `starts_at` TIME NOT NULL,
  `ends_at` TIME NOT NULL,
  `room` VARCHAR(50) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `class_routines_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `class_routines_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `class_routines_class_section_id_fk` FOREIGN KEY (`institution_id`,`class_section_id`) REFERENCES `class_sections`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `class_routines_class_subject_id_fk` FOREIGN KEY (`institution_id`,`class_subject_id`) REFERENCES `class_subjects`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `lesson_plans` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `class_subject_id` BIGINT UNSIGNED NOT NULL,
  `lesson_date` DATE NOT NULL,
  `topic` VARCHAR(180) NOT NULL,
  `completion_percent` DECIMAL(5,2) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lesson_plans_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `lesson_plans_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `lesson_plans_class_subject_id_fk` FOREIGN KEY (`institution_id`,`class_subject_id`) REFERENCES `class_subjects`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `assignments` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `class_subject_id` BIGINT UNSIGNED NOT NULL,
  `title` VARCHAR(180) NOT NULL,
  `details` TEXT NULL,
  `due_at` DATETIME NOT NULL,
  `max_marks` DECIMAL(7,2) NOT NULL DEFAULT 100,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `assignments_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `assignments_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `assignments_class_subject_id_fk` FOREIGN KEY (`institution_id`,`class_subject_id`) REFERENCES `class_subjects`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `enrollments` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `academic_session_id` BIGINT UNSIGNED NOT NULL,
  `class_section_id` BIGINT UNSIGNED NOT NULL,
  `roll_no` VARCHAR(30) NOT NULL,
  `status` VARCHAR(32) NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `enrollments_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `enrollments_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `enrollments_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `enrollments_academic_session_id_fk` FOREIGN KEY (`institution_id`,`academic_session_id`) REFERENCES `academic_sessions`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `enrollments_class_section_id_fk` FOREIGN KEY (`institution_id`,`class_section_id`) REFERENCES `class_sections`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `admission_offers` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `admission_application_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NULL,
  `offered_on` DATE NOT NULL,
  `status` VARCHAR(32) NOT NULL DEFAULT 'offered',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admission_offers_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `admission_offers_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `admission_offers_admission_application_id_fk` FOREIGN KEY (`institution_id`,`admission_application_id`) REFERENCES `admission_applications`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `admission_offers_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `attendance_sessions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `class_section_id` BIGINT UNSIGNED NOT NULL,
  `attendance_on` DATE NOT NULL,
  `period_code` VARCHAR(40) NOT NULL DEFAULT 'daily',
  `status` VARCHAR(24) NOT NULL DEFAULT 'open',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `attendance_sessions_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `attendance_sessions_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `attendance_sessions_class_section_id_fk` FOREIGN KEY (`institution_id`,`class_section_id`) REFERENCES `class_sections`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `teacher_assignments` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `employee_id` BIGINT UNSIGNED NOT NULL,
  `class_subject_id` BIGINT UNSIGNED NOT NULL,
  `academic_session_id` BIGINT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `teacher_assignments_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `teacher_assignments_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `teacher_assignments_employee_id_fk` FOREIGN KEY (`institution_id`,`employee_id`) REFERENCES `employees`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `teacher_assignments_class_subject_id_fk` FOREIGN KEY (`institution_id`,`class_subject_id`) REFERENCES `class_subjects`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `teacher_assignments_academic_session_id_fk` FOREIGN KEY (`institution_id`,`academic_session_id`) REFERENCES `academic_sessions`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `exam_papers` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `examination_id` BIGINT UNSIGNED NOT NULL,
  `subject_id` BIGINT UNSIGNED NOT NULL,
  `full_marks` DECIMAL(7,2) NOT NULL,
  `pass_marks` DECIMAL(7,2) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `exam_papers_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `exam_papers_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `exam_papers_examination_id_fk` FOREIGN KEY (`institution_id`,`examination_id`) REFERENCES `examinations`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `exam_papers_subject_id_fk` FOREIGN KEY (`institution_id`,`subject_id`) REFERENCES `subjects`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `published_results` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `examination_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `percentage` DECIMAL(5,2) NOT NULL,
  `gpa` DECIMAL(4,2) NOT NULL,
  `result` VARCHAR(20) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'draft',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `published_results_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `published_results_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `published_results_examination_id_fk` FOREIGN KEY (`institution_id`,`examination_id`) REFERENCES `examinations`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `published_results_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `fee_plan_lines` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `fee_plan_id` BIGINT UNSIGNED NOT NULL,
  `fee_head_id` BIGINT UNSIGNED NOT NULL,
  `amount` DECIMAL(14,2) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `fee_plan_lines_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `fee_plan_lines_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fee_plan_lines_fee_plan_id_fk` FOREIGN KEY (`institution_id`,`fee_plan_id`) REFERENCES `fee_plans`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `fee_plan_lines_fee_head_id_fk` FOREIGN KEY (`institution_id`,`fee_head_id`) REFERENCES `fee_heads`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `hostel_leave_requests` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `hostel_allocation_id` BIGINT UNSIGNED NOT NULL,
  `starts_on` DATE NOT NULL,
  `ends_on` DATE NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'pending',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hostel_leave_requests_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `hostel_leave_requests_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `hostel_leave_requests_hostel_allocation_id_fk` FOREIGN KEY (`institution_id`,`hostel_allocation_id`) REFERENCES `hostel_allocations`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `lms_resources` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `class_subject_id` BIGINT UNSIGNED NOT NULL,
  `title` VARCHAR(180) NOT NULL,
  `resource_type` VARCHAR(40) NOT NULL,
  `resource_url` VARCHAR(255) NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lms_resources_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `lms_resources_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `lms_resources_class_subject_id_fk` FOREIGN KEY (`institution_id`,`class_subject_id`) REFERENCES `class_subjects`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `student_promotions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `from_enrollment_id` BIGINT UNSIGNED NOT NULL,
  `to_enrollment_id` BIGINT UNSIGNED NULL,
  `promoted_on` DATE NOT NULL,
  `status` VARCHAR(32) NOT NULL DEFAULT 'pending',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_promotions_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `student_promotions_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_promotions_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_promotions_from_enrollment_id_fk` FOREIGN KEY (`institution_id`,`from_enrollment_id`) REFERENCES `enrollments`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_promotions_to_enrollment_id_fk` FOREIGN KEY (`institution_id`,`to_enrollment_id`) REFERENCES `enrollments`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `assignment_submissions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `assignment_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `submitted_at` DATETIME NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'submitted',
  `marks` DECIMAL(7,2) NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `assignment_submissions_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `assignment_submissions_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `assignment_submissions_assignment_id_fk` FOREIGN KEY (`institution_id`,`assignment_id`) REFERENCES `assignments`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `assignment_submissions_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `student_attendance` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `attendance_session_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `status` VARCHAR(16) NOT NULL DEFAULT 'present',
  `minutes_late` INT UNSIGNED NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_attendance_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `student_attendance_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_attendance_attendance_session_id_fk` FOREIGN KEY (`institution_id`,`attendance_session_id`) REFERENCES `attendance_sessions`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `student_attendance_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `exam_marks` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `exam_paper_id` BIGINT UNSIGNED NOT NULL,
  `student_id` BIGINT UNSIGNED NOT NULL,
  `marks` DECIMAL(7,2) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'draft',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `exam_marks_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `exam_marks_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `exam_marks_exam_paper_id_fk` FOREIGN KEY (`institution_id`,`exam_paper_id`) REFERENCES `exam_papers`(`institution_id`,`id`) ON DELETE RESTRICT,
  CONSTRAINT `exam_marks_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `exam_recheck_requests` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `institution_id` BIGINT UNSIGNED NOT NULL,
  `exam_mark_id` BIGINT UNSIGNED NOT NULL,
  `reason` TEXT NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'pending',
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `exam_recheck_requests_institution_id_id_uniq` (`institution_id`,`id`),
  CONSTRAINT `exam_recheck_requests_tenant_fk` FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `exam_recheck_requests_exam_mark_id_fk` FOREIGN KEY (`institution_id`,`exam_mark_id`) REFERENCES `exam_marks`(`institution_id`,`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Scoped business identifiers and operational query indexes
ALTER TABLE `academic_departments` ADD UNIQUE KEY `sms_academic_departments_uniq` (`institution_id`, `code`);
ALTER TABLE `academic_programs` ADD UNIQUE KEY `sms_academic_programs_uniq` (`institution_id`, `code`);
ALTER TABLE `class_levels` ADD UNIQUE KEY `sms_class_levels_uniq` (`institution_id`, `code`);
ALTER TABLE `class_sections` ADD UNIQUE KEY `sms_class_sections_uniq` (`institution_id`, `class_level_id`, `code`);
ALTER TABLE `subjects` ADD UNIQUE KEY `sms_subjects_uniq` (`institution_id`, `code`);
ALTER TABLE `students` ADD UNIQUE KEY `sms_students_uniq` (`institution_id`, `admission_no`);
ALTER TABLE `admission_applications` ADD UNIQUE KEY `sms_admission_applications_uniq` (`institution_id`, `application_no`);
ALTER TABLE `employees` ADD UNIQUE KEY `sms_employees_uniq` (`institution_id`, `employee_no`);
ALTER TABLE `grading_scales` ADD UNIQUE KEY `sms_grading_scales_uniq` (`institution_id`, `code`);
ALTER TABLE `chart_of_accounts` ADD UNIQUE KEY `sms_chart_of_accounts_uniq` (`institution_id`, `code`);
ALTER TABLE `fee_heads` ADD UNIQUE KEY `sms_fee_heads_uniq` (`institution_id`, `code`);
ALTER TABLE `student_invoices` ADD UNIQUE KEY `sms_student_invoices_uniq` (`institution_id`, `invoice_no`);
ALTER TABLE `student_payments` ADD UNIQUE KEY `sms_student_payments_uniq` (`institution_id`, `reference_no`);
ALTER TABLE `payment_methods` ADD UNIQUE KEY `sms_payment_methods_uniq` (`institution_id`, `code`);
ALTER TABLE `ledger_journals` ADD UNIQUE KEY `sms_ledger_journals_uniq` (`institution_id`, `journal_no`);
ALTER TABLE `library_copies` ADD UNIQUE KEY `sms_library_copies_uniq` (`institution_id`, `barcode`);
ALTER TABLE `vehicles` ADD UNIQUE KEY `sms_vehicles_uniq` (`institution_id`, `vehicle_code`);
ALTER TABLE `hostel_rooms` ADD UNIQUE KEY `sms_hostel_rooms_uniq` (`institution_id`, `hostel_id`, `room_code`);
ALTER TABLE `hostel_beds` ADD UNIQUE KEY `sms_hostel_beds_uniq` (`institution_id`, `hostel_room_id`, `bed_code`);
ALTER TABLE `inventory_items` ADD UNIQUE KEY `sms_inventory_items_uniq` (`institution_id`, `sku`);
ALTER TABLE `purchase_orders` ADD UNIQUE KEY `sms_purchase_orders_uniq` (`institution_id`, `po_number`);
ALTER TABLE `fixed_assets` ADD UNIQUE KEY `sms_fixed_assets_uniq` (`institution_id`, `asset_tag`);
ALTER TABLE `donation_funds` ADD UNIQUE KEY `sms_donation_funds_uniq` (`institution_id`, `code`);
ALTER TABLE `donations` ADD UNIQUE KEY `sms_donations_uniq` (`institution_id`, `receipt_no`);
ALTER TABLE `certificate_templates` ADD UNIQUE KEY `sms_certificate_templates_uniq` (`institution_id`, `code`);
ALTER TABLE `issued_certificates` ADD UNIQUE KEY `sms_issued_certificates_uniq` (`institution_id`, `certificate_no`);
ALTER TABLE `notification_templates` ADD UNIQUE KEY `sms_notification_templates_uniq` (`institution_id`, `code`);
ALTER TABLE `financial_period_closings` ADD UNIQUE KEY `sms_financial_period_closings_uniq` (`institution_id`, `academic_session_id`);
ALTER TABLE `student_guardians` ADD UNIQUE KEY `sms_student_guardians_combo_uniq` (`institution_id`, `student_id`, `guardian_id`);
ALTER TABLE `student_attendance` ADD UNIQUE KEY `sms_student_attendance_combo_uniq` (`institution_id`, `attendance_session_id`, `student_id`);
ALTER TABLE `exam_marks` ADD UNIQUE KEY `sms_exam_marks_combo_uniq` (`institution_id`, `exam_paper_id`, `student_id`);
ALTER TABLE `published_results` ADD UNIQUE KEY `sms_published_results_combo_uniq` (`institution_id`, `examination_id`, `student_id`);
ALTER TABLE `payment_allocations` ADD UNIQUE KEY `sms_payment_allocations_combo_uniq` (`institution_id`, `student_payment_id`, `student_invoice_id`);
ALTER TABLE `fee_plan_lines` ADD UNIQUE KEY `sms_fee_plan_lines_combo_uniq` (`institution_id`, `fee_plan_id`, `fee_head_id`);
ALTER TABLE `asset_assignments` ADD UNIQUE KEY `sms_asset_assignments_combo_uniq` (`institution_id`, `fixed_asset_id`, `employee_id`, `assigned_on`);
ALTER TABLE `students` ADD INDEX `sms_students_idx` (`institution_id`, `status`, `campus_id`);
ALTER TABLE `enrollments` ADD INDEX `sms_enrollments_idx` (`institution_id`, `academic_session_id`, `class_section_id`);
ALTER TABLE `student_attendance` ADD INDEX `sms_student_attendance_idx` (`institution_id`, `student_id`, `status`);
ALTER TABLE `exam_marks` ADD INDEX `sms_exam_marks_idx` (`institution_id`, `student_id`, `status`);
ALTER TABLE `student_invoices` ADD INDEX `sms_student_invoices_idx` (`institution_id`, `student_id`, `status`, `due_on`);
ALTER TABLE `student_payments` ADD INDEX `sms_student_payments_idx` (`institution_id`, `student_id`, `paid_on`);
ALTER TABLE `ledger_journals` ADD INDEX `sms_ledger_journals_idx` (`institution_id`, `posted_on`, `status`);
ALTER TABLE `donations` ADD INDEX `sms_donations_idx` (`institution_id`, `donation_fund_id`, `received_on`);
ALTER TABLE `hifz_progress_logs` ADD INDEX `sms_hifz_progress_logs_idx` (`institution_id`, `hifz_enrollment_id`, `logged_on`);
ALTER TABLE `notification_deliveries` ADD INDEX `sms_notification_deliveries_idx` (`institution_id`, `status`, `sent_at`);
ALTER TABLE `integration_logs` ADD INDEX `sms_integration_logs_idx` (`institution_id`, `status`, `logged_at`);

-- Fictional school, college, madrasha records covering all 20 modules
START TRANSACTION;
INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'School Administrator', 'admin.school@example.test', '2026-11-05 08:00:00', '$2y$12$LTt.z8o0eewG85MsVm/tIew5BYkk6kAWzv.iLZ2ojVMPU.SVX1azS', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 'Teacher Nabila', 'teacher.school@example.test', '2026-11-05 08:00:00', '$2y$12$B.0k3ZhEMFS4Fg7/I2Di.udssOJ3QahUnAYlCoeruQXZ5ybJiXOfS', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 'Accounts Officer', 'accounts.school@example.test', '2026-11-05 08:00:00', '$2y$12$s/UjeWcEJo5L27qSfjBf4eKZq8Rw7q3.9/zqo4sbjfWb6w3tGYs4G', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 'Demo Parent', 'parent.school@example.test', '2026-11-05 08:00:00', '$2y$12$9heyWKshTjkAM7LRUmGy6eCKwelv74xLltjk54l0fHtiXGIOS.uq6', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(5, 'Student Ayesha', 'student.school@example.test', '2026-11-05 08:00:00', '$2y$12$419rt5dH9VZzLKOvgvV2aOdPSrW8/PCeeR3pCwCqt4KUBUCa5HDFy', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(6, 'College Administrator', 'admin.college@example.test', '2026-11-05 08:00:00', '$2y$12$JIZROiSTmfaWJEpTiXJN2eONMO304pLQwVk6nkYkg.xglvK3/lbEm', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(7, 'Madrasha Administrator', 'admin.madrasha@example.test', '2026-11-05 08:00:00', '$2y$12$oZDOT4Sai2cP4IxboORwOe7RROk6xW67YKjWYd0P6HBVkMmpHpyxi', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(8, 'Ustad Mahmud', 'ustad.madrasha@example.test', '2026-11-05 08:00:00', '$2y$12$qH.WScj0c8clBqGX1G4Je.pkNivKDOVrSaxkFWB/cZxLpw8uGOwKi', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `institutions` (`id`, `code`, `slug`, `name`, `type`, `status`, `timezone`, `locale`, `currency`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'SCHDEMO', 'demo-sunrise-school', 'Sunrise Model School', 'school', 'active', 'Asia/Dhaka', 'bn', 'BDT', '2026-11-05 08:00:00', '2026-11-05 08:00:00', NULL),
(2, 'COLDEMO', 'demo-horizon-college', 'Horizon Science College', 'college', 'active', 'Asia/Dhaka', 'bn', 'BDT', '2026-11-05 08:00:00', '2026-11-05 08:00:00', NULL),
(3, 'MADDEMO', 'demo-noor-madrasha', 'Noorul Huda Madrasha', 'madrasha', 'active', 'Asia/Dhaka', 'bn', 'BDT', '2026-11-05 08:00:00', '2026-11-05 08:00:00', NULL);

INSERT INTO `campuses` (`id`, `institution_id`, `code`, `name`, `is_main`, `is_active`, `address`, `created_at`, `updated_at`) VALUES
(1, 1, 'MAIN', 'Sunrise Model School Main Campus', 1, 1, 'Demo address, Bangladesh', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'MAIN', 'Horizon Science College Main Campus', 1, 1, 'Demo address, Bangladesh', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'MAIN', 'Noorul Huda Madrasha Main Campus', 1, 1, 'Demo address, Bangladesh', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `academic_sessions` (`id`, `institution_id`, `code`, `name`, `starts_on`, `ends_on`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, '2026', 'Academic Year 2026', '2026-01-01', '2026-12-31', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, '2026', 'Academic Year 2026', '2026-01-01', '2026-12-31', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, '2026', 'Academic Year 2026', '2026-01-01', '2026-12-31', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `institution_roles` (`id`, `institution_id`, `key`, `name`, `is_system`, `created_at`, `updated_at`) VALUES
(1, 1, 'admin', 'Admin', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 1, 'teacher', 'Teacher', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 1, 'accountant', 'Accountant', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 'parent', 'Parent', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(5, 1, 'student', 'Student', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(6, 1, 'hifz_teacher', 'Hifz Teacher', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(7, 2, 'admin', 'Admin', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(8, 2, 'teacher', 'Teacher', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(9, 2, 'accountant', 'Accountant', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(10, 2, 'parent', 'Parent', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(11, 2, 'student', 'Student', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(12, 2, 'hifz_teacher', 'Hifz Teacher', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(13, 3, 'admin', 'Admin', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(14, 3, 'teacher', 'Teacher', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(15, 3, 'accountant', 'Accountant', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(16, 3, 'parent', 'Parent', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(17, 3, 'student', 'Student', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(18, 3, 'hifz_teacher', 'Hifz Teacher', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `institution_memberships` (`id`, `institution_id`, `user_id`, `status`, `can_access_all_campuses`, `joined_at`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'active', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 1, 2, 'active', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 1, 3, 'active', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 'active', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(5, 1, 5, 'active', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(6, 2, 6, 'active', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(7, 3, 7, 'active', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(8, 3, 8, 'active', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `membership_campuses` (`institution_id`, `membership_id`, `campus_id`, `created_at`) VALUES
(1, 1, 1, '2026-11-05 08:00:00'),
(1, 2, 1, '2026-11-05 08:00:00'),
(1, 3, 1, '2026-11-05 08:00:00'),
(1, 4, 1, '2026-11-05 08:00:00'),
(1, 5, 1, '2026-11-05 08:00:00'),
(2, 6, 2, '2026-11-05 08:00:00'),
(3, 7, 3, '2026-11-05 08:00:00'),
(3, 8, 3, '2026-11-05 08:00:00');

INSERT INTO `membership_roles` (`institution_id`, `membership_id`, `role_id`, `created_at`) VALUES
(1, 1, 1, '2026-11-05 08:00:00'),
(1, 2, 2, '2026-11-05 08:00:00'),
(1, 3, 3, '2026-11-05 08:00:00'),
(1, 4, 4, '2026-11-05 08:00:00'),
(1, 5, 5, '2026-11-05 08:00:00'),
(2, 6, 7, '2026-11-05 08:00:00'),
(3, 7, 13, '2026-11-05 08:00:00'),
(3, 8, 18, '2026-11-05 08:00:00');

INSERT INTO `institution_module_settings` (`id`, `institution_id`, `module_key`, `enabled`, `options`, `created_at`, `updated_at`) VALUES
(1, 1, 'academic', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 1, 'admission', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 1, 'analytics', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 'attendance', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(5, 1, 'campus', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(6, 1, 'certificates', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(7, 1, 'communication', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(8, 1, 'donations', 0, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(9, 1, 'exams', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(10, 1, 'finance', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(11, 1, 'hifz', 0, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(12, 1, 'hostel', 0, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(13, 1, 'hr', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(14, 1, 'integrations', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(15, 1, 'inventory', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(16, 1, 'library', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(17, 1, 'lifecycle', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(18, 1, 'lms', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(19, 1, 'scholarship', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(20, 1, 'sis', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(21, 1, 'transport', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(22, 1, 'welfare', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(23, 2, 'academic', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(24, 2, 'admission', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(25, 2, 'analytics', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(26, 2, 'attendance', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(27, 2, 'campus', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(28, 2, 'certificates', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(29, 2, 'communication', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(30, 2, 'donations', 0, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(31, 2, 'exams', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(32, 2, 'finance', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(33, 2, 'hifz', 0, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(34, 2, 'hostel', 0, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(35, 2, 'hr', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(36, 2, 'integrations', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(37, 2, 'inventory', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(38, 2, 'library', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(39, 2, 'lifecycle', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(40, 2, 'lms', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(41, 2, 'scholarship', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(42, 2, 'sis', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(43, 2, 'transport', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(44, 2, 'welfare', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(45, 3, 'academic', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(46, 3, 'admission', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(47, 3, 'analytics', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(48, 3, 'attendance', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(49, 3, 'campus', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(50, 3, 'certificates', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(51, 3, 'communication', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(52, 3, 'donations', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(53, 3, 'exams', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(54, 3, 'finance', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(55, 3, 'hifz', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(56, 3, 'hostel', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(57, 3, 'hr', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(58, 3, 'integrations', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(59, 3, 'inventory', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(60, 3, 'library', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(61, 3, 'lifecycle', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(62, 3, 'lms', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(63, 3, 'scholarship', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(64, 3, 'sis', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(65, 3, 'transport', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(66, 3, 'welfare', 1, NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `sms_permissions` (`id`, `key`, `module`, `label`, `created_at`, `updated_at`) VALUES
(1, 'dashboard.view', 'dashboard', 'View dashboard', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 'institutions.manage', 'institutions', 'Manage institution settings', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 'campuses.view', 'campuses', 'View authorized campuses', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 'campuses.manage', 'campuses', 'Manage campuses', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(5, 'memberships.view', 'security', 'View institution memberships', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(6, 'memberships.manage', 'security', 'Manage institution memberships', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(7, 'roles.manage', 'security', 'Manage role assignments', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(8, 'students.view', 'students', 'View authorized student records', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(9, 'students.create', 'students', 'Create student records', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(10, 'students.update', 'students', 'Update authorized student records', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(11, 'students.export', 'students', 'Export authorized student records', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(12, 'admissions.view', 'admissions', 'View admissions', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(13, 'admissions.manage', 'admissions', 'Manage admissions', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(14, 'academics.manage', 'academics', 'Manage curriculum and classes', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(15, 'attendance.view', 'attendance', 'View attendance', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(16, 'attendance.record', 'attendance', 'Record assigned attendance', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(17, 'attendance.approve_correction', 'attendance', 'Approve attendance corrections', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(18, 'exams.view', 'examinations', 'View examinations', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(19, 'marks.enter', 'examinations', 'Enter assigned subject marks', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(20, 'results.approve', 'examinations', 'Approve examination results', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(21, 'results.publish', 'examinations', 'Publish examination results', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(22, 'fees.view', 'finance', 'View fee information', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(23, 'fees.collect', 'finance', 'Collect approved fees', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(24, 'fees.adjust', 'finance', 'Manage authorized fee adjustments', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(25, 'refunds.request', 'finance', 'Request refund', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(26, 'refunds.approve', 'finance', 'Approve refund', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(27, 'accounting.post', 'finance', 'Post journal transactions', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(28, 'accounting.reconcile', 'finance', 'Reconcile accounts', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(29, 'hr.view', 'hr', 'View authorized staff data', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(30, 'payroll.process', 'hr', 'Process payroll', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(31, 'payroll.approve', 'hr', 'Approve payroll', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(32, 'hifz.progress.record', 'hifz', 'Record assigned Hifz progress', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(33, 'library.manage', 'library', 'Manage library', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(34, 'hostel.manage', 'hostel', 'Manage hostel operations', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(35, 'inventory.manage', 'inventory', 'Manage institutional inventory', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(36, 'donations.manage', 'donations', 'Manage donations and restricted funds', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(37, 'reports.export', 'reports', 'Export authorized reports', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(38, 'audit.view', 'security', 'View authorized audit logs', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `institution_role_permissions` (`role_id`, `permission_id`) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(1, 7),
(1, 8),
(1, 9),
(1, 10),
(1, 11),
(1, 12),
(1, 13),
(1, 14),
(1, 15),
(1, 16),
(1, 17),
(1, 18),
(1, 19),
(1, 20),
(1, 21),
(1, 22),
(1, 23),
(1, 24),
(1, 25),
(1, 26),
(1, 27),
(1, 28),
(1, 29),
(1, 30),
(1, 31),
(1, 32),
(1, 33),
(1, 34),
(1, 35),
(1, 36),
(1, 37),
(1, 38),
(7, 1),
(7, 2),
(7, 3),
(7, 4),
(7, 5),
(7, 6),
(7, 7),
(7, 8),
(7, 9),
(7, 10),
(7, 11),
(7, 12),
(7, 13),
(7, 14),
(7, 15),
(7, 16),
(7, 17),
(7, 18),
(7, 19),
(7, 20),
(7, 21),
(7, 22),
(7, 23),
(7, 24),
(7, 25),
(7, 26),
(7, 27),
(7, 28),
(7, 29),
(7, 30),
(7, 31),
(7, 32),
(7, 33),
(7, 34),
(7, 35),
(7, 36),
(7, 37),
(7, 38),
(13, 1),
(13, 2),
(13, 3),
(13, 4),
(13, 5),
(13, 6),
(13, 7),
(13, 8),
(13, 9),
(13, 10),
(13, 11),
(13, 12),
(13, 13),
(13, 14),
(13, 15),
(13, 16),
(13, 17),
(13, 18),
(13, 19),
(13, 20),
(13, 21),
(13, 22),
(13, 23),
(13, 24);

INSERT INTO `institution_role_permissions` (`role_id`, `permission_id`) VALUES
(13, 25),
(13, 26),
(13, 27),
(13, 28),
(13, 29),
(13, 30),
(13, 31),
(13, 32),
(13, 33),
(13, 34),
(13, 35),
(13, 36),
(13, 37),
(13, 38);

INSERT INTO `academic_departments` (`id`, `institution_id`, `campus_id`, `code`, `name`, `category`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'GEN', 'General Studies', 'general', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'SCI', 'Science Faculty', 'science', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'HIFZ', 'Hifz Department', 'hifz', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `academic_terms` (`id`, `institution_id`, `academic_session_id`, `name`, `starts_on`, `ends_on`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Term 2', '2026-11-05', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Semester 1', '2026-11-05', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Hifz Session', '2026-11-05', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `academic_calendar_events` (`id`, `institution_id`, `academic_session_id`, `title`, `event_type`, `starts_at`, `ends_at`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Annual Science Fair', 'activity', '2026-11-05 09:00:00', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Demo Academic Calendar Events', 'Demo event type', '2026-11-05 09:00:00', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Demo Academic Calendar Events', 'Demo event type', '2026-11-05 09:00:00', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `guardians` (`id`, `institution_id`, `user_id`, `name`, `relation`, `phone`, `email`, `created_at`, `updated_at`) VALUES
(1, 1, 4, 'Md Karim Rahman', 'father', '01700000001', 'parent.school@example.test', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, NULL, 'Mrs Farzana Ahmed', 'mother', '01700000002', 'Demo email', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, NULL, 'Mr Abdul Hakim', 'father', '01700000003', 'Demo email', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, NULL, 'Demo Guardian S-01', 'parent', '000-DMO-S0001', 'guardian-s-1@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, NULL, 'Demo Guardian S-02', 'parent', '000-DMO-S0002', 'guardian-s-2@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, NULL, 'Demo Guardian S-03', 'parent', '000-DMO-S0003', 'guardian-s-3@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, NULL, 'Demo Guardian S-04', 'parent', '000-DMO-S0004', 'guardian-s-4@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 1, NULL, 'Demo Guardian S-05', 'parent', '000-DMO-S0005', 'guardian-s-5@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 1, NULL, 'Demo Guardian S-06', 'parent', '000-DMO-S0006', 'guardian-s-6@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 1, NULL, 'Demo Guardian S-07', 'parent', '000-DMO-S0007', 'guardian-s-7@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 1, NULL, 'Demo Guardian S-08', 'parent', '000-DMO-S0008', 'guardian-s-8@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 1, NULL, 'Demo Guardian S-09', 'parent', '000-DMO-S0009', 'guardian-s-9@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 1, NULL, 'Demo Guardian S-10', 'parent', '000-DMO-S0010', 'guardian-s-10@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 1, NULL, 'Demo Guardian S-11', 'parent', '000-DMO-S0011', 'guardian-s-11@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 1, NULL, 'Demo Guardian S-12', 'parent', '000-DMO-S0012', 'guardian-s-12@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 2, NULL, 'Demo Guardian C-01', 'parent', '000-DMO-C0001', 'guardian-c-1@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 2, NULL, 'Demo Guardian C-02', 'parent', '000-DMO-C0002', 'guardian-c-2@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 2, NULL, 'Demo Guardian C-03', 'parent', '000-DMO-C0003', 'guardian-c-3@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 2, NULL, 'Demo Guardian C-04', 'parent', '000-DMO-C0004', 'guardian-c-4@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 2, NULL, 'Demo Guardian C-05', 'parent', '000-DMO-C0005', 'guardian-c-5@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 2, NULL, 'Demo Guardian C-06', 'parent', '000-DMO-C0006', 'guardian-c-6@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(22, 2, NULL, 'Demo Guardian C-07', 'parent', '000-DMO-C0007', 'guardian-c-7@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(23, 2, NULL, 'Demo Guardian C-08', 'parent', '000-DMO-C0008', 'guardian-c-8@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(24, 2, NULL, 'Demo Guardian C-09', 'parent', '000-DMO-C0009', 'guardian-c-9@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(25, 2, NULL, 'Demo Guardian C-10', 'parent', '000-DMO-C0010', 'guardian-c-10@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(26, 2, NULL, 'Demo Guardian C-11', 'parent', '000-DMO-C0011', 'guardian-c-11@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(27, 2, NULL, 'Demo Guardian C-12', 'parent', '000-DMO-C0012', 'guardian-c-12@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(28, 3, NULL, 'Demo Guardian M-01', 'parent', '000-DMO-M0001', 'guardian-m-1@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(29, 3, NULL, 'Demo Guardian M-02', 'parent', '000-DMO-M0002', 'guardian-m-2@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(30, 3, NULL, 'Demo Guardian M-03', 'parent', '000-DMO-M0003', 'guardian-m-3@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(31, 3, NULL, 'Demo Guardian M-04', 'parent', '000-DMO-M0004', 'guardian-m-4@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(32, 3, NULL, 'Demo Guardian M-05', 'parent', '000-DMO-M0005', 'guardian-m-5@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(33, 3, NULL, 'Demo Guardian M-06', 'parent', '000-DMO-M0006', 'guardian-m-6@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(34, 3, NULL, 'Demo Guardian M-07', 'parent', '000-DMO-M0007', 'guardian-m-7@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(35, 3, NULL, 'Demo Guardian M-08', 'parent', '000-DMO-M0008', 'guardian-m-8@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(36, 3, NULL, 'Demo Guardian M-09', 'parent', '000-DMO-M0009', 'guardian-m-9@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(37, 3, NULL, 'Demo Guardian M-10', 'parent', '000-DMO-M0010', 'guardian-m-10@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(38, 3, NULL, 'Demo Guardian M-11', 'parent', '000-DMO-M0011', 'guardian-m-11@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(39, 3, NULL, 'Demo Guardian M-12', 'parent', '000-DMO-M0012', 'guardian-m-12@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `students` (`id`, `institution_id`, `user_id`, `campus_id`, `admission_no`, `name`, `gender`, `birth_date`, `blood_group`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 5, 1, 'SCH-2026-001', 'Ayesha Rahman', 'female', '2014-02-14', 'B+', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, NULL, 2, 'COL-2026-001', 'Rafi Ahmed', 'male', '2009-06-16', 'A+', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, NULL, 3, 'MAD-2026-001', 'Yusuf Ali', 'male', '2013-08-21', 'O+', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, NULL, 1, 'SCH-EX-0001', 'Anika Rahman', 'female', '2014-02-02', 'B+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, NULL, 1, 'SCH-EX-0002', 'Shahid Hasan', 'male', '2014-03-03', 'O+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, NULL, 1, 'SCH-EX-0003', 'Nusrat Jahan', 'female', '2014-04-04', 'AB+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, NULL, 1, 'SCH-EX-0004', 'Fahim Ahmed', 'male', '2014-05-05', 'A+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 1, NULL, 1, 'SCH-EX-0005', 'Sadia Sultana', 'female', '2014-06-06', 'B+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 1, NULL, 1, 'SCH-EX-0006', 'Tanvir Hossain', 'male', '2014-07-07', 'O+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 1, NULL, 1, 'SCH-EX-0007', 'Mim Akter', 'female', '2014-08-08', 'AB+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 1, NULL, 1, 'SCH-EX-0008', 'Rahat Islam', 'male', '2014-09-09', 'A+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 1, NULL, 1, 'SCH-EX-0009', 'Tasnim Khan', 'female', '2014-10-10', 'B+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 1, NULL, 1, 'SCH-EX-0010', 'Arif Mahmud', 'male', '2014-11-11', 'O+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 1, NULL, 1, 'SCH-EX-0011', 'Jannat Ferdous', 'female', '2014-12-12', 'AB+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 1, NULL, 1, 'SCH-EX-0012', 'Abir Chowdhury', 'male', '2014-01-13', 'A+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 1, NULL, 1, 'SCH-EX-0013', 'Nadia Islam', 'female', '2014-02-14', 'B+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 1, NULL, 1, 'SCH-EX-0014', 'Farhan Kabir', 'male', '2014-03-15', 'O+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 1, NULL, 1, 'SCH-EX-0015', 'Afia Begum', 'female', '2014-04-16', 'AB+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 1, NULL, 1, 'SCH-EX-0016', 'Sakib Alam', 'male', '2014-05-17', 'A+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 1, NULL, 1, 'SCH-EX-0017', 'Mahin Ahmed', 'female', '2014-06-18', 'B+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 1, NULL, 1, 'SCH-EX-0018', 'Sumaiya Noor', 'male', '2014-07-19', 'O+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(22, 1, NULL, 1, 'SCH-EX-0019', 'Rafiul Hasan', 'female', '2014-08-20', 'AB+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(23, 1, NULL, 1, 'SCH-EX-0020', 'Ishrat Jahan', 'male', '2014-09-21', 'A+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(24, 1, NULL, 1, 'SCH-EX-0021', 'Zahid Rahman', 'female', '2014-10-22', 'B+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(25, 1, NULL, 1, 'SCH-EX-0022', 'Rukaiya Akter', 'male', '2014-11-23', 'O+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(26, 1, NULL, 1, 'SCH-EX-0023', 'Adnan Siddique', 'female', '2014-12-24', 'AB+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(27, 1, NULL, 1, 'SCH-EX-0024', 'Lamisa Haque', 'male', '2014-01-25', 'A+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(28, 2, NULL, 2, 'COL-EX-0001', 'Anika Rahman', 'female', '2009-02-02', 'B+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(29, 2, NULL, 2, 'COL-EX-0002', 'Shahid Hasan', 'male', '2009-03-03', 'O+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(30, 2, NULL, 2, 'COL-EX-0003', 'Nusrat Jahan', 'female', '2009-04-04', 'AB+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(31, 2, NULL, 2, 'COL-EX-0004', 'Fahim Ahmed', 'male', '2009-05-05', 'A+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(32, 2, NULL, 2, 'COL-EX-0005', 'Sadia Sultana', 'female', '2009-06-06', 'B+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(33, 2, NULL, 2, 'COL-EX-0006', 'Tanvir Hossain', 'male', '2009-07-07', 'O+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(34, 2, NULL, 2, 'COL-EX-0007', 'Mim Akter', 'female', '2009-08-08', 'AB+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(35, 2, NULL, 2, 'COL-EX-0008', 'Rahat Islam', 'male', '2009-09-09', 'A+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(36, 2, NULL, 2, 'COL-EX-0009', 'Tasnim Khan', 'female', '2009-10-10', 'B+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(37, 2, NULL, 2, 'COL-EX-0010', 'Arif Mahmud', 'male', '2009-11-11', 'O+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(38, 2, NULL, 2, 'COL-EX-0011', 'Jannat Ferdous', 'female', '2009-12-12', 'AB+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(39, 2, NULL, 2, 'COL-EX-0012', 'Abir Chowdhury', 'male', '2009-01-13', 'A+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(40, 2, NULL, 2, 'COL-EX-0013', 'Nadia Islam', 'female', '2009-02-14', 'B+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(41, 2, NULL, 2, 'COL-EX-0014', 'Farhan Kabir', 'male', '2009-03-15', 'O+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(42, 2, NULL, 2, 'COL-EX-0015', 'Afia Begum', 'female', '2009-04-16', 'AB+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(43, 2, NULL, 2, 'COL-EX-0016', 'Sakib Alam', 'male', '2009-05-17', 'A+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(44, 2, NULL, 2, 'COL-EX-0017', 'Mahin Ahmed', 'female', '2009-06-18', 'B+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(45, 2, NULL, 2, 'COL-EX-0018', 'Sumaiya Noor', 'male', '2009-07-19', 'O+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(46, 2, NULL, 2, 'COL-EX-0019', 'Rafiul Hasan', 'female', '2009-08-20', 'AB+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(47, 2, NULL, 2, 'COL-EX-0020', 'Ishrat Jahan', 'male', '2009-09-21', 'A+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(48, 2, NULL, 2, 'COL-EX-0021', 'Zahid Rahman', 'female', '2009-10-22', 'B+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(49, 2, NULL, 2, 'COL-EX-0022', 'Rukaiya Akter', 'male', '2009-11-23', 'O+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(50, 2, NULL, 2, 'COL-EX-0023', 'Adnan Siddique', 'female', '2009-12-24', 'AB+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(51, 2, NULL, 2, 'COL-EX-0024', 'Lamisa Haque', 'male', '2009-01-25', 'A+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(52, 3, NULL, 3, 'MAD-EX-0001', 'Anika Rahman', 'female', '2014-02-02', 'B+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(53, 3, NULL, 3, 'MAD-EX-0002', 'Shahid Hasan', 'male', '2014-03-03', 'O+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(54, 3, NULL, 3, 'MAD-EX-0003', 'Nusrat Jahan', 'female', '2014-04-04', 'AB+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(55, 3, NULL, 3, 'MAD-EX-0004', 'Fahim Ahmed', 'male', '2014-05-05', 'A+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(56, 3, NULL, 3, 'MAD-EX-0005', 'Sadia Sultana', 'female', '2014-06-06', 'B+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(57, 3, NULL, 3, 'MAD-EX-0006', 'Tanvir Hossain', 'male', '2014-07-07', 'O+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(58, 3, NULL, 3, 'MAD-EX-0007', 'Mim Akter', 'female', '2014-08-08', 'AB+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(59, 3, NULL, 3, 'MAD-EX-0008', 'Rahat Islam', 'male', '2014-09-09', 'A+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(60, 3, NULL, 3, 'MAD-EX-0009', 'Tasnim Khan', 'female', '2014-10-10', 'B+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(61, 3, NULL, 3, 'MAD-EX-0010', 'Arif Mahmud', 'male', '2014-11-11', 'O+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(62, 3, NULL, 3, 'MAD-EX-0011', 'Jannat Ferdous', 'female', '2014-12-12', 'AB+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(63, 3, NULL, 3, 'MAD-EX-0012', 'Abir Chowdhury', 'male', '2014-01-13', 'A+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(64, 3, NULL, 3, 'MAD-EX-0013', 'Nadia Islam', 'female', '2014-02-14', 'B+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(65, 3, NULL, 3, 'MAD-EX-0014', 'Farhan Kabir', 'male', '2014-03-15', 'O+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(66, 3, NULL, 3, 'MAD-EX-0015', 'Afia Begum', 'female', '2014-04-16', 'AB+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(67, 3, NULL, 3, 'MAD-EX-0016', 'Sakib Alam', 'male', '2014-05-17', 'A+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(68, 3, NULL, 3, 'MAD-EX-0017', 'Mahin Ahmed', 'female', '2014-06-18', 'B+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(69, 3, NULL, 3, 'MAD-EX-0018', 'Sumaiya Noor', 'male', '2014-07-19', 'O+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(70, 3, NULL, 3, 'MAD-EX-0019', 'Rafiul Hasan', 'female', '2014-08-20', 'AB+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(71, 3, NULL, 3, 'MAD-EX-0020', 'Ishrat Jahan', 'male', '2014-09-21', 'A+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(72, 3, NULL, 3, 'MAD-EX-0021', 'Zahid Rahman', 'female', '2014-10-22', 'B+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(73, 3, NULL, 3, 'MAD-EX-0022', 'Rukaiya Akter', 'male', '2014-11-23', 'O+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(74, 3, NULL, 3, 'MAD-EX-0023', 'Adnan Siddique', 'female', '2014-12-24', 'AB+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(75, 3, NULL, 3, 'MAD-EX-0024', 'Lamisa Haque', 'male', '2014-01-25', 'A+', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `admission_cycles` (`id`, `institution_id`, `academic_session_id`, `campus_id`, `title`, `opens_on`, `closes_on`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '2026 Grade 6 Admission', '2026-11-05', '2026-11-05', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '2026 College Admission', '2026-11-05', '2026-11-05', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '2026 Hifz Admission', '2026-11-05', '2026-11-05', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `employees` (`id`, `institution_id`, `user_id`, `campus_id`, `employee_no`, `name`, `designation`, `joined_on`, `basic_salary`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 2, 1, 'T-001', 'Nabila Islam', 'Class Teacher', '2026-11-05', '35000.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, NULL, 2, 'CT-01', 'Dr Farhana Khan', 'Lecturer', '2026-11-05', '48000.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 8, 3, 'HZ-01', 'Ustad Mahmud', 'Hifz Instructor', '2026-11-05', '30000.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, NULL, 1, 'EX-EMP-S-001', 'Demo Staff S-1', 'Subject Teacher', '2025-07-01', '29500.00', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, NULL, 1, 'EX-EMP-S-002', 'Demo Staff S-2', 'Office Assistant', '2025-07-01', '32000.00', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, NULL, 1, 'EX-EMP-S-003', 'Demo Staff S-3', 'Librarian', '2025-07-01', '34500.00', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 2, NULL, 2, 'EX-EMP-C-001', 'Demo Staff C-1', 'Subject Teacher', '2025-07-01', '30500.00', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 2, NULL, 2, 'EX-EMP-C-002', 'Demo Staff C-2', 'Office Assistant', '2025-07-01', '33000.00', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 2, NULL, 2, 'EX-EMP-C-003', 'Demo Staff C-3', 'Librarian', '2025-07-01', '35500.00', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 3, NULL, 3, 'EX-EMP-M-001', 'Demo Staff M-1', 'Subject Teacher', '2025-07-01', '31500.00', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 3, NULL, 3, 'EX-EMP-M-002', 'Demo Staff M-2', 'Office Assistant', '2025-07-01', '34000.00', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 3, NULL, 3, 'EX-EMP-M-003', 'Demo Staff M-3', 'Librarian', '2025-07-01', '36500.00', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `payroll_runs` (`id`, `institution_id`, `period_start`, `period_end`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, '2026-11-05', '2026-11-05', 'draft', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, '2026-11-05', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, '2026-11-05', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, '2026-10-01', '2026-10-31', 'draft', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 2, '2026-10-01', '2026-10-31', 'draft', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 3, '2026-10-01', '2026-10-31', 'draft', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `grading_scales` (`id`, `institution_id`, `code`, `name`, `created_at`, `updated_at`) VALUES
(1, 1, 'NCTB', 'School GPA 5', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'COL', 'College GPA 5', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'HIFZ', 'Madrasha Grading', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `chart_of_accounts` (`id`, `institution_id`, `code`, `name`, `account_type`, `parent_account_id`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, '1100', 'Student Receivables', 'asset', NULL, 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, '1100', 'Student Receivables', 'asset', NULL, 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, '1100', 'Student Receivables', 'asset', NULL, 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, '1000', 'Cash / Bank', 'asset', NULL, 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(5, 1, '4100', 'Tuition Revenue', 'income', NULL, 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(6, 2, '1000', 'Cash / Bank', 'asset', NULL, 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(7, 2, '4100', 'Tuition Revenue', 'income', NULL, 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(8, 3, '1000', 'Cash / Bank', 'asset', NULL, 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(9, 3, '4100', 'Tuition Revenue', 'income', NULL, 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `payment_methods` (`id`, `institution_id`, `code`, `name`, `method_type`, `created_at`, `updated_at`) VALUES
(1, 1, 'CASH', 'Cash', 'cash', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'BANK', 'Bank Deposit', 'bank', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'CASH', 'Cash', 'cash', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `ledger_journals` (`id`, `institution_id`, `journal_no`, `posted_on`, `source_type`, `source_reference`, `description`, `status`, `created_at`, `updated_at`) VALUES
(4, 1, 'J-1-INV', '2026-11-05', 'invoice', 'INV-S-2026-001', 'Tuition billing (demo)', 'posted', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(5, 1, 'J-1-PAY', '2026-11-05', 'payment', 'CASH-S-001', 'Partial collection (demo)', 'posted', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(6, 2, 'J-2-INV', '2026-11-05', 'invoice', 'INV-C-2026-001', 'Tuition billing (demo)', 'posted', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(7, 2, 'J-2-PAY', '2026-11-05', 'payment', 'BANK-C-001', 'Partial collection (demo)', 'posted', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(8, 3, 'J-3-INV', '2026-11-05', 'invoice', 'INV-M-2026-001', 'Tuition billing (demo)', 'posted', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(9, 3, 'J-3-PAY', '2026-11-05', 'payment', 'CASH-M-001', 'Partial collection (demo)', 'posted', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(10, 1, 'EX-J-INV-S-0001', '2026-10-12', 'invoice', 'EX-INV-S-0001', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 1, 'EX-J-PAY-S-0001', '2026-10-12', 'payment', 'EX-PAY-S-0001', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 1, 'EX-J-INV-S-0002', '2026-10-12', 'invoice', 'EX-INV-S-0002', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 1, 'EX-J-PAY-S-0002', '2026-10-12', 'payment', 'EX-PAY-S-0002', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 1, 'EX-J-INV-S-0003', '2026-10-12', 'invoice', 'EX-INV-S-0003', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 1, 'EX-J-INV-S-0004', '2026-10-12', 'invoice', 'EX-INV-S-0004', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 1, 'EX-J-PAY-S-0004', '2026-10-12', 'payment', 'EX-PAY-S-0004', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 1, 'EX-J-INV-S-0005', '2026-10-12', 'invoice', 'EX-INV-S-0005', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 1, 'EX-J-PAY-S-0005', '2026-10-12', 'payment', 'EX-PAY-S-0005', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 1, 'EX-J-INV-S-0006', '2026-10-12', 'invoice', 'EX-INV-S-0006', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 1, 'EX-J-INV-S-0007', '2026-10-12', 'invoice', 'EX-INV-S-0007', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 1, 'EX-J-PAY-S-0007', '2026-10-12', 'payment', 'EX-PAY-S-0007', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(22, 1, 'EX-J-INV-S-0008', '2026-10-12', 'invoice', 'EX-INV-S-0008', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(23, 1, 'EX-J-PAY-S-0008', '2026-10-12', 'payment', 'EX-PAY-S-0008', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(24, 1, 'EX-J-INV-S-0009', '2026-10-12', 'invoice', 'EX-INV-S-0009', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(25, 1, 'EX-J-INV-S-0010', '2026-10-12', 'invoice', 'EX-INV-S-0010', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(26, 1, 'EX-J-PAY-S-0010', '2026-10-12', 'payment', 'EX-PAY-S-0010', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(27, 1, 'EX-J-INV-S-0011', '2026-10-12', 'invoice', 'EX-INV-S-0011', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(28, 1, 'EX-J-PAY-S-0011', '2026-10-12', 'payment', 'EX-PAY-S-0011', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(29, 1, 'EX-J-INV-S-0012', '2026-10-12', 'invoice', 'EX-INV-S-0012', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(30, 1, 'EX-J-INV-S-0013', '2026-10-12', 'invoice', 'EX-INV-S-0013', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(31, 1, 'EX-J-PAY-S-0013', '2026-10-12', 'payment', 'EX-PAY-S-0013', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(32, 1, 'EX-J-INV-S-0014', '2026-10-12', 'invoice', 'EX-INV-S-0014', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(33, 1, 'EX-J-PAY-S-0014', '2026-10-12', 'payment', 'EX-PAY-S-0014', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(34, 1, 'EX-J-INV-S-0015', '2026-10-12', 'invoice', 'EX-INV-S-0015', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(35, 1, 'EX-J-INV-S-0016', '2026-10-12', 'invoice', 'EX-INV-S-0016', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(36, 1, 'EX-J-PAY-S-0016', '2026-10-12', 'payment', 'EX-PAY-S-0016', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(37, 1, 'EX-J-INV-S-0017', '2026-10-12', 'invoice', 'EX-INV-S-0017', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(38, 1, 'EX-J-PAY-S-0017', '2026-10-12', 'payment', 'EX-PAY-S-0017', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(39, 1, 'EX-J-INV-S-0018', '2026-10-12', 'invoice', 'EX-INV-S-0018', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(40, 1, 'EX-J-INV-S-0019', '2026-10-12', 'invoice', 'EX-INV-S-0019', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(41, 1, 'EX-J-PAY-S-0019', '2026-10-12', 'payment', 'EX-PAY-S-0019', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(42, 1, 'EX-J-INV-S-0020', '2026-10-12', 'invoice', 'EX-INV-S-0020', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(43, 1, 'EX-J-PAY-S-0020', '2026-10-12', 'payment', 'EX-PAY-S-0020', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(44, 1, 'EX-J-INV-S-0021', '2026-10-12', 'invoice', 'EX-INV-S-0021', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(45, 1, 'EX-J-INV-S-0022', '2026-10-12', 'invoice', 'EX-INV-S-0022', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(46, 1, 'EX-J-PAY-S-0022', '2026-10-12', 'payment', 'EX-PAY-S-0022', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(47, 1, 'EX-J-INV-S-0023', '2026-10-12', 'invoice', 'EX-INV-S-0023', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(48, 1, 'EX-J-PAY-S-0023', '2026-10-12', 'payment', 'EX-PAY-S-0023', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(49, 1, 'EX-J-INV-S-0024', '2026-10-12', 'invoice', 'EX-INV-S-0024', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(50, 2, 'EX-J-INV-C-0001', '2026-10-12', 'invoice', 'EX-INV-C-0001', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(51, 2, 'EX-J-PAY-C-0001', '2026-10-12', 'payment', 'EX-PAY-C-0001', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(52, 2, 'EX-J-INV-C-0002', '2026-10-12', 'invoice', 'EX-INV-C-0002', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(53, 2, 'EX-J-PAY-C-0002', '2026-10-12', 'payment', 'EX-PAY-C-0002', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(54, 2, 'EX-J-INV-C-0003', '2026-10-12', 'invoice', 'EX-INV-C-0003', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(55, 2, 'EX-J-INV-C-0004', '2026-10-12', 'invoice', 'EX-INV-C-0004', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(56, 2, 'EX-J-PAY-C-0004', '2026-10-12', 'payment', 'EX-PAY-C-0004', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(57, 2, 'EX-J-INV-C-0005', '2026-10-12', 'invoice', 'EX-INV-C-0005', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(58, 2, 'EX-J-PAY-C-0005', '2026-10-12', 'payment', 'EX-PAY-C-0005', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(59, 2, 'EX-J-INV-C-0006', '2026-10-12', 'invoice', 'EX-INV-C-0006', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(60, 2, 'EX-J-INV-C-0007', '2026-10-12', 'invoice', 'EX-INV-C-0007', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(61, 2, 'EX-J-PAY-C-0007', '2026-10-12', 'payment', 'EX-PAY-C-0007', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(62, 2, 'EX-J-INV-C-0008', '2026-10-12', 'invoice', 'EX-INV-C-0008', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(63, 2, 'EX-J-PAY-C-0008', '2026-10-12', 'payment', 'EX-PAY-C-0008', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(64, 2, 'EX-J-INV-C-0009', '2026-10-12', 'invoice', 'EX-INV-C-0009', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(65, 2, 'EX-J-INV-C-0010', '2026-10-12', 'invoice', 'EX-INV-C-0010', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(66, 2, 'EX-J-PAY-C-0010', '2026-10-12', 'payment', 'EX-PAY-C-0010', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(67, 2, 'EX-J-INV-C-0011', '2026-10-12', 'invoice', 'EX-INV-C-0011', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(68, 2, 'EX-J-PAY-C-0011', '2026-10-12', 'payment', 'EX-PAY-C-0011', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(69, 2, 'EX-J-INV-C-0012', '2026-10-12', 'invoice', 'EX-INV-C-0012', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(70, 2, 'EX-J-INV-C-0013', '2026-10-12', 'invoice', 'EX-INV-C-0013', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(71, 2, 'EX-J-PAY-C-0013', '2026-10-12', 'payment', 'EX-PAY-C-0013', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(72, 2, 'EX-J-INV-C-0014', '2026-10-12', 'invoice', 'EX-INV-C-0014', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(73, 2, 'EX-J-PAY-C-0014', '2026-10-12', 'payment', 'EX-PAY-C-0014', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(74, 2, 'EX-J-INV-C-0015', '2026-10-12', 'invoice', 'EX-INV-C-0015', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(75, 2, 'EX-J-INV-C-0016', '2026-10-12', 'invoice', 'EX-INV-C-0016', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(76, 2, 'EX-J-PAY-C-0016', '2026-10-12', 'payment', 'EX-PAY-C-0016', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(77, 2, 'EX-J-INV-C-0017', '2026-10-12', 'invoice', 'EX-INV-C-0017', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(78, 2, 'EX-J-PAY-C-0017', '2026-10-12', 'payment', 'EX-PAY-C-0017', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(79, 2, 'EX-J-INV-C-0018', '2026-10-12', 'invoice', 'EX-INV-C-0018', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(80, 2, 'EX-J-INV-C-0019', '2026-10-12', 'invoice', 'EX-INV-C-0019', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(81, 2, 'EX-J-PAY-C-0019', '2026-10-12', 'payment', 'EX-PAY-C-0019', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(82, 2, 'EX-J-INV-C-0020', '2026-10-12', 'invoice', 'EX-INV-C-0020', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(83, 2, 'EX-J-PAY-C-0020', '2026-10-12', 'payment', 'EX-PAY-C-0020', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(84, 2, 'EX-J-INV-C-0021', '2026-10-12', 'invoice', 'EX-INV-C-0021', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(85, 2, 'EX-J-INV-C-0022', '2026-10-12', 'invoice', 'EX-INV-C-0022', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(86, 2, 'EX-J-PAY-C-0022', '2026-10-12', 'payment', 'EX-PAY-C-0022', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(87, 2, 'EX-J-INV-C-0023', '2026-10-12', 'invoice', 'EX-INV-C-0023', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(88, 2, 'EX-J-PAY-C-0023', '2026-10-12', 'payment', 'EX-PAY-C-0023', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(89, 2, 'EX-J-INV-C-0024', '2026-10-12', 'invoice', 'EX-INV-C-0024', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(90, 3, 'EX-J-INV-M-0001', '2026-10-12', 'invoice', 'EX-INV-M-0001', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(91, 3, 'EX-J-PAY-M-0001', '2026-10-12', 'payment', 'EX-PAY-M-0001', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(92, 3, 'EX-J-INV-M-0002', '2026-10-12', 'invoice', 'EX-INV-M-0002', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(93, 3, 'EX-J-PAY-M-0002', '2026-10-12', 'payment', 'EX-PAY-M-0002', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(94, 3, 'EX-J-INV-M-0003', '2026-10-12', 'invoice', 'EX-INV-M-0003', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(95, 3, 'EX-J-INV-M-0004', '2026-10-12', 'invoice', 'EX-INV-M-0004', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(96, 3, 'EX-J-PAY-M-0004', '2026-10-12', 'payment', 'EX-PAY-M-0004', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(97, 3, 'EX-J-INV-M-0005', '2026-10-12', 'invoice', 'EX-INV-M-0005', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(98, 3, 'EX-J-PAY-M-0005', '2026-10-12', 'payment', 'EX-PAY-M-0005', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(99, 3, 'EX-J-INV-M-0006', '2026-10-12', 'invoice', 'EX-INV-M-0006', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(100, 3, 'EX-J-INV-M-0007', '2026-10-12', 'invoice', 'EX-INV-M-0007', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(101, 3, 'EX-J-PAY-M-0007', '2026-10-12', 'payment', 'EX-PAY-M-0007', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(102, 3, 'EX-J-INV-M-0008', '2026-10-12', 'invoice', 'EX-INV-M-0008', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(103, 3, 'EX-J-PAY-M-0008', '2026-10-12', 'payment', 'EX-PAY-M-0008', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `ledger_journals` (`id`, `institution_id`, `journal_no`, `posted_on`, `source_type`, `source_reference`, `description`, `status`, `created_at`, `updated_at`) VALUES
(104, 3, 'EX-J-INV-M-0009', '2026-10-12', 'invoice', 'EX-INV-M-0009', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(105, 3, 'EX-J-INV-M-0010', '2026-10-12', 'invoice', 'EX-INV-M-0010', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(106, 3, 'EX-J-PAY-M-0010', '2026-10-12', 'payment', 'EX-PAY-M-0010', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(107, 3, 'EX-J-INV-M-0011', '2026-10-12', 'invoice', 'EX-INV-M-0011', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(108, 3, 'EX-J-PAY-M-0011', '2026-10-12', 'payment', 'EX-PAY-M-0011', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(109, 3, 'EX-J-INV-M-0012', '2026-10-12', 'invoice', 'EX-INV-M-0012', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(110, 3, 'EX-J-INV-M-0013', '2026-10-12', 'invoice', 'EX-INV-M-0013', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(111, 3, 'EX-J-PAY-M-0013', '2026-10-12', 'payment', 'EX-PAY-M-0013', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(112, 3, 'EX-J-INV-M-0014', '2026-10-12', 'invoice', 'EX-INV-M-0014', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(113, 3, 'EX-J-PAY-M-0014', '2026-10-12', 'payment', 'EX-PAY-M-0014', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(114, 3, 'EX-J-INV-M-0015', '2026-10-12', 'invoice', 'EX-INV-M-0015', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(115, 3, 'EX-J-INV-M-0016', '2026-10-12', 'invoice', 'EX-INV-M-0016', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(116, 3, 'EX-J-PAY-M-0016', '2026-10-12', 'payment', 'EX-PAY-M-0016', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(117, 3, 'EX-J-INV-M-0017', '2026-10-12', 'invoice', 'EX-INV-M-0017', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(118, 3, 'EX-J-PAY-M-0017', '2026-10-12', 'payment', 'EX-PAY-M-0017', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(119, 3, 'EX-J-INV-M-0018', '2026-10-12', 'invoice', 'EX-INV-M-0018', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(120, 3, 'EX-J-INV-M-0019', '2026-10-12', 'invoice', 'EX-INV-M-0019', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(121, 3, 'EX-J-PAY-M-0019', '2026-10-12', 'payment', 'EX-PAY-M-0019', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(122, 3, 'EX-J-INV-M-0020', '2026-10-12', 'invoice', 'EX-INV-M-0020', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(123, 3, 'EX-J-PAY-M-0020', '2026-10-12', 'payment', 'EX-PAY-M-0020', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(124, 3, 'EX-J-INV-M-0021', '2026-10-12', 'invoice', 'EX-INV-M-0021', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(125, 3, 'EX-J-INV-M-0022', '2026-10-12', 'invoice', 'EX-INV-M-0022', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(126, 3, 'EX-J-PAY-M-0022', '2026-10-12', 'payment', 'EX-PAY-M-0022', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(127, 3, 'EX-J-INV-M-0023', '2026-10-12', 'invoice', 'EX-INV-M-0023', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(128, 3, 'EX-J-PAY-M-0023', '2026-10-12', 'payment', 'EX-PAY-M-0023', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(129, 3, 'EX-J-INV-M-0024', '2026-10-12', 'invoice', 'EX-INV-M-0024', 'Extended fictional demo transaction', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `financial_period_closings` (`id`, `institution_id`, `academic_session_id`, `closed_on`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `scholarships` (`id`, `institution_id`, `name`, `criteria`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'Merit Support', 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'College Merit Award', 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'Hifz Student Support', 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `notices` (`id`, `institution_id`, `title`, `body`, `audience`, `published_at`, `created_at`, `updated_at`) VALUES
(1, 1, 'School Annual Event', 'Demo announcement for parents', 'all', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'College Orientation', 'Fictional demonstration record', 'Demo audience', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'Hifz Parent Meeting', 'Fictional demonstration record', 'Demo audience', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 'Parent Orientation Meeting (S)', 'This is a fictional CampusSphere sample notice; no real announcement was sent.', 'all', '2026-10-15 09:00:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 'Demo Midterm Notice (S)', 'This is a fictional CampusSphere sample notice; no real announcement was sent.', 'all', '2026-10-15 09:00:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 2, 'Parent Orientation Meeting (C)', 'This is a fictional CampusSphere sample notice; no real announcement was sent.', 'all', '2026-10-15 09:00:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 2, 'Demo Midterm Notice (C)', 'This is a fictional CampusSphere sample notice; no real announcement was sent.', 'all', '2026-10-15 09:00:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 3, 'Parent Orientation Meeting (M)', 'This is a fictional CampusSphere sample notice; no real announcement was sent.', 'all', '2026-10-15 09:00:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 3, 'Demo Midterm Notice (M)', 'This is a fictional CampusSphere sample notice; no real announcement was sent.', 'all', '2026-10-15 09:00:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `direct_messages` (`id`, `institution_id`, `sender_user_id`, `recipient_user_id`, `body`, `read_at`, `created_at`, `updated_at`) VALUES
(1, 1, 2, 4, 'Sample teacher-parent message', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 6, 6, 'Demo staff message', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 8, 7, 'Demo Hifz progress update', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `notification_templates` (`id`, `institution_id`, `code`, `channel`, `body`, `created_at`, `updated_at`) VALUES
(1, 1, 'ABSENCE', 'sms', 'Attendance update: {student_name}', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'RESULT', 'email', 'Fictional demonstration record', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'HIFZ', 'sms', 'Fictional demonstration record', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `library_books` (`id`, `institution_id`, `isbn`, `title`, `author`, `category`, `created_at`, `updated_at`) VALUES
(1, 1, '9780000000001', 'Mathematics Grade Six', 'Demo Board', 'textbook', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, '9780000000002', 'Introduction to Physics', 'Demo Publisher', 'general', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, '9780000000003', 'Tajweed Guide', 'Demo Author', 'religious', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, NULL, 'Demo Mathematics Workbook (S)', 'CampusSphere Demo Editorial', 'Academic', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, NULL, 'Demo English Reader (S)', 'CampusSphere Demo Editorial', 'Academic', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, NULL, 'Demo General Knowledge (S)', 'CampusSphere Demo Editorial', 'Academic', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 2, NULL, 'Demo Mathematics Workbook (C)', 'CampusSphere Demo Editorial', 'Academic', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 2, NULL, 'Demo English Reader (C)', 'CampusSphere Demo Editorial', 'Academic', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 2, NULL, 'Demo General Knowledge (C)', 'CampusSphere Demo Editorial', 'Academic', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 3, NULL, 'Demo Mathematics Workbook (M)', 'CampusSphere Demo Editorial', 'Academic', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 3, NULL, 'Demo English Reader (M)', 'CampusSphere Demo Editorial', 'Academic', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 3, NULL, 'Demo General Knowledge (M)', 'CampusSphere Demo Editorial', 'Academic', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `vehicles` (`id`, `institution_id`, `vehicle_code`, `plate_number`, `seats`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'BUS-01', 'DEMO-DHA-001', 28, 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'BUS-02', 'DEMO-DHA-002', 25, 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'VAN-01', 'DEMO-DHA-003', 12, 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `hostels` (`id`, `institution_id`, `campus_id`, `name`, `category`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Demo Boys Hostel', 'boarding', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'College Hostel', 'general', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Hifz Boarding House', 'general', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `suppliers` (`id`, `institution_id`, `name`, `phone`, `address`, `created_at`, `updated_at`) VALUES
(1, 1, 'Demo Suppliers', 'Demo phone', 'Fictional demonstration record', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'Demo Suppliers', 'Demo phone', 'Fictional demonstration record', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'Demo Suppliers', 'Demo phone', 'Fictional demonstration record', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `inventory_items` (`id`, `institution_id`, `sku`, `name`, `unit`, `reorder_level`, `created_at`, `updated_at`) VALUES
(1, 1, 'NOTEBOOK-A5', 'A5 Notebook', 'piece', 20, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'CHEM-KIT', 'Chemistry Lab Kit', 'kit', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'QUR-STAND', 'Quran Stand', 'piece', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 'EX-ITEM-S-01', 'A4 Exercise Books (S)', 'piece', 15, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 'EX-ITEM-S-02', 'Whiteboard Markers (S)', 'piece', 15, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 'EX-ITEM-S-03', 'Classroom Chalk (S)', 'piece', 15, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 2, 'EX-ITEM-C-01', 'A4 Exercise Books (C)', 'piece', 15, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 2, 'EX-ITEM-C-02', 'Whiteboard Markers (C)', 'piece', 15, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 2, 'EX-ITEM-C-03', 'Classroom Chalk (C)', 'piece', 15, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 3, 'EX-ITEM-M-01', 'A4 Exercise Books (M)', 'piece', 15, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 3, 'EX-ITEM-M-02', 'Whiteboard Markers (M)', 'piece', 15, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 3, 'EX-ITEM-M-03', 'Classroom Chalk (M)', 'piece', 15, '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `fixed_assets` (`id`, `institution_id`, `asset_tag`, `name`, `category`, `purchased_on`, `purchase_cost`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'S-CHAIR-001', 'Teacher Chair', 'furniture', '2026-11-05', '4500.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'C-MIC-001', 'Microscope', 'lab', '2026-11-05', '9000.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'M-DESK-001', 'Reading Desk', 'furniture', '2026-11-05', '3000.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `donors` (`id`, `institution_id`, `name`, `phone`, `email`, `created_at`, `updated_at`) VALUES
(1, 1, 'Demo Education Supporter', 'Demo phone', 'Demo email', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'Demo College Supporter', 'Demo phone', 'Demo email', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'Demo Madrasha Donor', 'Demo phone', 'Demo email', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 'Fictional Supporter S-1', NULL, 'supporter-s-1@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 'Fictional Supporter S-2', NULL, 'supporter-s-2@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 2, 'Fictional Supporter C-1', NULL, 'supporter-c-1@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 2, 'Fictional Supporter C-2', NULL, 'supporter-c-2@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 3, 'Fictional Supporter M-1', NULL, 'supporter-m-1@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 3, 'Fictional Supporter M-2', NULL, 'supporter-m-2@example.test', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `donation_funds` (`id`, `institution_id`, `code`, `name`, `is_restricted`, `created_at`, `updated_at`) VALUES
(1, 1, 'GEN', 'General School Fund', 0, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'GEN', 'College Development', 0, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'ZAKAT', 'Zakat Assistance Fund', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `certificate_templates` (`id`, `institution_id`, `code`, `name`, `template_html`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'TC', 'Transfer Certificate', '<h1>Sample Transfer Certificate</h1>', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'TRANSCRIPT', 'Academic Transcript', 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'HIFZ', 'Hifz Completion Certificate', 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `visitor_logs` (`id`, `institution_id`, `campus_id`, `visitor_name`, `purpose`, `checked_in_at`, `checked_out_at`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Demo Visitor', 'Parent meeting', '2026-11-05 09:00:00', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Demo visitor name', 'Demo purpose', '2026-11-05 09:00:00', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Demo visitor name', 'Demo purpose', '2026-11-05 09:00:00', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `campus_events` (`id`, `institution_id`, `campus_id`, `title`, `starts_at`, `ends_at`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Demo Campus Events', '2026-11-05 09:00:00', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Demo Campus Events', '2026-11-05 09:00:00', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Demo Campus Events', '2026-11-05 09:00:00', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `room_bookings` (`id`, `institution_id`, `campus_id`, `booked_by_user_id`, `room_name`, `starts_at`, `ends_at`, `created_at`, `updated_at`) VALUES
(1, 1, 1, NULL, 'Demo room name', '2026-11-05 09:00:00', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, NULL, 'Demo room name', '2026-11-05 09:00:00', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, NULL, 'Demo room name', '2026-11-05 09:00:00', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `integration_connections` (`id`, `institution_id`, `provider`, `category`, `status`, `configuration`, `created_at`, `updated_at`) VALUES
(1, 1, 'Demo SMS Sandbox', 'sms', 'disabled', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'Demo Payment Sandbox', 'payment', 'disabled', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'Demo Attendance Device', 'attendance', 'disabled', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `report_exports` (`id`, `institution_id`, `user_id`, `report_key`, `requested_at`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'attendance_summary', '2026-11-05 09:00:00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 6, 'fee_summary', '2026-11-05 09:00:00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 7, 'hifz_summary', '2026-11-05 09:00:00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `academic_programs` (`id`, `institution_id`, `department_id`, `code`, `name`, `level`, `required_credits`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'SEC', 'Secondary Education', 'school', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'HSC', 'Higher Secondary Certificate', 'college', '120.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'QUR', 'Quran Memorization', 'hifz', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `subjects` (`id`, `institution_id`, `department_id`, `code`, `name`, `credit_hours`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'MATH', 'Mathematics', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'PHY', 'Physics', '4.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'QURAN', 'Quran Memorization', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `student_guardians` (`id`, `institution_id`, `student_id`, `guardian_id`, `relationship`, `is_primary`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'parent', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 'parent', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 'parent', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 4, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 5, 4, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 6, 5, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, 7, 5, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 1, 8, 6, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 1, 9, 6, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 1, 10, 7, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 1, 11, 7, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 1, 12, 8, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 1, 13, 8, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 1, 14, 9, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 1, 15, 9, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 1, 16, 10, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 1, 17, 10, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 1, 18, 11, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 1, 19, 11, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 1, 20, 12, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 1, 21, 12, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(22, 1, 22, 13, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(23, 1, 23, 13, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(24, 1, 24, 14, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(25, 1, 25, 14, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(26, 1, 26, 15, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(27, 1, 27, 15, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(28, 2, 28, 16, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(29, 2, 29, 16, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(30, 2, 30, 17, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(31, 2, 31, 17, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(32, 2, 32, 18, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(33, 2, 33, 18, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(34, 2, 34, 19, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(35, 2, 35, 19, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(36, 2, 36, 20, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(37, 2, 37, 20, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(38, 2, 38, 21, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(39, 2, 39, 21, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(40, 2, 40, 22, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(41, 2, 41, 22, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(42, 2, 42, 23, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(43, 2, 43, 23, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(44, 2, 44, 24, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(45, 2, 45, 24, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(46, 2, 46, 25, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(47, 2, 47, 25, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(48, 2, 48, 26, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(49, 2, 49, 26, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(50, 2, 50, 27, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(51, 2, 51, 27, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(52, 3, 52, 28, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(53, 3, 53, 28, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(54, 3, 54, 29, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(55, 3, 55, 29, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(56, 3, 56, 30, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(57, 3, 57, 30, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(58, 3, 58, 31, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(59, 3, 59, 31, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(60, 3, 60, 32, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(61, 3, 61, 32, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(62, 3, 62, 33, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(63, 3, 63, 33, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(64, 3, 64, 34, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(65, 3, 65, 34, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(66, 3, 66, 35, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(67, 3, 67, 35, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(68, 3, 68, 36, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(69, 3, 69, 36, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(70, 3, 70, 37, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(71, 3, 71, 37, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(72, 3, 72, 38, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(73, 3, 73, 38, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(74, 3, 74, 39, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(75, 3, 75, 39, 'parent', 1, '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `student_documents` (`id`, `institution_id`, `student_id`, `document_type`, `file_path`, `verification_status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Demo document type', NULL, 'Demo verification status', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Demo document type', NULL, 'Demo verification status', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 5, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 6, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, 7, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 1, 8, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 1, 9, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 1, 10, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 1, 11, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 1, 12, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 1, 13, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 1, 14, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 1, 15, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 1, 16, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 1, 17, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 1, 18, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 1, 19, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 1, 20, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 1, 21, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(22, 1, 22, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(23, 1, 23, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(24, 1, 24, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(25, 1, 25, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(26, 1, 26, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(27, 1, 27, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(28, 2, 28, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(29, 2, 29, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(30, 2, 30, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(31, 2, 31, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(32, 2, 32, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(33, 2, 33, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(34, 2, 34, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(35, 2, 35, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(36, 2, 36, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(37, 2, 37, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(38, 2, 38, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(39, 2, 39, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(40, 2, 40, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(41, 2, 41, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(42, 2, 42, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(43, 2, 43, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(44, 2, 44, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(45, 2, 45, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(46, 2, 46, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(47, 2, 47, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(48, 2, 48, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(49, 2, 49, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(50, 2, 50, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(51, 2, 51, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(52, 3, 52, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(53, 3, 53, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(54, 3, 54, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(55, 3, 55, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(56, 3, 56, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(57, 3, 57, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(58, 3, 58, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(59, 3, 59, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(60, 3, 60, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(61, 3, 61, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(62, 3, 62, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(63, 3, 63, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(64, 3, 64, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(65, 3, 65, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(66, 3, 66, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(67, 3, 67, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(68, 3, 68, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(69, 3, 69, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(70, 3, 70, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(71, 3, 71, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(72, 3, 72, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(73, 3, 73, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(74, 3, 74, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(75, 3, 75, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `student_transfers` (`id`, `institution_id`, `student_id`, `from_campus_id`, `to_campus_id`, `transferred_on`, `reason`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 1, '2026-11-05', 'Demonstration only', 'requested', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 2, '2026-11-05', 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 3, '2026-11-05', 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `student_health_records` (`id`, `institution_id`, `student_id`, `allergies`, `medical_notes`, `emergency_contact`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'None reported in demo data', 'Fictional test record', '01700000001', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Fictional demonstration record', NULL, 'Demo emergency contact', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Fictional demonstration record', NULL, 'Demo emergency contact', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `student_incidents` (`id`, `institution_id`, `student_id`, `occurred_on`, `category`, `details`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2026-11-05', 'attendance_followup', 'Illustrative follow-up only', 'resolved', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, '2026-11-05', 'general', 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, '2026-11-05', 'general', 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `student_leave_requests` (`id`, `institution_id`, `student_id`, `starts_on`, `ends_on`, `reason`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2026-11-05', '2026-11-05', 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, '2026-11-05', '2026-11-05', 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, '2026-11-05', '2026-11-05', 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `staff_attendance` (`id`, `institution_id`, `employee_id`, `attendance_on`, `status`, `check_in_at`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2026-11-05', 'active', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, '2026-11-05', 'active', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, '2026-11-05', 'active', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, '2026-10-20', 'present', '2026-10-20 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 4, '2026-10-21', 'present', '2026-10-21 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 4, '2026-10-22', 'present', '2026-10-22 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, 4, '2026-10-23', 'present', '2026-10-23 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 1, 5, '2026-10-20', 'present', '2026-10-20 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 1, 5, '2026-10-21', 'present', '2026-10-21 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 1, 5, '2026-10-22', 'present', '2026-10-22 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 1, 5, '2026-10-23', 'present', '2026-10-23 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 1, 6, '2026-10-20', 'present', '2026-10-20 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 1, 6, '2026-10-21', 'present', '2026-10-21 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 1, 6, '2026-10-22', 'present', '2026-10-22 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 1, 6, '2026-10-23', 'present', '2026-10-23 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 2, 7, '2026-10-20', 'present', '2026-10-20 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 2, 7, '2026-10-21', 'present', '2026-10-21 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 2, 7, '2026-10-22', 'present', '2026-10-22 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 2, 7, '2026-10-23', 'present', '2026-10-23 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 2, 8, '2026-10-20', 'present', '2026-10-20 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 2, 8, '2026-10-21', 'present', '2026-10-21 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(22, 2, 8, '2026-10-22', 'present', '2026-10-22 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(23, 2, 8, '2026-10-23', 'present', '2026-10-23 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(24, 2, 9, '2026-10-20', 'present', '2026-10-20 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(25, 2, 9, '2026-10-21', 'present', '2026-10-21 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(26, 2, 9, '2026-10-22', 'present', '2026-10-22 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(27, 2, 9, '2026-10-23', 'present', '2026-10-23 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(28, 3, 10, '2026-10-20', 'present', '2026-10-20 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(29, 3, 10, '2026-10-21', 'present', '2026-10-21 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(30, 3, 10, '2026-10-22', 'present', '2026-10-22 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(31, 3, 10, '2026-10-23', 'present', '2026-10-23 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(32, 3, 11, '2026-10-20', 'present', '2026-10-20 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(33, 3, 11, '2026-10-21', 'present', '2026-10-21 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(34, 3, 11, '2026-10-22', 'present', '2026-10-22 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(35, 3, 11, '2026-10-23', 'present', '2026-10-23 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(36, 3, 12, '2026-10-20', 'present', '2026-10-20 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(37, 3, 12, '2026-10-21', 'present', '2026-10-21 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(38, 3, 12, '2026-10-22', 'present', '2026-10-22 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(39, 3, 12, '2026-10-23', 'present', '2026-10-23 08:30:00', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `staff_leave_requests` (`id`, `institution_id`, `employee_id`, `starts_on`, `ends_on`, `reason`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2026-11-05', '2026-11-05', 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, '2026-11-05', '2026-11-05', 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, '2026-11-05', '2026-11-05', 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `payslips` (`id`, `institution_id`, `payroll_run_id`, `employee_id`, `gross_amount`, `deduction_amount`, `net_amount`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '35000.00', '1000.00', '34000.00', 'draft', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '48000.00', '0.00', '48000.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '30000.00', '0.00', '30000.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 4, '29500.00', '0.00', '29500.00', 'draft', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 4, 5, '32000.00', '0.00', '32000.00', 'draft', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 4, 6, '34500.00', '500.00', '34000.00', 'draft', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 2, 5, 7, '30500.00', '0.00', '30500.00', 'draft', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 2, 5, 8, '33000.00', '0.00', '33000.00', 'draft', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 2, 5, 9, '35500.00', '500.00', '35000.00', 'draft', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 3, 6, 10, '31500.00', '0.00', '31500.00', 'draft', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 3, 6, 11, '34000.00', '0.00', '34000.00', 'draft', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 3, 6, 12, '36500.00', '500.00', '36000.00', 'draft', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `staff_appraisals` (`id`, `institution_id`, `employee_id`, `reviewed_on`, `score`, `remarks`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2026-11-05', '91.00', 'Demonstration appraisal', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, '2026-11-05', '0.00', 'Fictional demonstration record', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, '2026-11-05', '0.00', 'Fictional demonstration record', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `grading_bands` (`id`, `institution_id`, `grading_scale_id`, `min_percent`, `max_percent`, `letter_grade`, `grade_point`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '80.00', '100.00', 'A+', '5.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, '80.00', '100.00', 'A+', '5.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, '80.00', '100.00', 'A+', '5.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `fee_heads` (`id`, `institution_id`, `code`, `name`, `revenue_account_id`, `created_at`, `updated_at`) VALUES
(1, 1, 'TUITION', 'Monthly Tuition', 5, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'TUITION', 'College Tuition', 7, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'HIFZ', 'Hifz Tuition', 9, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 'DEMO-TUITION-EXT', 'Extended Demo Tuition', 5, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 2, 'DEMO-TUITION-EXT', 'Extended Demo Tuition', 7, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 3, 'DEMO-TUITION-EXT', 'Extended Demo Tuition', 9, '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `student_invoices` (`id`, `institution_id`, `student_id`, `invoice_no`, `issued_on`, `due_on`, `total_amount`, `paid_amount`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'INV-S-2026-001', '2026-11-05', '2026-11-05', '2500.00', '1000.00', 'partial', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'INV-C-2026-001', '2026-11-05', '2026-11-05', '3800.00', '800.00', 'partial', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'INV-M-2026-001', '2026-11-05', '2026-11-05', '1800.00', '500.00', 'partial', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 'EX-INV-S-0001', '2026-10-01', '2026-10-15', '2500.00', '1250.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 5, 'EX-INV-S-0002', '2026-10-01', '2026-10-15', '2650.00', '2650.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 6, 'EX-INV-S-0003', '2026-10-01', '2026-10-15', '2800.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, 7, 'EX-INV-S-0004', '2026-10-01', '2026-10-15', '2950.00', '1475.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 1, 8, 'EX-INV-S-0005', '2026-10-01', '2026-10-15', '2500.00', '2500.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 1, 9, 'EX-INV-S-0006', '2026-10-01', '2026-10-15', '2650.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 1, 10, 'EX-INV-S-0007', '2026-10-01', '2026-10-15', '2800.00', '1400.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 1, 11, 'EX-INV-S-0008', '2026-10-01', '2026-10-15', '2950.00', '2950.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 1, 12, 'EX-INV-S-0009', '2026-10-01', '2026-10-15', '2500.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 1, 13, 'EX-INV-S-0010', '2026-10-01', '2026-10-15', '2650.00', '1325.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 1, 14, 'EX-INV-S-0011', '2026-10-01', '2026-10-15', '2800.00', '2800.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 1, 15, 'EX-INV-S-0012', '2026-10-01', '2026-10-15', '2950.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 1, 16, 'EX-INV-S-0013', '2026-10-01', '2026-10-15', '2500.00', '1250.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 1, 17, 'EX-INV-S-0014', '2026-10-01', '2026-10-15', '2650.00', '2650.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 1, 18, 'EX-INV-S-0015', '2026-10-01', '2026-10-15', '2800.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 1, 19, 'EX-INV-S-0016', '2026-10-01', '2026-10-15', '2950.00', '1475.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 1, 20, 'EX-INV-S-0017', '2026-10-01', '2026-10-15', '2500.00', '2500.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 1, 21, 'EX-INV-S-0018', '2026-10-01', '2026-10-15', '2650.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(22, 1, 22, 'EX-INV-S-0019', '2026-10-01', '2026-10-15', '2800.00', '1400.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(23, 1, 23, 'EX-INV-S-0020', '2026-10-01', '2026-10-15', '2950.00', '2950.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(24, 1, 24, 'EX-INV-S-0021', '2026-10-01', '2026-10-15', '2500.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(25, 1, 25, 'EX-INV-S-0022', '2026-10-01', '2026-10-15', '2650.00', '1325.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(26, 1, 26, 'EX-INV-S-0023', '2026-10-01', '2026-10-15', '2800.00', '2800.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(27, 1, 27, 'EX-INV-S-0024', '2026-10-01', '2026-10-15', '2950.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(28, 2, 28, 'EX-INV-C-0001', '2026-10-01', '2026-10-15', '3800.00', '1900.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(29, 2, 29, 'EX-INV-C-0002', '2026-10-01', '2026-10-15', '3950.00', '3950.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(30, 2, 30, 'EX-INV-C-0003', '2026-10-01', '2026-10-15', '4100.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(31, 2, 31, 'EX-INV-C-0004', '2026-10-01', '2026-10-15', '4250.00', '2125.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(32, 2, 32, 'EX-INV-C-0005', '2026-10-01', '2026-10-15', '3800.00', '3800.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(33, 2, 33, 'EX-INV-C-0006', '2026-10-01', '2026-10-15', '3950.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(34, 2, 34, 'EX-INV-C-0007', '2026-10-01', '2026-10-15', '4100.00', '2050.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(35, 2, 35, 'EX-INV-C-0008', '2026-10-01', '2026-10-15', '4250.00', '4250.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(36, 2, 36, 'EX-INV-C-0009', '2026-10-01', '2026-10-15', '3800.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(37, 2, 37, 'EX-INV-C-0010', '2026-10-01', '2026-10-15', '3950.00', '1975.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(38, 2, 38, 'EX-INV-C-0011', '2026-10-01', '2026-10-15', '4100.00', '4100.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(39, 2, 39, 'EX-INV-C-0012', '2026-10-01', '2026-10-15', '4250.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(40, 2, 40, 'EX-INV-C-0013', '2026-10-01', '2026-10-15', '3800.00', '1900.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(41, 2, 41, 'EX-INV-C-0014', '2026-10-01', '2026-10-15', '3950.00', '3950.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(42, 2, 42, 'EX-INV-C-0015', '2026-10-01', '2026-10-15', '4100.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(43, 2, 43, 'EX-INV-C-0016', '2026-10-01', '2026-10-15', '4250.00', '2125.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(44, 2, 44, 'EX-INV-C-0017', '2026-10-01', '2026-10-15', '3800.00', '3800.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(45, 2, 45, 'EX-INV-C-0018', '2026-10-01', '2026-10-15', '3950.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(46, 2, 46, 'EX-INV-C-0019', '2026-10-01', '2026-10-15', '4100.00', '2050.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(47, 2, 47, 'EX-INV-C-0020', '2026-10-01', '2026-10-15', '4250.00', '4250.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(48, 2, 48, 'EX-INV-C-0021', '2026-10-01', '2026-10-15', '3800.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(49, 2, 49, 'EX-INV-C-0022', '2026-10-01', '2026-10-15', '3950.00', '1975.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(50, 2, 50, 'EX-INV-C-0023', '2026-10-01', '2026-10-15', '4100.00', '4100.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(51, 2, 51, 'EX-INV-C-0024', '2026-10-01', '2026-10-15', '4250.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(52, 3, 52, 'EX-INV-M-0001', '2026-10-01', '2026-10-15', '1800.00', '900.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(53, 3, 53, 'EX-INV-M-0002', '2026-10-01', '2026-10-15', '1950.00', '1950.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(54, 3, 54, 'EX-INV-M-0003', '2026-10-01', '2026-10-15', '2100.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(55, 3, 55, 'EX-INV-M-0004', '2026-10-01', '2026-10-15', '2250.00', '1125.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(56, 3, 56, 'EX-INV-M-0005', '2026-10-01', '2026-10-15', '1800.00', '1800.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(57, 3, 57, 'EX-INV-M-0006', '2026-10-01', '2026-10-15', '1950.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(58, 3, 58, 'EX-INV-M-0007', '2026-10-01', '2026-10-15', '2100.00', '1050.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(59, 3, 59, 'EX-INV-M-0008', '2026-10-01', '2026-10-15', '2250.00', '2250.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(60, 3, 60, 'EX-INV-M-0009', '2026-10-01', '2026-10-15', '1800.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(61, 3, 61, 'EX-INV-M-0010', '2026-10-01', '2026-10-15', '1950.00', '975.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(62, 3, 62, 'EX-INV-M-0011', '2026-10-01', '2026-10-15', '2100.00', '2100.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(63, 3, 63, 'EX-INV-M-0012', '2026-10-01', '2026-10-15', '2250.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(64, 3, 64, 'EX-INV-M-0013', '2026-10-01', '2026-10-15', '1800.00', '900.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(65, 3, 65, 'EX-INV-M-0014', '2026-10-01', '2026-10-15', '1950.00', '1950.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(66, 3, 66, 'EX-INV-M-0015', '2026-10-01', '2026-10-15', '2100.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(67, 3, 67, 'EX-INV-M-0016', '2026-10-01', '2026-10-15', '2250.00', '1125.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(68, 3, 68, 'EX-INV-M-0017', '2026-10-01', '2026-10-15', '1800.00', '1800.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(69, 3, 69, 'EX-INV-M-0018', '2026-10-01', '2026-10-15', '1950.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(70, 3, 70, 'EX-INV-M-0019', '2026-10-01', '2026-10-15', '2100.00', '1050.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(71, 3, 71, 'EX-INV-M-0020', '2026-10-01', '2026-10-15', '2250.00', '2250.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(72, 3, 72, 'EX-INV-M-0021', '2026-10-01', '2026-10-15', '1800.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(73, 3, 73, 'EX-INV-M-0022', '2026-10-01', '2026-10-15', '1950.00', '975.00', 'partial', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(74, 3, 74, 'EX-INV-M-0023', '2026-10-01', '2026-10-15', '2100.00', '2100.00', 'paid', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(75, 3, 75, 'EX-INV-M-0024', '2026-10-01', '2026-10-15', '2250.00', '0.00', 'unpaid', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `ledger_lines` (`id`, `institution_id`, `ledger_journal_id`, `account_id`, `debit`, `credit`, `created_at`, `updated_at`) VALUES
(4, 1, 4, 1, '2500.00', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(5, 1, 4, 5, '0.00', '2500.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(6, 1, 5, 4, '1000.00', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(7, 1, 5, 1, '0.00', '1000.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(8, 2, 6, 2, '3800.00', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(9, 2, 6, 7, '0.00', '3800.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(10, 2, 7, 6, '800.00', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(11, 2, 7, 2, '0.00', '800.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(12, 3, 8, 3, '1800.00', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(13, 3, 8, 9, '0.00', '1800.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(14, 3, 9, 8, '500.00', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(15, 3, 9, 3, '0.00', '500.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(16, 1, 10, 1, '2500.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 1, 10, 5, '0.00', '2500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 1, 11, 4, '1250.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 1, 11, 1, '0.00', '1250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 1, 12, 1, '2650.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 1, 12, 5, '0.00', '2650.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(22, 1, 13, 4, '2650.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(23, 1, 13, 1, '0.00', '2650.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(24, 1, 14, 1, '2800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(25, 1, 14, 5, '0.00', '2800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(26, 1, 15, 1, '2950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(27, 1, 15, 5, '0.00', '2950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(28, 1, 16, 4, '1475.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(29, 1, 16, 1, '0.00', '1475.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(30, 1, 17, 1, '2500.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(31, 1, 17, 5, '0.00', '2500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(32, 1, 18, 4, '2500.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(33, 1, 18, 1, '0.00', '2500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(34, 1, 19, 1, '2650.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(35, 1, 19, 5, '0.00', '2650.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(36, 1, 20, 1, '2800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(37, 1, 20, 5, '0.00', '2800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(38, 1, 21, 4, '1400.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(39, 1, 21, 1, '0.00', '1400.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(40, 1, 22, 1, '2950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(41, 1, 22, 5, '0.00', '2950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(42, 1, 23, 4, '2950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(43, 1, 23, 1, '0.00', '2950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(44, 1, 24, 1, '2500.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(45, 1, 24, 5, '0.00', '2500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(46, 1, 25, 1, '2650.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(47, 1, 25, 5, '0.00', '2650.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(48, 1, 26, 4, '1325.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(49, 1, 26, 1, '0.00', '1325.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(50, 1, 27, 1, '2800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(51, 1, 27, 5, '0.00', '2800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(52, 1, 28, 4, '2800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(53, 1, 28, 1, '0.00', '2800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(54, 1, 29, 1, '2950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(55, 1, 29, 5, '0.00', '2950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(56, 1, 30, 1, '2500.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(57, 1, 30, 5, '0.00', '2500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(58, 1, 31, 4, '1250.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(59, 1, 31, 1, '0.00', '1250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(60, 1, 32, 1, '2650.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(61, 1, 32, 5, '0.00', '2650.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(62, 1, 33, 4, '2650.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(63, 1, 33, 1, '0.00', '2650.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(64, 1, 34, 1, '2800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(65, 1, 34, 5, '0.00', '2800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(66, 1, 35, 1, '2950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(67, 1, 35, 5, '0.00', '2950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(68, 1, 36, 4, '1475.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(69, 1, 36, 1, '0.00', '1475.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(70, 1, 37, 1, '2500.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(71, 1, 37, 5, '0.00', '2500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(72, 1, 38, 4, '2500.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(73, 1, 38, 1, '0.00', '2500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(74, 1, 39, 1, '2650.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(75, 1, 39, 5, '0.00', '2650.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(76, 1, 40, 1, '2800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(77, 1, 40, 5, '0.00', '2800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(78, 1, 41, 4, '1400.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(79, 1, 41, 1, '0.00', '1400.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(80, 1, 42, 1, '2950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(81, 1, 42, 5, '0.00', '2950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(82, 1, 43, 4, '2950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(83, 1, 43, 1, '0.00', '2950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(84, 1, 44, 1, '2500.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(85, 1, 44, 5, '0.00', '2500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(86, 1, 45, 1, '2650.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(87, 1, 45, 5, '0.00', '2650.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(88, 1, 46, 4, '1325.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(89, 1, 46, 1, '0.00', '1325.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(90, 1, 47, 1, '2800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(91, 1, 47, 5, '0.00', '2800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(92, 1, 48, 4, '2800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(93, 1, 48, 1, '0.00', '2800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(94, 1, 49, 1, '2950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(95, 1, 49, 5, '0.00', '2950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(96, 2, 50, 2, '3800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(97, 2, 50, 7, '0.00', '3800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(98, 2, 51, 6, '1900.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(99, 2, 51, 2, '0.00', '1900.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(100, 2, 52, 2, '3950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(101, 2, 52, 7, '0.00', '3950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(102, 2, 53, 6, '3950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(103, 2, 53, 2, '0.00', '3950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `ledger_lines` (`id`, `institution_id`, `ledger_journal_id`, `account_id`, `debit`, `credit`, `created_at`, `updated_at`) VALUES
(104, 2, 54, 2, '4100.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(105, 2, 54, 7, '0.00', '4100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(106, 2, 55, 2, '4250.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(107, 2, 55, 7, '0.00', '4250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(108, 2, 56, 6, '2125.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(109, 2, 56, 2, '0.00', '2125.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(110, 2, 57, 2, '3800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(111, 2, 57, 7, '0.00', '3800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(112, 2, 58, 6, '3800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(113, 2, 58, 2, '0.00', '3800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(114, 2, 59, 2, '3950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(115, 2, 59, 7, '0.00', '3950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(116, 2, 60, 2, '4100.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(117, 2, 60, 7, '0.00', '4100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(118, 2, 61, 6, '2050.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(119, 2, 61, 2, '0.00', '2050.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(120, 2, 62, 2, '4250.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(121, 2, 62, 7, '0.00', '4250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(122, 2, 63, 6, '4250.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(123, 2, 63, 2, '0.00', '4250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(124, 2, 64, 2, '3800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(125, 2, 64, 7, '0.00', '3800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(126, 2, 65, 2, '3950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(127, 2, 65, 7, '0.00', '3950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(128, 2, 66, 6, '1975.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(129, 2, 66, 2, '0.00', '1975.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(130, 2, 67, 2, '4100.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(131, 2, 67, 7, '0.00', '4100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(132, 2, 68, 6, '4100.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(133, 2, 68, 2, '0.00', '4100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(134, 2, 69, 2, '4250.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(135, 2, 69, 7, '0.00', '4250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(136, 2, 70, 2, '3800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(137, 2, 70, 7, '0.00', '3800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(138, 2, 71, 6, '1900.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(139, 2, 71, 2, '0.00', '1900.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(140, 2, 72, 2, '3950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(141, 2, 72, 7, '0.00', '3950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(142, 2, 73, 6, '3950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(143, 2, 73, 2, '0.00', '3950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(144, 2, 74, 2, '4100.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(145, 2, 74, 7, '0.00', '4100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(146, 2, 75, 2, '4250.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(147, 2, 75, 7, '0.00', '4250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(148, 2, 76, 6, '2125.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(149, 2, 76, 2, '0.00', '2125.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(150, 2, 77, 2, '3800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(151, 2, 77, 7, '0.00', '3800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(152, 2, 78, 6, '3800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(153, 2, 78, 2, '0.00', '3800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(154, 2, 79, 2, '3950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(155, 2, 79, 7, '0.00', '3950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(156, 2, 80, 2, '4100.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(157, 2, 80, 7, '0.00', '4100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(158, 2, 81, 6, '2050.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(159, 2, 81, 2, '0.00', '2050.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(160, 2, 82, 2, '4250.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(161, 2, 82, 7, '0.00', '4250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(162, 2, 83, 6, '4250.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(163, 2, 83, 2, '0.00', '4250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(164, 2, 84, 2, '3800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(165, 2, 84, 7, '0.00', '3800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(166, 2, 85, 2, '3950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(167, 2, 85, 7, '0.00', '3950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(168, 2, 86, 6, '1975.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(169, 2, 86, 2, '0.00', '1975.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(170, 2, 87, 2, '4100.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(171, 2, 87, 7, '0.00', '4100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(172, 2, 88, 6, '4100.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(173, 2, 88, 2, '0.00', '4100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(174, 2, 89, 2, '4250.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(175, 2, 89, 7, '0.00', '4250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(176, 3, 90, 3, '1800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(177, 3, 90, 9, '0.00', '1800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(178, 3, 91, 8, '900.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(179, 3, 91, 3, '0.00', '900.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(180, 3, 92, 3, '1950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(181, 3, 92, 9, '0.00', '1950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(182, 3, 93, 8, '1950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(183, 3, 93, 3, '0.00', '1950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(184, 3, 94, 3, '2100.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(185, 3, 94, 9, '0.00', '2100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(186, 3, 95, 3, '2250.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(187, 3, 95, 9, '0.00', '2250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(188, 3, 96, 8, '1125.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(189, 3, 96, 3, '0.00', '1125.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(190, 3, 97, 3, '1800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(191, 3, 97, 9, '0.00', '1800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(192, 3, 98, 8, '1800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(193, 3, 98, 3, '0.00', '1800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(194, 3, 99, 3, '1950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(195, 3, 99, 9, '0.00', '1950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(196, 3, 100, 3, '2100.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(197, 3, 100, 9, '0.00', '2100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(198, 3, 101, 8, '1050.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(199, 3, 101, 3, '0.00', '1050.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(200, 3, 102, 3, '2250.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(201, 3, 102, 9, '0.00', '2250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(202, 3, 103, 8, '2250.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(203, 3, 103, 3, '0.00', '2250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `ledger_lines` (`id`, `institution_id`, `ledger_journal_id`, `account_id`, `debit`, `credit`, `created_at`, `updated_at`) VALUES
(204, 3, 104, 3, '1800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(205, 3, 104, 9, '0.00', '1800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(206, 3, 105, 3, '1950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(207, 3, 105, 9, '0.00', '1950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(208, 3, 106, 8, '975.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(209, 3, 106, 3, '0.00', '975.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(210, 3, 107, 3, '2100.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(211, 3, 107, 9, '0.00', '2100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(212, 3, 108, 8, '2100.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(213, 3, 108, 3, '0.00', '2100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(214, 3, 109, 3, '2250.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(215, 3, 109, 9, '0.00', '2250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(216, 3, 110, 3, '1800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(217, 3, 110, 9, '0.00', '1800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(218, 3, 111, 8, '900.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(219, 3, 111, 3, '0.00', '900.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(220, 3, 112, 3, '1950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(221, 3, 112, 9, '0.00', '1950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(222, 3, 113, 8, '1950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(223, 3, 113, 3, '0.00', '1950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(224, 3, 114, 3, '2100.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(225, 3, 114, 9, '0.00', '2100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(226, 3, 115, 3, '2250.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(227, 3, 115, 9, '0.00', '2250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(228, 3, 116, 8, '1125.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(229, 3, 116, 3, '0.00', '1125.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(230, 3, 117, 3, '1800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(231, 3, 117, 9, '0.00', '1800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(232, 3, 118, 8, '1800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(233, 3, 118, 3, '0.00', '1800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(234, 3, 119, 3, '1950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(235, 3, 119, 9, '0.00', '1950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(236, 3, 120, 3, '2100.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(237, 3, 120, 9, '0.00', '2100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(238, 3, 121, 8, '1050.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(239, 3, 121, 3, '0.00', '1050.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(240, 3, 122, 3, '2250.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(241, 3, 122, 9, '0.00', '2250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(242, 3, 123, 8, '2250.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(243, 3, 123, 3, '0.00', '2250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(244, 3, 124, 3, '1800.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(245, 3, 124, 9, '0.00', '1800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(246, 3, 125, 3, '1950.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(247, 3, 125, 9, '0.00', '1950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(248, 3, 126, 8, '975.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(249, 3, 126, 3, '0.00', '975.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(250, 3, 127, 3, '2100.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(251, 3, 127, 9, '0.00', '2100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(252, 3, 128, 8, '2100.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(253, 3, 128, 3, '0.00', '2100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(254, 3, 129, 3, '2250.00', '0.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(255, 3, 129, 9, '0.00', '2250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `bank_accounts` (`id`, `institution_id`, `account_id`, `bank_name`, `account_mask`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 4, 'Demo Bank', '****1001', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 6, 'Demo Bank', '****2001', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 8, 'Demo Bank', '****3001', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `expenses` (`id`, `institution_id`, `expense_no`, `description`, `expense_on`, `amount`, `account_id`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'EXP-S-001', 'Classroom stationery', '2026-11-05', '350.00', 1, 'draft', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'Demo expense no', 'Demo description', '2026-11-05', '0.00', 2, 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'Demo expense no', 'Demo description', '2026-11-05', '0.00', 3, 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `scholarship_awards` (`id`, `institution_id`, `scholarship_id`, `student_id`, `amount`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '500.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '0.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '0.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 1, 16, '500.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 1, 17, '500.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 1, 18, '500.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 2, 2, 40, '500.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 2, 2, 41, '500.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 2, 2, 42, '500.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 3, 3, 64, '500.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 3, 3, 65, '500.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 3, 3, 66, '500.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `notification_deliveries` (`id`, `institution_id`, `notification_template_id`, `student_id`, `recipient`, `channel`, `status`, `sent_at`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '01700000001', 'sms', 'queued', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 'Demo recipient', 'Demo channel', 'active', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 'Demo recipient', 'Demo channel', 'active', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `parent_meetings` (`id`, `institution_id`, `student_id`, `employee_id`, `scheduled_at`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '2026-11-05 09:00:00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '2026-11-05 09:00:00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '2026-11-05 09:00:00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `library_copies` (`id`, `institution_id`, `library_book_id`, `barcode`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'SCH-LIB-0001', 'issued', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'COL-LIB-0001', 'issued', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'MAD-LIB-0001', 'issued', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 'EX-LIB-S-1-1', 'issued', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 4, 'EX-LIB-S-1-2', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 5, 'EX-LIB-S-2-1', 'issued', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, 5, 'EX-LIB-S-2-2', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 1, 6, 'EX-LIB-S-3-1', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 1, 6, 'EX-LIB-S-3-2', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 2, 7, 'EX-LIB-C-1-1', 'issued', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 2, 7, 'EX-LIB-C-1-2', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 2, 8, 'EX-LIB-C-2-1', 'issued', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 2, 8, 'EX-LIB-C-2-2', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 2, 9, 'EX-LIB-C-3-1', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 2, 9, 'EX-LIB-C-3-2', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 3, 10, 'EX-LIB-M-1-1', 'issued', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 3, 10, 'EX-LIB-M-1-2', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 3, 11, 'EX-LIB-M-2-1', 'issued', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 3, 11, 'EX-LIB-M-2-2', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 3, 12, 'EX-LIB-M-3-1', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 3, 12, 'EX-LIB-M-3-2', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `transport_routes` (`id`, `institution_id`, `vehicle_id`, `employee_id`, `route_name`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'Demo route name', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 'Demo route name', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 'Demo route name', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `hostel_rooms` (`id`, `institution_id`, `hostel_id`, `room_code`, `capacity`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Demo room code', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Demo room code', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Demo room code', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 1, 'EX-RM-S-1', 3, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 1, 'EX-RM-S-2', 3, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 2, 2, 'EX-RM-C-1', 3, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 2, 2, 'EX-RM-C-2', 3, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 3, 3, 'EX-RM-M-1', 3, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 3, 3, 'EX-RM-M-2', 3, '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `meal_plans` (`id`, `institution_id`, `hostel_id`, `name`, `monthly_rate`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Demo Meal Plans', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Demo Meal Plans', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Demo Meal Plans', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `stock_movements` (`id`, `institution_id`, `inventory_item_id`, `quantity`, `movement_type`, `reference_no`, `moved_on`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 50, 'receive', 'GRN-001', '2026-11-05', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 5, 'receive', 'GRN-002', '2026-11-05', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 15, 'receive', 'GRN-003', '2026-11-05', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 100, 'in', 'EX-STOCK-S-1-IN', '2026-10-18', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 4, -15, 'out', 'EX-STOCK-S-1-OUT', '2026-10-18', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 5, 100, 'in', 'EX-STOCK-S-2-IN', '2026-10-18', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, 5, -15, 'out', 'EX-STOCK-S-2-OUT', '2026-10-18', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 1, 6, 100, 'in', 'EX-STOCK-S-3-IN', '2026-10-18', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 1, 6, -15, 'out', 'EX-STOCK-S-3-OUT', '2026-10-18', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 2, 7, 100, 'in', 'EX-STOCK-C-1-IN', '2026-10-18', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 2, 7, -15, 'out', 'EX-STOCK-C-1-OUT', '2026-10-18', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 2, 8, 100, 'in', 'EX-STOCK-C-2-IN', '2026-10-18', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 2, 8, -15, 'out', 'EX-STOCK-C-2-OUT', '2026-10-18', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 2, 9, 100, 'in', 'EX-STOCK-C-3-IN', '2026-10-18', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 2, 9, -15, 'out', 'EX-STOCK-C-3-OUT', '2026-10-18', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 3, 10, 100, 'in', 'EX-STOCK-M-1-IN', '2026-10-18', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 3, 10, -15, 'out', 'EX-STOCK-M-1-OUT', '2026-10-18', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 3, 11, 100, 'in', 'EX-STOCK-M-2-IN', '2026-10-18', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 3, 11, -15, 'out', 'EX-STOCK-M-2-OUT', '2026-10-18', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 3, 12, 100, 'in', 'EX-STOCK-M-3-IN', '2026-10-18', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 3, 12, -15, 'out', 'EX-STOCK-M-3-OUT', '2026-10-18', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `purchase_orders` (`id`, `institution_id`, `supplier_id`, `po_number`, `ordered_on`, `total_amount`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'PO-S-001', '2026-11-05', '1250.00', 'draft', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'PO-C-001', '2026-11-05', '3000.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'PO-M-001', '2026-11-05', '1800.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `asset_assignments` (`id`, `institution_id`, `fixed_asset_id`, `employee_id`, `assigned_on`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `donations` (`id`, `institution_id`, `donor_id`, `donation_fund_id`, `receipt_no`, `amount`, `received_on`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'DON-S-001', '3000.00', '2026-11-05', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 'DON-C-001', '5000.00', '2026-11-05', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 'DON-M-001', '2500.00', '2026-11-05', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 1, 'EX-DON-S-0001', '2000.00', '2026-10-14', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 5, 1, 'EX-DON-S-0002', '2500.00', '2026-10-14', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 2, 6, 2, 'EX-DON-C-0001', '2000.00', '2026-10-14', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 2, 7, 2, 'EX-DON-C-0002', '2500.00', '2026-10-14', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 3, 8, 3, 'EX-DON-M-0001', '2000.00', '2026-10-14', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 3, 9, 3, 'EX-DON-M-0002', '2500.00', '2026-10-14', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `fund_expenses` (`id`, `institution_id`, `donation_fund_id`, `approved_by_user_id`, `description`, `amount`, `spent_on`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, NULL, 'Sample book support', '500.00', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, NULL, 'Sample campus activity', '600.00', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, NULL, 'Eligible student support (demo)', '400.00', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `welfare_cases` (`id`, `institution_id`, `student_id`, `category`, `details`, `opened_on`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'general', 'Fictional demonstration record', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'general', 'Fictional demonstration record', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'general', 'Fictional demonstration record', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `issued_certificates` (`id`, `institution_id`, `student_id`, `certificate_template_id`, `certificate_no`, `issued_on`, `verification_token`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'CERT-S-001', '2026-11-05', 'demo-sch-token-0001', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 'CERT-C-001', '2026-11-05', 'demo-col-token-0001', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 'CERT-M-001', '2026-11-05', 'demo-mad-token-0001', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `integration_logs` (`id`, `institution_id`, `integration_connection_id`, `event_name`, `status`, `logged_at`, `external_reference`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'connection_check', 'not_configured', '2026-11-05 09:00:00', 'Demo external reference', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'connection_check', 'not_configured', '2026-11-05 09:00:00', 'Demo external reference', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'connection_check', 'not_configured', '2026-11-05 09:00:00', 'Demo external reference', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `alumni_profiles` (`id`, `institution_id`, `student_id`, `graduation_year`, `notes`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 2025, 'Illustrative alumni profile; use historical student enrollment in production', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 1, 'Fictional demonstration record', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 1, 'Fictional demonstration record', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `class_levels` (`id`, `institution_id`, `program_id`, `code`, `name`, `sequence`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'G6', 'Grade 6', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'XI', 'Class XI', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'HIFZ-1', 'Hifz Level 1', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `payslip_items` (`id`, `institution_id`, `payslip_id`, `item_type`, `description`, `amount`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'earning', 'Basic salary', '35000.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'earning', 'Basic salary', '48000.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'earning', 'Basic salary', '30000.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 'earning', 'Basic salary (demo)', '29500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 5, 'earning', 'Basic salary (demo)', '32000.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 6, 'earning', 'Basic salary (demo)', '34500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, 6, 'deduction', 'Demo salary advance', '500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 2, 7, 'earning', 'Basic salary (demo)', '30500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 2, 8, 'earning', 'Basic salary (demo)', '33000.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 2, 9, 'earning', 'Basic salary (demo)', '35500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 2, 9, 'deduction', 'Demo salary advance', '500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 3, 10, 'earning', 'Basic salary (demo)', '31500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 3, 11, 'earning', 'Basic salary (demo)', '34000.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 3, 12, 'earning', 'Basic salary (demo)', '36500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 3, 12, 'deduction', 'Demo salary advance', '500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `student_invoice_lines` (`id`, `institution_id`, `student_invoice_id`, `fee_head_id`, `description`, `amount`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'November Tuition', '2500.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 'November College Tuition', '3800.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 'November Hifz Tuition', '1800.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 4, 'October 2026 demo tuition', '2500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 5, 4, 'October 2026 demo tuition', '2650.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 6, 4, 'October 2026 demo tuition', '2800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, 7, 4, 'October 2026 demo tuition', '2950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 1, 8, 4, 'October 2026 demo tuition', '2500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 1, 9, 4, 'October 2026 demo tuition', '2650.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 1, 10, 4, 'October 2026 demo tuition', '2800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 1, 11, 4, 'October 2026 demo tuition', '2950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 1, 12, 4, 'October 2026 demo tuition', '2500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 1, 13, 4, 'October 2026 demo tuition', '2650.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 1, 14, 4, 'October 2026 demo tuition', '2800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 1, 15, 4, 'October 2026 demo tuition', '2950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 1, 16, 4, 'October 2026 demo tuition', '2500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 1, 17, 4, 'October 2026 demo tuition', '2650.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 1, 18, 4, 'October 2026 demo tuition', '2800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 1, 19, 4, 'October 2026 demo tuition', '2950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 1, 20, 4, 'October 2026 demo tuition', '2500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 1, 21, 4, 'October 2026 demo tuition', '2650.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(22, 1, 22, 4, 'October 2026 demo tuition', '2800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(23, 1, 23, 4, 'October 2026 demo tuition', '2950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(24, 1, 24, 4, 'October 2026 demo tuition', '2500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(25, 1, 25, 4, 'October 2026 demo tuition', '2650.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(26, 1, 26, 4, 'October 2026 demo tuition', '2800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(27, 1, 27, 4, 'October 2026 demo tuition', '2950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(28, 2, 28, 5, 'October 2026 demo tuition', '3800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(29, 2, 29, 5, 'October 2026 demo tuition', '3950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(30, 2, 30, 5, 'October 2026 demo tuition', '4100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(31, 2, 31, 5, 'October 2026 demo tuition', '4250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(32, 2, 32, 5, 'October 2026 demo tuition', '3800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(33, 2, 33, 5, 'October 2026 demo tuition', '3950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(34, 2, 34, 5, 'October 2026 demo tuition', '4100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(35, 2, 35, 5, 'October 2026 demo tuition', '4250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(36, 2, 36, 5, 'October 2026 demo tuition', '3800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(37, 2, 37, 5, 'October 2026 demo tuition', '3950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(38, 2, 38, 5, 'October 2026 demo tuition', '4100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(39, 2, 39, 5, 'October 2026 demo tuition', '4250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(40, 2, 40, 5, 'October 2026 demo tuition', '3800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(41, 2, 41, 5, 'October 2026 demo tuition', '3950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(42, 2, 42, 5, 'October 2026 demo tuition', '4100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(43, 2, 43, 5, 'October 2026 demo tuition', '4250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(44, 2, 44, 5, 'October 2026 demo tuition', '3800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(45, 2, 45, 5, 'October 2026 demo tuition', '3950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(46, 2, 46, 5, 'October 2026 demo tuition', '4100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(47, 2, 47, 5, 'October 2026 demo tuition', '4250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(48, 2, 48, 5, 'October 2026 demo tuition', '3800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(49, 2, 49, 5, 'October 2026 demo tuition', '3950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(50, 2, 50, 5, 'October 2026 demo tuition', '4100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(51, 2, 51, 5, 'October 2026 demo tuition', '4250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(52, 3, 52, 6, 'October 2026 demo tuition', '1800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(53, 3, 53, 6, 'October 2026 demo tuition', '1950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(54, 3, 54, 6, 'October 2026 demo tuition', '2100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(55, 3, 55, 6, 'October 2026 demo tuition', '2250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(56, 3, 56, 6, 'October 2026 demo tuition', '1800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(57, 3, 57, 6, 'October 2026 demo tuition', '1950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(58, 3, 58, 6, 'October 2026 demo tuition', '2100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(59, 3, 59, 6, 'October 2026 demo tuition', '2250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(60, 3, 60, 6, 'October 2026 demo tuition', '1800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(61, 3, 61, 6, 'October 2026 demo tuition', '1950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(62, 3, 62, 6, 'October 2026 demo tuition', '2100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(63, 3, 63, 6, 'October 2026 demo tuition', '2250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(64, 3, 64, 6, 'October 2026 demo tuition', '1800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(65, 3, 65, 6, 'October 2026 demo tuition', '1950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(66, 3, 66, 6, 'October 2026 demo tuition', '2100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(67, 3, 67, 6, 'October 2026 demo tuition', '2250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(68, 3, 68, 6, 'October 2026 demo tuition', '1800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(69, 3, 69, 6, 'October 2026 demo tuition', '1950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(70, 3, 70, 6, 'October 2026 demo tuition', '2100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(71, 3, 71, 6, 'October 2026 demo tuition', '2250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(72, 3, 72, 6, 'October 2026 demo tuition', '1800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(73, 3, 73, 6, 'October 2026 demo tuition', '1950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(74, 3, 74, 6, 'October 2026 demo tuition', '2100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(75, 3, 75, 6, 'October 2026 demo tuition', '2250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `student_payments` (`id`, `institution_id`, `student_id`, `student_invoice_id`, `payment_method_id`, `amount`, `paid_on`, `reference_no`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 1, '1000.00', '2026-11-05', 'CASH-S-001', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 2, '800.00', '2026-11-05', 'BANK-C-001', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 3, '500.00', '2026-11-05', 'CASH-M-001', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 4, 1, '1250.00', '2026-10-12', 'EX-PAY-S-0001', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 5, 5, 1, '2650.00', '2026-10-12', 'EX-PAY-S-0002', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 7, 7, 1, '1475.00', '2026-10-12', 'EX-PAY-S-0004', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, 8, 8, 1, '2500.00', '2026-10-12', 'EX-PAY-S-0005', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 1, 10, 10, 1, '1400.00', '2026-10-12', 'EX-PAY-S-0007', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 1, 11, 11, 1, '2950.00', '2026-10-12', 'EX-PAY-S-0008', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 1, 13, 13, 1, '1325.00', '2026-10-12', 'EX-PAY-S-0010', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 1, 14, 14, 1, '2800.00', '2026-10-12', 'EX-PAY-S-0011', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 1, 16, 16, 1, '1250.00', '2026-10-12', 'EX-PAY-S-0013', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 1, 17, 17, 1, '2650.00', '2026-10-12', 'EX-PAY-S-0014', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 1, 19, 19, 1, '1475.00', '2026-10-12', 'EX-PAY-S-0016', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 1, 20, 20, 1, '2500.00', '2026-10-12', 'EX-PAY-S-0017', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 1, 22, 22, 1, '1400.00', '2026-10-12', 'EX-PAY-S-0019', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 1, 23, 23, 1, '2950.00', '2026-10-12', 'EX-PAY-S-0020', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 1, 25, 25, 1, '1325.00', '2026-10-12', 'EX-PAY-S-0022', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 1, 26, 26, 1, '2800.00', '2026-10-12', 'EX-PAY-S-0023', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 2, 28, 28, 2, '1900.00', '2026-10-12', 'EX-PAY-C-0001', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 2, 29, 29, 2, '3950.00', '2026-10-12', 'EX-PAY-C-0002', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(22, 2, 31, 31, 2, '2125.00', '2026-10-12', 'EX-PAY-C-0004', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(23, 2, 32, 32, 2, '3800.00', '2026-10-12', 'EX-PAY-C-0005', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(24, 2, 34, 34, 2, '2050.00', '2026-10-12', 'EX-PAY-C-0007', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(25, 2, 35, 35, 2, '4250.00', '2026-10-12', 'EX-PAY-C-0008', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(26, 2, 37, 37, 2, '1975.00', '2026-10-12', 'EX-PAY-C-0010', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(27, 2, 38, 38, 2, '4100.00', '2026-10-12', 'EX-PAY-C-0011', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(28, 2, 40, 40, 2, '1900.00', '2026-10-12', 'EX-PAY-C-0013', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(29, 2, 41, 41, 2, '3950.00', '2026-10-12', 'EX-PAY-C-0014', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(30, 2, 43, 43, 2, '2125.00', '2026-10-12', 'EX-PAY-C-0016', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(31, 2, 44, 44, 2, '3800.00', '2026-10-12', 'EX-PAY-C-0017', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(32, 2, 46, 46, 2, '2050.00', '2026-10-12', 'EX-PAY-C-0019', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(33, 2, 47, 47, 2, '4250.00', '2026-10-12', 'EX-PAY-C-0020', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(34, 2, 49, 49, 2, '1975.00', '2026-10-12', 'EX-PAY-C-0022', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(35, 2, 50, 50, 2, '4100.00', '2026-10-12', 'EX-PAY-C-0023', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(36, 3, 52, 52, 3, '900.00', '2026-10-12', 'EX-PAY-M-0001', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(37, 3, 53, 53, 3, '1950.00', '2026-10-12', 'EX-PAY-M-0002', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(38, 3, 55, 55, 3, '1125.00', '2026-10-12', 'EX-PAY-M-0004', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(39, 3, 56, 56, 3, '1800.00', '2026-10-12', 'EX-PAY-M-0005', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(40, 3, 58, 58, 3, '1050.00', '2026-10-12', 'EX-PAY-M-0007', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(41, 3, 59, 59, 3, '2250.00', '2026-10-12', 'EX-PAY-M-0008', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(42, 3, 61, 61, 3, '975.00', '2026-10-12', 'EX-PAY-M-0010', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(43, 3, 62, 62, 3, '2100.00', '2026-10-12', 'EX-PAY-M-0011', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(44, 3, 64, 64, 3, '900.00', '2026-10-12', 'EX-PAY-M-0013', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(45, 3, 65, 65, 3, '1950.00', '2026-10-12', 'EX-PAY-M-0014', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(46, 3, 67, 67, 3, '1125.00', '2026-10-12', 'EX-PAY-M-0016', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(47, 3, 68, 68, 3, '1800.00', '2026-10-12', 'EX-PAY-M-0017', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(48, 3, 70, 70, 3, '1050.00', '2026-10-12', 'EX-PAY-M-0019', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(49, 3, 71, 71, 3, '2250.00', '2026-10-12', 'EX-PAY-M-0020', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(50, 3, 73, 73, 3, '975.00', '2026-10-12', 'EX-PAY-M-0022', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(51, 3, 74, 74, 3, '2100.00', '2026-10-12', 'EX-PAY-M-0023', 'posted', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `bank_reconciliations` (`id`, `institution_id`, `bank_account_id`, `statement_on`, `statement_balance`, `ledger_balance`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2026-11-05', '0.00', '0.00', 'pending', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, '2026-11-05', '0.00', '0.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, '2026-11-05', '0.00', '0.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `library_loans` (`id`, `institution_id`, `library_copy_id`, `student_id`, `issued_on`, `due_on`, `returned_on`, `fine_amount`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '2026-11-05', '2026-11-05', NULL, '0.00', 'issued', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '2026-11-05', '2026-11-05', NULL, '0.00', 'issued', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '2026-11-05', '2026-11-05', NULL, '0.00', 'issued', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 4, '2026-10-20', '2026-11-20', NULL, '0.00', 'issued', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 6, 5, '2026-10-20', '2026-11-20', NULL, '0.00', 'issued', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 2, 10, 28, '2026-10-20', '2026-11-20', NULL, '0.00', 'issued', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 2, 12, 29, '2026-10-20', '2026-11-20', NULL, '0.00', 'issued', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 3, 16, 52, '2026-10-20', '2026-11-20', NULL, '0.00', 'issued', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 3, 18, 53, '2026-10-20', '2026-11-20', NULL, '0.00', 'issued', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `transport_stops` (`id`, `institution_id`, `transport_route_id`, `name`, `stop_order`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Demo Transport Stops', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Demo Transport Stops', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Demo Transport Stops', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 1, 'Extended Demo Stop S-1', 11, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 1, 'Extended Demo Stop S-2', 12, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 2, 2, 'Extended Demo Stop C-1', 11, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 2, 2, 'Extended Demo Stop C-2', 12, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 3, 3, 'Extended Demo Stop M-1', 11, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 3, 3, 'Extended Demo Stop M-2', 12, '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `hostel_beds` (`id`, `institution_id`, `hostel_room_id`, `bed_code`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Demo bed code', 'occupied', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Demo bed code', 'occupied', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Demo bed code', 'occupied', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 'EX-BED-1', 'occupied', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 4, 'EX-BED-2', 'occupied', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 4, 'EX-BED-3', 'occupied', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, 5, 'EX-BED-1', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 1, 5, 'EX-BED-2', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 1, 5, 'EX-BED-3', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 2, 6, 'EX-BED-1', 'occupied', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 2, 6, 'EX-BED-2', 'occupied', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 2, 6, 'EX-BED-3', 'occupied', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 2, 7, 'EX-BED-1', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 2, 7, 'EX-BED-2', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 2, 7, 'EX-BED-3', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 3, 8, 'EX-BED-1', 'occupied', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 3, 8, 'EX-BED-2', 'occupied', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 3, 8, 'EX-BED-3', 'occupied', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 3, 9, 'EX-BED-1', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 3, 9, 'EX-BED-2', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 3, 9, 'EX-BED-3', 'available', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `purchase_order_lines` (`id`, `institution_id`, `purchase_order_id`, `inventory_item_id`, `quantity`, `unit_price`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 50, '25.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 5, '600.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 15, '120.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `class_sections` (`id`, `institution_id`, `campus_id`, `class_level_id`, `code`, `name`, `shift`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'A', 'Section A', 'morning', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 'SCI-A', 'Science A', 'day', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 'B-1', 'Boarding 1', 'day', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `class_subjects` (`id`, `institution_id`, `class_level_id`, `subject_id`, `academic_session_id`, `is_compulsory`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 1, 0, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 2, 0, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 3, 0, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `admission_applications` (`id`, `institution_id`, `admission_cycle_id`, `class_level_id`, `application_no`, `applicant_name`, `guardian_phone`, `score`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'APP-S-001', 'Ayesha Rahman', '01700000001', '87.50', 'approved', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 'APP-C-001', 'Rafi Ahmed', '01700000002', '91.00', 'approved', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 'APP-M-001', 'Yusuf Ali', '01700000003', '78.00', 'approved', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 1, 1, 'EX-APP-S-0001', 'Anika Rahman', '000-DEMO-S-001', '68.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 1, 1, 'EX-APP-S-0002', 'Shahid Hasan', '000-DEMO-S-002', '71.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 1, 1, 'EX-APP-S-0003', 'Nusrat Jahan', '000-DEMO-S-003', '74.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, 1, 1, 'EX-APP-S-0004', 'Fahim Ahmed', '000-DEMO-S-004', '77.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 1, 1, 1, 'EX-APP-S-0005', 'Demo Applicant S-5', '000-DEMO-S-005', '80.00', 'waitlisted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 1, 1, 1, 'EX-APP-S-0006', 'Demo Applicant S-6', '000-DEMO-S-006', '83.00', 'waitlisted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 1, 1, 1, 'EX-APP-S-0007', 'Demo Applicant S-7', '000-DEMO-S-007', NULL, 'submitted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 1, 1, 1, 'EX-APP-S-0008', 'Demo Applicant S-8', '000-DEMO-S-008', NULL, 'submitted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 2, 2, 2, 'EX-APP-C-0001', 'Anika Rahman', '000-DEMO-C-001', '68.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 2, 2, 2, 'EX-APP-C-0002', 'Shahid Hasan', '000-DEMO-C-002', '71.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 2, 2, 2, 'EX-APP-C-0003', 'Nusrat Jahan', '000-DEMO-C-003', '74.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 2, 2, 2, 'EX-APP-C-0004', 'Fahim Ahmed', '000-DEMO-C-004', '77.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 2, 2, 2, 'EX-APP-C-0005', 'Demo Applicant C-5', '000-DEMO-C-005', '80.00', 'waitlisted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 2, 2, 2, 'EX-APP-C-0006', 'Demo Applicant C-6', '000-DEMO-C-006', '83.00', 'waitlisted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 2, 2, 2, 'EX-APP-C-0007', 'Demo Applicant C-7', '000-DEMO-C-007', NULL, 'submitted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 2, 2, 2, 'EX-APP-C-0008', 'Demo Applicant C-8', '000-DEMO-C-008', NULL, 'submitted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 3, 3, 3, 'EX-APP-M-0001', 'Anika Rahman', '000-DEMO-M-001', '68.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 3, 3, 3, 'EX-APP-M-0002', 'Shahid Hasan', '000-DEMO-M-002', '71.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(22, 3, 3, 3, 'EX-APP-M-0003', 'Nusrat Jahan', '000-DEMO-M-003', '74.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(23, 3, 3, 3, 'EX-APP-M-0004', 'Fahim Ahmed', '000-DEMO-M-004', '77.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(24, 3, 3, 3, 'EX-APP-M-0005', 'Demo Applicant M-5', '000-DEMO-M-005', '80.00', 'waitlisted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(25, 3, 3, 3, 'EX-APP-M-0006', 'Demo Applicant M-6', '000-DEMO-M-006', '83.00', 'waitlisted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(26, 3, 3, 3, 'EX-APP-M-0007', 'Demo Applicant M-7', '000-DEMO-M-007', NULL, 'submitted', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(27, 3, 3, 3, 'EX-APP-M-0008', 'Demo Applicant M-8', '000-DEMO-M-008', NULL, 'submitted', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `examinations` (`id`, `institution_id`, `academic_session_id`, `class_level_id`, `name`, `exam_type`, `starts_on`, `ends_on`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'Annual Examination 2026', 'annual', '2026-11-05', '2026-11-05', 'published', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 'Midterm 2026', 'midterm', '2026-11-05', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 'Hifz Assessment 2026', 'oral', '2026-11-05', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 1, 1, 'Extended Demo Class Test 2026', 'class_test', '2026-10-21', '2026-10-21', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 2, 2, 2, 'Extended Demo Class Test 2026', 'class_test', '2026-10-21', '2026-10-21', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 3, 3, 3, 'Extended Demo Class Test 2026', 'class_test', '2026-10-21', '2026-10-21', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `fee_plans` (`id`, `institution_id`, `class_level_id`, `academic_session_id`, `name`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'Grade 6 Monthly Fee', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 'Class XI Tuition', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 'Hifz Monthly Fee', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `payment_allocations` (`id`, `institution_id`, `student_payment_id`, `student_invoice_id`, `amount`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '1000.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '800.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '500.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 4, '1250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 5, 5, '2650.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 6, 7, '1475.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, 7, 8, '2500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 1, 8, 10, '1400.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 1, 9, 11, '2950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 1, 10, 13, '1325.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 1, 11, 14, '2800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 1, 12, 16, '1250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 1, 13, 17, '2650.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 1, 14, 19, '1475.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 1, 15, 20, '2500.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 1, 16, 22, '1400.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 1, 17, 23, '2950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 1, 18, 25, '1325.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 1, 19, 26, '2800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 2, 20, 28, '1900.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 2, 21, 29, '3950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(22, 2, 22, 31, '2125.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(23, 2, 23, 32, '3800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(24, 2, 24, 34, '2050.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(25, 2, 25, 35, '4250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(26, 2, 26, 37, '1975.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(27, 2, 27, 38, '4100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(28, 2, 28, 40, '1900.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(29, 2, 29, 41, '3950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(30, 2, 30, 43, '2125.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(31, 2, 31, 44, '3800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(32, 2, 32, 46, '2050.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(33, 2, 33, 47, '4250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(34, 2, 34, 49, '1975.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(35, 2, 35, 50, '4100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(36, 3, 36, 52, '900.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(37, 3, 37, 53, '1950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(38, 3, 38, 55, '1125.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(39, 3, 39, 56, '1800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(40, 3, 40, 58, '1050.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(41, 3, 41, 59, '2250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(42, 3, 42, 61, '975.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(43, 3, 43, 62, '2100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(44, 3, 44, 64, '900.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(45, 3, 45, 65, '1950.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(46, 3, 46, 67, '1125.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(47, 3, 47, 68, '1800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(48, 3, 48, 70, '1050.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(49, 3, 49, 71, '2250.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(50, 3, 50, 73, '975.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(51, 3, 51, 74, '2100.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `payment_refunds` (`id`, `institution_id`, `student_payment_id`, `amount`, `reason`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '100.00', 'Demonstration refund request, not posted', 'requested', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, '100.00', 'Demo only', 'requested', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, '100.00', 'Demo only', 'requested', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `student_transport_assignments` (`id`, `institution_id`, `student_id`, `transport_route_id`, `transport_stop_id`, `starts_on`, `monthly_fee`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 1, '2026-11-05', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 2, '2026-11-05', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 3, '2026-11-05', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 14, 1, 5, '2026-10-01', '800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 15, 1, 4, '2026-10-01', '800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 16, 1, 5, '2026-10-01', '800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, 17, 1, 4, '2026-10-01', '800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 2, 38, 2, 7, '2026-10-01', '800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 2, 39, 2, 6, '2026-10-01', '800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 2, 40, 2, 7, '2026-10-01', '800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 2, 41, 2, 6, '2026-10-01', '800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 3, 62, 3, 9, '2026-10-01', '800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 3, 63, 3, 8, '2026-10-01', '800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 3, 64, 3, 9, '2026-10-01', '800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 3, 65, 3, 8, '2026-10-01', '800.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `hostel_allocations` (`id`, `institution_id`, `student_id`, `hostel_bed_id`, `check_in_on`, `monthly_fee`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '2026-11-05', '0.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '2026-11-05', '0.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '2026-11-05', '0.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 9, 4, '2026-10-01', '2000.00', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 10, 5, '2026-10-01', '2000.00', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 11, 6, '2026-10-01', '2000.00', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 2, 33, 10, '2026-10-01', '2000.00', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 2, 34, 11, '2026-10-01', '2000.00', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 2, 35, 12, '2026-10-01', '2000.00', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 3, 57, 16, '2026-10-01', '1200.00', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 3, 58, 17, '2026-10-01', '1200.00', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 3, 59, 18, '2026-10-01', '1200.00', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `course_offerings` (`id`, `institution_id`, `academic_term_id`, `class_section_id`, `subject_id`, `capacity`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 1, 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 2, 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 3, 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `class_routines` (`id`, `institution_id`, `class_section_id`, `class_subject_id`, `day_of_week`, `starts_at`, `ends_at`, `room`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'Sunday', '09:00:00', '09:45:00', 'Room 101', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 'Demo day of ', '09:00:00', '09:00:00', 'Demo room', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 'Demo day of ', '09:00:00', '09:00:00', 'Demo room', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `lesson_plans` (`id`, `institution_id`, `class_subject_id`, `lesson_date`, `topic`, `completion_percent`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2026-11-05', 'Fractions', '60.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, '2026-11-05', 'Demo topic', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, '2026-11-05', 'Surah Al-Baqarah Revision', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `assignments` (`id`, `institution_id`, `class_subject_id`, `title`, `details`, `due_at`, `max_marks`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Fractions Worksheet', 'Fictional demonstration record', '2026-11-05 09:00:00', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Physics Lab Preparation', 'Fictional demonstration record', '2026-11-05 09:00:00', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Surah Recitation Practice', 'Fictional demonstration record', '2026-11-05 09:00:00', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `enrollments` (`id`, `institution_id`, `student_id`, `academic_session_id`, `class_section_id`, `roll_no`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 1, '06', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 2, '12', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 3, '03', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 1, 1, '21', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 5, 1, 1, '22', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 6, 1, 1, '23', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, 7, 1, 1, '24', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 1, 8, 1, 1, '25', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 1, 9, 1, 1, '26', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 1, 10, 1, 1, '27', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 1, 11, 1, 1, '28', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 1, 12, 1, 1, '29', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 1, 13, 1, 1, '30', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 1, 14, 1, 1, '31', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 1, 15, 1, 1, '32', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 1, 16, 1, 1, '33', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 1, 17, 1, 1, '34', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 1, 18, 1, 1, '35', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 1, 19, 1, 1, '36', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 1, 20, 1, 1, '37', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 1, 21, 1, 1, '38', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(22, 1, 22, 1, 1, '39', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(23, 1, 23, 1, 1, '40', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(24, 1, 24, 1, 1, '41', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(25, 1, 25, 1, 1, '42', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(26, 1, 26, 1, 1, '43', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(27, 1, 27, 1, 1, '44', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(28, 2, 28, 2, 2, '21', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(29, 2, 29, 2, 2, '22', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(30, 2, 30, 2, 2, '23', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(31, 2, 31, 2, 2, '24', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(32, 2, 32, 2, 2, '25', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(33, 2, 33, 2, 2, '26', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(34, 2, 34, 2, 2, '27', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(35, 2, 35, 2, 2, '28', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(36, 2, 36, 2, 2, '29', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(37, 2, 37, 2, 2, '30', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(38, 2, 38, 2, 2, '31', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(39, 2, 39, 2, 2, '32', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(40, 2, 40, 2, 2, '33', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(41, 2, 41, 2, 2, '34', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(42, 2, 42, 2, 2, '35', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(43, 2, 43, 2, 2, '36', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(44, 2, 44, 2, 2, '37', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(45, 2, 45, 2, 2, '38', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(46, 2, 46, 2, 2, '39', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(47, 2, 47, 2, 2, '40', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(48, 2, 48, 2, 2, '41', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(49, 2, 49, 2, 2, '42', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(50, 2, 50, 2, 2, '43', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(51, 2, 51, 2, 2, '44', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(52, 3, 52, 3, 3, '21', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(53, 3, 53, 3, 3, '22', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(54, 3, 54, 3, 3, '23', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(55, 3, 55, 3, 3, '24', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(56, 3, 56, 3, 3, '25', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(57, 3, 57, 3, 3, '26', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(58, 3, 58, 3, 3, '27', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(59, 3, 59, 3, 3, '28', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(60, 3, 60, 3, 3, '29', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(61, 3, 61, 3, 3, '30', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(62, 3, 62, 3, 3, '31', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(63, 3, 63, 3, 3, '32', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(64, 3, 64, 3, 3, '33', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(65, 3, 65, 3, 3, '34', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(66, 3, 66, 3, 3, '35', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(67, 3, 67, 3, 3, '36', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(68, 3, 68, 3, 3, '37', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(69, 3, 69, 3, 3, '38', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(70, 3, 70, 3, 3, '39', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(71, 3, 71, 3, 3, '40', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(72, 3, 72, 3, 3, '41', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(73, 3, 73, 3, 3, '42', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(74, 3, 74, 3, 3, '43', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(75, 3, 75, 3, 3, '44', 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `admission_offers` (`id`, `institution_id`, `admission_application_id`, `student_id`, `offered_on`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '2026-11-05', 'accepted', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '2026-11-05', 'accepted', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '2026-11-05', 'accepted', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `attendance_sessions` (`id`, `institution_id`, `class_section_id`, `attendance_on`, `period_code`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2026-11-05', 'Demo period code', 'closed', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, '2026-11-05', 'Demo period code', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, '2026-11-05', 'Demo period code', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 1, '2026-10-21', 'EXT-DEMO-S', 'closed', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 1, '2026-10-22', 'EXT-DEMO-S', 'closed', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 1, '2026-10-23', 'EXT-DEMO-S', 'closed', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, 1, '2026-10-24', 'EXT-DEMO-S', 'closed', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 1, 1, '2026-10-25', 'EXT-DEMO-S', 'closed', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 2, 2, '2026-10-21', 'EXT-DEMO-C', 'closed', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 2, 2, '2026-10-22', 'EXT-DEMO-C', 'closed', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 2, 2, '2026-10-23', 'EXT-DEMO-C', 'closed', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 2, 2, '2026-10-24', 'EXT-DEMO-C', 'closed', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 2, 2, '2026-10-25', 'EXT-DEMO-C', 'closed', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 3, 3, '2026-10-21', 'EXT-DEMO-M', 'closed', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 3, 3, '2026-10-22', 'EXT-DEMO-M', 'closed', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 3, 3, '2026-10-23', 'EXT-DEMO-M', 'closed', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 3, 3, '2026-10-24', 'EXT-DEMO-M', 'closed', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 3, 3, '2026-10-25', 'EXT-DEMO-M', 'closed', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `teacher_assignments` (`id`, `institution_id`, `employee_id`, `class_subject_id`, `academic_session_id`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 2, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 3, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `exam_papers` (`id`, `institution_id`, `examination_id`, `subject_id`, `full_marks`, `pass_marks`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '100.00', '33.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '0.00', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '0.00', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 1, '100.00', '33.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 2, 5, 2, '100.00', '33.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 3, 6, 3, '100.00', '33.00', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `published_results` (`id`, `institution_id`, `examination_id`, `student_id`, `percentage`, `gpa`, `result`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '86.00', '5.00', 'pass', 'published', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '91.00', '5.00', 'pass', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '83.00', '5.00', 'pass', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 4, '34.00', '1.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 4, 5, '41.00', '2.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 4, 6, '48.00', '2.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, 4, 7, '55.00', '3.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 1, 4, 8, '62.00', '3.50', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 1, 4, 9, '69.00', '3.50', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 1, 4, 10, '76.00', '4.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 1, 4, 11, '83.00', '5.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 1, 4, 12, '90.00', '5.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 1, 4, 13, '97.00', '5.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 1, 4, 14, '30.00', '0.00', 'fail', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 1, 4, 15, '37.00', '1.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 1, 4, 16, '44.00', '2.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 1, 4, 17, '51.00', '3.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 1, 4, 18, '58.00', '3.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 1, 4, 19, '65.00', '3.50', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 1, 4, 20, '72.00', '4.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 1, 4, 21, '79.00', '4.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(22, 1, 4, 22, '86.00', '5.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(23, 1, 4, 23, '93.00', '5.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(24, 1, 4, 24, '26.00', '0.00', 'fail', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(25, 1, 4, 25, '33.00', '1.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(26, 1, 4, 26, '40.00', '2.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(27, 1, 4, 27, '47.00', '2.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(28, 2, 5, 28, '37.00', '1.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(29, 2, 5, 29, '44.00', '2.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(30, 2, 5, 30, '51.00', '3.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(31, 2, 5, 31, '58.00', '3.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(32, 2, 5, 32, '65.00', '3.50', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(33, 2, 5, 33, '72.00', '4.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(34, 2, 5, 34, '79.00', '4.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(35, 2, 5, 35, '86.00', '5.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(36, 2, 5, 36, '93.00', '5.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(37, 2, 5, 37, '26.00', '0.00', 'fail', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(38, 2, 5, 38, '33.00', '1.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(39, 2, 5, 39, '40.00', '2.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(40, 2, 5, 40, '47.00', '2.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(41, 2, 5, 41, '54.00', '3.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(42, 2, 5, 42, '61.00', '3.50', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(43, 2, 5, 43, '68.00', '3.50', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(44, 2, 5, 44, '75.00', '4.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(45, 2, 5, 45, '82.00', '5.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(46, 2, 5, 46, '89.00', '5.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(47, 2, 5, 47, '96.00', '5.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(48, 2, 5, 48, '29.00', '0.00', 'fail', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(49, 2, 5, 49, '36.00', '1.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(50, 2, 5, 50, '43.00', '2.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(51, 2, 5, 51, '50.00', '3.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(52, 3, 6, 52, '40.00', '2.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(53, 3, 6, 53, '47.00', '2.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(54, 3, 6, 54, '54.00', '3.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(55, 3, 6, 55, '61.00', '3.50', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(56, 3, 6, 56, '68.00', '3.50', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(57, 3, 6, 57, '75.00', '4.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(58, 3, 6, 58, '82.00', '5.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(59, 3, 6, 59, '89.00', '5.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(60, 3, 6, 60, '96.00', '5.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(61, 3, 6, 61, '29.00', '0.00', 'fail', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(62, 3, 6, 62, '36.00', '1.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(63, 3, 6, 63, '43.00', '2.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(64, 3, 6, 64, '50.00', '3.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(65, 3, 6, 65, '57.00', '3.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(66, 3, 6, 66, '64.00', '3.50', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(67, 3, 6, 67, '71.00', '4.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(68, 3, 6, 68, '78.00', '4.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(69, 3, 6, 69, '85.00', '5.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(70, 3, 6, 70, '92.00', '5.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(71, 3, 6, 71, '25.00', '0.00', 'fail', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(72, 3, 6, 72, '32.00', '0.00', 'fail', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(73, 3, 6, 73, '39.00', '1.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(74, 3, 6, 74, '46.00', '2.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(75, 3, 6, 75, '53.00', '3.00', 'pass', 'published', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `fee_plan_lines` (`id`, `institution_id`, `fee_plan_id`, `fee_head_id`, `amount`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '2500.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '3800.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '1800.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `hostel_leave_requests` (`id`, `institution_id`, `hostel_allocation_id`, `starts_on`, `ends_on`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2026-11-05', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, '2026-11-05', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, '2026-11-05', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `lms_resources` (`id`, `institution_id`, `class_subject_id`, `title`, `resource_type`, `resource_url`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Demo Lms Resources', 'Demo resource type', 'Demo resource url', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Demo Lms Resources', 'Demo resource type', 'Demo resource url', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Demo Lms Resources', 'Demo resource type', 'Demo resource url', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `student_promotions` (`id`, `institution_id`, `student_id`, `from_enrollment_id`, `to_enrollment_id`, `promoted_on`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 1, '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 2, '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 3, '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `assignment_submissions` (`id`, `institution_id`, `assignment_id`, `student_id`, `submitted_at`, `status`, `marks`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '2026-11-05 09:00:00', 'active', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '2026-11-05 09:00:00', 'active', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '2026-11-05 09:00:00', 'active', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `student_attendance` (`id`, `institution_id`, `attendance_session_id`, `student_id`, `status`, `minutes_late`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'present', 0, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 'present', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 'late', 10, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 4, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 4, 5, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 4, 6, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, 4, 7, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 1, 4, 8, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 1, 4, 9, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 1, 4, 10, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 1, 4, 11, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 1, 4, 12, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 1, 4, 13, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 1, 4, 14, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 1, 4, 15, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 1, 4, 16, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 1, 4, 17, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 1, 4, 18, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 1, 4, 19, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 1, 4, 20, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 1, 4, 21, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(22, 1, 4, 22, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(23, 1, 4, 23, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(24, 1, 4, 24, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(25, 1, 4, 25, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(26, 1, 4, 26, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(27, 1, 4, 27, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(28, 1, 5, 4, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(29, 1, 5, 5, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(30, 1, 5, 6, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(31, 1, 5, 7, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(32, 1, 5, 8, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(33, 1, 5, 9, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(34, 1, 5, 10, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(35, 1, 5, 11, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(36, 1, 5, 12, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(37, 1, 5, 13, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(38, 1, 5, 14, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(39, 1, 5, 15, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(40, 1, 5, 16, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(41, 1, 5, 17, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(42, 1, 5, 18, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(43, 1, 5, 19, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(44, 1, 5, 20, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(45, 1, 5, 21, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(46, 1, 5, 22, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(47, 1, 5, 23, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(48, 1, 5, 24, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(49, 1, 5, 25, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(50, 1, 5, 26, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(51, 1, 5, 27, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(52, 1, 6, 4, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(53, 1, 6, 5, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(54, 1, 6, 6, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(55, 1, 6, 7, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(56, 1, 6, 8, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(57, 1, 6, 9, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(58, 1, 6, 10, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(59, 1, 6, 11, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(60, 1, 6, 12, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(61, 1, 6, 13, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(62, 1, 6, 14, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(63, 1, 6, 15, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(64, 1, 6, 16, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(65, 1, 6, 17, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(66, 1, 6, 18, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(67, 1, 6, 19, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(68, 1, 6, 20, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(69, 1, 6, 21, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(70, 1, 6, 22, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(71, 1, 6, 23, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(72, 1, 6, 24, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(73, 1, 6, 25, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(74, 1, 6, 26, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(75, 1, 6, 27, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(76, 1, 7, 4, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(77, 1, 7, 5, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(78, 1, 7, 6, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(79, 1, 7, 7, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(80, 1, 7, 8, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(81, 1, 7, 9, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(82, 1, 7, 10, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(83, 1, 7, 11, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(84, 1, 7, 12, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(85, 1, 7, 13, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(86, 1, 7, 14, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(87, 1, 7, 15, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(88, 1, 7, 16, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(89, 1, 7, 17, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(90, 1, 7, 18, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(91, 1, 7, 19, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(92, 1, 7, 20, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(93, 1, 7, 21, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(94, 1, 7, 22, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(95, 1, 7, 23, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(96, 1, 7, 24, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(97, 1, 7, 25, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(98, 1, 7, 26, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(99, 1, 7, 27, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(100, 1, 8, 4, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `student_attendance` (`id`, `institution_id`, `attendance_session_id`, `student_id`, `status`, `minutes_late`, `created_at`, `updated_at`) VALUES
(101, 1, 8, 5, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(102, 1, 8, 6, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(103, 1, 8, 7, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(104, 1, 8, 8, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(105, 1, 8, 9, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(106, 1, 8, 10, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(107, 1, 8, 11, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(108, 1, 8, 12, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(109, 1, 8, 13, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(110, 1, 8, 14, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(111, 1, 8, 15, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(112, 1, 8, 16, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(113, 1, 8, 17, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(114, 1, 8, 18, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(115, 1, 8, 19, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(116, 1, 8, 20, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(117, 1, 8, 21, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(118, 1, 8, 22, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(119, 1, 8, 23, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(120, 1, 8, 24, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(121, 1, 8, 25, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(122, 1, 8, 26, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(123, 1, 8, 27, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(124, 2, 9, 28, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(125, 2, 9, 29, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(126, 2, 9, 30, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(127, 2, 9, 31, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(128, 2, 9, 32, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(129, 2, 9, 33, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(130, 2, 9, 34, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(131, 2, 9, 35, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(132, 2, 9, 36, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(133, 2, 9, 37, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(134, 2, 9, 38, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(135, 2, 9, 39, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(136, 2, 9, 40, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(137, 2, 9, 41, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(138, 2, 9, 42, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(139, 2, 9, 43, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(140, 2, 9, 44, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(141, 2, 9, 45, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(142, 2, 9, 46, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(143, 2, 9, 47, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(144, 2, 9, 48, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(145, 2, 9, 49, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(146, 2, 9, 50, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(147, 2, 9, 51, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(148, 2, 10, 28, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(149, 2, 10, 29, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(150, 2, 10, 30, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(151, 2, 10, 31, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(152, 2, 10, 32, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(153, 2, 10, 33, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(154, 2, 10, 34, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(155, 2, 10, 35, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(156, 2, 10, 36, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(157, 2, 10, 37, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(158, 2, 10, 38, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(159, 2, 10, 39, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(160, 2, 10, 40, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(161, 2, 10, 41, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(162, 2, 10, 42, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(163, 2, 10, 43, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(164, 2, 10, 44, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(165, 2, 10, 45, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(166, 2, 10, 46, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(167, 2, 10, 47, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(168, 2, 10, 48, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(169, 2, 10, 49, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(170, 2, 10, 50, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(171, 2, 10, 51, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(172, 2, 11, 28, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(173, 2, 11, 29, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(174, 2, 11, 30, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(175, 2, 11, 31, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(176, 2, 11, 32, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(177, 2, 11, 33, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(178, 2, 11, 34, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(179, 2, 11, 35, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(180, 2, 11, 36, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(181, 2, 11, 37, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(182, 2, 11, 38, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(183, 2, 11, 39, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(184, 2, 11, 40, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(185, 2, 11, 41, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(186, 2, 11, 42, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(187, 2, 11, 43, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(188, 2, 11, 44, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(189, 2, 11, 45, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(190, 2, 11, 46, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(191, 2, 11, 47, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(192, 2, 11, 48, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(193, 2, 11, 49, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(194, 2, 11, 50, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(195, 2, 11, 51, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(196, 2, 12, 28, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(197, 2, 12, 29, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(198, 2, 12, 30, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(199, 2, 12, 31, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(200, 2, 12, 32, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `student_attendance` (`id`, `institution_id`, `attendance_session_id`, `student_id`, `status`, `minutes_late`, `created_at`, `updated_at`) VALUES
(201, 2, 12, 33, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(202, 2, 12, 34, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(203, 2, 12, 35, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(204, 2, 12, 36, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(205, 2, 12, 37, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(206, 2, 12, 38, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(207, 2, 12, 39, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(208, 2, 12, 40, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(209, 2, 12, 41, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(210, 2, 12, 42, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(211, 2, 12, 43, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(212, 2, 12, 44, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(213, 2, 12, 45, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(214, 2, 12, 46, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(215, 2, 12, 47, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(216, 2, 12, 48, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(217, 2, 12, 49, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(218, 2, 12, 50, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(219, 2, 12, 51, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(220, 2, 13, 28, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(221, 2, 13, 29, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(222, 2, 13, 30, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(223, 2, 13, 31, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(224, 2, 13, 32, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(225, 2, 13, 33, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(226, 2, 13, 34, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(227, 2, 13, 35, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(228, 2, 13, 36, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(229, 2, 13, 37, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(230, 2, 13, 38, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(231, 2, 13, 39, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(232, 2, 13, 40, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(233, 2, 13, 41, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(234, 2, 13, 42, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(235, 2, 13, 43, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(236, 2, 13, 44, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(237, 2, 13, 45, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(238, 2, 13, 46, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(239, 2, 13, 47, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(240, 2, 13, 48, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(241, 2, 13, 49, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(242, 2, 13, 50, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(243, 2, 13, 51, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(244, 3, 14, 52, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(245, 3, 14, 53, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(246, 3, 14, 54, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(247, 3, 14, 55, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(248, 3, 14, 56, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(249, 3, 14, 57, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(250, 3, 14, 58, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(251, 3, 14, 59, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(252, 3, 14, 60, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(253, 3, 14, 61, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(254, 3, 14, 62, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(255, 3, 14, 63, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(256, 3, 14, 64, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(257, 3, 14, 65, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(258, 3, 14, 66, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(259, 3, 14, 67, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(260, 3, 14, 68, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(261, 3, 14, 69, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(262, 3, 14, 70, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(263, 3, 14, 71, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(264, 3, 14, 72, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(265, 3, 14, 73, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(266, 3, 14, 74, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(267, 3, 14, 75, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(268, 3, 15, 52, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(269, 3, 15, 53, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(270, 3, 15, 54, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(271, 3, 15, 55, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(272, 3, 15, 56, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(273, 3, 15, 57, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(274, 3, 15, 58, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(275, 3, 15, 59, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(276, 3, 15, 60, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(277, 3, 15, 61, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(278, 3, 15, 62, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(279, 3, 15, 63, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(280, 3, 15, 64, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(281, 3, 15, 65, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(282, 3, 15, 66, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(283, 3, 15, 67, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(284, 3, 15, 68, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(285, 3, 15, 69, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(286, 3, 15, 70, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(287, 3, 15, 71, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(288, 3, 15, 72, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(289, 3, 15, 73, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(290, 3, 15, 74, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(291, 3, 15, 75, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(292, 3, 16, 52, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(293, 3, 16, 53, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(294, 3, 16, 54, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(295, 3, 16, 55, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(296, 3, 16, 56, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(297, 3, 16, 57, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(298, 3, 16, 58, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(299, 3, 16, 59, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(300, 3, 16, 60, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `student_attendance` (`id`, `institution_id`, `attendance_session_id`, `student_id`, `status`, `minutes_late`, `created_at`, `updated_at`) VALUES
(301, 3, 16, 61, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(302, 3, 16, 62, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(303, 3, 16, 63, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(304, 3, 16, 64, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(305, 3, 16, 65, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(306, 3, 16, 66, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(307, 3, 16, 67, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(308, 3, 16, 68, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(309, 3, 16, 69, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(310, 3, 16, 70, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(311, 3, 16, 71, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(312, 3, 16, 72, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(313, 3, 16, 73, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(314, 3, 16, 74, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(315, 3, 16, 75, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(316, 3, 17, 52, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(317, 3, 17, 53, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(318, 3, 17, 54, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(319, 3, 17, 55, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(320, 3, 17, 56, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(321, 3, 17, 57, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(322, 3, 17, 58, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(323, 3, 17, 59, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(324, 3, 17, 60, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(325, 3, 17, 61, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(326, 3, 17, 62, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(327, 3, 17, 63, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(328, 3, 17, 64, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(329, 3, 17, 65, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(330, 3, 17, 66, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(331, 3, 17, 67, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(332, 3, 17, 68, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(333, 3, 17, 69, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(334, 3, 17, 70, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(335, 3, 17, 71, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(336, 3, 17, 72, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(337, 3, 17, 73, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(338, 3, 17, 74, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(339, 3, 17, 75, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(340, 3, 18, 52, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(341, 3, 18, 53, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(342, 3, 18, 54, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(343, 3, 18, 55, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(344, 3, 18, 56, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(345, 3, 18, 57, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(346, 3, 18, 58, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(347, 3, 18, 59, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(348, 3, 18, 60, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(349, 3, 18, 61, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(350, 3, 18, 62, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(351, 3, 18, 63, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(352, 3, 18, 64, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(353, 3, 18, 65, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(354, 3, 18, 66, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(355, 3, 18, 67, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(356, 3, 18, 68, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(357, 3, 18, 69, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(358, 3, 18, 70, 'absent', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(359, 3, 18, 71, 'late', 10, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(360, 3, 18, 72, 'excused', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(361, 3, 18, 73, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(362, 3, 18, 74, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(363, 3, 18, 75, 'present', 0, '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `exam_marks` (`id`, `institution_id`, `exam_paper_id`, `student_id`, `marks`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '86.00', 'approved', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '91.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '83.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 1, 4, 4, '34.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 1, 4, 5, '41.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 1, 4, 6, '48.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 1, 4, 7, '55.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 1, 4, 8, '62.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 1, 4, 9, '69.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 1, 4, 10, '76.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 1, 4, 11, '83.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 1, 4, 12, '90.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 1, 4, 13, '97.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 1, 4, 14, '30.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 1, 4, 15, '37.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 1, 4, 16, '44.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 1, 4, 17, '51.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 1, 4, 18, '58.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 1, 4, 19, '65.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 1, 4, 20, '72.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 1, 4, 21, '79.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(22, 1, 4, 22, '86.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(23, 1, 4, 23, '93.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(24, 1, 4, 24, '26.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(25, 1, 4, 25, '33.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(26, 1, 4, 26, '40.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(27, 1, 4, 27, '47.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(28, 2, 5, 28, '37.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(29, 2, 5, 29, '44.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(30, 2, 5, 30, '51.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(31, 2, 5, 31, '58.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(32, 2, 5, 32, '65.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(33, 2, 5, 33, '72.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(34, 2, 5, 34, '79.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(35, 2, 5, 35, '86.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(36, 2, 5, 36, '93.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(37, 2, 5, 37, '26.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(38, 2, 5, 38, '33.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(39, 2, 5, 39, '40.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(40, 2, 5, 40, '47.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(41, 2, 5, 41, '54.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(42, 2, 5, 42, '61.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(43, 2, 5, 43, '68.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(44, 2, 5, 44, '75.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(45, 2, 5, 45, '82.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(46, 2, 5, 46, '89.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(47, 2, 5, 47, '96.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(48, 2, 5, 48, '29.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(49, 2, 5, 49, '36.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(50, 2, 5, 50, '43.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(51, 2, 5, 51, '50.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(52, 3, 6, 52, '40.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(53, 3, 6, 53, '47.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(54, 3, 6, 54, '54.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(55, 3, 6, 55, '61.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(56, 3, 6, 56, '68.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(57, 3, 6, 57, '75.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(58, 3, 6, 58, '82.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(59, 3, 6, 59, '89.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(60, 3, 6, 60, '96.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(61, 3, 6, 61, '29.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(62, 3, 6, 62, '36.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(63, 3, 6, 63, '43.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(64, 3, 6, 64, '50.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(65, 3, 6, 65, '57.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(66, 3, 6, 66, '64.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(67, 3, 6, 67, '71.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(68, 3, 6, 68, '78.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(69, 3, 6, 69, '85.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(70, 3, 6, 70, '92.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(71, 3, 6, 71, '25.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(72, 3, 6, 72, '32.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(73, 3, 6, 73, '39.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(74, 3, 6, 74, '46.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(75, 3, 6, 75, '53.00', 'approved', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `exam_recheck_requests` (`id`, `institution_id`, `exam_mark_id`, `reason`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `hifz_groups` (`id`, `institution_id`, `name`, `employee_id`, `created_at`, `updated_at`) VALUES
(1, 3, 'Hifz Group A', 3, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `hifz_enrollments` (`id`, `institution_id`, `student_id`, `hifz_group_id`, `started_on`, `target_juz`, `status`, `created_at`, `updated_at`) VALUES
(1, 3, 3, 1, '2026-11-05', 30, 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 3, 52, 1, '2026-09-01', 30, 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(3, 3, 53, 1, '2026-09-01', 30, 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(4, 3, 54, 1, '2026-09-01', 30, 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 3, 55, 1, '2026-09-01', 30, 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 3, 56, 1, '2026-09-01', 30, 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 3, 57, 1, '2026-09-01', 30, 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 3, 58, 1, '2026-09-01', 30, 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 3, 59, 1, '2026-09-01', 30, 'active', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `hifz_progress_logs` (`id`, `institution_id`, `hifz_enrollment_id`, `logged_on`, `sabaq`, `sabqi`, `manzil`, `juz_completed`, `accuracy_percent`, `notes`, `created_at`, `updated_at`) VALUES
(1, 3, 1, '2026-11-05', 'Surah Al-Mulk 1-10', 'Surah Ar-Rahman', 'Juz Amma', 5, '92.00', 'Illustrative progress record', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 3, 2, '2026-10-16', 'Surah Al-Mulk, verses 5-9', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 2, '86.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(3, 3, 2, '2026-10-17', 'Surah Al-Mulk, verses 10-14', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 3, '87.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(4, 3, 2, '2026-10-18', 'Surah Al-Mulk, verses 15-19', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 4, '88.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 3, 3, '2026-10-16', 'Surah Al-Mulk, verses 5-9', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 3, '87.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 3, 3, '2026-10-17', 'Surah Al-Mulk, verses 10-14', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 4, '88.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 3, 3, '2026-10-18', 'Surah Al-Mulk, verses 15-19', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 5, '89.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 3, 4, '2026-10-16', 'Surah Al-Mulk, verses 5-9', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 4, '88.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 3, 4, '2026-10-17', 'Surah Al-Mulk, verses 10-14', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 5, '89.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(10, 3, 4, '2026-10-18', 'Surah Al-Mulk, verses 15-19', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 6, '90.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(11, 3, 5, '2026-10-16', 'Surah Al-Mulk, verses 5-9', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 5, '89.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(12, 3, 5, '2026-10-17', 'Surah Al-Mulk, verses 10-14', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 6, '90.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(13, 3, 5, '2026-10-18', 'Surah Al-Mulk, verses 15-19', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 7, '91.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(14, 3, 6, '2026-10-16', 'Surah Al-Mulk, verses 5-9', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 1, '90.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(15, 3, 6, '2026-10-17', 'Surah Al-Mulk, verses 10-14', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 2, '91.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(16, 3, 6, '2026-10-18', 'Surah Al-Mulk, verses 15-19', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 3, '92.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(17, 3, 7, '2026-10-16', 'Surah Al-Mulk, verses 5-9', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 2, '91.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(18, 3, 7, '2026-10-17', 'Surah Al-Mulk, verses 10-14', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 3, '92.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(19, 3, 7, '2026-10-18', 'Surah Al-Mulk, verses 15-19', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 4, '93.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(20, 3, 8, '2026-10-16', 'Surah Al-Mulk, verses 5-9', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 3, '92.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(21, 3, 8, '2026-10-17', 'Surah Al-Mulk, verses 10-14', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 4, '93.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(22, 3, 8, '2026-10-18', 'Surah Al-Mulk, verses 15-19', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 5, '84.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(23, 3, 9, '2026-10-16', 'Surah Al-Mulk, verses 5-9', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 4, '93.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(24, 3, 9, '2026-10-17', 'Surah Al-Mulk, verses 10-14', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 5, '84.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(25, 3, 9, '2026-10-18', 'Surah Al-Mulk, verses 15-19', 'Surah Ar-Rahman revision', 'Juz Amma daily revision', 6, '85.00', 'Fictional Hifz progress for testing.', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

INSERT INTO `hifz_assessments` (`id`, `institution_id`, `hifz_enrollment_id`, `assessed_on`, `score`, `remarks`, `created_at`, `updated_at`) VALUES
(1, 3, 1, '2026-11-05', '90.00', 'Good revision', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 3, 2, '2026-10-24', '81.00', 'Illustrative weekly assessment', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(3, 3, 3, '2026-10-24', '82.00', 'Illustrative weekly assessment', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(4, 3, 4, '2026-10-24', '83.00', 'Illustrative weekly assessment', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(5, 3, 5, '2026-10-24', '84.00', 'Illustrative weekly assessment', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(6, 3, 6, '2026-10-24', '85.00', 'Illustrative weekly assessment', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(7, 3, 7, '2026-10-24', '86.00', 'Illustrative weekly assessment', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(8, 3, 8, '2026-10-24', '87.00', 'Illustrative weekly assessment', '2026-11-05 09:00:00', '2026-11-05 09:00:00'),
(9, 3, 9, '2026-10-24', '88.00', 'Illustrative weekly assessment', '2026-11-05 09:00:00', '2026-11-05 09:00:00');

