-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: Nov 06, 2026 at 09:37 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `scm-system`
--

-- --------------------------------------------------------

--
-- Table structure for table `academic_calendar_events`
--

CREATE TABLE `academic_calendar_events` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `academic_session_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(180) NOT NULL,
  `event_type` varchar(40) NOT NULL,
  `starts_at` datetime NOT NULL,
  `ends_at` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `academic_departments`
--

CREATE TABLE `academic_departments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `campus_id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(32) NOT NULL,
  `name` varchar(160) NOT NULL,
  `category` varchar(40) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `academic_programs`
--

CREATE TABLE `academic_programs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `department_id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(32) NOT NULL,
  `name` varchar(140) NOT NULL,
  `level` varchar(40) NOT NULL,
  `required_credits` decimal(8,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `academic_sessions`
--

CREATE TABLE `academic_sessions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(32) NOT NULL,
  `name` varchar(100) NOT NULL,
  `starts_on` date NOT NULL,
  `ends_on` date NOT NULL,
  `status` enum('planned','active','closed') NOT NULL DEFAULT 'planned',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `academic_terms`
--

CREATE TABLE `academic_terms` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `academic_session_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `starts_on` date NOT NULL,
  `ends_on` date NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `admission_applications`
--

CREATE TABLE `admission_applications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `admission_cycle_id` bigint(20) UNSIGNED NOT NULL,
  `class_level_id` bigint(20) UNSIGNED NOT NULL,
  `application_no` varchar(50) NOT NULL,
  `applicant_name` varchar(180) NOT NULL,
  `guardian_phone` varchar(32) NOT NULL,
  `score` decimal(7,2) DEFAULT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'submitted',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `admission_cycles`
--

CREATE TABLE `admission_cycles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `academic_session_id` bigint(20) UNSIGNED NOT NULL,
  `campus_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(150) NOT NULL,
  `opens_on` date NOT NULL,
  `closes_on` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `admission_offers`
--

CREATE TABLE `admission_offers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `admission_application_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED DEFAULT NULL,
  `offered_on` date NOT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'offered',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `alumni_profiles`
--

CREATE TABLE `alumni_profiles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `graduation_year` int(10) UNSIGNED NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `asset_assignments`
--

CREATE TABLE `asset_assignments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `fixed_asset_id` bigint(20) UNSIGNED NOT NULL,
  `employee_id` bigint(20) UNSIGNED NOT NULL,
  `assigned_on` date NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `assignments`
--

CREATE TABLE `assignments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `class_subject_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(180) NOT NULL,
  `details` text DEFAULT NULL,
  `due_at` datetime NOT NULL,
  `max_marks` decimal(7,2) NOT NULL DEFAULT 100.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `assignment_submissions`
--

