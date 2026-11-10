-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.4.3 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.8.0.6908
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for scm-system
CREATE DATABASE IF NOT EXISTS `scm-system` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `scm-system`;

-- Dumping structure for table scm-system.academic_calendar_events
CREATE TABLE IF NOT EXISTS `academic_calendar_events` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `academic_session_id` bigint unsigned NOT NULL,
  `title` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_type` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `starts_at` datetime NOT NULL,
  `ends_at` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `academic_calendar_events_institution_id_id_unique` (`institution_id`,`id`),
  KEY `academic_calendar_events_academic_session_id_fk` (`institution_id`,`academic_session_id`),
  CONSTRAINT `academic_calendar_events_academic_session_id_fk` FOREIGN KEY (`institution_id`, `academic_session_id`) REFERENCES `academic_sessions` (`institution_id`, `id`),
  CONSTRAINT `academic_calendar_events_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.academic_calendar_events: ~0 rows (approximately)

-- Dumping structure for table scm-system.academic_departments
CREATE TABLE IF NOT EXISTS `academic_departments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `campus_id` bigint unsigned NOT NULL,
  `code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `academic_departments_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_academic_departments_uniq` (`institution_id`,`code`),
  KEY `academic_departments_campus_id_fk` (`institution_id`,`campus_id`),
  CONSTRAINT `academic_departments_campus_id_fk` FOREIGN KEY (`institution_id`, `campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  CONSTRAINT `academic_departments_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.academic_departments: ~0 rows (approximately)

-- Dumping structure for table scm-system.academic_programs
CREATE TABLE IF NOT EXISTS `academic_programs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `department_id` bigint unsigned NOT NULL,
  `code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(140) COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `required_credits` decimal(8,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `academic_programs_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_academic_programs_uniq` (`institution_id`,`code`),
  KEY `academic_programs_department_id_fk` (`institution_id`,`department_id`),
  CONSTRAINT `academic_programs_department_id_fk` FOREIGN KEY (`institution_id`, `department_id`) REFERENCES `academic_departments` (`institution_id`, `id`),
  CONSTRAINT `academic_programs_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.academic_programs: ~0 rows (approximately)

-- Dumping structure for table scm-system.academic_sessions
CREATE TABLE IF NOT EXISTS `academic_sessions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `starts_on` date NOT NULL,
  `ends_on` date NOT NULL,
  `status` enum('planned','active','closed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'planned',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `academic_sessions_institution_id_code_unique` (`institution_id`,`code`),
  UNIQUE KEY `academic_sessions_institution_id_id_unique` (`institution_id`,`id`),
  CONSTRAINT `academic_sessions_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.academic_sessions: ~0 rows (approximately)

-- Dumping structure for table scm-system.academic_terms
CREATE TABLE IF NOT EXISTS `academic_terms` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `academic_session_id` bigint unsigned NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `starts_on` date NOT NULL,
  `ends_on` date NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `academic_terms_institution_id_id_unique` (`institution_id`,`id`),
  KEY `academic_terms_academic_session_id_fk` (`institution_id`,`academic_session_id`),
  CONSTRAINT `academic_terms_academic_session_id_fk` FOREIGN KEY (`institution_id`, `academic_session_id`) REFERENCES `academic_sessions` (`institution_id`, `id`),
  CONSTRAINT `academic_terms_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.academic_terms: ~0 rows (approximately)

-- Dumping structure for table scm-system.admission_applications
CREATE TABLE IF NOT EXISTS `admission_applications` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `admission_cycle_id` bigint unsigned NOT NULL,
  `class_level_id` bigint unsigned NOT NULL,
  `application_no` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `applicant_name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `guardian_phone` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `score` decimal(7,2) DEFAULT NULL,
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'submitted',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admission_applications_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_admission_applications_uniq` (`institution_id`,`application_no`),
  KEY `admission_applications_admission_cycle_id_fk` (`institution_id`,`admission_cycle_id`),
  KEY `admission_applications_class_level_id_fk` (`institution_id`,`class_level_id`),
  CONSTRAINT `admission_applications_admission_cycle_id_fk` FOREIGN KEY (`institution_id`, `admission_cycle_id`) REFERENCES `admission_cycles` (`institution_id`, `id`),
  CONSTRAINT `admission_applications_class_level_id_fk` FOREIGN KEY (`institution_id`, `class_level_id`) REFERENCES `class_levels` (`institution_id`, `id`),
  CONSTRAINT `admission_applications_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.admission_applications: ~0 rows (approximately)

-- Dumping structure for table scm-system.admission_cycles
CREATE TABLE IF NOT EXISTS `admission_cycles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `academic_session_id` bigint unsigned NOT NULL,
  `campus_id` bigint unsigned NOT NULL,
  `title` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `opens_on` date NOT NULL,
  `closes_on` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admission_cycles_institution_id_id_unique` (`institution_id`,`id`),
  KEY `admission_cycles_academic_session_id_fk` (`institution_id`,`academic_session_id`),
  KEY `admission_cycles_campus_id_fk` (`institution_id`,`campus_id`),
  CONSTRAINT `admission_cycles_academic_session_id_fk` FOREIGN KEY (`institution_id`, `academic_session_id`) REFERENCES `academic_sessions` (`institution_id`, `id`),
  CONSTRAINT `admission_cycles_campus_id_fk` FOREIGN KEY (`institution_id`, `campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  CONSTRAINT `admission_cycles_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.admission_cycles: ~0 rows (approximately)

-- Dumping structure for table scm-system.admission_offers
CREATE TABLE IF NOT EXISTS `admission_offers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `admission_application_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned DEFAULT NULL,
  `offered_on` date NOT NULL,
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'offered',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admission_offers_institution_id_id_unique` (`institution_id`,`id`),
  KEY `admission_offers_admission_application_id_fk` (`institution_id`,`admission_application_id`),
  KEY `admission_offers_student_id_fk` (`institution_id`,`student_id`),
  CONSTRAINT `admission_offers_admission_application_id_fk` FOREIGN KEY (`institution_id`, `admission_application_id`) REFERENCES `admission_applications` (`institution_id`, `id`),
  CONSTRAINT `admission_offers_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `admission_offers_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.admission_offers: ~0 rows (approximately)

-- Dumping structure for table scm-system.alumni_profiles
CREATE TABLE IF NOT EXISTS `alumni_profiles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `graduation_year` int unsigned NOT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `alumni_profiles_institution_id_id_unique` (`institution_id`,`id`),
  KEY `alumni_profiles_student_id_fk` (`institution_id`,`student_id`),
  CONSTRAINT `alumni_profiles_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `alumni_profiles_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.alumni_profiles: ~0 rows (approximately)

-- Dumping structure for table scm-system.asset_assignments
CREATE TABLE IF NOT EXISTS `asset_assignments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `fixed_asset_id` bigint unsigned NOT NULL,
  `employee_id` bigint unsigned NOT NULL,
  `assigned_on` date NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `asset_assignments_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_asset_assignments_combo_uniq` (`institution_id`,`fixed_asset_id`,`employee_id`,`assigned_on`),
  KEY `asset_assignments_employee_id_fk` (`institution_id`,`employee_id`),
  CONSTRAINT `asset_assignments_employee_id_fk` FOREIGN KEY (`institution_id`, `employee_id`) REFERENCES `employees` (`institution_id`, `id`),
  CONSTRAINT `asset_assignments_fixed_asset_id_fk` FOREIGN KEY (`institution_id`, `fixed_asset_id`) REFERENCES `fixed_assets` (`institution_id`, `id`),
  CONSTRAINT `asset_assignments_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.asset_assignments: ~0 rows (approximately)

-- Dumping structure for table scm-system.assignments
CREATE TABLE IF NOT EXISTS `assignments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `class_subject_id` bigint unsigned NOT NULL,
  `title` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `details` text COLLATE utf8mb4_unicode_ci,
  `due_at` datetime NOT NULL,
  `max_marks` decimal(7,2) NOT NULL DEFAULT '100.00',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `assignments_institution_id_id_unique` (`institution_id`,`id`),
  KEY `assignments_class_subject_id_fk` (`institution_id`,`class_subject_id`),
  CONSTRAINT `assignments_class_subject_id_fk` FOREIGN KEY (`institution_id`, `class_subject_id`) REFERENCES `class_subjects` (`institution_id`, `id`),
  CONSTRAINT `assignments_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.assignments: ~0 rows (approximately)

-- Dumping structure for table scm-system.assignment_submissions
CREATE TABLE IF NOT EXISTS `assignment_submissions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `assignment_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `submitted_at` datetime NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'submitted',
  `marks` decimal(7,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `assignment_submissions_institution_id_id_unique` (`institution_id`,`id`),
  KEY `assignment_submissions_assignment_id_fk` (`institution_id`,`assignment_id`),
  KEY `assignment_submissions_student_id_fk` (`institution_id`,`student_id`),
  CONSTRAINT `assignment_submissions_assignment_id_fk` FOREIGN KEY (`institution_id`, `assignment_id`) REFERENCES `assignments` (`institution_id`, `id`),
  CONSTRAINT `assignment_submissions_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `assignment_submissions_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.assignment_submissions: ~0 rows (approximately)

-- Dumping structure for table scm-system.attendance_sessions
CREATE TABLE IF NOT EXISTS `attendance_sessions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `class_section_id` bigint unsigned NOT NULL,
  `attendance_on` date NOT NULL,
  `period_code` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'daily',
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `attendance_sessions_institution_id_id_unique` (`institution_id`,`id`),
  KEY `attendance_sessions_class_section_id_fk` (`institution_id`,`class_section_id`),
  CONSTRAINT `attendance_sessions_class_section_id_fk` FOREIGN KEY (`institution_id`, `class_section_id`) REFERENCES `class_sections` (`institution_id`, `id`),
  CONSTRAINT `attendance_sessions_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.attendance_sessions: ~0 rows (approximately)

-- Dumping structure for table scm-system.bank_accounts
CREATE TABLE IF NOT EXISTS `bank_accounts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `account_id` bigint unsigned NOT NULL,
  `bank_name` varchar(140) COLLATE utf8mb4_unicode_ci NOT NULL,
  `account_mask` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `bank_accounts_institution_id_id_unique` (`institution_id`,`id`),
  KEY `bank_accounts_account_id_fk` (`institution_id`,`account_id`),
  CONSTRAINT `bank_accounts_account_id_fk` FOREIGN KEY (`institution_id`, `account_id`) REFERENCES `chart_of_accounts` (`institution_id`, `id`),
  CONSTRAINT `bank_accounts_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.bank_accounts: ~0 rows (approximately)

-- Dumping structure for table scm-system.bank_reconciliations
CREATE TABLE IF NOT EXISTS `bank_reconciliations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `bank_account_id` bigint unsigned NOT NULL,
  `statement_on` date NOT NULL,
  `statement_balance` decimal(14,2) NOT NULL,
  `ledger_balance` decimal(14,2) NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `bank_reconciliations_institution_id_id_unique` (`institution_id`,`id`),
  KEY `bank_reconciliations_bank_account_id_fk` (`institution_id`,`bank_account_id`),
  CONSTRAINT `bank_reconciliations_bank_account_id_fk` FOREIGN KEY (`institution_id`, `bank_account_id`) REFERENCES `bank_accounts` (`institution_id`, `id`),
  CONSTRAINT `bank_reconciliations_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.bank_reconciliations: ~0 rows (approximately)

-- Dumping structure for table scm-system.cache
CREATE TABLE IF NOT EXISTS `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.cache: ~0 rows (approximately)

-- Dumping structure for table scm-system.cache_locks
CREATE TABLE IF NOT EXISTS `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.cache_locks: ~0 rows (approximately)

-- Dumping structure for table scm-system.campuses
CREATE TABLE IF NOT EXISTS `campuses` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_main` tinyint(1) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `address` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `campuses_institution_id_code_unique` (`institution_id`,`code`),
  UNIQUE KEY `campuses_institution_id_id_unique` (`institution_id`,`id`),
  CONSTRAINT `campuses_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.campuses: ~0 rows (approximately)

-- Dumping structure for table scm-system.campus_events
CREATE TABLE IF NOT EXISTS `campus_events` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `campus_id` bigint unsigned NOT NULL,
  `title` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `starts_at` datetime NOT NULL,
  `ends_at` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `campus_events_institution_id_id_unique` (`institution_id`,`id`),
  KEY `campus_events_campus_id_fk` (`institution_id`,`campus_id`),
  CONSTRAINT `campus_events_campus_id_fk` FOREIGN KEY (`institution_id`, `campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  CONSTRAINT `campus_events_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.campus_events: ~0 rows (approximately)

-- Dumping structure for table scm-system.certificate_templates
CREATE TABLE IF NOT EXISTS `certificate_templates` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_html` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `certificate_templates_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_certificate_templates_uniq` (`institution_id`,`code`),
  CONSTRAINT `certificate_templates_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.certificate_templates: ~0 rows (approximately)

-- Dumping structure for table scm-system.chart_of_accounts
CREATE TABLE IF NOT EXISTS `chart_of_accounts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(140) COLLATE utf8mb4_unicode_ci NOT NULL,
  `account_type` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_account_id` bigint unsigned DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chart_of_accounts_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_chart_of_accounts_uniq` (`institution_id`,`code`),
  KEY `chart_of_accounts_parent_account_id_fk` (`institution_id`,`parent_account_id`),
  CONSTRAINT `chart_of_accounts_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `chart_of_accounts_parent_account_id_fk` FOREIGN KEY (`institution_id`, `parent_account_id`) REFERENCES `chart_of_accounts` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.chart_of_accounts: ~0 rows (approximately)

-- Dumping structure for table scm-system.class_levels
CREATE TABLE IF NOT EXISTS `class_levels` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `program_id` bigint unsigned DEFAULT NULL,
  `code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sequence` int unsigned NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `class_levels_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_class_levels_uniq` (`institution_id`,`code`),
  KEY `class_levels_program_id_fk` (`institution_id`,`program_id`),
  CONSTRAINT `class_levels_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `class_levels_program_id_fk` FOREIGN KEY (`institution_id`, `program_id`) REFERENCES `academic_programs` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.class_levels: ~0 rows (approximately)

-- Dumping structure for table scm-system.class_routines
CREATE TABLE IF NOT EXISTS `class_routines` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `class_section_id` bigint unsigned NOT NULL,
  `class_subject_id` bigint unsigned NOT NULL,
  `day_of_week` varchar(12) COLLATE utf8mb4_unicode_ci NOT NULL,
  `starts_at` time NOT NULL,
  `ends_at` time NOT NULL,
  `room` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `class_routines_institution_id_id_unique` (`institution_id`,`id`),
  KEY `class_routines_class_section_id_fk` (`institution_id`,`class_section_id`),
  KEY `class_routines_class_subject_id_fk` (`institution_id`,`class_subject_id`),
  CONSTRAINT `class_routines_class_section_id_fk` FOREIGN KEY (`institution_id`, `class_section_id`) REFERENCES `class_sections` (`institution_id`, `id`),
  CONSTRAINT `class_routines_class_subject_id_fk` FOREIGN KEY (`institution_id`, `class_subject_id`) REFERENCES `class_subjects` (`institution_id`, `id`),
  CONSTRAINT `class_routines_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.class_routines: ~0 rows (approximately)

-- Dumping structure for table scm-system.class_sections
CREATE TABLE IF NOT EXISTS `class_sections` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `campus_id` bigint unsigned NOT NULL,
  `class_level_id` bigint unsigned NOT NULL,
  `code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `shift` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'day',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `class_sections_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_class_sections_uniq` (`institution_id`,`class_level_id`,`code`),
  KEY `class_sections_campus_id_fk` (`institution_id`,`campus_id`),
  CONSTRAINT `class_sections_campus_id_fk` FOREIGN KEY (`institution_id`, `campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  CONSTRAINT `class_sections_class_level_id_fk` FOREIGN KEY (`institution_id`, `class_level_id`) REFERENCES `class_levels` (`institution_id`, `id`),
  CONSTRAINT `class_sections_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.class_sections: ~0 rows (approximately)

-- Dumping structure for table scm-system.class_subjects
CREATE TABLE IF NOT EXISTS `class_subjects` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `class_level_id` bigint unsigned NOT NULL,
  `subject_id` bigint unsigned NOT NULL,
  `academic_session_id` bigint unsigned NOT NULL,
  `is_compulsory` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `class_subjects_institution_id_id_unique` (`institution_id`,`id`),
  KEY `class_subjects_class_level_id_fk` (`institution_id`,`class_level_id`),
  KEY `class_subjects_subject_id_fk` (`institution_id`,`subject_id`),
  KEY `class_subjects_academic_session_id_fk` (`institution_id`,`academic_session_id`),
  CONSTRAINT `class_subjects_academic_session_id_fk` FOREIGN KEY (`institution_id`, `academic_session_id`) REFERENCES `academic_sessions` (`institution_id`, `id`),
  CONSTRAINT `class_subjects_class_level_id_fk` FOREIGN KEY (`institution_id`, `class_level_id`) REFERENCES `class_levels` (`institution_id`, `id`),
  CONSTRAINT `class_subjects_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `class_subjects_subject_id_fk` FOREIGN KEY (`institution_id`, `subject_id`) REFERENCES `subjects` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.class_subjects: ~0 rows (approximately)

-- Dumping structure for table scm-system.course_offerings
CREATE TABLE IF NOT EXISTS `course_offerings` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `academic_term_id` bigint unsigned NOT NULL,
  `class_section_id` bigint unsigned NOT NULL,
  `subject_id` bigint unsigned NOT NULL,
  `capacity` int unsigned NOT NULL DEFAULT '30',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `course_offerings_institution_id_id_unique` (`institution_id`,`id`),
  KEY `course_offerings_academic_term_id_fk` (`institution_id`,`academic_term_id`),
  KEY `course_offerings_class_section_id_fk` (`institution_id`,`class_section_id`),
  KEY `course_offerings_subject_id_fk` (`institution_id`,`subject_id`),
  CONSTRAINT `course_offerings_academic_term_id_fk` FOREIGN KEY (`institution_id`, `academic_term_id`) REFERENCES `academic_terms` (`institution_id`, `id`),
  CONSTRAINT `course_offerings_class_section_id_fk` FOREIGN KEY (`institution_id`, `class_section_id`) REFERENCES `class_sections` (`institution_id`, `id`),
  CONSTRAINT `course_offerings_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `course_offerings_subject_id_fk` FOREIGN KEY (`institution_id`, `subject_id`) REFERENCES `subjects` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.course_offerings: ~0 rows (approximately)

-- Dumping structure for table scm-system.direct_messages
CREATE TABLE IF NOT EXISTS `direct_messages` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `sender_user_id` bigint unsigned NOT NULL,
  `recipient_user_id` bigint unsigned NOT NULL,
  `body` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `read_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `direct_messages_institution_id_id_unique` (`institution_id`,`id`),
  KEY `direct_messages_sender_user_id_fk` (`sender_user_id`),
  KEY `direct_messages_recipient_user_id_fk` (`recipient_user_id`),
  CONSTRAINT `direct_messages_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `direct_messages_recipient_user_id_fk` FOREIGN KEY (`recipient_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `direct_messages_sender_user_id_fk` FOREIGN KEY (`sender_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.direct_messages: ~0 rows (approximately)

-- Dumping structure for table scm-system.donations
CREATE TABLE IF NOT EXISTS `donations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `donor_id` bigint unsigned NOT NULL,
  `donation_fund_id` bigint unsigned NOT NULL,
  `receipt_no` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `received_on` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `donations_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_donations_uniq` (`institution_id`,`receipt_no`),
  KEY `donations_donor_id_fk` (`institution_id`,`donor_id`),
  KEY `sms_donations_idx` (`institution_id`,`donation_fund_id`,`received_on`),
  CONSTRAINT `donations_donation_fund_id_fk` FOREIGN KEY (`institution_id`, `donation_fund_id`) REFERENCES `donation_funds` (`institution_id`, `id`),
  CONSTRAINT `donations_donor_id_fk` FOREIGN KEY (`institution_id`, `donor_id`) REFERENCES `donors` (`institution_id`, `id`),
  CONSTRAINT `donations_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.donations: ~0 rows (approximately)

-- Dumping structure for table scm-system.donation_funds
CREATE TABLE IF NOT EXISTS `donation_funds` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `code` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_restricted` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `donation_funds_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_donation_funds_uniq` (`institution_id`,`code`),
  CONSTRAINT `donation_funds_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.donation_funds: ~0 rows (approximately)

-- Dumping structure for table scm-system.donors
CREATE TABLE IF NOT EXISTS `donors` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `name` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(160) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `donors_institution_id_id_unique` (`institution_id`,`id`),
  CONSTRAINT `donors_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.donors: ~0 rows (approximately)

-- Dumping structure for table scm-system.employees
CREATE TABLE IF NOT EXISTS `employees` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `campus_id` bigint unsigned NOT NULL,
  `employee_no` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `designation` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `joined_on` date NOT NULL,
  `basic_salary` decimal(14,2) NOT NULL DEFAULT '0.00',
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `employees_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_employees_uniq` (`institution_id`,`employee_no`),
  KEY `employees_user_id_fk` (`user_id`),
  KEY `employees_campus_id_fk` (`institution_id`,`campus_id`),
  CONSTRAINT `employees_campus_id_fk` FOREIGN KEY (`institution_id`, `campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  CONSTRAINT `employees_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `employees_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.employees: ~0 rows (approximately)

-- Dumping structure for table scm-system.enrollments
CREATE TABLE IF NOT EXISTS `enrollments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `academic_session_id` bigint unsigned NOT NULL,
  `class_section_id` bigint unsigned NOT NULL,
  `roll_no` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `enrollments_institution_id_id_unique` (`institution_id`,`id`),
  KEY `enrollments_student_id_fk` (`institution_id`,`student_id`),
  KEY `enrollments_class_section_id_fk` (`institution_id`,`class_section_id`),
  KEY `sms_enrollments_idx` (`institution_id`,`academic_session_id`,`class_section_id`),
  CONSTRAINT `enrollments_academic_session_id_fk` FOREIGN KEY (`institution_id`, `academic_session_id`) REFERENCES `academic_sessions` (`institution_id`, `id`),
  CONSTRAINT `enrollments_class_section_id_fk` FOREIGN KEY (`institution_id`, `class_section_id`) REFERENCES `class_sections` (`institution_id`, `id`),
  CONSTRAINT `enrollments_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `enrollments_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.enrollments: ~0 rows (approximately)

-- Dumping structure for table scm-system.examinations
CREATE TABLE IF NOT EXISTS `examinations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `academic_session_id` bigint unsigned NOT NULL,
  `class_level_id` bigint unsigned NOT NULL,
  `name` varchar(140) COLLATE utf8mb4_unicode_ci NOT NULL,
  `exam_type` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `starts_on` date NOT NULL,
  `ends_on` date NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `examinations_institution_id_id_unique` (`institution_id`,`id`),
  KEY `examinations_academic_session_id_fk` (`institution_id`,`academic_session_id`),
  KEY `examinations_class_level_id_fk` (`institution_id`,`class_level_id`),
  CONSTRAINT `examinations_academic_session_id_fk` FOREIGN KEY (`institution_id`, `academic_session_id`) REFERENCES `academic_sessions` (`institution_id`, `id`),
  CONSTRAINT `examinations_class_level_id_fk` FOREIGN KEY (`institution_id`, `class_level_id`) REFERENCES `class_levels` (`institution_id`, `id`),
  CONSTRAINT `examinations_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.examinations: ~0 rows (approximately)

-- Dumping structure for table scm-system.exam_marks
CREATE TABLE IF NOT EXISTS `exam_marks` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `exam_paper_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `marks` decimal(7,2) NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `exam_marks_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_exam_marks_combo_uniq` (`institution_id`,`exam_paper_id`,`student_id`),
  KEY `sms_exam_marks_idx` (`institution_id`,`student_id`,`status`),
  CONSTRAINT `exam_marks_exam_paper_id_fk` FOREIGN KEY (`institution_id`, `exam_paper_id`) REFERENCES `exam_papers` (`institution_id`, `id`),
  CONSTRAINT `exam_marks_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `exam_marks_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.exam_marks: ~0 rows (approximately)

-- Dumping structure for table scm-system.exam_papers
CREATE TABLE IF NOT EXISTS `exam_papers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `examination_id` bigint unsigned NOT NULL,
  `subject_id` bigint unsigned NOT NULL,
  `full_marks` decimal(7,2) NOT NULL,
  `pass_marks` decimal(7,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `exam_papers_institution_id_id_unique` (`institution_id`,`id`),
  KEY `exam_papers_examination_id_fk` (`institution_id`,`examination_id`),
  KEY `exam_papers_subject_id_fk` (`institution_id`,`subject_id`),
  CONSTRAINT `exam_papers_examination_id_fk` FOREIGN KEY (`institution_id`, `examination_id`) REFERENCES `examinations` (`institution_id`, `id`),
  CONSTRAINT `exam_papers_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `exam_papers_subject_id_fk` FOREIGN KEY (`institution_id`, `subject_id`) REFERENCES `subjects` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.exam_papers: ~0 rows (approximately)

-- Dumping structure for table scm-system.exam_recheck_requests
CREATE TABLE IF NOT EXISTS `exam_recheck_requests` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `exam_mark_id` bigint unsigned NOT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `exam_recheck_requests_institution_id_id_unique` (`institution_id`,`id`),
  KEY `exam_recheck_requests_exam_mark_id_fk` (`institution_id`,`exam_mark_id`),
  CONSTRAINT `exam_recheck_requests_exam_mark_id_fk` FOREIGN KEY (`institution_id`, `exam_mark_id`) REFERENCES `exam_marks` (`institution_id`, `id`),
  CONSTRAINT `exam_recheck_requests_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.exam_recheck_requests: ~0 rows (approximately)

-- Dumping structure for table scm-system.expenses
CREATE TABLE IF NOT EXISTS `expenses` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `expense_no` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expense_on` date NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `account_id` bigint unsigned NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `expenses_institution_id_id_unique` (`institution_id`,`id`),
  KEY `expenses_account_id_fk` (`institution_id`,`account_id`),
  CONSTRAINT `expenses_account_id_fk` FOREIGN KEY (`institution_id`, `account_id`) REFERENCES `chart_of_accounts` (`institution_id`, `id`),
  CONSTRAINT `expenses_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.expenses: ~0 rows (approximately)

-- Dumping structure for table scm-system.failed_jobs
CREATE TABLE IF NOT EXISTS `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.failed_jobs: ~0 rows (approximately)

-- Dumping structure for table scm-system.fee_heads
CREATE TABLE IF NOT EXISTS `fee_heads` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `revenue_account_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `fee_heads_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_fee_heads_uniq` (`institution_id`,`code`),
  KEY `fee_heads_revenue_account_id_fk` (`institution_id`,`revenue_account_id`),
  CONSTRAINT `fee_heads_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `fee_heads_revenue_account_id_fk` FOREIGN KEY (`institution_id`, `revenue_account_id`) REFERENCES `chart_of_accounts` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.fee_heads: ~0 rows (approximately)

-- Dumping structure for table scm-system.fee_plans
CREATE TABLE IF NOT EXISTS `fee_plans` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `class_level_id` bigint unsigned NOT NULL,
  `academic_session_id` bigint unsigned NOT NULL,
  `name` varchar(140) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `fee_plans_institution_id_id_unique` (`institution_id`,`id`),
  KEY `fee_plans_class_level_id_fk` (`institution_id`,`class_level_id`),
  KEY `fee_plans_academic_session_id_fk` (`institution_id`,`academic_session_id`),
  CONSTRAINT `fee_plans_academic_session_id_fk` FOREIGN KEY (`institution_id`, `academic_session_id`) REFERENCES `academic_sessions` (`institution_id`, `id`),
  CONSTRAINT `fee_plans_class_level_id_fk` FOREIGN KEY (`institution_id`, `class_level_id`) REFERENCES `class_levels` (`institution_id`, `id`),
  CONSTRAINT `fee_plans_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.fee_plans: ~0 rows (approximately)

-- Dumping structure for table scm-system.fee_plan_lines
CREATE TABLE IF NOT EXISTS `fee_plan_lines` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `fee_plan_id` bigint unsigned NOT NULL,
  `fee_head_id` bigint unsigned NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `fee_plan_lines_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_fee_plan_lines_combo_uniq` (`institution_id`,`fee_plan_id`,`fee_head_id`),
  KEY `fee_plan_lines_fee_head_id_fk` (`institution_id`,`fee_head_id`),
  CONSTRAINT `fee_plan_lines_fee_head_id_fk` FOREIGN KEY (`institution_id`, `fee_head_id`) REFERENCES `fee_heads` (`institution_id`, `id`),
  CONSTRAINT `fee_plan_lines_fee_plan_id_fk` FOREIGN KEY (`institution_id`, `fee_plan_id`) REFERENCES `fee_plans` (`institution_id`, `id`),
  CONSTRAINT `fee_plan_lines_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.fee_plan_lines: ~0 rows (approximately)

-- Dumping structure for table scm-system.financial_period_closings
CREATE TABLE IF NOT EXISTS `financial_period_closings` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `academic_session_id` bigint unsigned NOT NULL,
  `closed_on` date NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `financial_period_closings_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_financial_period_closings_uniq` (`institution_id`,`academic_session_id`),
  CONSTRAINT `financial_period_closings_academic_session_id_fk` FOREIGN KEY (`institution_id`, `academic_session_id`) REFERENCES `academic_sessions` (`institution_id`, `id`),
  CONSTRAINT `financial_period_closings_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.financial_period_closings: ~0 rows (approximately)

-- Dumping structure for table scm-system.fixed_assets
CREATE TABLE IF NOT EXISTS `fixed_assets` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `asset_tag` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `purchased_on` date NOT NULL,
  `purchase_cost` decimal(14,2) NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `fixed_assets_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_fixed_assets_uniq` (`institution_id`,`asset_tag`),
  CONSTRAINT `fixed_assets_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.fixed_assets: ~0 rows (approximately)

-- Dumping structure for table scm-system.fund_expenses
CREATE TABLE IF NOT EXISTS `fund_expenses` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `donation_fund_id` bigint unsigned NOT NULL,
  `approved_by_user_id` bigint unsigned DEFAULT NULL,
  `description` varchar(190) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `spent_on` date NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'approved',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `fund_expenses_institution_id_id_unique` (`institution_id`,`id`),
  KEY `fund_expenses_donation_fund_id_fk` (`institution_id`,`donation_fund_id`),
  KEY `fund_expenses_approved_by_user_id_fk` (`approved_by_user_id`),
  CONSTRAINT `fund_expenses_approved_by_user_id_fk` FOREIGN KEY (`approved_by_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fund_expenses_donation_fund_id_fk` FOREIGN KEY (`institution_id`, `donation_fund_id`) REFERENCES `donation_funds` (`institution_id`, `id`),
  CONSTRAINT `fund_expenses_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.fund_expenses: ~0 rows (approximately)

-- Dumping structure for table scm-system.grading_bands
CREATE TABLE IF NOT EXISTS `grading_bands` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `grading_scale_id` bigint unsigned NOT NULL,
  `min_percent` decimal(5,2) NOT NULL,
  `max_percent` decimal(5,2) NOT NULL,
  `letter_grade` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL,
  `grade_point` decimal(4,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `grading_bands_institution_id_id_unique` (`institution_id`,`id`),
  KEY `grading_bands_grading_scale_id_fk` (`institution_id`,`grading_scale_id`),
  CONSTRAINT `grading_bands_grading_scale_id_fk` FOREIGN KEY (`institution_id`, `grading_scale_id`) REFERENCES `grading_scales` (`institution_id`, `id`),
  CONSTRAINT `grading_bands_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.grading_bands: ~0 rows (approximately)

-- Dumping structure for table scm-system.grading_scales
CREATE TABLE IF NOT EXISTS `grading_scales` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `grading_scales_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_grading_scales_uniq` (`institution_id`,`code`),
  CONSTRAINT `grading_scales_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.grading_scales: ~0 rows (approximately)

-- Dumping structure for table scm-system.guardians
CREATE TABLE IF NOT EXISTS `guardians` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `relation` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(180) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `guardians_institution_id_id_unique` (`institution_id`,`id`),
  KEY `guardians_user_id_fk` (`user_id`),
  CONSTRAINT `guardians_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `guardians_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.guardians: ~0 rows (approximately)

-- Dumping structure for table scm-system.hifz_assessments
CREATE TABLE IF NOT EXISTS `hifz_assessments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `hifz_enrollment_id` bigint unsigned NOT NULL,
  `assessed_on` date NOT NULL,
  `score` decimal(5,2) NOT NULL,
  `remarks` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hifz_assessments_institution_id_id_unique` (`institution_id`,`id`),
  KEY `hifz_assessments_hifz_enrollment_id_fk` (`institution_id`,`hifz_enrollment_id`),
  CONSTRAINT `hifz_assessments_hifz_enrollment_id_fk` FOREIGN KEY (`institution_id`, `hifz_enrollment_id`) REFERENCES `hifz_enrollments` (`institution_id`, `id`),
  CONSTRAINT `hifz_assessments_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.hifz_assessments: ~0 rows (approximately)

-- Dumping structure for table scm-system.hifz_enrollments
CREATE TABLE IF NOT EXISTS `hifz_enrollments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `hifz_group_id` bigint unsigned NOT NULL,
  `started_on` date NOT NULL,
  `target_juz` int unsigned NOT NULL DEFAULT '30',
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hifz_enrollments_institution_id_id_unique` (`institution_id`,`id`),
  KEY `hifz_enrollments_student_id_fk` (`institution_id`,`student_id`),
  KEY `hifz_enrollments_hifz_group_id_fk` (`institution_id`,`hifz_group_id`),
  CONSTRAINT `hifz_enrollments_hifz_group_id_fk` FOREIGN KEY (`institution_id`, `hifz_group_id`) REFERENCES `hifz_groups` (`institution_id`, `id`),
  CONSTRAINT `hifz_enrollments_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `hifz_enrollments_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.hifz_enrollments: ~0 rows (approximately)

-- Dumping structure for table scm-system.hifz_groups
CREATE TABLE IF NOT EXISTS `hifz_groups` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `employee_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hifz_groups_institution_id_id_unique` (`institution_id`,`id`),
  KEY `hifz_groups_employee_id_fk` (`institution_id`,`employee_id`),
  CONSTRAINT `hifz_groups_employee_id_fk` FOREIGN KEY (`institution_id`, `employee_id`) REFERENCES `employees` (`institution_id`, `id`),
  CONSTRAINT `hifz_groups_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.hifz_groups: ~0 rows (approximately)

-- Dumping structure for table scm-system.hifz_progress_logs
CREATE TABLE IF NOT EXISTS `hifz_progress_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `hifz_enrollment_id` bigint unsigned NOT NULL,
  `logged_on` date NOT NULL,
  `sabaq` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sabqi` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `manzil` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `juz_completed` int unsigned NOT NULL DEFAULT '0',
  `accuracy_percent` decimal(5,2) NOT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hifz_progress_logs_institution_id_id_unique` (`institution_id`,`id`),
  KEY `sms_hifz_progress_logs_idx` (`institution_id`,`hifz_enrollment_id`,`logged_on`),
  CONSTRAINT `hifz_progress_logs_hifz_enrollment_id_fk` FOREIGN KEY (`institution_id`, `hifz_enrollment_id`) REFERENCES `hifz_enrollments` (`institution_id`, `id`),
  CONSTRAINT `hifz_progress_logs_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.hifz_progress_logs: ~0 rows (approximately)

-- Dumping structure for table scm-system.hostels
CREATE TABLE IF NOT EXISTS `hostels` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `campus_id` bigint unsigned NOT NULL,
  `name` varchar(140) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hostels_institution_id_id_unique` (`institution_id`,`id`),
  KEY `hostels_campus_id_fk` (`institution_id`,`campus_id`),
  CONSTRAINT `hostels_campus_id_fk` FOREIGN KEY (`institution_id`, `campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  CONSTRAINT `hostels_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.hostels: ~0 rows (approximately)

-- Dumping structure for table scm-system.hostel_allocations
CREATE TABLE IF NOT EXISTS `hostel_allocations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `hostel_bed_id` bigint unsigned NOT NULL,
  `check_in_on` date NOT NULL,
  `monthly_fee` decimal(14,2) NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hostel_allocations_institution_id_id_unique` (`institution_id`,`id`),
  KEY `hostel_allocations_student_id_fk` (`institution_id`,`student_id`),
  KEY `hostel_allocations_hostel_bed_id_fk` (`institution_id`,`hostel_bed_id`),
  CONSTRAINT `hostel_allocations_hostel_bed_id_fk` FOREIGN KEY (`institution_id`, `hostel_bed_id`) REFERENCES `hostel_beds` (`institution_id`, `id`),
  CONSTRAINT `hostel_allocations_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `hostel_allocations_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.hostel_allocations: ~0 rows (approximately)

-- Dumping structure for table scm-system.hostel_beds
CREATE TABLE IF NOT EXISTS `hostel_beds` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `hostel_room_id` bigint unsigned NOT NULL,
  `bed_code` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'available',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hostel_beds_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_hostel_beds_uniq` (`institution_id`,`hostel_room_id`,`bed_code`),
  CONSTRAINT `hostel_beds_hostel_room_id_fk` FOREIGN KEY (`institution_id`, `hostel_room_id`) REFERENCES `hostel_rooms` (`institution_id`, `id`),
  CONSTRAINT `hostel_beds_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.hostel_beds: ~0 rows (approximately)

-- Dumping structure for table scm-system.hostel_leave_requests
CREATE TABLE IF NOT EXISTS `hostel_leave_requests` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `hostel_allocation_id` bigint unsigned NOT NULL,
  `starts_on` date NOT NULL,
  `ends_on` date NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hostel_leave_requests_institution_id_id_unique` (`institution_id`,`id`),
  KEY `hostel_leave_requests_hostel_allocation_id_fk` (`institution_id`,`hostel_allocation_id`),
  CONSTRAINT `hostel_leave_requests_hostel_allocation_id_fk` FOREIGN KEY (`institution_id`, `hostel_allocation_id`) REFERENCES `hostel_allocations` (`institution_id`, `id`),
  CONSTRAINT `hostel_leave_requests_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.hostel_leave_requests: ~0 rows (approximately)

-- Dumping structure for table scm-system.hostel_rooms
CREATE TABLE IF NOT EXISTS `hostel_rooms` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `hostel_id` bigint unsigned NOT NULL,
  `room_code` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `capacity` int unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `hostel_rooms_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_hostel_rooms_uniq` (`institution_id`,`hostel_id`,`room_code`),
  CONSTRAINT `hostel_rooms_hostel_id_fk` FOREIGN KEY (`institution_id`, `hostel_id`) REFERENCES `hostels` (`institution_id`, `id`),
  CONSTRAINT `hostel_rooms_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.hostel_rooms: ~0 rows (approximately)

-- Dumping structure for table scm-system.institutions
CREATE TABLE IF NOT EXISTS `institutions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('school','college','madrasha','mixed') COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('draft','active','suspended') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `timezone` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Asia/Dhaka',
  `locale` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'bn',
  `currency` char(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'BDT',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `institutions_code_unique` (`code`),
  UNIQUE KEY `institutions_slug_unique` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.institutions: ~1 rows (approximately)
INSERT INTO `institutions` (`id`, `code`, `slug`, `name`, `type`, `status`, `timezone`, `locale`, `currency`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(2, 'SCHDEMO', 'demo-sunrise-school', 'Sunrise Model School', 'school', 'active', 'Asia/Dhaka', 'bn', 'BDT', '2026-11-05 13:36:00', '2026-11-05 13:36:00', NULL);

-- Dumping structure for table scm-system.institution_memberships
CREATE TABLE IF NOT EXISTS `institution_memberships` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `status` enum('invited','active','suspended','revoked') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'invited',
  `can_access_all_campuses` tinyint(1) NOT NULL DEFAULT '0',
  `joined_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `institution_memberships_institution_id_user_id_unique` (`institution_id`,`user_id`),
  UNIQUE KEY `institution_memberships_institution_id_id_unique` (`institution_id`,`id`),
  KEY `institution_memberships_user_id_foreign` (`user_id`),
  CONSTRAINT `institution_memberships_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `institution_memberships_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.institution_memberships: ~1 rows (approximately)
INSERT INTO `institution_memberships` (`id`, `institution_id`, `user_id`, `status`, `can_access_all_campuses`, `joined_at`, `created_at`, `updated_at`) VALUES
	(2, 2, 1, 'active', 1, '2026-11-05 13:36:00', NULL, '2026-11-05 13:36:00');

-- Dumping structure for table scm-system.institution_module_settings
CREATE TABLE IF NOT EXISTS `institution_module_settings` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `module_key` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `institution_module_settings_institution_id_module_key_unique` (`institution_id`,`module_key`),
  CONSTRAINT `institution_module_settings_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `institution_module_settings_chk_1` CHECK (json_valid(`options`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.institution_module_settings: ~0 rows (approximately)

-- Dumping structure for table scm-system.institution_roles
CREATE TABLE IF NOT EXISTS `institution_roles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `key` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `institution_roles_institution_id_key_unique` (`institution_id`,`key`),
  UNIQUE KEY `institution_roles_institution_id_id_unique` (`institution_id`,`id`),
  CONSTRAINT `institution_roles_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.institution_roles: ~1 rows (approximately)
INSERT INTO `institution_roles` (`id`, `institution_id`, `key`, `name`, `is_system`, `created_at`, `updated_at`) VALUES
	(2, 2, 'admin', 'Administrator', 1, '2026-11-05 13:36:00', '2026-11-05 13:36:00');

-- Dumping structure for table scm-system.institution_role_permissions
CREATE TABLE IF NOT EXISTS `institution_role_permissions` (
  `role_id` bigint unsigned NOT NULL,
  `permission_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`role_id`,`permission_id`),
  KEY `institution_role_permissions_permission_id_foreign` (`permission_id`),
  CONSTRAINT `institution_role_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `sms_permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `institution_role_permissions_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `institution_roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.institution_role_permissions: ~38 rows (approximately)
INSERT INTO `institution_role_permissions` (`role_id`, `permission_id`) VALUES
	(2, 1),
	(2, 2),
	(2, 3),
	(2, 4),
	(2, 5),
	(2, 6),
	(2, 7),
	(2, 8),
	(2, 9),
	(2, 10),
	(2, 11),
	(2, 12),
	(2, 13),
	(2, 14),
	(2, 15),
	(2, 16),
	(2, 17),
	(2, 18),
	(2, 19),
	(2, 20),
	(2, 21),
	(2, 22),
	(2, 23),
	(2, 24),
	(2, 25),
	(2, 26),
	(2, 27),
	(2, 28),
	(2, 29),
	(2, 30),
	(2, 31),
	(2, 32),
	(2, 33),
	(2, 34),
	(2, 35),
	(2, 36),
	(2, 37),
	(2, 38);

-- Dumping structure for table scm-system.integration_connections
CREATE TABLE IF NOT EXISTS `integration_connections` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `provider` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'disabled',
  `configuration` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `integration_connections_institution_id_id_unique` (`institution_id`,`id`),
  CONSTRAINT `integration_connections_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `integration_connections_chk_1` CHECK (json_valid(`configuration`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.integration_connections: ~0 rows (approximately)

-- Dumping structure for table scm-system.integration_logs
CREATE TABLE IF NOT EXISTS `integration_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `integration_connection_id` bigint unsigned NOT NULL,
  `event_name` varchar(140) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `logged_at` datetime NOT NULL,
  `external_reference` varchar(140) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `integration_logs_institution_id_id_unique` (`institution_id`,`id`),
  KEY `integration_logs_integration_connection_id_fk` (`institution_id`,`integration_connection_id`),
  KEY `sms_integration_logs_idx` (`institution_id`,`status`,`logged_at`),
  CONSTRAINT `integration_logs_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `integration_logs_integration_connection_id_fk` FOREIGN KEY (`institution_id`, `integration_connection_id`) REFERENCES `integration_connections` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.integration_logs: ~0 rows (approximately)

-- Dumping structure for table scm-system.inventory_items
CREATE TABLE IF NOT EXISTS `inventory_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `sku` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `unit` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reorder_level` int unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `inventory_items_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_inventory_items_uniq` (`institution_id`,`sku`),
  CONSTRAINT `inventory_items_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.inventory_items: ~0 rows (approximately)

-- Dumping structure for table scm-system.issued_certificates
CREATE TABLE IF NOT EXISTS `issued_certificates` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `certificate_template_id` bigint unsigned NOT NULL,
  `certificate_no` varchar(65) COLLATE utf8mb4_unicode_ci NOT NULL,
  `issued_on` date NOT NULL,
  `verification_token` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'issued',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `issued_certificates_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_issued_certificates_uniq` (`institution_id`,`certificate_no`),
  KEY `issued_certificates_student_id_fk` (`institution_id`,`student_id`),
  KEY `issued_certificates_certificate_template_id_fk` (`institution_id`,`certificate_template_id`),
  CONSTRAINT `issued_certificates_certificate_template_id_fk` FOREIGN KEY (`institution_id`, `certificate_template_id`) REFERENCES `certificate_templates` (`institution_id`, `id`),
  CONSTRAINT `issued_certificates_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `issued_certificates_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.issued_certificates: ~0 rows (approximately)

-- Dumping structure for table scm-system.jobs
CREATE TABLE IF NOT EXISTS `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.jobs: ~0 rows (approximately)

-- Dumping structure for table scm-system.job_batches
CREATE TABLE IF NOT EXISTS `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.job_batches: ~0 rows (approximately)

-- Dumping structure for table scm-system.ledger_journals
CREATE TABLE IF NOT EXISTS `ledger_journals` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `journal_no` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `posted_on` date NOT NULL,
  `source_type` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `source_reference` varchar(70) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(220) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'posted',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ledger_journals_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_ledger_journals_uniq` (`institution_id`,`journal_no`),
  KEY `sms_ledger_journals_idx` (`institution_id`,`posted_on`,`status`),
  CONSTRAINT `ledger_journals_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.ledger_journals: ~0 rows (approximately)

-- Dumping structure for table scm-system.ledger_lines
CREATE TABLE IF NOT EXISTS `ledger_lines` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `ledger_journal_id` bigint unsigned NOT NULL,
  `account_id` bigint unsigned NOT NULL,
  `debit` decimal(14,2) NOT NULL DEFAULT '0.00',
  `credit` decimal(14,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ledger_lines_institution_id_id_unique` (`institution_id`,`id`),
  KEY `ledger_lines_ledger_journal_id_fk` (`institution_id`,`ledger_journal_id`),
  KEY `ledger_lines_account_id_fk` (`institution_id`,`account_id`),
  CONSTRAINT `ledger_lines_account_id_fk` FOREIGN KEY (`institution_id`, `account_id`) REFERENCES `chart_of_accounts` (`institution_id`, `id`),
  CONSTRAINT `ledger_lines_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `ledger_lines_ledger_journal_id_fk` FOREIGN KEY (`institution_id`, `ledger_journal_id`) REFERENCES `ledger_journals` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.ledger_lines: ~0 rows (approximately)

-- Dumping structure for table scm-system.lesson_plans
CREATE TABLE IF NOT EXISTS `lesson_plans` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `class_subject_id` bigint unsigned NOT NULL,
  `lesson_date` date NOT NULL,
  `topic` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `completion_percent` decimal(5,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lesson_plans_institution_id_id_unique` (`institution_id`,`id`),
  KEY `lesson_plans_class_subject_id_fk` (`institution_id`,`class_subject_id`),
  CONSTRAINT `lesson_plans_class_subject_id_fk` FOREIGN KEY (`institution_id`, `class_subject_id`) REFERENCES `class_subjects` (`institution_id`, `id`),
  CONSTRAINT `lesson_plans_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.lesson_plans: ~0 rows (approximately)

-- Dumping structure for table scm-system.library_books
CREATE TABLE IF NOT EXISTS `library_books` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `isbn` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(220) COLLATE utf8mb4_unicode_ci NOT NULL,
  `author` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `library_books_institution_id_id_unique` (`institution_id`,`id`),
  CONSTRAINT `library_books_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.library_books: ~0 rows (approximately)

-- Dumping structure for table scm-system.library_copies
CREATE TABLE IF NOT EXISTS `library_copies` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `library_book_id` bigint unsigned NOT NULL,
  `barcode` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'available',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `library_copies_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_library_copies_uniq` (`institution_id`,`barcode`),
  KEY `library_copies_library_book_id_fk` (`institution_id`,`library_book_id`),
  CONSTRAINT `library_copies_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `library_copies_library_book_id_fk` FOREIGN KEY (`institution_id`, `library_book_id`) REFERENCES `library_books` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.library_copies: ~0 rows (approximately)

-- Dumping structure for table scm-system.library_loans
CREATE TABLE IF NOT EXISTS `library_loans` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `library_copy_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `issued_on` date NOT NULL,
  `due_on` date NOT NULL,
  `returned_on` date DEFAULT NULL,
  `fine_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'issued',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `library_loans_institution_id_id_unique` (`institution_id`,`id`),
  KEY `library_loans_library_copy_id_fk` (`institution_id`,`library_copy_id`),
  KEY `library_loans_student_id_fk` (`institution_id`,`student_id`),
  CONSTRAINT `library_loans_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `library_loans_library_copy_id_fk` FOREIGN KEY (`institution_id`, `library_copy_id`) REFERENCES `library_copies` (`institution_id`, `id`),
  CONSTRAINT `library_loans_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.library_loans: ~0 rows (approximately)

-- Dumping structure for table scm-system.lms_resources
CREATE TABLE IF NOT EXISTS `lms_resources` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `class_subject_id` bigint unsigned NOT NULL,
  `title` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `resource_type` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `resource_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lms_resources_institution_id_id_unique` (`institution_id`,`id`),
  KEY `lms_resources_class_subject_id_fk` (`institution_id`,`class_subject_id`),
  CONSTRAINT `lms_resources_class_subject_id_fk` FOREIGN KEY (`institution_id`, `class_subject_id`) REFERENCES `class_subjects` (`institution_id`, `id`),
  CONSTRAINT `lms_resources_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.lms_resources: ~0 rows (approximately)

-- Dumping structure for table scm-system.meal_plans
CREATE TABLE IF NOT EXISTS `meal_plans` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `hostel_id` bigint unsigned NOT NULL,
  `name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `monthly_rate` decimal(14,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `meal_plans_institution_id_id_unique` (`institution_id`,`id`),
  KEY `meal_plans_hostel_id_fk` (`institution_id`,`hostel_id`),
  CONSTRAINT `meal_plans_hostel_id_fk` FOREIGN KEY (`institution_id`, `hostel_id`) REFERENCES `hostels` (`institution_id`, `id`),
  CONSTRAINT `meal_plans_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.meal_plans: ~0 rows (approximately)

-- Dumping structure for table scm-system.membership_campuses
CREATE TABLE IF NOT EXISTS `membership_campuses` (
  `institution_id` bigint unsigned NOT NULL,
  `membership_id` bigint unsigned NOT NULL,
  `campus_id` bigint unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`institution_id`,`membership_id`,`campus_id`),
  KEY `mc_campus_fk` (`institution_id`,`campus_id`),
  CONSTRAINT `mc_campus_fk` FOREIGN KEY (`institution_id`, `campus_id`) REFERENCES `campuses` (`institution_id`, `id`) ON DELETE CASCADE,
  CONSTRAINT `mc_membership_fk` FOREIGN KEY (`institution_id`, `membership_id`) REFERENCES `institution_memberships` (`institution_id`, `id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.membership_campuses: ~0 rows (approximately)

-- Dumping structure for table scm-system.membership_roles
CREATE TABLE IF NOT EXISTS `membership_roles` (
  `institution_id` bigint unsigned NOT NULL,
  `membership_id` bigint unsigned NOT NULL,
  `role_id` bigint unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`institution_id`,`membership_id`,`role_id`),
  KEY `mr_role_fk` (`institution_id`,`role_id`),
  CONSTRAINT `mr_membership_fk` FOREIGN KEY (`institution_id`, `membership_id`) REFERENCES `institution_memberships` (`institution_id`, `id`) ON DELETE CASCADE,
  CONSTRAINT `mr_role_fk` FOREIGN KEY (`institution_id`, `role_id`) REFERENCES `institution_roles` (`institution_id`, `id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.membership_roles: ~1 rows (approximately)
INSERT INTO `membership_roles` (`institution_id`, `membership_id`, `role_id`, `created_at`) VALUES
	(2, 2, 2, '2026-11-05 13:36:00');

-- Dumping structure for table scm-system.migrations
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.migrations: ~6 rows (approximately)
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
	(1, '0001_01_01_000000_create_users_table', 1),
	(2, '0001_01_01_000001_create_cache_table', 1),
	(3, '0001_01_01_000002_create_jobs_table', 1),
	(4, '2026_11_04_000001_create_sms_core_tables', 1),
	(5, '2026_11_05_000002_create_sms_domain_tables', 1),
	(6, '2026_11_05_000003_add_sms_domain_business_keys', 1);

-- Dumping structure for table scm-system.notices
CREATE TABLE IF NOT EXISTS `notices` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `title` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `audience` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `published_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `notices_institution_id_id_unique` (`institution_id`,`id`),
  CONSTRAINT `notices_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.notices: ~0 rows (approximately)

-- Dumping structure for table scm-system.notification_deliveries
CREATE TABLE IF NOT EXISTS `notification_deliveries` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `notification_template_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned DEFAULT NULL,
  `recipient` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `channel` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'queued',
  `sent_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `notification_deliveries_institution_id_id_unique` (`institution_id`,`id`),
  KEY `notification_deliveries_notification_template_id_fk` (`institution_id`,`notification_template_id`),
  KEY `notification_deliveries_student_id_fk` (`institution_id`,`student_id`),
  KEY `sms_notification_deliveries_idx` (`institution_id`,`status`,`sent_at`),
  CONSTRAINT `notification_deliveries_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `notification_deliveries_notification_template_id_fk` FOREIGN KEY (`institution_id`, `notification_template_id`) REFERENCES `notification_templates` (`institution_id`, `id`),
  CONSTRAINT `notification_deliveries_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.notification_deliveries: ~0 rows (approximately)

-- Dumping structure for table scm-system.notification_templates
CREATE TABLE IF NOT EXISTS `notification_templates` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `channel` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `notification_templates_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_notification_templates_uniq` (`institution_id`,`code`),
  CONSTRAINT `notification_templates_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.notification_templates: ~0 rows (approximately)

-- Dumping structure for table scm-system.parent_meetings
CREATE TABLE IF NOT EXISTS `parent_meetings` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `employee_id` bigint unsigned NOT NULL,
  `scheduled_at` datetime NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'requested',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `parent_meetings_institution_id_id_unique` (`institution_id`,`id`),
  KEY `parent_meetings_student_id_fk` (`institution_id`,`student_id`),
  KEY `parent_meetings_employee_id_fk` (`institution_id`,`employee_id`),
  CONSTRAINT `parent_meetings_employee_id_fk` FOREIGN KEY (`institution_id`, `employee_id`) REFERENCES `employees` (`institution_id`, `id`),
  CONSTRAINT `parent_meetings_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `parent_meetings_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.parent_meetings: ~0 rows (approximately)

-- Dumping structure for table scm-system.payment_allocations
CREATE TABLE IF NOT EXISTS `payment_allocations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_payment_id` bigint unsigned NOT NULL,
  `student_invoice_id` bigint unsigned NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payment_allocations_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_payment_allocations_combo_uniq` (`institution_id`,`student_payment_id`,`student_invoice_id`),
  KEY `payment_allocations_student_invoice_id_fk` (`institution_id`,`student_invoice_id`),
  CONSTRAINT `payment_allocations_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `payment_allocations_student_invoice_id_fk` FOREIGN KEY (`institution_id`, `student_invoice_id`) REFERENCES `student_invoices` (`institution_id`, `id`),
  CONSTRAINT `payment_allocations_student_payment_id_fk` FOREIGN KEY (`institution_id`, `student_payment_id`) REFERENCES `student_payments` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.payment_allocations: ~0 rows (approximately)

-- Dumping structure for table scm-system.payment_methods
CREATE TABLE IF NOT EXISTS `payment_methods` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `method_type` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payment_methods_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_payment_methods_uniq` (`institution_id`,`code`),
  CONSTRAINT `payment_methods_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.payment_methods: ~0 rows (approximately)

-- Dumping structure for table scm-system.payment_refunds
CREATE TABLE IF NOT EXISTS `payment_refunds` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_payment_id` bigint unsigned NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'requested',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payment_refunds_institution_id_id_unique` (`institution_id`,`id`),
  KEY `payment_refunds_student_payment_id_fk` (`institution_id`,`student_payment_id`),
  CONSTRAINT `payment_refunds_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `payment_refunds_student_payment_id_fk` FOREIGN KEY (`institution_id`, `student_payment_id`) REFERENCES `student_payments` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.payment_refunds: ~0 rows (approximately)

-- Dumping structure for table scm-system.payroll_runs
CREATE TABLE IF NOT EXISTS `payroll_runs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payroll_runs_institution_id_id_unique` (`institution_id`,`id`),
  CONSTRAINT `payroll_runs_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.payroll_runs: ~0 rows (approximately)

-- Dumping structure for table scm-system.payslips
CREATE TABLE IF NOT EXISTS `payslips` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `payroll_run_id` bigint unsigned NOT NULL,
  `employee_id` bigint unsigned NOT NULL,
  `gross_amount` decimal(14,2) NOT NULL,
  `deduction_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `net_amount` decimal(14,2) NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payslips_institution_id_id_unique` (`institution_id`,`id`),
  KEY `payslips_payroll_run_id_fk` (`institution_id`,`payroll_run_id`),
  KEY `payslips_employee_id_fk` (`institution_id`,`employee_id`),
  CONSTRAINT `payslips_employee_id_fk` FOREIGN KEY (`institution_id`, `employee_id`) REFERENCES `employees` (`institution_id`, `id`),
  CONSTRAINT `payslips_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `payslips_payroll_run_id_fk` FOREIGN KEY (`institution_id`, `payroll_run_id`) REFERENCES `payroll_runs` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.payslips: ~0 rows (approximately)

-- Dumping structure for table scm-system.payslip_items
CREATE TABLE IF NOT EXISTS `payslip_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `payslip_id` bigint unsigned NOT NULL,
  `item_type` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(140) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payslip_items_institution_id_id_unique` (`institution_id`,`id`),
  KEY `payslip_items_payslip_id_fk` (`institution_id`,`payslip_id`),
  CONSTRAINT `payslip_items_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `payslip_items_payslip_id_fk` FOREIGN KEY (`institution_id`, `payslip_id`) REFERENCES `payslips` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.payslip_items: ~0 rows (approximately)

-- Dumping structure for table scm-system.platform_admin_users
CREATE TABLE IF NOT EXISTS `platform_admin_users` (
  `user_id` bigint unsigned NOT NULL,
  `granted_by_user_id` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  KEY `platform_admin_users_granted_by_user_id_foreign` (`granted_by_user_id`),
  CONSTRAINT `platform_admin_users_granted_by_user_id_foreign` FOREIGN KEY (`granted_by_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `platform_admin_users_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.platform_admin_users: ~0 rows (approximately)

-- Dumping structure for table scm-system.published_results
CREATE TABLE IF NOT EXISTS `published_results` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `examination_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `percentage` decimal(5,2) NOT NULL,
  `gpa` decimal(4,2) NOT NULL,
  `result` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `published_results_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_published_results_combo_uniq` (`institution_id`,`examination_id`,`student_id`),
  KEY `published_results_student_id_fk` (`institution_id`,`student_id`),
  CONSTRAINT `published_results_examination_id_fk` FOREIGN KEY (`institution_id`, `examination_id`) REFERENCES `examinations` (`institution_id`, `id`),
  CONSTRAINT `published_results_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `published_results_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.published_results: ~0 rows (approximately)

-- Dumping structure for table scm-system.purchase_orders
CREATE TABLE IF NOT EXISTS `purchase_orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `supplier_id` bigint unsigned NOT NULL,
  `po_number` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ordered_on` date NOT NULL,
  `total_amount` decimal(14,2) NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `purchase_orders_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_purchase_orders_uniq` (`institution_id`,`po_number`),
  KEY `purchase_orders_supplier_id_fk` (`institution_id`,`supplier_id`),
  CONSTRAINT `purchase_orders_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `purchase_orders_supplier_id_fk` FOREIGN KEY (`institution_id`, `supplier_id`) REFERENCES `suppliers` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.purchase_orders: ~0 rows (approximately)

-- Dumping structure for table scm-system.purchase_order_lines
CREATE TABLE IF NOT EXISTS `purchase_order_lines` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `purchase_order_id` bigint unsigned NOT NULL,
  `inventory_item_id` bigint unsigned NOT NULL,
  `quantity` int unsigned NOT NULL,
  `unit_price` decimal(14,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `purchase_order_lines_institution_id_id_unique` (`institution_id`,`id`),
  KEY `purchase_order_lines_purchase_order_id_fk` (`institution_id`,`purchase_order_id`),
  KEY `purchase_order_lines_inventory_item_id_fk` (`institution_id`,`inventory_item_id`),
  CONSTRAINT `purchase_order_lines_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `purchase_order_lines_inventory_item_id_fk` FOREIGN KEY (`institution_id`, `inventory_item_id`) REFERENCES `inventory_items` (`institution_id`, `id`),
  CONSTRAINT `purchase_order_lines_purchase_order_id_fk` FOREIGN KEY (`institution_id`, `purchase_order_id`) REFERENCES `purchase_orders` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.purchase_order_lines: ~0 rows (approximately)

-- Dumping structure for table scm-system.report_exports
CREATE TABLE IF NOT EXISTS `report_exports` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `report_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `requested_at` datetime NOT NULL,
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `report_exports_institution_id_id_unique` (`institution_id`,`id`),
  KEY `report_exports_user_id_fk` (`user_id`),
  CONSTRAINT `report_exports_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `report_exports_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.report_exports: ~0 rows (approximately)

-- Dumping structure for table scm-system.room_bookings
CREATE TABLE IF NOT EXISTS `room_bookings` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `campus_id` bigint unsigned NOT NULL,
  `booked_by_user_id` bigint unsigned DEFAULT NULL,
  `room_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `starts_at` datetime NOT NULL,
  `ends_at` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `room_bookings_institution_id_id_unique` (`institution_id`,`id`),
  KEY `room_bookings_campus_id_fk` (`institution_id`,`campus_id`),
  KEY `room_bookings_booked_by_user_id_fk` (`booked_by_user_id`),
  CONSTRAINT `room_bookings_booked_by_user_id_fk` FOREIGN KEY (`booked_by_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `room_bookings_campus_id_fk` FOREIGN KEY (`institution_id`, `campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  CONSTRAINT `room_bookings_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.room_bookings: ~0 rows (approximately)

-- Dumping structure for table scm-system.scholarships
CREATE TABLE IF NOT EXISTS `scholarships` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `name` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `criteria` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `scholarships_institution_id_id_unique` (`institution_id`,`id`),
  CONSTRAINT `scholarships_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.scholarships: ~0 rows (approximately)

-- Dumping structure for table scm-system.scholarship_awards
CREATE TABLE IF NOT EXISTS `scholarship_awards` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `scholarship_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'approved',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `scholarship_awards_institution_id_id_unique` (`institution_id`,`id`),
  KEY `scholarship_awards_scholarship_id_fk` (`institution_id`,`scholarship_id`),
  KEY `scholarship_awards_student_id_fk` (`institution_id`,`student_id`),
  CONSTRAINT `scholarship_awards_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `scholarship_awards_scholarship_id_fk` FOREIGN KEY (`institution_id`, `scholarship_id`) REFERENCES `scholarships` (`institution_id`, `id`),
  CONSTRAINT `scholarship_awards_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.scholarship_awards: ~0 rows (approximately)

-- Dumping structure for table scm-system.sms_audit_logs
CREATE TABLE IF NOT EXISTS `sms_audit_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned DEFAULT NULL,
  `actor_user_id` bigint unsigned DEFAULT NULL,
  `action` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `resource_type` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `resource_id` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `before_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `after_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `request_id` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `sms_audit_logs_actor_user_id_foreign` (`actor_user_id`),
  KEY `sms_audit_logs_institution_id_created_at_index` (`institution_id`,`created_at`),
  KEY `sms_audit_logs_resource_type_resource_id_index` (`resource_type`,`resource_id`),
  CONSTRAINT `sms_audit_logs_actor_user_id_foreign` FOREIGN KEY (`actor_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `sms_audit_logs_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `sms_audit_logs_chk_1` CHECK (json_valid(`before_data`)),
  CONSTRAINT `sms_audit_logs_chk_2` CHECK (json_valid(`after_data`)),
  CONSTRAINT `sms_audit_logs_chk_3` CHECK (json_valid(`metadata`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.sms_audit_logs: ~0 rows (approximately)

-- Dumping structure for table scm-system.sms_idempotency_records
CREATE TABLE IF NOT EXISTS `sms_idempotency_records` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `operation` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `idempotency_key` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `request_sha256` char(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('processing','completed','failed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'processing',
  `response_status` smallint unsigned DEFAULT NULL,
  `response_body` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `expires_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sms_idempotency_unique` (`institution_id`,`operation`,`idempotency_key`),
  KEY `sms_idempotency_records_status_expires_at_index` (`status`,`expires_at`),
  CONSTRAINT `sms_idempotency_records_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `sms_idempotency_records_chk_1` CHECK (json_valid(`response_body`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.sms_idempotency_records: ~0 rows (approximately)

-- Dumping structure for table scm-system.sms_outbox_events
CREATE TABLE IF NOT EXISTS `sms_outbox_events` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `event_type` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `aggregate_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `aggregate_id` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `status` enum('pending','processing','completed','failed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `attempts` smallint unsigned NOT NULL DEFAULT '0',
  `available_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `processed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sms_outbox_events_status_available_at_index` (`status`,`available_at`),
  KEY `sms_outbox_aggregate_idx` (`institution_id`,`aggregate_type`,`aggregate_id`),
  CONSTRAINT `sms_outbox_events_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `sms_outbox_events_chk_1` CHECK (json_valid(`payload`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.sms_outbox_events: ~0 rows (approximately)

-- Dumping structure for table scm-system.sms_permissions
CREATE TABLE IF NOT EXISTS `sms_permissions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `module` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sms_permissions_key_unique` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.sms_permissions: ~38 rows (approximately)
INSERT INTO `sms_permissions` (`id`, `key`, `module`, `label`, `created_at`, `updated_at`) VALUES
	(1, 'dashboard.view', 'dashboard', 'View dashboard', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(2, 'institutions.manage', 'institutions', 'Manage institution settings', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(3, 'campuses.view', 'campuses', 'View authorized campuses', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(4, 'campuses.manage', 'campuses', 'Manage campuses', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(5, 'memberships.view', 'security', 'View institution memberships', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(6, 'memberships.manage', 'security', 'Manage institution memberships', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(7, 'roles.manage', 'security', 'Manage role assignments', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(8, 'students.view', 'students', 'View authorized student records', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(9, 'students.create', 'students', 'Create student records', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(10, 'students.update', 'students', 'Update authorized student records', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(11, 'students.export', 'students', 'Export authorized student records', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(12, 'admissions.view', 'admissions', 'View admissions', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(13, 'admissions.manage', 'admissions', 'Manage admissions', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(14, 'academics.manage', 'academics', 'Manage curriculum and classes', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(15, 'attendance.view', 'attendance', 'View attendance', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(16, 'attendance.record', 'attendance', 'Record assigned attendance', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(17, 'attendance.approve_correction', 'attendance', 'Approve attendance corrections', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(18, 'exams.view', 'examinations', 'View examinations', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(19, 'marks.enter', 'examinations', 'Enter assigned subject marks', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(20, 'results.approve', 'examinations', 'Approve examination results', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(21, 'results.publish', 'examinations', 'Publish examination results', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(22, 'fees.view', 'finance', 'View fee information', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(23, 'fees.collect', 'finance', 'Collect approved fees', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(24, 'fees.adjust', 'finance', 'Manage authorized fee adjustments', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(25, 'refunds.request', 'finance', 'Request refund', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(26, 'refunds.approve', 'finance', 'Approve refund', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(27, 'accounting.post', 'finance', 'Post journal transactions', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(28, 'accounting.reconcile', 'finance', 'Reconcile accounts', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(29, 'hr.view', 'hr', 'View authorized staff data', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(30, 'payroll.process', 'hr', 'Process payroll', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(31, 'payroll.approve', 'hr', 'Approve payroll', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(32, 'hifz.progress.record', 'hifz', 'Record assigned Hifz progress', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(33, 'library.manage', 'library', 'Manage library', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(34, 'hostel.manage', 'hostel', 'Manage hostel operations', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(35, 'inventory.manage', 'inventory', 'Manage institutional inventory', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(36, 'donations.manage', 'donations', 'Manage donations and restricted funds', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(37, 'reports.export', 'reports', 'Export authorized reports', '2026-11-05 13:32:23', '2026-11-05 13:35:12'),
	(38, 'audit.view', 'security', 'View authorized audit logs', '2026-11-05 13:32:23', '2026-11-05 13:35:12');

-- Dumping structure for table scm-system.staff_appraisals
CREATE TABLE IF NOT EXISTS `staff_appraisals` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `employee_id` bigint unsigned NOT NULL,
  `reviewed_on` date NOT NULL,
  `score` decimal(5,2) NOT NULL,
  `remarks` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `staff_appraisals_institution_id_id_unique` (`institution_id`,`id`),
  KEY `staff_appraisals_employee_id_fk` (`institution_id`,`employee_id`),
  CONSTRAINT `staff_appraisals_employee_id_fk` FOREIGN KEY (`institution_id`, `employee_id`) REFERENCES `employees` (`institution_id`, `id`),
  CONSTRAINT `staff_appraisals_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.staff_appraisals: ~0 rows (approximately)

-- Dumping structure for table scm-system.staff_attendance
CREATE TABLE IF NOT EXISTS `staff_attendance` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `employee_id` bigint unsigned NOT NULL,
  `attendance_on` date NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'present',
  `check_in_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `staff_attendance_institution_id_id_unique` (`institution_id`,`id`),
  KEY `staff_attendance_employee_id_fk` (`institution_id`,`employee_id`),
  CONSTRAINT `staff_attendance_employee_id_fk` FOREIGN KEY (`institution_id`, `employee_id`) REFERENCES `employees` (`institution_id`, `id`),
  CONSTRAINT `staff_attendance_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.staff_attendance: ~0 rows (approximately)

-- Dumping structure for table scm-system.staff_leave_requests
CREATE TABLE IF NOT EXISTS `staff_leave_requests` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `employee_id` bigint unsigned NOT NULL,
  `starts_on` date NOT NULL,
  `ends_on` date NOT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `staff_leave_requests_institution_id_id_unique` (`institution_id`,`id`),
  KEY `staff_leave_requests_employee_id_fk` (`institution_id`,`employee_id`),
  CONSTRAINT `staff_leave_requests_employee_id_fk` FOREIGN KEY (`institution_id`, `employee_id`) REFERENCES `employees` (`institution_id`, `id`),
  CONSTRAINT `staff_leave_requests_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.staff_leave_requests: ~0 rows (approximately)

-- Dumping structure for table scm-system.stock_movements
CREATE TABLE IF NOT EXISTS `stock_movements` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `inventory_item_id` bigint unsigned NOT NULL,
  `quantity` int NOT NULL,
  `movement_type` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reference_no` varchar(70) COLLATE utf8mb4_unicode_ci NOT NULL,
  `moved_on` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stock_movements_institution_id_id_unique` (`institution_id`,`id`),
  KEY `stock_movements_inventory_item_id_fk` (`institution_id`,`inventory_item_id`),
  CONSTRAINT `stock_movements_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `stock_movements_inventory_item_id_fk` FOREIGN KEY (`institution_id`, `inventory_item_id`) REFERENCES `inventory_items` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.stock_movements: ~0 rows (approximately)

-- Dumping structure for table scm-system.students
CREATE TABLE IF NOT EXISTS `students` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `campus_id` bigint unsigned NOT NULL,
  `admission_no` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `gender` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `blood_group` varchar(8) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `students_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_students_uniq` (`institution_id`,`admission_no`),
  KEY `students_user_id_fk` (`user_id`),
  KEY `students_campus_id_fk` (`institution_id`,`campus_id`),
  KEY `sms_students_idx` (`institution_id`,`status`,`campus_id`),
  CONSTRAINT `students_campus_id_fk` FOREIGN KEY (`institution_id`, `campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  CONSTRAINT `students_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `students_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.students: ~0 rows (approximately)

-- Dumping structure for table scm-system.student_attendance
CREATE TABLE IF NOT EXISTS `student_attendance` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `attendance_session_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `status` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'present',
  `minutes_late` int unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_attendance_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_student_attendance_combo_uniq` (`institution_id`,`attendance_session_id`,`student_id`),
  KEY `sms_student_attendance_idx` (`institution_id`,`student_id`,`status`),
  CONSTRAINT `student_attendance_attendance_session_id_fk` FOREIGN KEY (`institution_id`, `attendance_session_id`) REFERENCES `attendance_sessions` (`institution_id`, `id`),
  CONSTRAINT `student_attendance_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `student_attendance_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.student_attendance: ~0 rows (approximately)

-- Dumping structure for table scm-system.student_documents
CREATE TABLE IF NOT EXISTS `student_documents` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `document_type` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `verification_status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_documents_institution_id_id_unique` (`institution_id`,`id`),
  KEY `student_documents_student_id_fk` (`institution_id`,`student_id`),
  CONSTRAINT `student_documents_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `student_documents_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.student_documents: ~0 rows (approximately)

-- Dumping structure for table scm-system.student_guardians
CREATE TABLE IF NOT EXISTS `student_guardians` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `guardian_id` bigint unsigned NOT NULL,
  `relationship` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_guardians_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_student_guardians_combo_uniq` (`institution_id`,`student_id`,`guardian_id`),
  KEY `student_guardians_guardian_id_fk` (`institution_id`,`guardian_id`),
  CONSTRAINT `student_guardians_guardian_id_fk` FOREIGN KEY (`institution_id`, `guardian_id`) REFERENCES `guardians` (`institution_id`, `id`),
  CONSTRAINT `student_guardians_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `student_guardians_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.student_guardians: ~0 rows (approximately)

-- Dumping structure for table scm-system.student_health_records
CREATE TABLE IF NOT EXISTS `student_health_records` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `allergies` text COLLATE utf8mb4_unicode_ci,
  `medical_notes` text COLLATE utf8mb4_unicode_ci,
  `emergency_contact` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_health_records_institution_id_id_unique` (`institution_id`,`id`),
  KEY `student_health_records_student_id_fk` (`institution_id`,`student_id`),
  CONSTRAINT `student_health_records_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `student_health_records_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.student_health_records: ~0 rows (approximately)

-- Dumping structure for table scm-system.student_incidents
CREATE TABLE IF NOT EXISTS `student_incidents` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `occurred_on` date NOT NULL,
  `category` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `details` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_incidents_institution_id_id_unique` (`institution_id`,`id`),
  KEY `student_incidents_student_id_fk` (`institution_id`,`student_id`),
  CONSTRAINT `student_incidents_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `student_incidents_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.student_incidents: ~0 rows (approximately)

-- Dumping structure for table scm-system.student_invoices
CREATE TABLE IF NOT EXISTS `student_invoices` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `invoice_no` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `issued_on` date NOT NULL,
  `due_on` date NOT NULL,
  `total_amount` decimal(14,2) NOT NULL,
  `paid_amount` decimal(14,2) NOT NULL DEFAULT '0.00',
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'unpaid',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_invoices_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_student_invoices_uniq` (`institution_id`,`invoice_no`),
  KEY `sms_student_invoices_idx` (`institution_id`,`student_id`,`status`,`due_on`),
  CONSTRAINT `student_invoices_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `student_invoices_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.student_invoices: ~0 rows (approximately)

-- Dumping structure for table scm-system.student_invoice_lines
CREATE TABLE IF NOT EXISTS `student_invoice_lines` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_invoice_id` bigint unsigned NOT NULL,
  `fee_head_id` bigint unsigned NOT NULL,
  `description` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_invoice_lines_institution_id_id_unique` (`institution_id`,`id`),
  KEY `student_invoice_lines_student_invoice_id_fk` (`institution_id`,`student_invoice_id`),
  KEY `student_invoice_lines_fee_head_id_fk` (`institution_id`,`fee_head_id`),
  CONSTRAINT `student_invoice_lines_fee_head_id_fk` FOREIGN KEY (`institution_id`, `fee_head_id`) REFERENCES `fee_heads` (`institution_id`, `id`),
  CONSTRAINT `student_invoice_lines_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `student_invoice_lines_student_invoice_id_fk` FOREIGN KEY (`institution_id`, `student_invoice_id`) REFERENCES `student_invoices` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.student_invoice_lines: ~0 rows (approximately)

-- Dumping structure for table scm-system.student_leave_requests
CREATE TABLE IF NOT EXISTS `student_leave_requests` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `starts_on` date NOT NULL,
  `ends_on` date NOT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_leave_requests_institution_id_id_unique` (`institution_id`,`id`),
  KEY `student_leave_requests_student_id_fk` (`institution_id`,`student_id`),
  CONSTRAINT `student_leave_requests_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `student_leave_requests_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.student_leave_requests: ~0 rows (approximately)

-- Dumping structure for table scm-system.student_payments
CREATE TABLE IF NOT EXISTS `student_payments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `student_invoice_id` bigint unsigned NOT NULL,
  `payment_method_id` bigint unsigned NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `paid_on` date NOT NULL,
  `reference_no` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'posted',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_payments_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_student_payments_uniq` (`institution_id`,`reference_no`),
  KEY `student_payments_student_invoice_id_fk` (`institution_id`,`student_invoice_id`),
  KEY `student_payments_payment_method_id_fk` (`institution_id`,`payment_method_id`),
  KEY `sms_student_payments_idx` (`institution_id`,`student_id`,`paid_on`),
  CONSTRAINT `student_payments_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `student_payments_payment_method_id_fk` FOREIGN KEY (`institution_id`, `payment_method_id`) REFERENCES `payment_methods` (`institution_id`, `id`),
  CONSTRAINT `student_payments_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`),
  CONSTRAINT `student_payments_student_invoice_id_fk` FOREIGN KEY (`institution_id`, `student_invoice_id`) REFERENCES `student_invoices` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.student_payments: ~0 rows (approximately)

-- Dumping structure for table scm-system.student_promotions
CREATE TABLE IF NOT EXISTS `student_promotions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `from_enrollment_id` bigint unsigned NOT NULL,
  `to_enrollment_id` bigint unsigned DEFAULT NULL,
  `promoted_on` date NOT NULL,
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_promotions_institution_id_id_unique` (`institution_id`,`id`),
  KEY `student_promotions_student_id_fk` (`institution_id`,`student_id`),
  KEY `student_promotions_from_enrollment_id_fk` (`institution_id`,`from_enrollment_id`),
  KEY `student_promotions_to_enrollment_id_fk` (`institution_id`,`to_enrollment_id`),
  CONSTRAINT `student_promotions_from_enrollment_id_fk` FOREIGN KEY (`institution_id`, `from_enrollment_id`) REFERENCES `enrollments` (`institution_id`, `id`),
  CONSTRAINT `student_promotions_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `student_promotions_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`),
  CONSTRAINT `student_promotions_to_enrollment_id_fk` FOREIGN KEY (`institution_id`, `to_enrollment_id`) REFERENCES `enrollments` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.student_promotions: ~0 rows (approximately)

-- Dumping structure for table scm-system.student_transfers
CREATE TABLE IF NOT EXISTS `student_transfers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `from_campus_id` bigint unsigned NOT NULL,
  `to_campus_id` bigint unsigned DEFAULT NULL,
  `transferred_on` date NOT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'requested',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_transfers_institution_id_id_unique` (`institution_id`,`id`),
  KEY `student_transfers_student_id_fk` (`institution_id`,`student_id`),
  KEY `student_transfers_from_campus_id_fk` (`institution_id`,`from_campus_id`),
  KEY `student_transfers_to_campus_id_fk` (`institution_id`,`to_campus_id`),
  CONSTRAINT `student_transfers_from_campus_id_fk` FOREIGN KEY (`institution_id`, `from_campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  CONSTRAINT `student_transfers_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `student_transfers_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`),
  CONSTRAINT `student_transfers_to_campus_id_fk` FOREIGN KEY (`institution_id`, `to_campus_id`) REFERENCES `campuses` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.student_transfers: ~0 rows (approximately)

-- Dumping structure for table scm-system.student_transport_assignments
CREATE TABLE IF NOT EXISTS `student_transport_assignments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `transport_route_id` bigint unsigned NOT NULL,
  `transport_stop_id` bigint unsigned NOT NULL,
  `starts_on` date NOT NULL,
  `monthly_fee` decimal(14,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_transport_assignments_institution_id_id_unique` (`institution_id`,`id`),
  KEY `student_transport_assignments_student_id_fk` (`institution_id`,`student_id`),
  KEY `student_transport_assignments_transport_route_id_fk` (`institution_id`,`transport_route_id`),
  KEY `student_transport_assignments_transport_stop_id_fk` (`institution_id`,`transport_stop_id`),
  CONSTRAINT `student_transport_assignments_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `student_transport_assignments_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`),
  CONSTRAINT `student_transport_assignments_transport_route_id_fk` FOREIGN KEY (`institution_id`, `transport_route_id`) REFERENCES `transport_routes` (`institution_id`, `id`),
  CONSTRAINT `student_transport_assignments_transport_stop_id_fk` FOREIGN KEY (`institution_id`, `transport_stop_id`) REFERENCES `transport_stops` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.student_transport_assignments: ~0 rows (approximately)

-- Dumping structure for table scm-system.subjects
CREATE TABLE IF NOT EXISTS `subjects` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `department_id` bigint unsigned DEFAULT NULL,
  `code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(140) COLLATE utf8mb4_unicode_ci NOT NULL,
  `credit_hours` decimal(6,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `subjects_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_subjects_uniq` (`institution_id`,`code`),
  KEY `subjects_department_id_fk` (`institution_id`,`department_id`),
  CONSTRAINT `subjects_department_id_fk` FOREIGN KEY (`institution_id`, `department_id`) REFERENCES `academic_departments` (`institution_id`, `id`),
  CONSTRAINT `subjects_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.subjects: ~0 rows (approximately)

-- Dumping structure for table scm-system.suppliers
CREATE TABLE IF NOT EXISTS `suppliers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `suppliers_institution_id_id_unique` (`institution_id`,`id`),
  CONSTRAINT `suppliers_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.suppliers: ~0 rows (approximately)

-- Dumping structure for table scm-system.teacher_assignments
CREATE TABLE IF NOT EXISTS `teacher_assignments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `employee_id` bigint unsigned NOT NULL,
  `class_subject_id` bigint unsigned NOT NULL,
  `academic_session_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `teacher_assignments_institution_id_id_unique` (`institution_id`,`id`),
  KEY `teacher_assignments_employee_id_fk` (`institution_id`,`employee_id`),
  KEY `teacher_assignments_class_subject_id_fk` (`institution_id`,`class_subject_id`),
  KEY `teacher_assignments_academic_session_id_fk` (`institution_id`,`academic_session_id`),
  CONSTRAINT `teacher_assignments_academic_session_id_fk` FOREIGN KEY (`institution_id`, `academic_session_id`) REFERENCES `academic_sessions` (`institution_id`, `id`),
  CONSTRAINT `teacher_assignments_class_subject_id_fk` FOREIGN KEY (`institution_id`, `class_subject_id`) REFERENCES `class_subjects` (`institution_id`, `id`),
  CONSTRAINT `teacher_assignments_employee_id_fk` FOREIGN KEY (`institution_id`, `employee_id`) REFERENCES `employees` (`institution_id`, `id`),
  CONSTRAINT `teacher_assignments_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.teacher_assignments: ~0 rows (approximately)

-- Dumping structure for table scm-system.transport_routes
CREATE TABLE IF NOT EXISTS `transport_routes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `vehicle_id` bigint unsigned NOT NULL,
  `employee_id` bigint unsigned DEFAULT NULL,
  `route_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transport_routes_institution_id_id_unique` (`institution_id`,`id`),
  KEY `transport_routes_vehicle_id_fk` (`institution_id`,`vehicle_id`),
  KEY `transport_routes_employee_id_fk` (`institution_id`,`employee_id`),
  CONSTRAINT `transport_routes_employee_id_fk` FOREIGN KEY (`institution_id`, `employee_id`) REFERENCES `employees` (`institution_id`, `id`),
  CONSTRAINT `transport_routes_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `transport_routes_vehicle_id_fk` FOREIGN KEY (`institution_id`, `vehicle_id`) REFERENCES `vehicles` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.transport_routes: ~0 rows (approximately)

-- Dumping structure for table scm-system.transport_stops
CREATE TABLE IF NOT EXISTS `transport_stops` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `transport_route_id` bigint unsigned NOT NULL,
  `name` varchar(140) COLLATE utf8mb4_unicode_ci NOT NULL,
  `stop_order` int unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transport_stops_institution_id_id_unique` (`institution_id`,`id`),
  KEY `transport_stops_transport_route_id_fk` (`institution_id`,`transport_route_id`),
  CONSTRAINT `transport_stops_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `transport_stops_transport_route_id_fk` FOREIGN KEY (`institution_id`, `transport_route_id`) REFERENCES `transport_routes` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.transport_stops: ~0 rows (approximately)

-- Dumping structure for table scm-system.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.users: ~8 rows (approximately)
INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES
	(1, 'School Administrator', 'admin.school@example.test', NULL, '$2y$12$u3D.U92fSw9Esm0uIJGkjuFOzYFOtsvOf.76TkINZjt/h1UPIROwW', NULL, '2026-11-05 13:16:57', '2026-11-05 13:16:57'),
	(2, 'Teacher Nabila', 'teacher.school@example.test', '2026-11-05 02:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 02:00:00', '2026-11-05 02:00:00'),
	(3, 'Accounts Officer', 'accounts.school@example.test', '2026-11-05 02:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 02:00:00', '2026-11-05 02:00:00'),
	(4, 'Demo Parent', 'parent.school@example.test', '2026-11-05 02:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 02:00:00', '2026-11-05 02:00:00'),
	(5, 'Student Ayesha', 'student.school@example.test', '2026-11-05 02:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 02:00:00', '2026-11-05 02:00:00'),
	(6, 'College Administrator', 'admin.college@example.test', '2026-11-05 02:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 02:00:00', '2026-11-05 02:00:00'),
	(7, 'Madrasha Administrator', 'admin.madrasha@example.test', '2026-11-05 02:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 02:00:00', '2026-11-05 02:00:00'),
	(8, 'Ustad Mahmud', 'ustad.madrasha@example.test', '2026-11-05 02:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 02:00:00', '2026-11-05 02:00:00');

-- Dumping structure for table scm-system.vehicles
CREATE TABLE IF NOT EXISTS `vehicles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `vehicle_code` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `plate_number` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `seats` int unsigned NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `vehicles_institution_id_id_unique` (`institution_id`,`id`),
  UNIQUE KEY `sms_vehicles_uniq` (`institution_id`,`vehicle_code`),
  CONSTRAINT `vehicles_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.vehicles: ~0 rows (approximately)

-- Dumping structure for table scm-system.visitor_logs
CREATE TABLE IF NOT EXISTS `visitor_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `campus_id` bigint unsigned NOT NULL,
  `visitor_name` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `purpose` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `checked_in_at` datetime NOT NULL,
  `checked_out_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `visitor_logs_institution_id_id_unique` (`institution_id`,`id`),
  KEY `visitor_logs_campus_id_fk` (`institution_id`,`campus_id`),
  CONSTRAINT `visitor_logs_campus_id_fk` FOREIGN KEY (`institution_id`, `campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  CONSTRAINT `visitor_logs_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.visitor_logs: ~0 rows (approximately)

-- Dumping structure for table scm-system.welfare_cases
CREATE TABLE IF NOT EXISTS `welfare_cases` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `category` varchar(70) COLLATE utf8mb4_unicode_ci NOT NULL,
  `details` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `opened_on` date NOT NULL,
  `status` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `welfare_cases_institution_id_id_unique` (`institution_id`,`id`),
  KEY `welfare_cases_student_id_fk` (`institution_id`,`student_id`),
  CONSTRAINT `welfare_cases_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  CONSTRAINT `welfare_cases_student_id_fk` FOREIGN KEY (`institution_id`, `student_id`) REFERENCES `students` (`institution_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table scm-system.welfare_cases: ~0 rows (approximately)

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
