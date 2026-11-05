-- Run ONLY after php artisan migrate on empty database
START TRANSACTION;
INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'School Administrator', 'admin.school@example.test', '2026-11-05 08:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 'Teacher Nabila', 'teacher.school@example.test', '2026-11-05 08:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 'Accounts Officer', 'accounts.school@example.test', '2026-11-05 08:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(4, 'Demo Parent', 'parent.school@example.test', '2026-11-05 08:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(5, 'Student Ayesha', 'student.school@example.test', '2026-11-05 08:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(6, 'College Administrator', 'admin.college@example.test', '2026-11-05 08:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(7, 'Madrasha Administrator', 'admin.madrasha@example.test', '2026-11-05 08:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(8, 'Ustad Mahmud', 'ustad.madrasha@example.test', '2026-11-05 08:00:00', '$2y$12$yW3tCFSq/7jxEqIuoOrBYuDffCRTdpAtzTzOeLuSCwI7YCDRWXRoC', NULL, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

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
(13, 24),
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
(3, 3, NULL, 'Mr Abdul Hakim', 'father', '01700000003', 'Demo email', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `students` (`id`, `institution_id`, `user_id`, `campus_id`, `admission_no`, `name`, `gender`, `birth_date`, `blood_group`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 5, 1, 'SCH-2026-001', 'Ayesha Rahman', 'female', '2014-02-14', 'B+', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, NULL, 2, 'COL-2026-001', 'Rafi Ahmed', 'male', '2009-06-16', 'A+', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, NULL, 3, 'MAD-2026-001', 'Yusuf Ali', 'male', '2013-08-21', 'O+', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `admission_cycles` (`id`, `institution_id`, `academic_session_id`, `campus_id`, `title`, `opens_on`, `closes_on`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '2026 Grade 6 Admission', '2026-11-05', '2026-11-05', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '2026 College Admission', '2026-11-05', '2026-11-05', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '2026 Hifz Admission', '2026-11-05', '2026-11-05', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `employees` (`id`, `institution_id`, `user_id`, `campus_id`, `employee_no`, `name`, `designation`, `joined_on`, `basic_salary`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 2, 1, 'T-001', 'Nabila Islam', 'Class Teacher', '2026-11-05', '35000.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, NULL, 2, 'CT-01', 'Dr Farhana Khan', 'Lecturer', '2026-11-05', '48000.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 8, 3, 'HZ-01', 'Ustad Mahmud', 'Hifz Instructor', '2026-11-05', '30000.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `payroll_runs` (`id`, `institution_id`, `period_start`, `period_end`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, '2026-11-05', '2026-11-05', 'draft', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, '2026-11-05', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, '2026-11-05', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `grading_scales` (`id`, `institution_id`, `code`, `name`, `created_at`, `updated_at`) VALUES
(1, 1, 'NCTB', 'School GPA 5', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'COL', 'College GPA 5', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'HIFZ', 'Madrasha Grading', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `chart_of_accounts` (`id`, `institution_id`, `code`, `name`, `account_type`, `parent_account_id`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, '1100', 'Student Receivables', 'asset', NULL, 0, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, '1100', 'Student Receivables', 'asset', NULL, 0, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, '1100', 'Student Receivables', 'asset', NULL, 0, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
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
(9, 3, 'J-3-PAY', '2026-11-05', 'payment', 'CASH-M-001', 'Partial collection (demo)', 'posted', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

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
(3, 3, 'Hifz Parent Meeting', 'Fictional demonstration record', 'Demo audience', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

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
(3, 3, '9780000000003', 'Tajweed Guide', 'Demo Author', 'religious', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

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
(3, 3, 'QUR-STAND', 'Quran Stand', 'piece', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `fixed_assets` (`id`, `institution_id`, `asset_tag`, `name`, `category`, `purchased_on`, `purchase_cost`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'S-CHAIR-001', 'Teacher Chair', 'furniture', '2026-11-05', '4500.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'C-MIC-001', 'Microscope', 'lab', '2026-11-05', '9000.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'M-DESK-001', 'Reading Desk', 'furniture', '2026-11-05', '3000.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `donors` (`id`, `institution_id`, `name`, `phone`, `email`, `created_at`, `updated_at`) VALUES
(1, 1, 'Demo Education Supporter', 'Demo phone', 'Demo email', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'Demo College Supporter', 'Demo phone', 'Demo email', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'Demo Madrasha Donor', 'Demo phone', 'Demo email', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

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
(3, 3, 3, 3, 'parent', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `student_documents` (`id`, `institution_id`, `student_id`, `document_type`, `file_path`, `verification_status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'birth_certificate', NULL, 'pending_upload', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Demo document type', NULL, 'Demo verification status', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Demo document type', NULL, 'Demo verification status', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

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
(3, 3, 3, '2026-11-05', 'active', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `staff_leave_requests` (`id`, `institution_id`, `employee_id`, `starts_on`, `ends_on`, `reason`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2026-11-05', '2026-11-05', 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, '2026-11-05', '2026-11-05', 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, '2026-11-05', '2026-11-05', 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `payslips` (`id`, `institution_id`, `payroll_run_id`, `employee_id`, `gross_amount`, `deduction_amount`, `net_amount`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '35000.00', '1000.00', '34000.00', 'draft', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '48000.00', '0.00', '48000.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '30000.00', '0.00', '30000.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `staff_appraisals` (`id`, `institution_id`, `employee_id`, `reviewed_on`, `score`, `remarks`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2026-11-05', '91.00', 'Demonstration appraisal', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, '2026-11-05', '0.00', 'Fictional demonstration record', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, '2026-11-05', '0.00', 'Fictional demonstration record', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `grading_bands` (`id`, `institution_id`, `grading_scale_id`, `min_percent`, `max_percent`, `letter_grade`, `grade_point`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '80.00', '100.00', 'A+', '5.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, '80.00', '100.00', 'A+', '5.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, '80.00', '100.00', 'A+', '5.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `fee_heads` (`id`, `institution_id`, `code`, `name`, `revenue_account_id`, `created_at`, `updated_at`) VALUES
(1, 1, 'TUITION', 'Monthly Tuition', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'TUITION', 'College Tuition', 2, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'HIFZ', 'Hifz Tuition', 3, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `student_invoices` (`id`, `institution_id`, `student_id`, `invoice_no`, `issued_on`, `due_on`, `total_amount`, `paid_amount`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'INV-S-2026-001', '2026-11-05', '2026-11-05', '2500.00', '1000.00', 'partial', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'INV-C-2026-001', '2026-11-05', '2026-11-05', '3800.00', '800.00', 'partial', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'INV-M-2026-001', '2026-11-05', '2026-11-05', '1800.00', '500.00', 'partial', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

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
(15, 3, 9, 3, '0.00', '500.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `bank_accounts` (`id`, `institution_id`, `account_id`, `bank_name`, `account_mask`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Demo Bank', '****1001', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Demo Bank', '****2001', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Demo Bank', '****3001', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `expenses` (`id`, `institution_id`, `expense_no`, `description`, `expense_on`, `amount`, `account_id`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'EXP-S-001', 'Classroom stationery', '2026-11-05', '350.00', 1, 'draft', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 'Demo expense no', 'Demo description', '2026-11-05', '0.00', 2, 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 'Demo expense no', 'Demo description', '2026-11-05', '0.00', 3, 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `scholarship_awards` (`id`, `institution_id`, `scholarship_id`, `student_id`, `amount`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '500.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '0.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '0.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `notification_deliveries` (`id`, `institution_id`, `notification_template_id`, `student_id`, `recipient`, `channel`, `status`, `sent_at`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '01700000001', 'sms', 'queued', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 'Demo recipient', 'Demo channel', 'active', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 'Demo recipient', 'Demo channel', 'active', '2026-11-05 09:00:00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `parent_meetings` (`id`, `institution_id`, `student_id`, `employee_id`, `scheduled_at`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '2026-11-05 09:00:00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '2026-11-05 09:00:00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '2026-11-05 09:00:00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `library_copies` (`id`, `institution_id`, `library_book_id`, `barcode`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'SCH-LIB-0001', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'COL-LIB-0001', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'MAD-LIB-0001', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `transport_routes` (`id`, `institution_id`, `vehicle_id`, `employee_id`, `route_name`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'Demo route name', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 'Demo route name', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 'Demo route name', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `hostel_rooms` (`id`, `institution_id`, `hostel_id`, `room_code`, `capacity`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Demo room code', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Demo room code', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Demo room code', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `meal_plans` (`id`, `institution_id`, `hostel_id`, `name`, `monthly_rate`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Demo Meal Plans', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Demo Meal Plans', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Demo Meal Plans', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `stock_movements` (`id`, `institution_id`, `inventory_item_id`, `quantity`, `movement_type`, `reference_no`, `moved_on`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 50, 'receive', 'GRN-001', '2026-11-05', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 5, 'receive', 'GRN-002', '2026-11-05', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 15, 'receive', 'GRN-003', '2026-11-05', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `purchase_orders` (`id`, `institution_id`, `supplier_id`, `po_number`, `ordered_on`, `total_amount`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'PO-S-001', '2026-11-05', '1250.00', 'draft', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'PO-C-001', '2026-11-05', '3000.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'PO-M-001', '2026-11-05', '1800.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `asset_assignments` (`id`, `institution_id`, `fixed_asset_id`, `employee_id`, `assigned_on`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `hifz_groups` (`id`, `institution_id`, `name`, `employee_id`, `created_at`, `updated_at`) VALUES
(1, 3, 'Hifz Group A', 3, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `donations` (`id`, `institution_id`, `donor_id`, `donation_fund_id`, `receipt_no`, `amount`, `received_on`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'DON-S-001', '3000.00', '2026-11-05', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 'DON-C-001', '5000.00', '2026-11-05', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 'DON-M-001', '2500.00', '2026-11-05', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

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
(3, 3, 3, 'earning', 'Basic salary', '30000.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `student_invoice_lines` (`id`, `institution_id`, `student_invoice_id`, `fee_head_id`, `description`, `amount`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'November Tuition', '2500.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 'November College Tuition', '3800.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 'November Hifz Tuition', '1800.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `student_payments` (`id`, `institution_id`, `student_id`, `student_invoice_id`, `payment_method_id`, `amount`, `paid_on`, `reference_no`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 1, '1000.00', '2026-11-05', 'CASH-S-001', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 2, '800.00', '2026-11-05', 'BANK-C-001', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 3, '500.00', '2026-11-05', 'CASH-M-001', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `bank_reconciliations` (`id`, `institution_id`, `bank_account_id`, `statement_on`, `statement_balance`, `ledger_balance`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2026-11-05', '0.00', '0.00', 'pending', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, '2026-11-05', '0.00', '0.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, '2026-11-05', '0.00', '0.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `library_loans` (`id`, `institution_id`, `library_copy_id`, `student_id`, `issued_on`, `due_on`, `returned_on`, `fine_amount`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '2026-11-05', '2026-11-05', NULL, '0.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '2026-11-05', '2026-11-05', NULL, '0.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '2026-11-05', '2026-11-05', NULL, '0.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `transport_stops` (`id`, `institution_id`, `transport_route_id`, `name`, `stop_order`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Demo Transport Stops', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Demo Transport Stops', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Demo Transport Stops', 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `hostel_beds` (`id`, `institution_id`, `hostel_room_id`, `bed_code`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Demo bed code', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Demo bed code', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Demo bed code', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `purchase_order_lines` (`id`, `institution_id`, `purchase_order_id`, `inventory_item_id`, `quantity`, `unit_price`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 50, '25.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 5, '600.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 15, '120.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `hifz_enrollments` (`id`, `institution_id`, `student_id`, `hifz_group_id`, `started_on`, `target_juz`, `status`, `created_at`, `updated_at`) VALUES
(1, 3, 3, 1, '2026-11-05', 30, 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

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
(3, 3, 3, 3, 'APP-M-001', 'Yusuf Ali', '01700000003', '78.00', 'approved', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `examinations` (`id`, `institution_id`, `academic_session_id`, `class_level_id`, `name`, `exam_type`, `starts_on`, `ends_on`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'Annual Examination 2026', 'annual', '2026-11-05', '2026-11-05', 'published', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 'Midterm 2026', 'midterm', '2026-11-05', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 'Hifz Assessment 2026', 'oral', '2026-11-05', '2026-11-05', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `fee_plans` (`id`, `institution_id`, `class_level_id`, `academic_session_id`, `name`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'Grade 6 Monthly Fee', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 'Class XI Tuition', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 'Hifz Monthly Fee', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `payment_allocations` (`id`, `institution_id`, `student_payment_id`, `student_invoice_id`, `amount`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '1000.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '800.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '500.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `payment_refunds` (`id`, `institution_id`, `student_payment_id`, `amount`, `reason`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '100.00', 'Demonstration refund request, not posted', 'requested', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, '100.00', 'Demo only', 'requested', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, '100.00', 'Demo only', 'requested', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `student_transport_assignments` (`id`, `institution_id`, `student_id`, `transport_route_id`, `transport_stop_id`, `starts_on`, `monthly_fee`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 1, '2026-11-05', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 2, '2026-11-05', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 3, '2026-11-05', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `hostel_allocations` (`id`, `institution_id`, `student_id`, `hostel_bed_id`, `check_in_on`, `monthly_fee`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '2026-11-05', '0.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '2026-11-05', '0.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '2026-11-05', '0.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `hifz_progress_logs` (`id`, `institution_id`, `hifz_enrollment_id`, `logged_on`, `sabaq`, `sabqi`, `manzil`, `juz_completed`, `accuracy_percent`, `notes`, `created_at`, `updated_at`) VALUES
(1, 3, 1, '2026-11-05', 'Surah Al-Mulk 1-10', 'Surah Ar-Rahman', 'Juz Amma', 5, '92.00', 'Illustrative progress record', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `hifz_assessments` (`id`, `institution_id`, `hifz_enrollment_id`, `assessed_on`, `score`, `remarks`, `created_at`, `updated_at`) VALUES
(1, 3, 1, '2026-11-05', '90.00', 'Good revision', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

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
(3, 3, 3, 3, 3, '03', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `admission_offers` (`id`, `institution_id`, `admission_application_id`, `student_id`, `offered_on`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '2026-11-05', 'accepted', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '2026-11-05', 'accepted', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '2026-11-05', 'accepted', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `attendance_sessions` (`id`, `institution_id`, `class_section_id`, `attendance_on`, `period_code`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2026-11-05', 'Demo period code', 'closed', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, '2026-11-05', 'Demo period code', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, '2026-11-05', 'Demo period code', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `teacher_assignments` (`id`, `institution_id`, `employee_id`, `class_subject_id`, `academic_session_id`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 1, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, 2, '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, 3, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `exam_papers` (`id`, `institution_id`, `examination_id`, `subject_id`, `full_marks`, `pass_marks`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '100.00', '33.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '0.00', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '0.00', '0.00', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `published_results` (`id`, `institution_id`, `examination_id`, `student_id`, `percentage`, `gpa`, `result`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '86.00', '5.00', 'pass', 'published', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '91.00', '5.00', 'pass', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '83.00', '5.00', 'pass', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

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
(3, 3, 3, 3, 'late', 10, '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `exam_marks` (`id`, `institution_id`, `exam_paper_id`, `student_id`, `marks`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '86.00', 'approved', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 2, '91.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 3, '83.00', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');

INSERT INTO `exam_recheck_requests` (`id`, `institution_id`, `exam_mark_id`, `reason`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(2, 2, 2, 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00'),
(3, 3, 3, 'Fictional demonstration record', 'active', '2026-11-05 08:00:00', '2026-11-05 08:00:00');
COMMIT;