CREATE TABLE `assignment_submissions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `assignment_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `submitted_at` datetime NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'submitted',
  `marks` decimal(7,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `attendance_sessions`
--

CREATE TABLE `attendance_sessions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `class_section_id` bigint(20) UNSIGNED NOT NULL,
  `attendance_on` date NOT NULL,
  `period_code` varchar(40) NOT NULL DEFAULT 'daily',
  `status` varchar(24) NOT NULL DEFAULT 'open',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bank_accounts`
--

CREATE TABLE `bank_accounts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `account_id` bigint(20) UNSIGNED NOT NULL,
  `bank_name` varchar(140) NOT NULL,
  `account_mask` varchar(24) NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bank_reconciliations`
--

CREATE TABLE `bank_reconciliations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `bank_account_id` bigint(20) UNSIGNED NOT NULL,
  `statement_on` date NOT NULL,
  `statement_balance` decimal(14,2) NOT NULL,
  `ledger_balance` decimal(14,2) NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `campuses`
--

CREATE TABLE `campuses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(32) NOT NULL,
  `name` varchar(160) NOT NULL,
  `is_main` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `address` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `campus_events`
--

CREATE TABLE `campus_events` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `campus_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(180) NOT NULL,
  `starts_at` datetime NOT NULL,
  `ends_at` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `certificate_templates`
--

CREATE TABLE `certificate_templates` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(50) NOT NULL,
  `name` varchar(150) NOT NULL,
  `template_html` text NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `chart_of_accounts`
--

CREATE TABLE `chart_of_accounts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(32) NOT NULL,
  `name` varchar(140) NOT NULL,
  `account_type` varchar(40) NOT NULL,
  `parent_account_id` bigint(20) UNSIGNED DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `class_levels`
--

CREATE TABLE `class_levels` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `program_id` bigint(20) UNSIGNED DEFAULT NULL,
  `code` varchar(32) NOT NULL,
  `name` varchar(100) NOT NULL,
  `sequence` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `class_routines`
--

CREATE TABLE `class_routines` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `class_section_id` bigint(20) UNSIGNED NOT NULL,
  `class_subject_id` bigint(20) UNSIGNED NOT NULL,
  `day_of_week` varchar(12) NOT NULL,
  `starts_at` time NOT NULL,
  `ends_at` time NOT NULL,
  `room` varchar(50) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `class_sections`
--

CREATE TABLE `class_sections` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `campus_id` bigint(20) UNSIGNED NOT NULL,
  `class_level_id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(32) NOT NULL,
  `name` varchar(80) NOT NULL,
  `shift` varchar(32) NOT NULL DEFAULT 'day',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `class_subjects`
--

CREATE TABLE `class_subjects` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `class_level_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED NOT NULL,
  `academic_session_id` bigint(20) UNSIGNED NOT NULL,
  `is_compulsory` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `course_offerings`
--

CREATE TABLE `course_offerings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `academic_term_id` bigint(20) UNSIGNED NOT NULL,
  `class_section_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED NOT NULL,
  `capacity` int(10) UNSIGNED NOT NULL DEFAULT 30,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `direct_messages`
--

CREATE TABLE `direct_messages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `sender_user_id` bigint(20) UNSIGNED NOT NULL,
  `recipient_user_id` bigint(20) UNSIGNED NOT NULL,
  `body` text NOT NULL,
  `read_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `donations`
--

CREATE TABLE `donations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `donor_id` bigint(20) UNSIGNED NOT NULL,
  `donation_fund_id` bigint(20) UNSIGNED NOT NULL,
  `receipt_no` varchar(60) NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `received_on` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `donation_funds`
--

CREATE TABLE `donation_funds` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(40) NOT NULL,
  `name` varchar(180) NOT NULL,
  `is_restricted` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `donors`
--

CREATE TABLE `donors` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(160) NOT NULL,
  `phone` varchar(40) DEFAULT NULL,
  `email` varchar(160) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `employees`
--

CREATE TABLE `employees` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `campus_id` bigint(20) UNSIGNED NOT NULL,
  `employee_no` varchar(40) NOT NULL,
  `name` varchar(180) NOT NULL,
  `designation` varchar(100) NOT NULL,
  `joined_on` date NOT NULL,
  `basic_salary` decimal(14,2) NOT NULL DEFAULT 0.00,
  `status` varchar(24) NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `enrollments`
--

CREATE TABLE `enrollments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `academic_session_id` bigint(20) UNSIGNED NOT NULL,
  `class_section_id` bigint(20) UNSIGNED NOT NULL,
  `roll_no` varchar(30) NOT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `examinations`
--

CREATE TABLE `examinations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `academic_session_id` bigint(20) UNSIGNED NOT NULL,
  `class_level_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(140) NOT NULL,
  `exam_type` varchar(60) NOT NULL,
  `starts_on` date NOT NULL,
  `ends_on` date NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `exam_marks`
--

CREATE TABLE `exam_marks` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `exam_paper_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `marks` decimal(7,2) NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `exam_papers`
--

CREATE TABLE `exam_papers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `examination_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED NOT NULL,
  `full_marks` decimal(7,2) NOT NULL,
  `pass_marks` decimal(7,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `exam_recheck_requests`
--

CREATE TABLE `exam_recheck_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `exam_mark_id` bigint(20) UNSIGNED NOT NULL,
  `reason` text NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `expenses`
--

CREATE TABLE `expenses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `expense_no` varchar(50) NOT NULL,
  `description` varchar(200) NOT NULL,
  `expense_on` date NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `account_id` bigint(20) UNSIGNED NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fee_heads`
--

CREATE TABLE `fee_heads` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(32) NOT NULL,
  `name` varchar(120) NOT NULL,
  `revenue_account_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fee_plans`
--

CREATE TABLE `fee_plans` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `class_level_id` bigint(20) UNSIGNED NOT NULL,
  `academic_session_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(140) NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fee_plan_lines`
--

CREATE TABLE `fee_plan_lines` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `fee_plan_id` bigint(20) UNSIGNED NOT NULL,
  `fee_head_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `financial_period_closings`
--

CREATE TABLE `financial_period_closings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `academic_session_id` bigint(20) UNSIGNED NOT NULL,
  `closed_on` date NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fixed_assets`
--

CREATE TABLE `fixed_assets` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `asset_tag` varchar(60) NOT NULL,
  `name` varchar(160) NOT NULL,
  `category` varchar(100) NOT NULL,
  `purchased_on` date NOT NULL,
  `purchase_cost` decimal(14,2) NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fund_expenses`
--

CREATE TABLE `fund_expenses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `donation_fund_id` bigint(20) UNSIGNED NOT NULL,
  `approved_by_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `description` varchar(190) NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `spent_on` date NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'approved',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `grading_bands`
--

CREATE TABLE `grading_bands` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `grading_scale_id` bigint(20) UNSIGNED NOT NULL,
  `min_percent` decimal(5,2) NOT NULL,
  `max_percent` decimal(5,2) NOT NULL,
  `letter_grade` varchar(8) NOT NULL,
  `grade_point` decimal(4,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `grading_scales`
--

CREATE TABLE `grading_scales` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(32) NOT NULL,
  `name` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `guardians`
--

CREATE TABLE `guardians` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(180) NOT NULL,
  `relation` varchar(40) NOT NULL,
  `phone` varchar(32) NOT NULL,
  `email` varchar(180) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hifz_assessments`
--

CREATE TABLE `hifz_assessments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `hifz_enrollment_id` bigint(20) UNSIGNED NOT NULL,
  `assessed_on` date NOT NULL,
  `score` decimal(5,2) NOT NULL,
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hifz_enrollments`
--

CREATE TABLE `hifz_enrollments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `hifz_group_id` bigint(20) UNSIGNED NOT NULL,
  `started_on` date NOT NULL,
  `target_juz` int(10) UNSIGNED NOT NULL DEFAULT 30,
  `status` varchar(24) NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hifz_groups`
--

CREATE TABLE `hifz_groups` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `employee_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hifz_progress_logs`
--

CREATE TABLE `hifz_progress_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `hifz_enrollment_id` bigint(20) UNSIGNED NOT NULL,
  `logged_on` date NOT NULL,
  `sabaq` varchar(150) NOT NULL,
  `sabqi` varchar(150) NOT NULL,
  `manzil` varchar(150) NOT NULL,
  `juz_completed` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `accuracy_percent` decimal(5,2) NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hostels`
--

CREATE TABLE `hostels` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `campus_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(140) NOT NULL,
  `category` varchar(40) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hostel_allocations`
--

CREATE TABLE `hostel_allocations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `hostel_bed_id` bigint(20) UNSIGNED NOT NULL,
  `check_in_on` date NOT NULL,
  `monthly_fee` decimal(14,2) NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hostel_beds`
--

CREATE TABLE `hostel_beds` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `hostel_room_id` bigint(20) UNSIGNED NOT NULL,
  `bed_code` varchar(40) NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'available',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hostel_leave_requests`
--

CREATE TABLE `hostel_leave_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `hostel_allocation_id` bigint(20) UNSIGNED NOT NULL,
  `starts_on` date NOT NULL,
  `ends_on` date NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hostel_rooms`
--

CREATE TABLE `hostel_rooms` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `hostel_id` bigint(20) UNSIGNED NOT NULL,
  `room_code` varchar(40) NOT NULL,
  `capacity` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `institutions`
--

CREATE TABLE `institutions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(32) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `name` varchar(200) NOT NULL,
  `type` enum('school','college','madrasha','mixed') NOT NULL,
  `status` enum('draft','active','suspended') NOT NULL DEFAULT 'draft',
  `timezone` varchar(64) NOT NULL DEFAULT 'Asia/Dhaka',
  `locale` varchar(8) NOT NULL DEFAULT 'bn',
  `currency` char(3) NOT NULL DEFAULT 'BDT',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `institutions`
--

INSERT INTO `institutions` (`id`, `code`, `slug`, `name`, `type`, `status`, `timezone`, `locale`, `currency`, `created_at`, `updated_at`, `deleted_at`) VALUES
(2, 'SCHDEMO', 'demo-sunrise-school', 'Sunrise Model School', 'school', 'active', 'Asia/Dhaka', 'bn', 'BDT', '2026-11-05 13:36:00', '2026-11-05 13:36:00', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `institution_memberships`
--

CREATE TABLE `institution_memberships` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `status` enum('invited','active','suspended','revoked') NOT NULL DEFAULT 'invited',
  `can_access_all_campuses` tinyint(1) NOT NULL DEFAULT 0,
  `joined_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `institution_memberships`
--

INSERT INTO `institution_memberships` (`id`, `institution_id`, `user_id`, `status`, `can_access_all_campuses`, `joined_at`, `created_at`, `updated_at`) VALUES
(2, 2, 1, 'active', 1, '2026-11-05 13:36:00', NULL, '2026-11-05 13:36:00');

-- --------------------------------------------------------

--
-- Table structure for table `institution_module_settings`
--

CREATE TABLE `institution_module_settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `module_key` varchar(80) NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT 0,
  `options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`options`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `institution_roles`
--

CREATE TABLE `institution_roles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `key` varchar(80) NOT NULL,
  `name` varchar(120) NOT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `institution_roles`
--

INSERT INTO `institution_roles` (`id`, `institution_id`, `key`, `name`, `is_system`, `created_at`, `updated_at`) VALUES
(2, 2, 'admin', 'Administrator', 1, '2026-11-05 13:36:00', '2026-11-05 13:36:00');

-- --------------------------------------------------------

--
-- Table structure for table `institution_role_permissions`
--

CREATE TABLE `institution_role_permissions` (
  `role_id` bigint(20) UNSIGNED NOT NULL,
  `permission_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `institution_role_permissions`
--

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

-- --------------------------------------------------------

--
-- Table structure for table `integration_connections`
--

CREATE TABLE `integration_connections` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `provider` varchar(100) NOT NULL,
  `category` varchar(60) NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'disabled',
  `configuration` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`configuration`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `integration_logs`
--

CREATE TABLE `integration_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `integration_connection_id` bigint(20) UNSIGNED NOT NULL,
  `event_name` varchar(140) NOT NULL,
  `status` varchar(32) NOT NULL,
  `logged_at` datetime NOT NULL,
  `external_reference` varchar(140) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory_items`
--

CREATE TABLE `inventory_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `sku` varchar(60) NOT NULL,
  `name` varchar(180) NOT NULL,
  `unit` varchar(32) NOT NULL,
  `reorder_level` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `issued_certificates`
--

CREATE TABLE `issued_certificates` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `certificate_template_id` bigint(20) UNSIGNED NOT NULL,
  `certificate_no` varchar(65) NOT NULL,
  `issued_on` date NOT NULL,
  `verification_token` varchar(100) NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'issued',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ledger_journals`
--

CREATE TABLE `ledger_journals` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `journal_no` varchar(50) NOT NULL,
  `posted_on` date NOT NULL,
  `source_type` varchar(60) NOT NULL,
  `source_reference` varchar(70) DEFAULT NULL,
  `description` varchar(220) NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'posted',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ledger_lines`
--

CREATE TABLE `ledger_lines` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `ledger_journal_id` bigint(20) UNSIGNED NOT NULL,
  `account_id` bigint(20) UNSIGNED NOT NULL,
  `debit` decimal(14,2) NOT NULL DEFAULT 0.00,
  `credit` decimal(14,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lesson_plans`
--

CREATE TABLE `lesson_plans` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `class_subject_id` bigint(20) UNSIGNED NOT NULL,
  `lesson_date` date NOT NULL,
  `topic` varchar(180) NOT NULL,
  `completion_percent` decimal(5,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `library_books`
--

CREATE TABLE `library_books` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `isbn` varchar(32) DEFAULT NULL,
  `title` varchar(220) NOT NULL,
  `author` varchar(160) NOT NULL,
  `category` varchar(80) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `library_copies`
--

CREATE TABLE `library_copies` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `library_book_id` bigint(20) UNSIGNED NOT NULL,
  `barcode` varchar(64) NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'available',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `library_loans`
--

CREATE TABLE `library_loans` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `library_copy_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `issued_on` date NOT NULL,
  `due_on` date NOT NULL,
  `returned_on` date DEFAULT NULL,
  `fine_amount` decimal(14,2) NOT NULL DEFAULT 0.00,
  `status` varchar(24) NOT NULL DEFAULT 'issued',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lms_resources`
--

CREATE TABLE `lms_resources` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `class_subject_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(180) NOT NULL,
  `resource_type` varchar(40) NOT NULL,
  `resource_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `meal_plans`
--

CREATE TABLE `meal_plans` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `hostel_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(120) NOT NULL,
  `monthly_rate` decimal(14,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `membership_campuses`
--

CREATE TABLE `membership_campuses` (
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `membership_id` bigint(20) UNSIGNED NOT NULL,
  `campus_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `membership_roles`
--

CREATE TABLE `membership_roles` (
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `membership_id` bigint(20) UNSIGNED NOT NULL,
  `role_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `membership_roles`
--

INSERT INTO `membership_roles` (`institution_id`, `membership_id`, `role_id`, `created_at`) VALUES
(2, 2, 2, '2026-11-05 13:36:00');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_11_04_000001_create_sms_core_tables', 1),
(5, '2026_11_05_000002_create_sms_domain_tables', 1),
(6, '2026_11_05_000003_add_sms_domain_business_keys', 1);

-- --------------------------------------------------------

--
-- Table structure for table `notices`
--

CREATE TABLE `notices` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(180) NOT NULL,
  `body` text NOT NULL,
  `audience` varchar(50) NOT NULL,
  `published_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notification_deliveries`
--

CREATE TABLE `notification_deliveries` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `notification_template_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED DEFAULT NULL,
  `recipient` varchar(160) NOT NULL,
  `channel` varchar(32) NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'queued',
  `sent_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notification_templates`
--

CREATE TABLE `notification_templates` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(50) NOT NULL,
  `channel` varchar(32) NOT NULL,
  `body` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `parent_meetings`
--

CREATE TABLE `parent_meetings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `employee_id` bigint(20) UNSIGNED NOT NULL,
  `scheduled_at` datetime NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'requested',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payment_allocations`
--

CREATE TABLE `payment_allocations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_payment_id` bigint(20) UNSIGNED NOT NULL,
  `student_invoice_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payment_methods`
--

CREATE TABLE `payment_methods` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(32) NOT NULL,
  `name` varchar(120) NOT NULL,
  `method_type` varchar(40) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payment_refunds`
--

CREATE TABLE `payment_refunds` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_payment_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `reason` text NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'requested',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payroll_runs`
--

CREATE TABLE `payroll_runs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payslips`
--

CREATE TABLE `payslips` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `payroll_run_id` bigint(20) UNSIGNED NOT NULL,
  `employee_id` bigint(20) UNSIGNED NOT NULL,
  `gross_amount` decimal(14,2) NOT NULL,
  `deduction_amount` decimal(14,2) NOT NULL DEFAULT 0.00,
  `net_amount` decimal(14,2) NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payslip_items`
--

CREATE TABLE `payslip_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `payslip_id` bigint(20) UNSIGNED NOT NULL,
  `item_type` varchar(32) NOT NULL,
  `description` varchar(140) NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `platform_admin_users`
--

CREATE TABLE `platform_admin_users` (
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `granted_by_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `published_results`
--

CREATE TABLE `published_results` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `examination_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `percentage` decimal(5,2) NOT NULL,
  `gpa` decimal(4,2) NOT NULL,
  `result` varchar(20) NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `purchase_orders`
--

CREATE TABLE `purchase_orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `supplier_id` bigint(20) UNSIGNED NOT NULL,
  `po_number` varchar(60) NOT NULL,
  `ordered_on` date NOT NULL,
  `total_amount` decimal(14,2) NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `purchase_order_lines`
--

CREATE TABLE `purchase_order_lines` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `purchase_order_id` bigint(20) UNSIGNED NOT NULL,
  `inventory_item_id` bigint(20) UNSIGNED NOT NULL,
  `quantity` int(10) UNSIGNED NOT NULL,
  `unit_price` decimal(14,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `report_exports`
--

CREATE TABLE `report_exports` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `report_key` varchar(100) NOT NULL,
  `requested_at` datetime NOT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `room_bookings`
--

CREATE TABLE `room_bookings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `campus_id` bigint(20) UNSIGNED NOT NULL,
  `booked_by_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `room_name` varchar(100) NOT NULL,
  `starts_at` datetime NOT NULL,
  `ends_at` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `scholarships`
--

CREATE TABLE `scholarships` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(160) NOT NULL,
  `criteria` text DEFAULT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `scholarship_awards`
--

CREATE TABLE `scholarship_awards` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `scholarship_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'approved',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sms_audit_logs`
--

CREATE TABLE `sms_audit_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED DEFAULT NULL,
  `actor_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `resource_type` varchar(120) NOT NULL,
  `resource_id` varchar(80) DEFAULT NULL,
  `before_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`before_data`)),
  `after_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`after_data`)),
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `request_id` varchar(40) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sms_idempotency_records`
--

CREATE TABLE `sms_idempotency_records` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `operation` varchar(60) NOT NULL,
  `idempotency_key` varchar(160) NOT NULL,
  `request_sha256` char(64) NOT NULL,
  `status` enum('processing','completed','failed') NOT NULL DEFAULT 'processing',
  `response_status` smallint(5) UNSIGNED DEFAULT NULL,
  `response_body` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`response_body`)),
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sms_outbox_events`
--

CREATE TABLE `sms_outbox_events` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `event_type` varchar(120) NOT NULL,
  `aggregate_type` varchar(100) NOT NULL,
  `aggregate_id` varchar(80) NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`payload`)),
  `status` enum('pending','processing','completed','failed') NOT NULL DEFAULT 'pending',
  `attempts` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `available_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `processed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sms_permissions`
--

CREATE TABLE `sms_permissions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `key` varchar(120) NOT NULL,
  `module` varchar(80) NOT NULL,
  `label` varchar(160) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sms_permissions`
--

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

-- --------------------------------------------------------

--
-- Table structure for table `staff_appraisals`
--

CREATE TABLE `staff_appraisals` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `employee_id` bigint(20) UNSIGNED NOT NULL,
  `reviewed_on` date NOT NULL,
  `score` decimal(5,2) NOT NULL,
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `staff_attendance`
--

CREATE TABLE `staff_attendance` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `employee_id` bigint(20) UNSIGNED NOT NULL,
  `attendance_on` date NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'present',
  `check_in_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `staff_leave_requests`
--

CREATE TABLE `staff_leave_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `employee_id` bigint(20) UNSIGNED NOT NULL,
  `starts_on` date NOT NULL,
  `ends_on` date NOT NULL,
  `reason` text NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `stock_movements`
--

CREATE TABLE `stock_movements` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `inventory_item_id` bigint(20) UNSIGNED NOT NULL,
  `quantity` int(11) NOT NULL,
  `movement_type` varchar(30) NOT NULL,
  `reference_no` varchar(70) NOT NULL,
  `moved_on` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `campus_id` bigint(20) UNSIGNED NOT NULL,
  `admission_no` varchar(40) NOT NULL,
  `name` varchar(180) NOT NULL,
  `gender` varchar(20) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `blood_group` varchar(8) DEFAULT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_attendance`
--

CREATE TABLE `student_attendance` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `attendance_session_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `status` varchar(16) NOT NULL DEFAULT 'present',
  `minutes_late` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_documents`
--

CREATE TABLE `student_documents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `document_type` varchar(60) NOT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `verification_status` varchar(32) NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_guardians`
--

CREATE TABLE `student_guardians` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `guardian_id` bigint(20) UNSIGNED NOT NULL,
  `relationship` varchar(32) NOT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_health_records`
--

CREATE TABLE `student_health_records` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `allergies` text DEFAULT NULL,
  `medical_notes` text DEFAULT NULL,
  `emergency_contact` varchar(32) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_incidents`
--

CREATE TABLE `student_incidents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `occurred_on` date NOT NULL,
  `category` varchar(60) NOT NULL,
  `details` text NOT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'open',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_invoices`
--

CREATE TABLE `student_invoices` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `invoice_no` varchar(50) NOT NULL,
  `issued_on` date NOT NULL,
  `due_on` date NOT NULL,
  `total_amount` decimal(14,2) NOT NULL,
  `paid_amount` decimal(14,2) NOT NULL DEFAULT 0.00,
  `status` varchar(24) NOT NULL DEFAULT 'unpaid',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_invoice_lines`
--

CREATE TABLE `student_invoice_lines` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_invoice_id` bigint(20) UNSIGNED NOT NULL,
  `fee_head_id` bigint(20) UNSIGNED NOT NULL,
  `description` varchar(180) NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_leave_requests`
--

CREATE TABLE `student_leave_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `starts_on` date NOT NULL,
  `ends_on` date NOT NULL,
  `reason` text NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_payments`
--

CREATE TABLE `student_payments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `student_invoice_id` bigint(20) UNSIGNED NOT NULL,
  `payment_method_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `paid_on` date NOT NULL,
  `reference_no` varchar(100) NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'posted',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_promotions`
--

CREATE TABLE `student_promotions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `from_enrollment_id` bigint(20) UNSIGNED NOT NULL,
  `to_enrollment_id` bigint(20) UNSIGNED DEFAULT NULL,
  `promoted_on` date NOT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_transfers`
--

CREATE TABLE `student_transfers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `from_campus_id` bigint(20) UNSIGNED NOT NULL,
  `to_campus_id` bigint(20) UNSIGNED DEFAULT NULL,
  `transferred_on` date NOT NULL,
  `reason` text NOT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'requested',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_transport_assignments`
--

CREATE TABLE `student_transport_assignments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `transport_route_id` bigint(20) UNSIGNED NOT NULL,
  `transport_stop_id` bigint(20) UNSIGNED NOT NULL,
  `starts_on` date NOT NULL,
  `monthly_fee` decimal(14,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `subjects`
--

CREATE TABLE `subjects` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `department_id` bigint(20) UNSIGNED DEFAULT NULL,
  `code` varchar(32) NOT NULL,
  `name` varchar(140) NOT NULL,
  `credit_hours` decimal(6,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `suppliers`
--

CREATE TABLE `suppliers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(180) NOT NULL,
  `phone` varchar(40) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `teacher_assignments`
--

CREATE TABLE `teacher_assignments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `employee_id` bigint(20) UNSIGNED NOT NULL,
  `class_subject_id` bigint(20) UNSIGNED NOT NULL,
  `academic_session_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `transport_routes`
--

CREATE TABLE `transport_routes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `vehicle_id` bigint(20) UNSIGNED NOT NULL,
  `employee_id` bigint(20) UNSIGNED DEFAULT NULL,
  `route_name` varchar(150) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `transport_stops`
--

CREATE TABLE `transport_stops` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `transport_route_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(140) NOT NULL,
  `stop_order` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'School Administrator', 'admin.school@example.test', NULL, '$2y$12$u3D.U92fSw9Esm0uIJGkjuFOzYFOtsvOf.76TkINZjt/h1UPIROwW', NULL, '2026-11-05 13:16:57', '2026-11-05 13:16:57'),
(2, 'Teacher Nabila', 'teacher.school@example.test', '2026-11-05 02:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 02:00:00', '2026-11-05 02:00:00'),
(3, 'Accounts Officer', 'accounts.school@example.test', '2026-11-05 02:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 02:00:00', '2026-11-05 02:00:00'),
(4, 'Demo Parent', 'parent.school@example.test', '2026-11-05 02:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 02:00:00', '2026-11-05 02:00:00'),
(5, 'Student Ayesha', 'student.school@example.test', '2026-11-05 02:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 02:00:00', '2026-11-05 02:00:00'),
(6, 'College Administrator', 'admin.college@example.test', '2026-11-05 02:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 02:00:00', '2026-11-05 02:00:00'),
(7, 'Madrasha Administrator', 'admin.madrasha@example.test', '2026-11-05 02:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 02:00:00', '2026-11-05 02:00:00'),
(8, 'Ustad Mahmud', 'ustad.madrasha@example.test', '2026-11-05 02:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 02:00:00', '2026-11-05 02:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `vehicles`
--

CREATE TABLE `vehicles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `vehicle_code` varchar(40) NOT NULL,
  `plate_number` varchar(60) NOT NULL,
  `seats` int(10) UNSIGNED NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `visitor_logs`
--

CREATE TABLE `visitor_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `campus_id` bigint(20) UNSIGNED NOT NULL,
  `visitor_name` varchar(180) NOT NULL,
  `purpose` varchar(150) NOT NULL,
  `checked_in_at` datetime NOT NULL,
  `checked_out_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `welfare_cases`
--

CREATE TABLE `welfare_cases` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `institution_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `category` varchar(70) NOT NULL,
  `details` text NOT NULL,
  `opened_on` date NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'open',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `academic_calendar_events`
--
ALTER TABLE `academic_calendar_events`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `academic_calendar_events_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `academic_calendar_events_academic_session_id_fk` (`institution_id`,`academic_session_id`);

--
-- Indexes for table `academic_departments`
--
ALTER TABLE `academic_departments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `academic_departments_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_academic_departments_uniq` (`institution_id`,`code`),
  ADD KEY `academic_departments_campus_id_fk` (`institution_id`,`campus_id`);

--
-- Indexes for table `academic_programs`
--
ALTER TABLE `academic_programs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `academic_programs_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_academic_programs_uniq` (`institution_id`,`code`),
  ADD KEY `academic_programs_department_id_fk` (`institution_id`,`department_id`);

--
-- Indexes for table `academic_sessions`
--
ALTER TABLE `academic_sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `academic_sessions_institution_id_code_unique` (`institution_id`,`code`),
  ADD UNIQUE KEY `academic_sessions_institution_id_id_unique` (`institution_id`,`id`);

--
-- Indexes for table `academic_terms`
--
ALTER TABLE `academic_terms`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `academic_terms_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `academic_terms_academic_session_id_fk` (`institution_id`,`academic_session_id`);

--
-- Indexes for table `admission_applications`
--
ALTER TABLE `admission_applications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `admission_applications_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_admission_applications_uniq` (`institution_id`,`application_no`),
  ADD KEY `admission_applications_admission_cycle_id_fk` (`institution_id`,`admission_cycle_id`),
  ADD KEY `admission_applications_class_level_id_fk` (`institution_id`,`class_level_id`);

--
-- Indexes for table `admission_cycles`
--
ALTER TABLE `admission_cycles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `admission_cycles_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `admission_cycles_academic_session_id_fk` (`institution_id`,`academic_session_id`),
  ADD KEY `admission_cycles_campus_id_fk` (`institution_id`,`campus_id`);

--
-- Indexes for table `admission_offers`
--
ALTER TABLE `admission_offers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `admission_offers_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `admission_offers_admission_application_id_fk` (`institution_id`,`admission_application_id`),
  ADD KEY `admission_offers_student_id_fk` (`institution_id`,`student_id`);

--
-- Indexes for table `alumni_profiles`
--
ALTER TABLE `alumni_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `alumni_profiles_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `alumni_profiles_student_id_fk` (`institution_id`,`student_id`);

--
-- Indexes for table `asset_assignments`
--
ALTER TABLE `asset_assignments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `asset_assignments_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_asset_assignments_combo_uniq` (`institution_id`,`fixed_asset_id`,`employee_id`,`assigned_on`),
  ADD KEY `asset_assignments_employee_id_fk` (`institution_id`,`employee_id`);

--
-- Indexes for table `assignments`
--
ALTER TABLE `assignments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `assignments_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `assignments_class_subject_id_fk` (`institution_id`,`class_subject_id`);

--
-- Indexes for table `assignment_submissions`
--
ALTER TABLE `assignment_submissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `assignment_submissions_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `assignment_submissions_assignment_id_fk` (`institution_id`,`assignment_id`),
  ADD KEY `assignment_submissions_student_id_fk` (`institution_id`,`student_id`);

--
-- Indexes for table `attendance_sessions`
--
ALTER TABLE `attendance_sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `attendance_sessions_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `attendance_sessions_class_section_id_fk` (`institution_id`,`class_section_id`);

--
-- Indexes for table `bank_accounts`
--
ALTER TABLE `bank_accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `bank_accounts_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `bank_accounts_account_id_fk` (`institution_id`,`account_id`);

--
-- Indexes for table `bank_reconciliations`
--
ALTER TABLE `bank_reconciliations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `bank_reconciliations_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `bank_reconciliations_bank_account_id_fk` (`institution_id`,`bank_account_id`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indexes for table `campuses`
--
ALTER TABLE `campuses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `campuses_institution_id_code_unique` (`institution_id`,`code`),
  ADD UNIQUE KEY `campuses_institution_id_id_unique` (`institution_id`,`id`);

--
-- Indexes for table `campus_events`
--
ALTER TABLE `campus_events`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `campus_events_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `campus_events_campus_id_fk` (`institution_id`,`campus_id`);

--
-- Indexes for table `certificate_templates`
--
ALTER TABLE `certificate_templates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `certificate_templates_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_certificate_templates_uniq` (`institution_id`,`code`);

--
-- Indexes for table `chart_of_accounts`
--
ALTER TABLE `chart_of_accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `chart_of_accounts_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_chart_of_accounts_uniq` (`institution_id`,`code`),
  ADD KEY `chart_of_accounts_parent_account_id_fk` (`institution_id`,`parent_account_id`);

--
-- Indexes for table `class_levels`
--
ALTER TABLE `class_levels`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `class_levels_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_class_levels_uniq` (`institution_id`,`code`),
  ADD KEY `class_levels_program_id_fk` (`institution_id`,`program_id`);

--
-- Indexes for table `class_routines`
--
ALTER TABLE `class_routines`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `class_routines_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `class_routines_class_section_id_fk` (`institution_id`,`class_section_id`),
  ADD KEY `class_routines_class_subject_id_fk` (`institution_id`,`class_subject_id`);

--
-- Indexes for table `class_sections`
--
ALTER TABLE `class_sections`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `class_sections_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_class_sections_uniq` (`institution_id`,`class_level_id`,`code`),
  ADD KEY `class_sections_campus_id_fk` (`institution_id`,`campus_id`);

--
-- Indexes for table `class_subjects`
--
ALTER TABLE `class_subjects`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `class_subjects_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `class_subjects_class_level_id_fk` (`institution_id`,`class_level_id`),
  ADD KEY `class_subjects_subject_id_fk` (`institution_id`,`subject_id`),
  ADD KEY `class_subjects_academic_session_id_fk` (`institution_id`,`academic_session_id`);

--
-- Indexes for table `course_offerings`
--
ALTER TABLE `course_offerings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `course_offerings_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `course_offerings_academic_term_id_fk` (`institution_id`,`academic_term_id`),
  ADD KEY `course_offerings_class_section_id_fk` (`institution_id`,`class_section_id`),
  ADD KEY `course_offerings_subject_id_fk` (`institution_id`,`subject_id`);

--
-- Indexes for table `direct_messages`
--
ALTER TABLE `direct_messages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `direct_messages_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `direct_messages_sender_user_id_fk` (`sender_user_id`),
  ADD KEY `direct_messages_recipient_user_id_fk` (`recipient_user_id`);

--
-- Indexes for table `donations`
--
ALTER TABLE `donations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `donations_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_donations_uniq` (`institution_id`,`receipt_no`),
  ADD KEY `donations_donor_id_fk` (`institution_id`,`donor_id`),
  ADD KEY `sms_donations_idx` (`institution_id`,`donation_fund_id`,`received_on`);

--
-- Indexes for table `donation_funds`
--
ALTER TABLE `donation_funds`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `donation_funds_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_donation_funds_uniq` (`institution_id`,`code`);

--
-- Indexes for table `donors`
--
ALTER TABLE `donors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `donors_institution_id_id_unique` (`institution_id`,`id`);

--
-- Indexes for table `employees`
--
ALTER TABLE `employees`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `employees_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_employees_uniq` (`institution_id`,`employee_no`),
  ADD KEY `employees_user_id_fk` (`user_id`),
  ADD KEY `employees_campus_id_fk` (`institution_id`,`campus_id`);

--
-- Indexes for table `enrollments`
--
ALTER TABLE `enrollments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `enrollments_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `enrollments_student_id_fk` (`institution_id`,`student_id`),
  ADD KEY `enrollments_class_section_id_fk` (`institution_id`,`class_section_id`),
  ADD KEY `sms_enrollments_idx` (`institution_id`,`academic_session_id`,`class_section_id`);

--
-- Indexes for table `examinations`
--
ALTER TABLE `examinations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `examinations_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `examinations_academic_session_id_fk` (`institution_id`,`academic_session_id`),
  ADD KEY `examinations_class_level_id_fk` (`institution_id`,`class_level_id`);

--
-- Indexes for table `exam_marks`
--
ALTER TABLE `exam_marks`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `exam_marks_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_exam_marks_combo_uniq` (`institution_id`,`exam_paper_id`,`student_id`),
  ADD KEY `sms_exam_marks_idx` (`institution_id`,`student_id`,`status`);

--
-- Indexes for table `exam_papers`
--
ALTER TABLE `exam_papers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `exam_papers_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `exam_papers_examination_id_fk` (`institution_id`,`examination_id`),
  ADD KEY `exam_papers_subject_id_fk` (`institution_id`,`subject_id`);

--
-- Indexes for table `exam_recheck_requests`
--
ALTER TABLE `exam_recheck_requests`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `exam_recheck_requests_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `exam_recheck_requests_exam_mark_id_fk` (`institution_id`,`exam_mark_id`);

--
-- Indexes for table `expenses`
--
ALTER TABLE `expenses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `expenses_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `expenses_account_id_fk` (`institution_id`,`account_id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `fee_heads`
--
ALTER TABLE `fee_heads`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `fee_heads_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_fee_heads_uniq` (`institution_id`,`code`),
  ADD KEY `fee_heads_revenue_account_id_fk` (`institution_id`,`revenue_account_id`);

--
-- Indexes for table `fee_plans`
--
ALTER TABLE `fee_plans`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `fee_plans_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `fee_plans_class_level_id_fk` (`institution_id`,`class_level_id`),
  ADD KEY `fee_plans_academic_session_id_fk` (`institution_id`,`academic_session_id`);

--
-- Indexes for table `fee_plan_lines`
--
ALTER TABLE `fee_plan_lines`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `fee_plan_lines_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_fee_plan_lines_combo_uniq` (`institution_id`,`fee_plan_id`,`fee_head_id`),
  ADD KEY `fee_plan_lines_fee_head_id_fk` (`institution_id`,`fee_head_id`);

--
-- Indexes for table `financial_period_closings`
--
ALTER TABLE `financial_period_closings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `financial_period_closings_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_financial_period_closings_uniq` (`institution_id`,`academic_session_id`);

--
-- Indexes for table `fixed_assets`
--
ALTER TABLE `fixed_assets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `fixed_assets_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_fixed_assets_uniq` (`institution_id`,`asset_tag`);

--
-- Indexes for table `fund_expenses`
--
ALTER TABLE `fund_expenses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `fund_expenses_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `fund_expenses_donation_fund_id_fk` (`institution_id`,`donation_fund_id`),
  ADD KEY `fund_expenses_approved_by_user_id_fk` (`approved_by_user_id`);

--
-- Indexes for table `grading_bands`
--
ALTER TABLE `grading_bands`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `grading_bands_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `grading_bands_grading_scale_id_fk` (`institution_id`,`grading_scale_id`);

--
-- Indexes for table `grading_scales`
--
ALTER TABLE `grading_scales`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `grading_scales_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_grading_scales_uniq` (`institution_id`,`code`);

--
-- Indexes for table `guardians`
--
ALTER TABLE `guardians`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `guardians_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `guardians_user_id_fk` (`user_id`);

--
-- Indexes for table `hifz_assessments`
--
ALTER TABLE `hifz_assessments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `hifz_assessments_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `hifz_assessments_hifz_enrollment_id_fk` (`institution_id`,`hifz_enrollment_id`);

--
-- Indexes for table `hifz_enrollments`
--
ALTER TABLE `hifz_enrollments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `hifz_enrollments_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `hifz_enrollments_student_id_fk` (`institution_id`,`student_id`),
  ADD KEY `hifz_enrollments_hifz_group_id_fk` (`institution_id`,`hifz_group_id`);

--
-- Indexes for table `hifz_groups`
--
ALTER TABLE `hifz_groups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `hifz_groups_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `hifz_groups_employee_id_fk` (`institution_id`,`employee_id`);

--
-- Indexes for table `hifz_progress_logs`
--
ALTER TABLE `hifz_progress_logs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `hifz_progress_logs_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `sms_hifz_progress_logs_idx` (`institution_id`,`hifz_enrollment_id`,`logged_on`);

--
-- Indexes for table `hostels`
--
ALTER TABLE `hostels`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `hostels_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `hostels_campus_id_fk` (`institution_id`,`campus_id`);

--
-- Indexes for table `hostel_allocations`
--
ALTER TABLE `hostel_allocations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `hostel_allocations_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `hostel_allocations_student_id_fk` (`institution_id`,`student_id`),
  ADD KEY `hostel_allocations_hostel_bed_id_fk` (`institution_id`,`hostel_bed_id`);

--
-- Indexes for table `hostel_beds`
--
ALTER TABLE `hostel_beds`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `hostel_beds_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_hostel_beds_uniq` (`institution_id`,`hostel_room_id`,`bed_code`);

--
-- Indexes for table `hostel_leave_requests`
--
ALTER TABLE `hostel_leave_requests`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `hostel_leave_requests_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `hostel_leave_requests_hostel_allocation_id_fk` (`institution_id`,`hostel_allocation_id`);

--
-- Indexes for table `hostel_rooms`
--
ALTER TABLE `hostel_rooms`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `hostel_rooms_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_hostel_rooms_uniq` (`institution_id`,`hostel_id`,`room_code`);

--
-- Indexes for table `institutions`
--
ALTER TABLE `institutions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `institutions_code_unique` (`code`),
  ADD UNIQUE KEY `institutions_slug_unique` (`slug`);

--
-- Indexes for table `institution_memberships`
--
ALTER TABLE `institution_memberships`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `institution_memberships_institution_id_user_id_unique` (`institution_id`,`user_id`),
  ADD UNIQUE KEY `institution_memberships_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `institution_memberships_user_id_foreign` (`user_id`);

--
-- Indexes for table `institution_module_settings`
--
ALTER TABLE `institution_module_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `institution_module_settings_institution_id_module_key_unique` (`institution_id`,`module_key`);

--
-- Indexes for table `institution_roles`
--
ALTER TABLE `institution_roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `institution_roles_institution_id_key_unique` (`institution_id`,`key`),
  ADD UNIQUE KEY `institution_roles_institution_id_id_unique` (`institution_id`,`id`);

--
-- Indexes for table `institution_role_permissions`
--
ALTER TABLE `institution_role_permissions`
  ADD PRIMARY KEY (`role_id`,`permission_id`),
  ADD KEY `institution_role_permissions_permission_id_foreign` (`permission_id`);

--
-- Indexes for table `integration_connections`
--
ALTER TABLE `integration_connections`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `integration_connections_institution_id_id_unique` (`institution_id`,`id`);

--
-- Indexes for table `integration_logs`
--
ALTER TABLE `integration_logs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `integration_logs_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `integration_logs_integration_connection_id_fk` (`institution_id`,`integration_connection_id`),
  ADD KEY `sms_integration_logs_idx` (`institution_id`,`status`,`logged_at`);

--
-- Indexes for table `inventory_items`
--
ALTER TABLE `inventory_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `inventory_items_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_inventory_items_uniq` (`institution_id`,`sku`);

--
-- Indexes for table `issued_certificates`
--
ALTER TABLE `issued_certificates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `issued_certificates_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_issued_certificates_uniq` (`institution_id`,`certificate_no`),
  ADD KEY `issued_certificates_student_id_fk` (`institution_id`,`student_id`),
  ADD KEY `issued_certificates_certificate_template_id_fk` (`institution_id`,`certificate_template_id`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ledger_journals`
--
ALTER TABLE `ledger_journals`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ledger_journals_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_ledger_journals_uniq` (`institution_id`,`journal_no`),
  ADD KEY `sms_ledger_journals_idx` (`institution_id`,`posted_on`,`status`);

--
-- Indexes for table `ledger_lines`
--
ALTER TABLE `ledger_lines`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ledger_lines_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `ledger_lines_ledger_journal_id_fk` (`institution_id`,`ledger_journal_id`),
  ADD KEY `ledger_lines_account_id_fk` (`institution_id`,`account_id`);

--
-- Indexes for table `lesson_plans`
--
ALTER TABLE `lesson_plans`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `lesson_plans_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `lesson_plans_class_subject_id_fk` (`institution_id`,`class_subject_id`);

--
-- Indexes for table `library_books`
--
ALTER TABLE `library_books`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `library_books_institution_id_id_unique` (`institution_id`,`id`);

--
-- Indexes for table `library_copies`
--
ALTER TABLE `library_copies`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `library_copies_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_library_copies_uniq` (`institution_id`,`barcode`),
  ADD KEY `library_copies_library_book_id_fk` (`institution_id`,`library_book_id`);

--
-- Indexes for table `library_loans`
--
ALTER TABLE `library_loans`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `library_loans_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `library_loans_library_copy_id_fk` (`institution_id`,`library_copy_id`),
  ADD KEY `library_loans_student_id_fk` (`institution_id`,`student_id`);

--
-- Indexes for table `lms_resources`
--
ALTER TABLE `lms_resources`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `lms_resources_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `lms_resources_class_subject_id_fk` (`institution_id`,`class_subject_id`);

--
-- Indexes for table `meal_plans`
--
ALTER TABLE `meal_plans`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `meal_plans_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `meal_plans_hostel_id_fk` (`institution_id`,`hostel_id`);

--
-- Indexes for table `membership_campuses`
--
ALTER TABLE `membership_campuses`
  ADD PRIMARY KEY (`institution_id`,`membership_id`,`campus_id`),
  ADD KEY `mc_campus_fk` (`institution_id`,`campus_id`);

--
-- Indexes for table `membership_roles`
--
ALTER TABLE `membership_roles`
  ADD PRIMARY KEY (`institution_id`,`membership_id`,`role_id`),
  ADD KEY `mr_role_fk` (`institution_id`,`role_id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notices`
--
ALTER TABLE `notices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `notices_institution_id_id_unique` (`institution_id`,`id`);

--
-- Indexes for table `notification_deliveries`
--
ALTER TABLE `notification_deliveries`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `notification_deliveries_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `notification_deliveries_notification_template_id_fk` (`institution_id`,`notification_template_id`),
  ADD KEY `notification_deliveries_student_id_fk` (`institution_id`,`student_id`),
  ADD KEY `sms_notification_deliveries_idx` (`institution_id`,`status`,`sent_at`);

--
-- Indexes for table `notification_templates`
--
ALTER TABLE `notification_templates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `notification_templates_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_notification_templates_uniq` (`institution_id`,`code`);

--
-- Indexes for table `parent_meetings`
--
ALTER TABLE `parent_meetings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `parent_meetings_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `parent_meetings_student_id_fk` (`institution_id`,`student_id`),
  ADD KEY `parent_meetings_employee_id_fk` (`institution_id`,`employee_id`);

--
-- Indexes for table `payment_allocations`
--
ALTER TABLE `payment_allocations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `payment_allocations_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_payment_allocations_combo_uniq` (`institution_id`,`student_payment_id`,`student_invoice_id`),
  ADD KEY `payment_allocations_student_invoice_id_fk` (`institution_id`,`student_invoice_id`);

--
-- Indexes for table `payment_methods`
--
ALTER TABLE `payment_methods`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `payment_methods_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_payment_methods_uniq` (`institution_id`,`code`);

--
-- Indexes for table `payment_refunds`
--
ALTER TABLE `payment_refunds`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `payment_refunds_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `payment_refunds_student_payment_id_fk` (`institution_id`,`student_payment_id`);

--
-- Indexes for table `payroll_runs`
--
ALTER TABLE `payroll_runs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `payroll_runs_institution_id_id_unique` (`institution_id`,`id`);

--
-- Indexes for table `payslips`
--
ALTER TABLE `payslips`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `payslips_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `payslips_payroll_run_id_fk` (`institution_id`,`payroll_run_id`),
  ADD KEY `payslips_employee_id_fk` (`institution_id`,`employee_id`);

--
-- Indexes for table `payslip_items`
--
ALTER TABLE `payslip_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `payslip_items_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `payslip_items_payslip_id_fk` (`institution_id`,`payslip_id`);

--
-- Indexes for table `platform_admin_users`
--
ALTER TABLE `platform_admin_users`
  ADD PRIMARY KEY (`user_id`),
  ADD KEY `platform_admin_users_granted_by_user_id_foreign` (`granted_by_user_id`);

--
-- Indexes for table `published_results`
--
ALTER TABLE `published_results`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `published_results_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_published_results_combo_uniq` (`institution_id`,`examination_id`,`student_id`),
  ADD KEY `published_results_student_id_fk` (`institution_id`,`student_id`);

--
-- Indexes for table `purchase_orders`
--
ALTER TABLE `purchase_orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `purchase_orders_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_purchase_orders_uniq` (`institution_id`,`po_number`),
  ADD KEY `purchase_orders_supplier_id_fk` (`institution_id`,`supplier_id`);

--
-- Indexes for table `purchase_order_lines`
--
ALTER TABLE `purchase_order_lines`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `purchase_order_lines_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `purchase_order_lines_purchase_order_id_fk` (`institution_id`,`purchase_order_id`),
  ADD KEY `purchase_order_lines_inventory_item_id_fk` (`institution_id`,`inventory_item_id`);

--
-- Indexes for table `report_exports`
--
ALTER TABLE `report_exports`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `report_exports_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `report_exports_user_id_fk` (`user_id`);

--
-- Indexes for table `room_bookings`
--
ALTER TABLE `room_bookings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `room_bookings_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `room_bookings_campus_id_fk` (`institution_id`,`campus_id`),
  ADD KEY `room_bookings_booked_by_user_id_fk` (`booked_by_user_id`);

--
-- Indexes for table `scholarships`
--
ALTER TABLE `scholarships`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `scholarships_institution_id_id_unique` (`institution_id`,`id`);

--
-- Indexes for table `scholarship_awards`
--
ALTER TABLE `scholarship_awards`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `scholarship_awards_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `scholarship_awards_scholarship_id_fk` (`institution_id`,`scholarship_id`),
  ADD KEY `scholarship_awards_student_id_fk` (`institution_id`,`student_id`);

--
-- Indexes for table `sms_audit_logs`
--
ALTER TABLE `sms_audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sms_audit_logs_actor_user_id_foreign` (`actor_user_id`),
  ADD KEY `sms_audit_logs_institution_id_created_at_index` (`institution_id`,`created_at`),
  ADD KEY `sms_audit_logs_resource_type_resource_id_index` (`resource_type`,`resource_id`);

--
-- Indexes for table `sms_idempotency_records`
--
ALTER TABLE `sms_idempotency_records`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `sms_idempotency_unique` (`institution_id`,`operation`,`idempotency_key`),
  ADD KEY `sms_idempotency_records_status_expires_at_index` (`status`,`expires_at`);

--
-- Indexes for table `sms_outbox_events`
--
ALTER TABLE `sms_outbox_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sms_outbox_events_status_available_at_index` (`status`,`available_at`),
  ADD KEY `sms_outbox_aggregate_idx` (`institution_id`,`aggregate_type`,`aggregate_id`);

--
-- Indexes for table `sms_permissions`
--
ALTER TABLE `sms_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `sms_permissions_key_unique` (`key`);

--
-- Indexes for table `staff_appraisals`
--
ALTER TABLE `staff_appraisals`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `staff_appraisals_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `staff_appraisals_employee_id_fk` (`institution_id`,`employee_id`);

--
-- Indexes for table `staff_attendance`
--
ALTER TABLE `staff_attendance`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `staff_attendance_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `staff_attendance_employee_id_fk` (`institution_id`,`employee_id`);

--
-- Indexes for table `staff_leave_requests`
--
ALTER TABLE `staff_leave_requests`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `staff_leave_requests_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `staff_leave_requests_employee_id_fk` (`institution_id`,`employee_id`);

--
-- Indexes for table `stock_movements`
--
ALTER TABLE `stock_movements`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `stock_movements_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `stock_movements_inventory_item_id_fk` (`institution_id`,`inventory_item_id`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `students_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_students_uniq` (`institution_id`,`admission_no`),
  ADD KEY `students_user_id_fk` (`user_id`),
  ADD KEY `students_campus_id_fk` (`institution_id`,`campus_id`),
  ADD KEY `sms_students_idx` (`institution_id`,`status`,`campus_id`);

--
-- Indexes for table `student_attendance`
--
ALTER TABLE `student_attendance`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_attendance_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_student_attendance_combo_uniq` (`institution_id`,`attendance_session_id`,`student_id`),
  ADD KEY `sms_student_attendance_idx` (`institution_id`,`student_id`,`status`);

--
-- Indexes for table `student_documents`
--
ALTER TABLE `student_documents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_documents_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `student_documents_student_id_fk` (`institution_id`,`student_id`);

--
-- Indexes for table `student_guardians`
--
ALTER TABLE `student_guardians`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_guardians_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_student_guardians_combo_uniq` (`institution_id`,`student_id`,`guardian_id`),
  ADD KEY `student_guardians_guardian_id_fk` (`institution_id`,`guardian_id`);

--
-- Indexes for table `student_health_records`
--
ALTER TABLE `student_health_records`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_health_records_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `student_health_records_student_id_fk` (`institution_id`,`student_id`);

--
-- Indexes for table `student_incidents`
--
ALTER TABLE `student_incidents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_incidents_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `student_incidents_student_id_fk` (`institution_id`,`student_id`);

--
-- Indexes for table `student_invoices`
--
ALTER TABLE `student_invoices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_invoices_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_student_invoices_uniq` (`institution_id`,`invoice_no`),
  ADD KEY `sms_student_invoices_idx` (`institution_id`,`student_id`,`status`,`due_on`);

--
-- Indexes for table `student_invoice_lines`
--
ALTER TABLE `student_invoice_lines`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_invoice_lines_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `student_invoice_lines_student_invoice_id_fk` (`institution_id`,`student_invoice_id`),
  ADD KEY `student_invoice_lines_fee_head_id_fk` (`institution_id`,`fee_head_id`);

--
-- Indexes for table `student_leave_requests`
--
ALTER TABLE `student_leave_requests`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_leave_requests_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `student_leave_requests_student_id_fk` (`institution_id`,`student_id`);

--
-- Indexes for table `student_payments`
--
ALTER TABLE `student_payments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_payments_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_student_payments_uniq` (`institution_id`,`reference_no`),
  ADD KEY `student_payments_student_invoice_id_fk` (`institution_id`,`student_invoice_id`),
  ADD KEY `student_payments_payment_method_id_fk` (`institution_id`,`payment_method_id`),
  ADD KEY `sms_student_payments_idx` (`institution_id`,`student_id`,`paid_on`);

--
-- Indexes for table `student_promotions`
--
ALTER TABLE `student_promotions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_promotions_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `student_promotions_student_id_fk` (`institution_id`,`student_id`),
  ADD KEY `student_promotions_from_enrollment_id_fk` (`institution_id`,`from_enrollment_id`),
  ADD KEY `student_promotions_to_enrollment_id_fk` (`institution_id`,`to_enrollment_id`);

--
-- Indexes for table `student_transfers`
--
ALTER TABLE `student_transfers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_transfers_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `student_transfers_student_id_fk` (`institution_id`,`student_id`),
  ADD KEY `student_transfers_from_campus_id_fk` (`institution_id`,`from_campus_id`),
  ADD KEY `student_transfers_to_campus_id_fk` (`institution_id`,`to_campus_id`);

--
-- Indexes for table `student_transport_assignments`
--
ALTER TABLE `student_transport_assignments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_transport_assignments_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `student_transport_assignments_student_id_fk` (`institution_id`,`student_id`),
  ADD KEY `student_transport_assignments_transport_route_id_fk` (`institution_id`,`transport_route_id`),
  ADD KEY `student_transport_assignments_transport_stop_id_fk` (`institution_id`,`transport_stop_id`);

--
-- Indexes for table `subjects`
--
ALTER TABLE `subjects`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `subjects_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_subjects_uniq` (`institution_id`,`code`),
  ADD KEY `subjects_department_id_fk` (`institution_id`,`department_id`);

--
-- Indexes for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `suppliers_institution_id_id_unique` (`institution_id`,`id`);

--
-- Indexes for table `teacher_assignments`
--
ALTER TABLE `teacher_assignments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `teacher_assignments_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `teacher_assignments_employee_id_fk` (`institution_id`,`employee_id`),
  ADD KEY `teacher_assignments_class_subject_id_fk` (`institution_id`,`class_subject_id`),
  ADD KEY `teacher_assignments_academic_session_id_fk` (`institution_id`,`academic_session_id`);

--
-- Indexes for table `transport_routes`
--
ALTER TABLE `transport_routes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `transport_routes_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `transport_routes_vehicle_id_fk` (`institution_id`,`vehicle_id`),
  ADD KEY `transport_routes_employee_id_fk` (`institution_id`,`employee_id`);

--
-- Indexes for table `transport_stops`
--
ALTER TABLE `transport_stops`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `transport_stops_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `transport_stops_transport_route_id_fk` (`institution_id`,`transport_route_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Indexes for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `vehicles_institution_id_id_unique` (`institution_id`,`id`),
  ADD UNIQUE KEY `sms_vehicles_uniq` (`institution_id`,`vehicle_code`);

--
-- Indexes for table `visitor_logs`
--
ALTER TABLE `visitor_logs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `visitor_logs_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `visitor_logs_campus_id_fk` (`institution_id`,`campus_id`);

--
-- Indexes for table `welfare_cases`
--
ALTER TABLE `welfare_cases`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `welfare_cases_institution_id_id_unique` (`institution_id`,`id`),
  ADD KEY `welfare_cases_student_id_fk` (`institution_id`,`student_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `academic_calendar_events`
--
ALTER TABLE `academic_calendar_events`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `academic_departments`
--
ALTER TABLE `academic_departments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `academic_programs`
--
ALTER TABLE `academic_programs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `academic_sessions`
--
ALTER TABLE `academic_sessions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `academic_terms`
--
ALTER TABLE `academic_terms`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `admission_applications`
--
ALTER TABLE `admission_applications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `admission_cycles`
--
ALTER TABLE `admission_cycles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `admission_offers`
--
ALTER TABLE `admission_offers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `alumni_profiles`
--
ALTER TABLE `alumni_profiles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `asset_assignments`
--
ALTER TABLE `asset_assignments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `assignments`
--
ALTER TABLE `assignments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `assignment_submissions`
--
ALTER TABLE `assignment_submissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `attendance_sessions`
--
ALTER TABLE `attendance_sessions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bank_accounts`
--
ALTER TABLE `bank_accounts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bank_reconciliations`
--
ALTER TABLE `bank_reconciliations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `campuses`
--
ALTER TABLE `campuses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `campus_events`
--
ALTER TABLE `campus_events`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `certificate_templates`
--
ALTER TABLE `certificate_templates`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `chart_of_accounts`
--
ALTER TABLE `chart_of_accounts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `class_levels`
--
ALTER TABLE `class_levels`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `class_routines`
--
ALTER TABLE `class_routines`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `class_sections`
--
ALTER TABLE `class_sections`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `class_subjects`
--
ALTER TABLE `class_subjects`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `course_offerings`
--
ALTER TABLE `course_offerings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `direct_messages`
--
ALTER TABLE `direct_messages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `donations`
--
ALTER TABLE `donations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `donation_funds`
--
ALTER TABLE `donation_funds`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `donors`
--
ALTER TABLE `donors`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `employees`
--
ALTER TABLE `employees`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `enrollments`
--
ALTER TABLE `enrollments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `examinations`
--
ALTER TABLE `examinations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `exam_marks`
--
ALTER TABLE `exam_marks`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `exam_papers`
--
ALTER TABLE `exam_papers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `exam_recheck_requests`
--
ALTER TABLE `exam_recheck_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fee_heads`
--
ALTER TABLE `fee_heads`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fee_plans`
--
ALTER TABLE `fee_plans`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fee_plan_lines`
--
ALTER TABLE `fee_plan_lines`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `financial_period_closings`
--
ALTER TABLE `financial_period_closings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fixed_assets`
--
ALTER TABLE `fixed_assets`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fund_expenses`
--
ALTER TABLE `fund_expenses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `grading_bands`
--
ALTER TABLE `grading_bands`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `grading_scales`
--
ALTER TABLE `grading_scales`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `guardians`
--
ALTER TABLE `guardians`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hifz_assessments`
--
ALTER TABLE `hifz_assessments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hifz_enrollments`
--
ALTER TABLE `hifz_enrollments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hifz_groups`
--
ALTER TABLE `hifz_groups`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hifz_progress_logs`
--
ALTER TABLE `hifz_progress_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hostels`
--
ALTER TABLE `hostels`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hostel_allocations`
--
ALTER TABLE `hostel_allocations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hostel_beds`
--
ALTER TABLE `hostel_beds`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hostel_leave_requests`
--
ALTER TABLE `hostel_leave_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hostel_rooms`
--
ALTER TABLE `hostel_rooms`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `institutions`
--
ALTER TABLE `institutions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `institution_memberships`
--
ALTER TABLE `institution_memberships`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `institution_module_settings`
--
ALTER TABLE `institution_module_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `institution_roles`
--
ALTER TABLE `institution_roles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `integration_connections`
--
ALTER TABLE `integration_connections`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `integration_logs`
--
ALTER TABLE `integration_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory_items`
--
ALTER TABLE `inventory_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `issued_certificates`
--
ALTER TABLE `issued_certificates`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ledger_journals`
--
ALTER TABLE `ledger_journals`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ledger_lines`
--
ALTER TABLE `ledger_lines`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lesson_plans`
--
ALTER TABLE `lesson_plans`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `library_books`
--
ALTER TABLE `library_books`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `library_copies`
--
ALTER TABLE `library_copies`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `library_loans`
--
ALTER TABLE `library_loans`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lms_resources`
--
ALTER TABLE `lms_resources`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `meal_plans`
--
ALTER TABLE `meal_plans`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `notices`
--
ALTER TABLE `notices`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notification_deliveries`
--
ALTER TABLE `notification_deliveries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notification_templates`
--
ALTER TABLE `notification_templates`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `parent_meetings`
--
ALTER TABLE `parent_meetings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payment_allocations`
--
ALTER TABLE `payment_allocations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payment_methods`
--
ALTER TABLE `payment_methods`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payment_refunds`
--
ALTER TABLE `payment_refunds`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payroll_runs`
--
ALTER TABLE `payroll_runs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payslips`
--
ALTER TABLE `payslips`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payslip_items`
--
ALTER TABLE `payslip_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `published_results`
--
ALTER TABLE `published_results`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `purchase_orders`
--
ALTER TABLE `purchase_orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `purchase_order_lines`
--
ALTER TABLE `purchase_order_lines`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `report_exports`
--
ALTER TABLE `report_exports`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `room_bookings`
--
ALTER TABLE `room_bookings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `scholarships`
--
ALTER TABLE `scholarships`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `scholarship_awards`
--
ALTER TABLE `scholarship_awards`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sms_audit_logs`
--
ALTER TABLE `sms_audit_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sms_idempotency_records`
--
ALTER TABLE `sms_idempotency_records`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sms_outbox_events`
--
ALTER TABLE `sms_outbox_events`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sms_permissions`
--
ALTER TABLE `sms_permissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=77;

--
-- AUTO_INCREMENT for table `staff_appraisals`
--
ALTER TABLE `staff_appraisals`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `staff_attendance`
--
ALTER TABLE `staff_attendance`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `staff_leave_requests`
--
ALTER TABLE `staff_leave_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `stock_movements`
--
ALTER TABLE `stock_movements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student_attendance`
--
ALTER TABLE `student_attendance`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student_documents`
--
ALTER TABLE `student_documents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student_guardians`
--
ALTER TABLE `student_guardians`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student_health_records`
--
ALTER TABLE `student_health_records`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student_incidents`
--
ALTER TABLE `student_incidents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student_invoices`
--
ALTER TABLE `student_invoices`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student_invoice_lines`
--
ALTER TABLE `student_invoice_lines`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student_leave_requests`
--
ALTER TABLE `student_leave_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student_payments`
--
ALTER TABLE `student_payments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student_promotions`
--
ALTER TABLE `student_promotions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student_transfers`
--
ALTER TABLE `student_transfers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student_transport_assignments`
--
ALTER TABLE `student_transport_assignments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `subjects`
--
ALTER TABLE `subjects`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `suppliers`
--
ALTER TABLE `suppliers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `teacher_assignments`
--
ALTER TABLE `teacher_assignments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transport_routes`
--
ALTER TABLE `transport_routes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transport_stops`
--
ALTER TABLE `transport_stops`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `vehicles`
--
ALTER TABLE `vehicles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `visitor_logs`
--
ALTER TABLE `visitor_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `welfare_cases`
--
ALTER TABLE `welfare_cases`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `academic_calendar_events`
--
ALTER TABLE `academic_calendar_events`
  ADD CONSTRAINT `academic_calendar_events_academic_session_id_fk` FOREIGN KEY (`institution_id`,`academic_session_id`) REFERENCES `academic_sessions` (`institution_id`, `id`),
  ADD CONSTRAINT `academic_calendar_events_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `academic_departments`
--
ALTER TABLE `academic_departments`
  ADD CONSTRAINT `academic_departments_campus_id_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  ADD CONSTRAINT `academic_departments_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `academic_programs`
--
ALTER TABLE `academic_programs`
  ADD CONSTRAINT `academic_programs_department_id_fk` FOREIGN KEY (`institution_id`,`department_id`) REFERENCES `academic_departments` (`institution_id`, `id`),
  ADD CONSTRAINT `academic_programs_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `academic_sessions`
--
ALTER TABLE `academic_sessions`
  ADD CONSTRAINT `academic_sessions_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `academic_terms`
--
ALTER TABLE `academic_terms`
  ADD CONSTRAINT `academic_terms_academic_session_id_fk` FOREIGN KEY (`institution_id`,`academic_session_id`) REFERENCES `academic_sessions` (`institution_id`, `id`),
  ADD CONSTRAINT `academic_terms_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `admission_applications`
--
ALTER TABLE `admission_applications`
  ADD CONSTRAINT `admission_applications_admission_cycle_id_fk` FOREIGN KEY (`institution_id`,`admission_cycle_id`) REFERENCES `admission_cycles` (`institution_id`, `id`),
  ADD CONSTRAINT `admission_applications_class_level_id_fk` FOREIGN KEY (`institution_id`,`class_level_id`) REFERENCES `class_levels` (`institution_id`, `id`),
  ADD CONSTRAINT `admission_applications_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `admission_cycles`
--
ALTER TABLE `admission_cycles`
  ADD CONSTRAINT `admission_cycles_academic_session_id_fk` FOREIGN KEY (`institution_id`,`academic_session_id`) REFERENCES `academic_sessions` (`institution_id`, `id`),
  ADD CONSTRAINT `admission_cycles_campus_id_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  ADD CONSTRAINT `admission_cycles_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `admission_offers`
--
ALTER TABLE `admission_offers`
  ADD CONSTRAINT `admission_offers_admission_application_id_fk` FOREIGN KEY (`institution_id`,`admission_application_id`) REFERENCES `admission_applications` (`institution_id`, `id`),
  ADD CONSTRAINT `admission_offers_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `admission_offers_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `alumni_profiles`
--
ALTER TABLE `alumni_profiles`
  ADD CONSTRAINT `alumni_profiles_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `alumni_profiles_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `asset_assignments`
--
ALTER TABLE `asset_assignments`
  ADD CONSTRAINT `asset_assignments_employee_id_fk` FOREIGN KEY (`institution_id`,`employee_id`) REFERENCES `employees` (`institution_id`, `id`),
  ADD CONSTRAINT `asset_assignments_fixed_asset_id_fk` FOREIGN KEY (`institution_id`,`fixed_asset_id`) REFERENCES `fixed_assets` (`institution_id`, `id`),
  ADD CONSTRAINT `asset_assignments_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `assignments`
--
ALTER TABLE `assignments`
  ADD CONSTRAINT `assignments_class_subject_id_fk` FOREIGN KEY (`institution_id`,`class_subject_id`) REFERENCES `class_subjects` (`institution_id`, `id`),
  ADD CONSTRAINT `assignments_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `assignment_submissions`
--
ALTER TABLE `assignment_submissions`
  ADD CONSTRAINT `assignment_submissions_assignment_id_fk` FOREIGN KEY (`institution_id`,`assignment_id`) REFERENCES `assignments` (`institution_id`, `id`),
  ADD CONSTRAINT `assignment_submissions_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `assignment_submissions_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `attendance_sessions`
--
ALTER TABLE `attendance_sessions`
  ADD CONSTRAINT `attendance_sessions_class_section_id_fk` FOREIGN KEY (`institution_id`,`class_section_id`) REFERENCES `class_sections` (`institution_id`, `id`),
  ADD CONSTRAINT `attendance_sessions_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `bank_accounts`
--
ALTER TABLE `bank_accounts`
  ADD CONSTRAINT `bank_accounts_account_id_fk` FOREIGN KEY (`institution_id`,`account_id`) REFERENCES `chart_of_accounts` (`institution_id`, `id`),
  ADD CONSTRAINT `bank_accounts_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `bank_reconciliations`
--
ALTER TABLE `bank_reconciliations`
  ADD CONSTRAINT `bank_reconciliations_bank_account_id_fk` FOREIGN KEY (`institution_id`,`bank_account_id`) REFERENCES `bank_accounts` (`institution_id`, `id`),
  ADD CONSTRAINT `bank_reconciliations_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `campuses`
--
ALTER TABLE `campuses`
  ADD CONSTRAINT `campuses_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `campus_events`
--
ALTER TABLE `campus_events`
  ADD CONSTRAINT `campus_events_campus_id_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  ADD CONSTRAINT `campus_events_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `certificate_templates`
--
ALTER TABLE `certificate_templates`
  ADD CONSTRAINT `certificate_templates_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `chart_of_accounts`
--
ALTER TABLE `chart_of_accounts`
  ADD CONSTRAINT `chart_of_accounts_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `chart_of_accounts_parent_account_id_fk` FOREIGN KEY (`institution_id`,`parent_account_id`) REFERENCES `chart_of_accounts` (`institution_id`, `id`);

--
-- Constraints for table `class_levels`
--
ALTER TABLE `class_levels`
  ADD CONSTRAINT `class_levels_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `class_levels_program_id_fk` FOREIGN KEY (`institution_id`,`program_id`) REFERENCES `academic_programs` (`institution_id`, `id`);

--
-- Constraints for table `class_routines`
--
ALTER TABLE `class_routines`
  ADD CONSTRAINT `class_routines_class_section_id_fk` FOREIGN KEY (`institution_id`,`class_section_id`) REFERENCES `class_sections` (`institution_id`, `id`),
  ADD CONSTRAINT `class_routines_class_subject_id_fk` FOREIGN KEY (`institution_id`,`class_subject_id`) REFERENCES `class_subjects` (`institution_id`, `id`),
  ADD CONSTRAINT `class_routines_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `class_sections`
--
ALTER TABLE `class_sections`
  ADD CONSTRAINT `class_sections_campus_id_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  ADD CONSTRAINT `class_sections_class_level_id_fk` FOREIGN KEY (`institution_id`,`class_level_id`) REFERENCES `class_levels` (`institution_id`, `id`),
  ADD CONSTRAINT `class_sections_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `class_subjects`
--
ALTER TABLE `class_subjects`
  ADD CONSTRAINT `class_subjects_academic_session_id_fk` FOREIGN KEY (`institution_id`,`academic_session_id`) REFERENCES `academic_sessions` (`institution_id`, `id`),
  ADD CONSTRAINT `class_subjects_class_level_id_fk` FOREIGN KEY (`institution_id`,`class_level_id`) REFERENCES `class_levels` (`institution_id`, `id`),
  ADD CONSTRAINT `class_subjects_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `class_subjects_subject_id_fk` FOREIGN KEY (`institution_id`,`subject_id`) REFERENCES `subjects` (`institution_id`, `id`);

--
-- Constraints for table `course_offerings`
--
ALTER TABLE `course_offerings`
  ADD CONSTRAINT `course_offerings_academic_term_id_fk` FOREIGN KEY (`institution_id`,`academic_term_id`) REFERENCES `academic_terms` (`institution_id`, `id`),
  ADD CONSTRAINT `course_offerings_class_section_id_fk` FOREIGN KEY (`institution_id`,`class_section_id`) REFERENCES `class_sections` (`institution_id`, `id`),
  ADD CONSTRAINT `course_offerings_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `course_offerings_subject_id_fk` FOREIGN KEY (`institution_id`,`subject_id`) REFERENCES `subjects` (`institution_id`, `id`);

--
-- Constraints for table `direct_messages`
--
ALTER TABLE `direct_messages`
  ADD CONSTRAINT `direct_messages_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `direct_messages_recipient_user_id_fk` FOREIGN KEY (`recipient_user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `direct_messages_sender_user_id_fk` FOREIGN KEY (`sender_user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `donations`
--
ALTER TABLE `donations`
  ADD CONSTRAINT `donations_donation_fund_id_fk` FOREIGN KEY (`institution_id`,`donation_fund_id`) REFERENCES `donation_funds` (`institution_id`, `id`),
  ADD CONSTRAINT `donations_donor_id_fk` FOREIGN KEY (`institution_id`,`donor_id`) REFERENCES `donors` (`institution_id`, `id`),
  ADD CONSTRAINT `donations_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `donation_funds`
--
ALTER TABLE `donation_funds`
  ADD CONSTRAINT `donation_funds_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `donors`
--
ALTER TABLE `donors`
  ADD CONSTRAINT `donors_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `employees`
--
ALTER TABLE `employees`
  ADD CONSTRAINT `employees_campus_id_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  ADD CONSTRAINT `employees_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `employees_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `enrollments`
--
ALTER TABLE `enrollments`
  ADD CONSTRAINT `enrollments_academic_session_id_fk` FOREIGN KEY (`institution_id`,`academic_session_id`) REFERENCES `academic_sessions` (`institution_id`, `id`),
  ADD CONSTRAINT `enrollments_class_section_id_fk` FOREIGN KEY (`institution_id`,`class_section_id`) REFERENCES `class_sections` (`institution_id`, `id`),
  ADD CONSTRAINT `enrollments_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `enrollments_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `examinations`
--
ALTER TABLE `examinations`
  ADD CONSTRAINT `examinations_academic_session_id_fk` FOREIGN KEY (`institution_id`,`academic_session_id`) REFERENCES `academic_sessions` (`institution_id`, `id`),
  ADD CONSTRAINT `examinations_class_level_id_fk` FOREIGN KEY (`institution_id`,`class_level_id`) REFERENCES `class_levels` (`institution_id`, `id`),
  ADD CONSTRAINT `examinations_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `exam_marks`
--
ALTER TABLE `exam_marks`
  ADD CONSTRAINT `exam_marks_exam_paper_id_fk` FOREIGN KEY (`institution_id`,`exam_paper_id`) REFERENCES `exam_papers` (`institution_id`, `id`),
  ADD CONSTRAINT `exam_marks_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `exam_marks_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `exam_papers`
--
ALTER TABLE `exam_papers`
  ADD CONSTRAINT `exam_papers_examination_id_fk` FOREIGN KEY (`institution_id`,`examination_id`) REFERENCES `examinations` (`institution_id`, `id`),
  ADD CONSTRAINT `exam_papers_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `exam_papers_subject_id_fk` FOREIGN KEY (`institution_id`,`subject_id`) REFERENCES `subjects` (`institution_id`, `id`);

--
-- Constraints for table `exam_recheck_requests`
--
ALTER TABLE `exam_recheck_requests`
  ADD CONSTRAINT `exam_recheck_requests_exam_mark_id_fk` FOREIGN KEY (`institution_id`,`exam_mark_id`) REFERENCES `exam_marks` (`institution_id`, `id`),
  ADD CONSTRAINT `exam_recheck_requests_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `expenses`
--
ALTER TABLE `expenses`
  ADD CONSTRAINT `expenses_account_id_fk` FOREIGN KEY (`institution_id`,`account_id`) REFERENCES `chart_of_accounts` (`institution_id`, `id`),
  ADD CONSTRAINT `expenses_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `fee_heads`
--
ALTER TABLE `fee_heads`
  ADD CONSTRAINT `fee_heads_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `fee_heads_revenue_account_id_fk` FOREIGN KEY (`institution_id`,`revenue_account_id`) REFERENCES `chart_of_accounts` (`institution_id`, `id`);

--
-- Constraints for table `fee_plans`
--
ALTER TABLE `fee_plans`
  ADD CONSTRAINT `fee_plans_academic_session_id_fk` FOREIGN KEY (`institution_id`,`academic_session_id`) REFERENCES `academic_sessions` (`institution_id`, `id`),
  ADD CONSTRAINT `fee_plans_class_level_id_fk` FOREIGN KEY (`institution_id`,`class_level_id`) REFERENCES `class_levels` (`institution_id`, `id`),
  ADD CONSTRAINT `fee_plans_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `fee_plan_lines`
--
ALTER TABLE `fee_plan_lines`
  ADD CONSTRAINT `fee_plan_lines_fee_head_id_fk` FOREIGN KEY (`institution_id`,`fee_head_id`) REFERENCES `fee_heads` (`institution_id`, `id`),
  ADD CONSTRAINT `fee_plan_lines_fee_plan_id_fk` FOREIGN KEY (`institution_id`,`fee_plan_id`) REFERENCES `fee_plans` (`institution_id`, `id`),
  ADD CONSTRAINT `fee_plan_lines_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `financial_period_closings`
--
ALTER TABLE `financial_period_closings`
  ADD CONSTRAINT `financial_period_closings_academic_session_id_fk` FOREIGN KEY (`institution_id`,`academic_session_id`) REFERENCES `academic_sessions` (`institution_id`, `id`),
  ADD CONSTRAINT `financial_period_closings_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `fixed_assets`
--
ALTER TABLE `fixed_assets`
  ADD CONSTRAINT `fixed_assets_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `fund_expenses`
--
ALTER TABLE `fund_expenses`
  ADD CONSTRAINT `fund_expenses_approved_by_user_id_fk` FOREIGN KEY (`approved_by_user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fund_expenses_donation_fund_id_fk` FOREIGN KEY (`institution_id`,`donation_fund_id`) REFERENCES `donation_funds` (`institution_id`, `id`),
  ADD CONSTRAINT `fund_expenses_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `grading_bands`
--
ALTER TABLE `grading_bands`
  ADD CONSTRAINT `grading_bands_grading_scale_id_fk` FOREIGN KEY (`institution_id`,`grading_scale_id`) REFERENCES `grading_scales` (`institution_id`, `id`),
  ADD CONSTRAINT `grading_bands_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `grading_scales`
--
ALTER TABLE `grading_scales`
  ADD CONSTRAINT `grading_scales_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `guardians`
--
ALTER TABLE `guardians`
  ADD CONSTRAINT `guardians_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `guardians_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `hifz_assessments`
--
ALTER TABLE `hifz_assessments`
  ADD CONSTRAINT `hifz_assessments_hifz_enrollment_id_fk` FOREIGN KEY (`institution_id`,`hifz_enrollment_id`) REFERENCES `hifz_enrollments` (`institution_id`, `id`),
  ADD CONSTRAINT `hifz_assessments_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `hifz_enrollments`
--
ALTER TABLE `hifz_enrollments`
  ADD CONSTRAINT `hifz_enrollments_hifz_group_id_fk` FOREIGN KEY (`institution_id`,`hifz_group_id`) REFERENCES `hifz_groups` (`institution_id`, `id`),
  ADD CONSTRAINT `hifz_enrollments_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `hifz_enrollments_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `hifz_groups`
--
ALTER TABLE `hifz_groups`
  ADD CONSTRAINT `hifz_groups_employee_id_fk` FOREIGN KEY (`institution_id`,`employee_id`) REFERENCES `employees` (`institution_id`, `id`),
  ADD CONSTRAINT `hifz_groups_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `hifz_progress_logs`
--
ALTER TABLE `hifz_progress_logs`
  ADD CONSTRAINT `hifz_progress_logs_hifz_enrollment_id_fk` FOREIGN KEY (`institution_id`,`hifz_enrollment_id`) REFERENCES `hifz_enrollments` (`institution_id`, `id`),
  ADD CONSTRAINT `hifz_progress_logs_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `hostels`
--
ALTER TABLE `hostels`
  ADD CONSTRAINT `hostels_campus_id_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  ADD CONSTRAINT `hostels_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `hostel_allocations`
--
ALTER TABLE `hostel_allocations`
  ADD CONSTRAINT `hostel_allocations_hostel_bed_id_fk` FOREIGN KEY (`institution_id`,`hostel_bed_id`) REFERENCES `hostel_beds` (`institution_id`, `id`),
  ADD CONSTRAINT `hostel_allocations_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `hostel_allocations_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `hostel_beds`
--
ALTER TABLE `hostel_beds`
  ADD CONSTRAINT `hostel_beds_hostel_room_id_fk` FOREIGN KEY (`institution_id`,`hostel_room_id`) REFERENCES `hostel_rooms` (`institution_id`, `id`),
  ADD CONSTRAINT `hostel_beds_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `hostel_leave_requests`
--
ALTER TABLE `hostel_leave_requests`
  ADD CONSTRAINT `hostel_leave_requests_hostel_allocation_id_fk` FOREIGN KEY (`institution_id`,`hostel_allocation_id`) REFERENCES `hostel_allocations` (`institution_id`, `id`),
  ADD CONSTRAINT `hostel_leave_requests_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `hostel_rooms`
--
ALTER TABLE `hostel_rooms`
  ADD CONSTRAINT `hostel_rooms_hostel_id_fk` FOREIGN KEY (`institution_id`,`hostel_id`) REFERENCES `hostels` (`institution_id`, `id`),
  ADD CONSTRAINT `hostel_rooms_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `institution_memberships`
--
ALTER TABLE `institution_memberships`
  ADD CONSTRAINT `institution_memberships_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `institution_memberships_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `institution_module_settings`
--
ALTER TABLE `institution_module_settings`
  ADD CONSTRAINT `institution_module_settings_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `institution_roles`
--
ALTER TABLE `institution_roles`
  ADD CONSTRAINT `institution_roles_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `institution_role_permissions`
--
ALTER TABLE `institution_role_permissions`
  ADD CONSTRAINT `institution_role_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `sms_permissions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `institution_role_permissions_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `institution_roles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `integration_connections`
--
ALTER TABLE `integration_connections`
  ADD CONSTRAINT `integration_connections_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `integration_logs`
--
ALTER TABLE `integration_logs`
  ADD CONSTRAINT `integration_logs_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `integration_logs_integration_connection_id_fk` FOREIGN KEY (`institution_id`,`integration_connection_id`) REFERENCES `integration_connections` (`institution_id`, `id`);

--
-- Constraints for table `inventory_items`
--
ALTER TABLE `inventory_items`
  ADD CONSTRAINT `inventory_items_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `issued_certificates`
--
ALTER TABLE `issued_certificates`
  ADD CONSTRAINT `issued_certificates_certificate_template_id_fk` FOREIGN KEY (`institution_id`,`certificate_template_id`) REFERENCES `certificate_templates` (`institution_id`, `id`),
  ADD CONSTRAINT `issued_certificates_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `issued_certificates_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `ledger_journals`
--
ALTER TABLE `ledger_journals`
  ADD CONSTRAINT `ledger_journals_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `ledger_lines`
--
ALTER TABLE `ledger_lines`
  ADD CONSTRAINT `ledger_lines_account_id_fk` FOREIGN KEY (`institution_id`,`account_id`) REFERENCES `chart_of_accounts` (`institution_id`, `id`),
  ADD CONSTRAINT `ledger_lines_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `ledger_lines_ledger_journal_id_fk` FOREIGN KEY (`institution_id`,`ledger_journal_id`) REFERENCES `ledger_journals` (`institution_id`, `id`);

--
-- Constraints for table `lesson_plans`
--
ALTER TABLE `lesson_plans`
  ADD CONSTRAINT `lesson_plans_class_subject_id_fk` FOREIGN KEY (`institution_id`,`class_subject_id`) REFERENCES `class_subjects` (`institution_id`, `id`),
  ADD CONSTRAINT `lesson_plans_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `library_books`
--
ALTER TABLE `library_books`
  ADD CONSTRAINT `library_books_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `library_copies`
--
ALTER TABLE `library_copies`
  ADD CONSTRAINT `library_copies_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `library_copies_library_book_id_fk` FOREIGN KEY (`institution_id`,`library_book_id`) REFERENCES `library_books` (`institution_id`, `id`);

--
-- Constraints for table `library_loans`
--
ALTER TABLE `library_loans`
  ADD CONSTRAINT `library_loans_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `library_loans_library_copy_id_fk` FOREIGN KEY (`institution_id`,`library_copy_id`) REFERENCES `library_copies` (`institution_id`, `id`),
  ADD CONSTRAINT `library_loans_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `lms_resources`
--
ALTER TABLE `lms_resources`
  ADD CONSTRAINT `lms_resources_class_subject_id_fk` FOREIGN KEY (`institution_id`,`class_subject_id`) REFERENCES `class_subjects` (`institution_id`, `id`),
  ADD CONSTRAINT `lms_resources_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `meal_plans`
--
ALTER TABLE `meal_plans`
  ADD CONSTRAINT `meal_plans_hostel_id_fk` FOREIGN KEY (`institution_id`,`hostel_id`) REFERENCES `hostels` (`institution_id`, `id`),
  ADD CONSTRAINT `meal_plans_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `membership_campuses`
--
ALTER TABLE `membership_campuses`
  ADD CONSTRAINT `mc_campus_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses` (`institution_id`, `id`) ON DELETE CASCADE,
  ADD CONSTRAINT `mc_membership_fk` FOREIGN KEY (`institution_id`,`membership_id`) REFERENCES `institution_memberships` (`institution_id`, `id`) ON DELETE CASCADE;

--
-- Constraints for table `membership_roles`
--
ALTER TABLE `membership_roles`
  ADD CONSTRAINT `mr_membership_fk` FOREIGN KEY (`institution_id`,`membership_id`) REFERENCES `institution_memberships` (`institution_id`, `id`) ON DELETE CASCADE,
  ADD CONSTRAINT `mr_role_fk` FOREIGN KEY (`institution_id`,`role_id`) REFERENCES `institution_roles` (`institution_id`, `id`) ON DELETE CASCADE;

--
-- Constraints for table `notices`
--
ALTER TABLE `notices`
  ADD CONSTRAINT `notices_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `notification_deliveries`
--
ALTER TABLE `notification_deliveries`
  ADD CONSTRAINT `notification_deliveries_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `notification_deliveries_notification_template_id_fk` FOREIGN KEY (`institution_id`,`notification_template_id`) REFERENCES `notification_templates` (`institution_id`, `id`),
  ADD CONSTRAINT `notification_deliveries_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `notification_templates`
--
ALTER TABLE `notification_templates`
  ADD CONSTRAINT `notification_templates_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `parent_meetings`
--
ALTER TABLE `parent_meetings`
  ADD CONSTRAINT `parent_meetings_employee_id_fk` FOREIGN KEY (`institution_id`,`employee_id`) REFERENCES `employees` (`institution_id`, `id`),
  ADD CONSTRAINT `parent_meetings_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `parent_meetings_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `payment_allocations`
--
ALTER TABLE `payment_allocations`
  ADD CONSTRAINT `payment_allocations_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `payment_allocations_student_invoice_id_fk` FOREIGN KEY (`institution_id`,`student_invoice_id`) REFERENCES `student_invoices` (`institution_id`, `id`),
  ADD CONSTRAINT `payment_allocations_student_payment_id_fk` FOREIGN KEY (`institution_id`,`student_payment_id`) REFERENCES `student_payments` (`institution_id`, `id`);

--
-- Constraints for table `payment_methods`
--
ALTER TABLE `payment_methods`
  ADD CONSTRAINT `payment_methods_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `payment_refunds`
--
ALTER TABLE `payment_refunds`
  ADD CONSTRAINT `payment_refunds_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `payment_refunds_student_payment_id_fk` FOREIGN KEY (`institution_id`,`student_payment_id`) REFERENCES `student_payments` (`institution_id`, `id`);

--
-- Constraints for table `payroll_runs`
--
ALTER TABLE `payroll_runs`
  ADD CONSTRAINT `payroll_runs_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `payslips`
--
ALTER TABLE `payslips`
  ADD CONSTRAINT `payslips_employee_id_fk` FOREIGN KEY (`institution_id`,`employee_id`) REFERENCES `employees` (`institution_id`, `id`),
  ADD CONSTRAINT `payslips_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `payslips_payroll_run_id_fk` FOREIGN KEY (`institution_id`,`payroll_run_id`) REFERENCES `payroll_runs` (`institution_id`, `id`);

--
-- Constraints for table `payslip_items`
--
ALTER TABLE `payslip_items`
  ADD CONSTRAINT `payslip_items_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `payslip_items_payslip_id_fk` FOREIGN KEY (`institution_id`,`payslip_id`) REFERENCES `payslips` (`institution_id`, `id`);

--
-- Constraints for table `platform_admin_users`
--
ALTER TABLE `platform_admin_users`
  ADD CONSTRAINT `platform_admin_users_granted_by_user_id_foreign` FOREIGN KEY (`granted_by_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `platform_admin_users_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `published_results`
--
ALTER TABLE `published_results`
  ADD CONSTRAINT `published_results_examination_id_fk` FOREIGN KEY (`institution_id`,`examination_id`) REFERENCES `examinations` (`institution_id`, `id`),
  ADD CONSTRAINT `published_results_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `published_results_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `purchase_orders`
--
ALTER TABLE `purchase_orders`
  ADD CONSTRAINT `purchase_orders_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `purchase_orders_supplier_id_fk` FOREIGN KEY (`institution_id`,`supplier_id`) REFERENCES `suppliers` (`institution_id`, `id`);

--
-- Constraints for table `purchase_order_lines`
--
ALTER TABLE `purchase_order_lines`
  ADD CONSTRAINT `purchase_order_lines_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `purchase_order_lines_inventory_item_id_fk` FOREIGN KEY (`institution_id`,`inventory_item_id`) REFERENCES `inventory_items` (`institution_id`, `id`),
  ADD CONSTRAINT `purchase_order_lines_purchase_order_id_fk` FOREIGN KEY (`institution_id`,`purchase_order_id`) REFERENCES `purchase_orders` (`institution_id`, `id`);

--
-- Constraints for table `report_exports`
--
ALTER TABLE `report_exports`
  ADD CONSTRAINT `report_exports_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `report_exports_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `room_bookings`
--
ALTER TABLE `room_bookings`
  ADD CONSTRAINT `room_bookings_booked_by_user_id_fk` FOREIGN KEY (`booked_by_user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `room_bookings_campus_id_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  ADD CONSTRAINT `room_bookings_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `scholarships`
--
ALTER TABLE `scholarships`
  ADD CONSTRAINT `scholarships_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `scholarship_awards`
--
ALTER TABLE `scholarship_awards`
  ADD CONSTRAINT `scholarship_awards_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `scholarship_awards_scholarship_id_fk` FOREIGN KEY (`institution_id`,`scholarship_id`) REFERENCES `scholarships` (`institution_id`, `id`),
  ADD CONSTRAINT `scholarship_awards_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `sms_audit_logs`
--
ALTER TABLE `sms_audit_logs`
  ADD CONSTRAINT `sms_audit_logs_actor_user_id_foreign` FOREIGN KEY (`actor_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `sms_audit_logs_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `sms_idempotency_records`
--
ALTER TABLE `sms_idempotency_records`
  ADD CONSTRAINT `sms_idempotency_records_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `sms_outbox_events`
--
ALTER TABLE `sms_outbox_events`
  ADD CONSTRAINT `sms_outbox_events_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `staff_appraisals`
--
ALTER TABLE `staff_appraisals`
  ADD CONSTRAINT `staff_appraisals_employee_id_fk` FOREIGN KEY (`institution_id`,`employee_id`) REFERENCES `employees` (`institution_id`, `id`),
  ADD CONSTRAINT `staff_appraisals_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `staff_attendance`
--
ALTER TABLE `staff_attendance`
  ADD CONSTRAINT `staff_attendance_employee_id_fk` FOREIGN KEY (`institution_id`,`employee_id`) REFERENCES `employees` (`institution_id`, `id`),
  ADD CONSTRAINT `staff_attendance_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `staff_leave_requests`
--
ALTER TABLE `staff_leave_requests`
  ADD CONSTRAINT `staff_leave_requests_employee_id_fk` FOREIGN KEY (`institution_id`,`employee_id`) REFERENCES `employees` (`institution_id`, `id`),
  ADD CONSTRAINT `staff_leave_requests_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `stock_movements`
--
ALTER TABLE `stock_movements`
  ADD CONSTRAINT `stock_movements_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `stock_movements_inventory_item_id_fk` FOREIGN KEY (`institution_id`,`inventory_item_id`) REFERENCES `inventory_items` (`institution_id`, `id`);

--
-- Constraints for table `students`
--
ALTER TABLE `students`
  ADD CONSTRAINT `students_campus_id_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  ADD CONSTRAINT `students_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `students_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `student_attendance`
--
ALTER TABLE `student_attendance`
  ADD CONSTRAINT `student_attendance_attendance_session_id_fk` FOREIGN KEY (`institution_id`,`attendance_session_id`) REFERENCES `attendance_sessions` (`institution_id`, `id`),
  ADD CONSTRAINT `student_attendance_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `student_attendance_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `student_documents`
--
ALTER TABLE `student_documents`
  ADD CONSTRAINT `student_documents_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `student_documents_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `student_guardians`
--
ALTER TABLE `student_guardians`
  ADD CONSTRAINT `student_guardians_guardian_id_fk` FOREIGN KEY (`institution_id`,`guardian_id`) REFERENCES `guardians` (`institution_id`, `id`),
  ADD CONSTRAINT `student_guardians_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `student_guardians_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `student_health_records`
--
ALTER TABLE `student_health_records`
  ADD CONSTRAINT `student_health_records_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `student_health_records_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `student_incidents`
--
ALTER TABLE `student_incidents`
  ADD CONSTRAINT `student_incidents_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `student_incidents_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `student_invoices`
--
ALTER TABLE `student_invoices`
  ADD CONSTRAINT `student_invoices_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `student_invoices_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `student_invoice_lines`
--
ALTER TABLE `student_invoice_lines`
  ADD CONSTRAINT `student_invoice_lines_fee_head_id_fk` FOREIGN KEY (`institution_id`,`fee_head_id`) REFERENCES `fee_heads` (`institution_id`, `id`),
  ADD CONSTRAINT `student_invoice_lines_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `student_invoice_lines_student_invoice_id_fk` FOREIGN KEY (`institution_id`,`student_invoice_id`) REFERENCES `student_invoices` (`institution_id`, `id`);

--
-- Constraints for table `student_leave_requests`
--
ALTER TABLE `student_leave_requests`
  ADD CONSTRAINT `student_leave_requests_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `student_leave_requests_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);

--
-- Constraints for table `student_payments`
--
ALTER TABLE `student_payments`
  ADD CONSTRAINT `student_payments_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `student_payments_payment_method_id_fk` FOREIGN KEY (`institution_id`,`payment_method_id`) REFERENCES `payment_methods` (`institution_id`, `id`),
  ADD CONSTRAINT `student_payments_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`),
  ADD CONSTRAINT `student_payments_student_invoice_id_fk` FOREIGN KEY (`institution_id`,`student_invoice_id`) REFERENCES `student_invoices` (`institution_id`, `id`);

--
-- Constraints for table `student_promotions`
--
ALTER TABLE `student_promotions`
  ADD CONSTRAINT `student_promotions_from_enrollment_id_fk` FOREIGN KEY (`institution_id`,`from_enrollment_id`) REFERENCES `enrollments` (`institution_id`, `id`),
  ADD CONSTRAINT `student_promotions_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `student_promotions_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`),
  ADD CONSTRAINT `student_promotions_to_enrollment_id_fk` FOREIGN KEY (`institution_id`,`to_enrollment_id`) REFERENCES `enrollments` (`institution_id`, `id`);

--
-- Constraints for table `student_transfers`
--
ALTER TABLE `student_transfers`
  ADD CONSTRAINT `student_transfers_from_campus_id_fk` FOREIGN KEY (`institution_id`,`from_campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  ADD CONSTRAINT `student_transfers_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `student_transfers_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`),
  ADD CONSTRAINT `student_transfers_to_campus_id_fk` FOREIGN KEY (`institution_id`,`to_campus_id`) REFERENCES `campuses` (`institution_id`, `id`);

--
-- Constraints for table `student_transport_assignments`
--
ALTER TABLE `student_transport_assignments`
  ADD CONSTRAINT `student_transport_assignments_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `student_transport_assignments_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`),
  ADD CONSTRAINT `student_transport_assignments_transport_route_id_fk` FOREIGN KEY (`institution_id`,`transport_route_id`) REFERENCES `transport_routes` (`institution_id`, `id`),
  ADD CONSTRAINT `student_transport_assignments_transport_stop_id_fk` FOREIGN KEY (`institution_id`,`transport_stop_id`) REFERENCES `transport_stops` (`institution_id`, `id`);

--
-- Constraints for table `subjects`
--
ALTER TABLE `subjects`
  ADD CONSTRAINT `subjects_department_id_fk` FOREIGN KEY (`institution_id`,`department_id`) REFERENCES `academic_departments` (`institution_id`, `id`),
  ADD CONSTRAINT `subjects_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD CONSTRAINT `suppliers_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `teacher_assignments`
--
ALTER TABLE `teacher_assignments`
  ADD CONSTRAINT `teacher_assignments_academic_session_id_fk` FOREIGN KEY (`institution_id`,`academic_session_id`) REFERENCES `academic_sessions` (`institution_id`, `id`),
  ADD CONSTRAINT `teacher_assignments_class_subject_id_fk` FOREIGN KEY (`institution_id`,`class_subject_id`) REFERENCES `class_subjects` (`institution_id`, `id`),
  ADD CONSTRAINT `teacher_assignments_employee_id_fk` FOREIGN KEY (`institution_id`,`employee_id`) REFERENCES `employees` (`institution_id`, `id`),
  ADD CONSTRAINT `teacher_assignments_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `transport_routes`
--
ALTER TABLE `transport_routes`
  ADD CONSTRAINT `transport_routes_employee_id_fk` FOREIGN KEY (`institution_id`,`employee_id`) REFERENCES `employees` (`institution_id`, `id`),
  ADD CONSTRAINT `transport_routes_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `transport_routes_vehicle_id_fk` FOREIGN KEY (`institution_id`,`vehicle_id`) REFERENCES `vehicles` (`institution_id`, `id`);

--
-- Constraints for table `transport_stops`
--
ALTER TABLE `transport_stops`
  ADD CONSTRAINT `transport_stops_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `transport_stops_transport_route_id_fk` FOREIGN KEY (`institution_id`,`transport_route_id`) REFERENCES `transport_routes` (`institution_id`, `id`);

--
-- Constraints for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD CONSTRAINT `vehicles_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `visitor_logs`
--
ALTER TABLE `visitor_logs`
  ADD CONSTRAINT `visitor_logs_campus_id_fk` FOREIGN KEY (`institution_id`,`campus_id`) REFERENCES `campuses` (`institution_id`, `id`),
  ADD CONSTRAINT `visitor_logs_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`);

--
-- Constraints for table `welfare_cases`
--
ALTER TABLE `welfare_cases`
  ADD CONSTRAINT `welfare_cases_institution_id_foreign` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`),
  ADD CONSTRAINT `welfare_cases_student_id_fk` FOREIGN KEY (`institution_id`,`student_id`) REFERENCES `students` (`institution_id`, `id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
