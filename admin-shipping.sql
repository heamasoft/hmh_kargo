-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Aug 13, 2026 at 12:45 PM
-- Server version: 8.0.46-0ubuntu0.24.04.3
-- PHP Version: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `admin-shipping`
--

-- --------------------------------------------------------

--
-- Table structure for table `accounts`
--

CREATE TABLE `accounts` (
  `id` bigint UNSIGNED NOT NULL,
  `plan` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `balance_iqd` bigint NOT NULL DEFAULT '0',
  `note` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `currency` varchar(4) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'IQD'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `accounts`
--

INSERT INTO `accounts` (`id`, `plan`, `type`, `name`, `balance_iqd`, `note`, `created_at`, `updated_at`, `currency`) VALUES
(1, 'shein', 'fund', 'Ahmed', 10422, NULL, '2026-07-14 13:48:34', '2026-08-12 16:53:33', 'IQD'),
(2, 'shein', 'fund', 'Salim', 0, NULL, '2026-07-14 13:48:44', '2026-07-14 13:48:44', 'IQD'),
(3, 'shein', 'card', 'Ahmed Serdar (zain)', -85562855, NULL, '2026-07-14 13:49:20', '2026-08-12 22:16:52', 'IQD'),
(4, 'shein', 'card', 'Ahmed (FIB)', -6006432, NULL, '2026-07-14 13:49:37', '2026-08-12 21:52:30', 'IQD'),
(5, 'turkish', 'card', 'ahmed ziraat', 474103, NULL, '2026-07-25 13:27:27', '2026-08-12 21:49:12', 'TL'),
(6, 'turkish', 'fund', 'main', 1071, NULL, '2026-07-30 12:36:42', '2026-08-10 14:58:02', 'USD'),
(7, 'turkish', 'fund', 'Main Dinar', 480531, '', '2026-07-30 13:35:30', '2026-08-10 14:53:51', 'IQD');

-- --------------------------------------------------------

--
-- Table structure for table `account_transfers`
--

CREATE TABLE `account_transfers` (
  `id` bigint UNSIGNED NOT NULL,
  `plan` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `from_id` bigint UNSIGNED NOT NULL,
  `to_id` bigint UNSIGNED NOT NULL,
  `from_amount` decimal(14,2) NOT NULL,
  `to_amount` decimal(14,2) NOT NULL,
  `rate` decimal(18,6) NOT NULL DEFAULT '1.000000',
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `account_transfers`
--

INSERT INTO `account_transfers` (`id`, `plan`, `from_id`, `to_id`, `from_amount`, `to_amount`, `rate`, `note`, `created_at`) VALUES
(1, 'turkish', 5, 7, 3750.00, 103500.00, 27.600000, NULL, '2026-07-30 14:22:52'),
(2, 'turkish', 5, 7, 6233.00, 172030.80, 27.600000, NULL, '2026-07-30 14:36:51');

-- --------------------------------------------------------

--
-- Table structure for table `addresses`
--

CREATE TABLE `addresses` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `recipient_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `governorate` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `street` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `addresses`
--

INSERT INTO `addresses` (`id`, `user_id`, `recipient_name`, `governorate`, `city`, `street`, `phone`, `note`, `is_default`, `created_at`, `updated_at`) VALUES
(1, 3, 'shimal', 'دهوك', 'زاخو', 'New zako', '7504848085', NULL, 1, '2026-07-07 08:55:08', '2026-07-07 08:55:08'),
(2, 3, 'shimal', 'كركوك', 'الحويجة', 'Ttt', '7504848085', NULL, 0, '2026-07-07 08:57:15', '2026-07-07 08:57:15'),
(3, 8, 'taha new', 'أربيل', 'شقلاوة', 'Rre', '7501122334', NULL, 1, '2026-07-09 11:14:49', '2026-07-09 11:14:49'),
(4, 13, 'shimal sendi', 'دهوك', 'زاخو', 'New zakhi', '7504845522', NULL, 1, '2026-08-08 10:51:27', '2026-08-08 10:51:27'),
(5, 14, 'user1', 'دهوك', 'زاخو', 'kurnish', '7518016694', NULL, 1, '2026-08-08 12:02:14', '2026-08-08 12:02:14');

-- --------------------------------------------------------

--
-- Table structure for table `admin_notifications`
--

CREATE TABLE `admin_notifications` (
  `id` bigint UNSIGNED NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'order_cancelled',
  `order_id` bigint UNSIGNED DEFAULT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `order_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text COLLATE utf8mb4_unicode_ci,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admin_notifications`
--

INSERT INTO `admin_notifications` (`id`, `type`, `order_id`, `user_id`, `order_code`, `title`, `body`, `read_at`, `created_at`, `updated_at`) VALUES
(1, 'order_cancelled', 14, 3, 'HM-20014', 'Order HM-20014 cancelled', 'shimal cancelled HM-20014 · 30,450 IQD · COD', NULL, '2026-07-07 13:18:05', '2026-07-07 13:18:05'),
(2, 'order_cancelled', 11, 3, 'HM-20011', 'Order HM-20011 cancelled', 'shimal cancelled HM-20011 · 32,050 IQD · wallet (refunded)', NULL, '2026-07-07 13:18:19', '2026-07-07 13:18:19'),
(3, 'order_cancelled', 40, 3, 'HM-20040', 'Order HM-20040 cancelled', 'hh cancelled HM-20040 · 60,750 IQD · wallet (refunded)', NULL, '2026-07-14 14:47:07', '2026-07-14 14:47:07'),
(4, 'order_cancelled', 48, 3, 'HM-20048', 'Order HM-20048 cancelled', 'hh cancelled HM-20048 · $12.75 · wallet (refunded)', NULL, '2026-07-23 09:43:59', '2026-07-23 09:43:59'),
(5, 'order_cancelled', 49, 3, 'HM-20049', 'Order HM-20049 cancelled', 'hh cancelled HM-20049 · $27.25 · wallet (refunded)', NULL, '2026-07-23 09:44:03', '2026-07-23 09:44:03'),
(6, 'order_cancelled', 47, 3, 'HM-20047', 'Order HM-20047 cancelled', 'hh cancelled HM-20047 · 12,250 IQD · wallet (refunded)', NULL, '2026-07-23 09:44:12', '2026-07-23 09:44:12'),
(7, 'order_cancelled', 50, 3, 'HM-20050', 'Order HM-20050 cancelled', 'hh cancelled HM-20050 · $12.75 · wallet (refunded)', NULL, '2026-07-23 09:44:14', '2026-07-23 09:44:14'),
(8, 'order_cancelled', 51, 3, 'HM-20051', 'Order HM-20051 cancelled', 'hh cancelled HM-20051 · $32.50 · wallet (refunded)', NULL, '2026-07-23 09:44:15', '2026-07-23 09:44:15'),
(9, 'order_cancelled', 52, 3, 'HM-20052', 'Order HM-20052 cancelled', 'hh cancelled HM-20052 · 160,500 IQD · wallet (refunded)', NULL, '2026-07-23 09:44:20', '2026-07-23 09:44:20'),
(10, 'order_cancelled', 53, 3, 'HM-20053', 'Order HM-20053 cancelled', 'hh cancelled HM-20053 · $12.75 · wallet (refunded)', NULL, '2026-07-23 09:44:22', '2026-07-23 09:44:22'),
(11, 'order_cancelled', 88, 13, 'HM-20088', 'Order HM-20088 cancelled', 'shimal sendi cancelled HM-20088 · 1,750 IQD · wallet (refunded)', NULL, '2026-08-08 11:32:12', '2026-08-08 11:32:12'),
(12, 'order_cancelled', 89, 13, 'HM-20089', 'Order HM-20089 cancelled', 'shimal sendi cancelled HM-20089 · $11.57 · COD (refunded)', NULL, '2026-08-08 12:28:24', '2026-08-08 12:28:24'),
(13, 'order_cancelled', 87, 13, 'HM-20087', 'Order HM-20087 cancelled', 'shimal sendi cancelled HM-20087 · $31.25 · wallet (refunded)', NULL, '2026-08-08 12:32:56', '2026-08-08 12:32:56');

-- --------------------------------------------------------

--
-- Table structure for table `admin_tokens`
--

CREATE TABLE `admin_tokens` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `token_hash` char(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admin_tokens`
--

INSERT INTO `admin_tokens` (`id`, `user_id`, `token_hash`, `created_at`, `last_used_at`) VALUES
(2, 1, 'ae3054fce3a23035d2a67bfd325645473aafc927ffd795fe7f4395c8a6a58a58', '2026-07-07 15:26:14', '2026-07-07 15:26:36'),
(4, 2, 'd1200b309e3be2a4dec609d5be45602023c41287fcd0265739fbcdf8913c2b35', '2026-07-08 15:46:25', '2026-07-08 15:46:36'),
(6, 2, '535e94a6c1d74cfd1067759ac228c406404345062b3add3e1d7f1563962c4ef3', '2026-07-09 13:28:51', '2026-07-09 13:36:56'),
(7, 1, '73ea86e0007223998f4fc289189e82c9558701935eec75d938977d9be5219e16', '2026-07-09 14:10:17', '2026-07-09 14:45:21'),
(8, 1, '85810cac4c14909df181b1b75b6ea04d355556865a54ec695cda8dd3dea8ecd4', '2026-07-11 08:10:47', '2026-07-11 09:20:59'),
(9, 1, '3416d9dfab20e059808c6808d3ca10ad1fff7b70f31114652897f71c0546b799', '2026-07-11 09:26:01', '2026-07-11 09:32:32'),
(11, 2, '50031a332bf25eb351ede7bd1e33e38f2be22c9f7bb81cd58d5251563726e9b2', '2026-07-11 12:50:28', '2026-07-11 13:48:06'),
(12, 2, 'a65e4f5c6c7886729bf6af9d96fcb18c3aebdb64b3ea4bee9a8f1514e9b8e85d', '2026-07-11 13:49:53', '2026-07-11 14:16:29'),
(13, 2, 'aa778ef60439a4d636670c701699f9e38ce33e8b7ac16ab4b12663e615011929', '2026-07-11 14:18:59', '2026-07-11 14:20:34'),
(15, 2, '5a5b2c612c006635e1d0cb0459ae921e0315f28de426b4fd3939ab4966436fdb', '2026-07-14 08:31:31', '2026-07-14 09:34:34'),
(19, 3, '0233d819a5e06cde4159ebafc44f678383230b6e9aaf0aa5656b52f0fb641efe', '2026-07-14 13:03:39', NULL),
(21, 3, '6273626ee486369fc34d8daaf8e29bc30883e1b645ab553b7e0cf44871ad50c6', '2026-07-14 13:06:11', '2026-07-14 13:52:03'),
(22, 3, 'ea552fd0852b806a36e7c8ad1e58adca79379def6012f916f331975d391d8ee9', '2026-07-14 14:27:46', '2026-07-14 15:50:46'),
(24, 3, '38155f13e615dafff9f4faab7df937f9ca217ff2719f4ac843e6fe4e64145b15', '2026-07-15 13:09:18', '2026-07-15 13:36:19'),
(25, 3, '410c9855b96353216bd6d08838ae5ff7463edece421a01a5961eeaf337fb6abb', '2026-07-15 15:13:57', '2026-07-15 15:54:58'),
(26, 3, 'dfebba974df8a0af87ae2f92c3ed743fcffaa474bdad227e55cbb84afaab4514', '2026-07-16 12:40:39', '2026-07-16 13:32:12'),
(27, 3, '6908b1c8677aa3cc4e879b22da72f3c61765680442bd66834c1d5c92666638d4', '2026-07-16 13:33:37', '2026-07-16 14:02:53'),
(28, 3, '6506ae9be8b36ca94fe93eb9053d1c90207aeccbece16c746631ad45ecf66c57', '2026-07-16 14:04:32', '2026-07-16 14:36:43'),
(29, 3, '07ef9d63c1fa1895053845ad4299979ad11d500a8140eb092c2f4306155a8550', '2026-07-21 13:33:30', '2026-07-21 15:04:36'),
(32, 3, '780bbf7f0fdd0e4fba02cd090e9e896effa61df092ec3576489edbb05f33d49b', '2026-07-22 13:50:18', '2026-07-25 13:27:40'),
(33, 3, '812cecddf3196380e9f786210e771cf49ceb43c904996b059dcd641bf94e8b50', '2026-07-23 15:46:16', '2026-07-23 15:55:04'),
(34, 3, '055173c1744c3ab3c1facac2b37eee50c49bfa52fbb21efec83cab35b2bcc989', '2026-07-24 20:16:48', '2026-07-24 20:31:38'),
(35, 3, '9051dbd58ed2795cdbfcf397bc3118777395041c10279935bde2236cade3ddf6', '2026-07-24 20:33:04', '2026-07-24 20:33:46'),
(36, 3, 'f041b32b94d58dba110aa5ecab74c277a3d5c47035d09f2cec5f4f95efa85ccc', '2026-07-25 06:58:37', '2026-07-25 09:06:01'),
(37, 3, '091605d1c07f675b24279ae67e3b7c11767036c8fdde2200e1e6e62ec48bfc28', '2026-07-25 09:08:03', '2026-07-25 09:57:19'),
(38, 3, '8f92ebe0d8b7d452975ab888314a5eefbd7d88363fb3b1bd9bf7b8849dbc8d2d', '2026-07-28 13:37:36', '2026-07-29 13:09:22'),
(39, 3, '555163a75da30b800794a1f0e1f01b36e434f28630dec82a23781e1b19e7c610', '2026-07-29 13:31:12', '2026-07-29 13:31:14'),
(40, 3, '299e997a985851457119c48aeeb33b7958b56c30f502a2d210298e5047b6386e', '2026-07-29 15:14:09', '2026-07-29 15:17:33'),
(41, 3, 'ae96b626abb173a908f2ddb28fa450bc31ce47e0b19ba5e3069d40378a0b3d4b', '2026-07-30 12:00:51', '2026-07-30 15:35:58'),
(42, 3, 'dbe7bb9fc1f54352b033055cd4897d592c83a10796bf62834d3470d912594a4a', '2026-07-31 06:13:03', '2026-07-31 09:34:00'),
(43, 3, 'd00f3623b4cd95851dbd986d2916711e463d7af6ff81a8bd8586104a9bd89120', '2026-07-31 13:03:12', '2026-07-31 13:03:19'),
(44, 3, 'c9bafc22a20f6c0c659c5f9806ea58c761bec834f2269a82884175af24fa97da', '2026-07-31 13:15:59', '2026-07-31 13:18:47'),
(45, 3, '776f9a387f666a7210f57f4cf54e64a169d30610230aafb821aa4a4f6c26a0bc', '2026-07-31 13:28:51', '2026-07-31 13:29:40'),
(46, 3, '0a878b36dc84e6afc96219e248b74262c53dddf9c49224f57ffed95bfd83502d', '2026-07-31 13:45:51', '2026-07-31 14:27:58'),
(47, 3, 'cc0347471754da4fcdf4ca25aac5a7222d2cd7fb7c9e3c8a4cee17e968f77655', '2026-08-01 07:40:30', '2026-08-02 17:51:25'),
(48, 3, '9fbadd02afd00bf1267059b6de3f709f5b47bd9cf3b7d1a6743f802a0f86a5d8', '2026-08-02 13:13:43', '2026-08-02 13:33:50'),
(49, 3, '8c46f19a4f368c5a98dbe4307723be0be60c5d6d12fac974b000778f71fbe0e9', '2026-08-02 17:55:41', '2026-08-02 18:14:19'),
(50, 3, '592d1a15516355d72be9b273eec3798318427e24293766de7fe73dee1096cae9', '2026-08-04 13:15:49', '2026-08-04 19:27:56'),
(51, 3, 'b23ffa8123b7e8a4bab5bb9a503479b373585e7189add097c79de91c51d618f4', '2026-08-05 13:44:11', '2026-08-05 15:52:21'),
(53, 3, '28a577005992e473c188675c1cc7e0f4bf71d86efab249c88f400f94563bf9f5', '2026-08-06 12:17:18', '2026-08-06 13:40:09'),
(54, 3, '281536846762bcb152cf5b38df3c36ea0cdd7a8918182dd1130b591ae8a38b3a', '2026-08-07 07:32:59', '2026-08-08 11:49:43'),
(55, 3, '3b81550e293869dc09cc5fc9d4d679e1d73771966e85d223e459fa89869ca65b', '2026-08-09 12:57:44', '2026-08-10 15:23:57'),
(56, 3, 'b5abf39ce671610ced8918ea0ecf23eb3571205d5ad0c10b1cfde8784775217d', '2026-08-11 12:51:53', '2026-08-11 12:54:33'),
(58, 3, 'abef3b52c5a300f3159a2a485af5a9f93c40d23ba73d19e58f99c500bc25ea28', '2026-08-11 13:48:22', '2026-08-11 14:34:50'),
(59, 3, '36a2edf3998c87dd51ea0be17b3a7eb2b3d5e9063b13dc2bf91cf182de05be06', '2026-08-12 14:28:36', '2026-08-12 14:28:44'),
(60, 3, '8a9aa9de3b22d3acd43ea5a4ce60f4f65cbf2e4d4905e41c5bd9572f4c76f915', '2026-08-12 14:33:41', '2026-08-12 14:33:42'),
(61, 3, 'd317d797c906e2933479c7c6f76c6734cce03bf8f01559e4ca863106492bf572', '2026-08-12 14:45:27', '2026-08-12 14:45:28'),
(67, 3, '17b38250de2eabd0d8f1544ca64a76cd8dc6f49b60e6d2bdc3b887becf913822', '2026-08-12 16:04:59', '2026-08-12 16:08:01'),
(74, 3, 'e807a3654b79fa0b323948a5073bb2100f3c2748bd635cc63043e73c92e9dccf', '2026-08-12 17:20:35', '2026-08-13 09:51:10'),
(75, 3, '3e2df634c8122bb930b9de0986760bb55df9fcff41adf142f40f074b66472e5f', '2026-08-12 18:15:07', '2026-08-12 18:15:43'),
(76, 3, 'dcd20a51b4466ce3677b59b097c79d2dc20b65da28788bc4287709b342eeec1f', '2026-08-13 11:57:31', '2026-08-13 12:45:22');

-- --------------------------------------------------------

--
-- Table structure for table `admin_users`
--

CREATE TABLE `admin_users` (
  `id` bigint UNSIGNED NOT NULL,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `plan` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `role_id` bigint UNSIGNED DEFAULT NULL,
  `permissions_override` text COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admin_users`
--

INSERT INTO `admin_users` (`id`, `username`, `name`, `password`, `plan`, `is_active`, `created_at`, `updated_at`, `role_id`, `permissions_override`) VALUES
(1, 'shein', 'Shein Admin', '$2y$10$EGjSkYeX39.hTK5BV2zS0Ocwpzu9a6Di1g1yeiMsD2OUJKo7SYUCC', 'shein', 1, '2026-07-08 15:40:30', '2026-08-10 13:43:21', NULL, '{\"users.manage\":false}'),
(2, 'turkish', 'Turkish Admin', '$2y$10$SLxDzW9cMoomUiafCdWUUepHXrWFAHvbKqWmcYxfyoqdEV9kn6qie', 'turkish', 1, '2026-07-08 15:40:30', '2026-07-08 15:40:30', NULL, NULL),
(3, 'super', 'Super Admin', '$2y$10$qYOoSZ/6Df2B8YVbo3sWUOCgYytkF2PtsyggXgmm4HC2iQvwmJ2bq', 'both', 1, '2026-07-14 13:00:17', '2026-07-14 13:00:17', NULL, NULL),
(4, 'istanbul', 'istanbulofis', '$2y$10$v77xeE9pat9gLWs9AUGCoeMe/lkH9cVn9c319FA32.zVQC8tF4qqS', 'turkish', 1, '2026-08-12 17:12:33', '2026-08-12 17:17:28', NULL, '{\"page.bought\":true}');

-- --------------------------------------------------------

--
-- Table structure for table `boxes`
--

CREATE TABLE `boxes` (
  `id` bigint UNSIGNED NOT NULL,
  `plan` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `card_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `paid_price_iqd` bigint DEFAULT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `terminated_at` timestamp NULL DEFAULT NULL,
  `card_id` bigint UNSIGNED DEFAULT NULL,
  `card_amount` decimal(14,2) DEFAULT NULL,
  `card_currency` varchar(4) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `boxes`
--

INSERT INTO `boxes` (`id`, `plan`, `label`, `card_name`, `paid_price_iqd`, `note`, `created_at`, `updated_at`, `terminated_at`, `card_id`, `card_amount`, `card_currency`) VALUES
(1, 'shein', 'shein100', 'Ahmed Serdar (zain)', 155000, NULL, '2026-07-11 12:13:32', '2026-08-09 13:44:14', NULL, 3, 155000.00, 'IQD'),
(2, 'turkish', 'TRE 600', 'ahmed ziraat', NULL, NULL, '2026-07-11 12:51:21', '2026-08-10 14:57:35', '2026-08-01 13:24:32', 5, 90.00, 'TL'),
(3, 'turkish', 'tr1', 'ahmed ziraat', NULL, NULL, '2026-07-14 08:38:40', '2026-07-31 13:17:35', NULL, 5, 17.00, 'TL'),
(4, 'shein', 'SH 100', 'Ahmed (FIB)', 23000, NULL, '2026-07-14 13:23:35', '2026-08-12 23:03:26', '2026-08-12 23:03:26', 4, 23000.00, 'IQD'),
(5, 'turkish', 'ggg 800', 'ahmed ziraat', NULL, NULL, '2026-07-14 14:43:40', '2026-07-25 13:27:35', NULL, 5, 17.00, 'TL'),
(6, 'turkish', '4545458', 'ahmed ziraat', NULL, NULL, '2026-07-31 14:20:59', '2026-07-31 14:22:24', NULL, 5, 40.00, 'TL'),
(7, 'turkish', 'hep22', 'ahmed ziraat', NULL, NULL, '2026-08-01 07:41:33', '2026-08-01 13:57:35', '2026-08-01 13:57:35', 5, 53.00, 'TL'),
(8, 'turkish', '123456', 'ahmed ziraat', NULL, NULL, '2026-08-01 08:26:37', '2026-08-01 08:29:15', '2026-08-01 08:29:15', 5, 320.00, 'TL'),
(9, 'turkish', '432434', 'ahmed ziraat', NULL, NULL, '2026-08-01 13:56:50', '2026-08-02 12:37:07', '2026-08-02 12:37:07', 5, 11.00, 'TL'),
(10, 'turkish', '123456', 'ahmed ziraat', NULL, NULL, '2026-08-02 17:43:09', '2026-08-02 17:46:56', '2026-08-02 17:46:37', 5, 31.00, 'TL'),
(11, 'turkish', '98988787', 'ahmed ziraat', NULL, NULL, '2026-08-02 17:48:02', '2026-08-05 15:08:33', '2026-08-05 15:08:33', 5, 7.00, 'TL'),
(12, 'turkish', '99999', 'ahmed ziraat', NULL, NULL, '2026-08-02 18:02:22', '2026-08-02 18:04:17', '2026-08-02 18:04:17', 5, 12417.00, 'TL'),
(13, 'turkish', '9999999', 'ahmed ziraat', NULL, NULL, '2026-08-05 15:05:50', '2026-08-05 15:06:46', NULL, 5, 150.00, 'TL'),
(14, 'turkish', '5454', 'ahmed ziraat', NULL, NULL, '2026-08-05 15:51:32', '2026-08-06 13:06:30', '2026-08-06 13:06:30', 5, 36.00, 'TL'),
(15, 'turkish', 'wq', 'ahmed ziraat', NULL, NULL, '2026-08-08 09:27:57', '2026-08-08 09:28:13', '2026-08-08 09:28:13', 5, 12.00, 'TL'),
(16, 'shein', '12', 'Ahmed (FIB)', 5286863, '12222', '2026-08-12 15:36:05', '2026-08-12 22:01:28', '2026-08-12 22:01:28', 4, 5286863.00, 'IQD'),
(17, 'shein', '12345', 'Ahmed (FIB)', 50000, NULL, '2026-08-12 16:42:19', '2026-08-12 22:11:39', '2026-08-12 22:11:39', 4, 50000.00, 'IQD'),
(18, 'turkish', '125', 'ahmed ziraat', NULL, NULL, '2026-08-12 17:34:44', '2026-08-12 17:43:28', '2026-08-12 17:41:28', 5, 14.00, 'TL'),
(19, 'turkish', '1569', 'ahmed ziraat', NULL, NULL, '2026-08-12 17:37:08', '2026-08-12 17:39:08', NULL, 5, 6.00, 'TL'),
(20, 'turkish', '6969698', 'ahmed ziraat', NULL, NULL, '2026-08-12 17:37:32', '2026-08-12 21:51:14', '2026-08-12 21:45:13', 5, 26.00, 'TL'),
(21, 'turkish', '2525', 'ahmed ziraat', NULL, NULL, '2026-08-12 17:39:43', '2026-08-12 17:40:00', NULL, 5, 11.00, 'TL'),
(22, 'turkish', '252525', 'ahmed ziraat', NULL, '255', '2026-08-12 21:41:27', '2026-08-12 21:51:18', '2026-08-12 21:45:16', 5, 11.00, 'TL'),
(23, 'turkish', '55555', 'ahmed ziraat', NULL, NULL, '2026-08-12 21:43:17', '2026-08-12 21:51:23', '2026-08-12 21:45:19', 5, 40.00, 'TL'),
(24, 'turkish', '55555', 'ahmed ziraat', NULL, NULL, '2026-08-12 21:44:20', '2026-08-13 12:45:12', '2026-08-12 21:45:21', 5, 40.00, 'TL'),
(25, 'turkish', '66666', 'ahmed ziraat', NULL, NULL, '2026-08-12 21:44:46', '2026-08-13 12:45:17', '2026-08-12 21:45:30', 5, 13.00, 'TL'),
(26, 'turkish', '55555', 'ahmed ziraat', NULL, NULL, '2026-08-12 21:47:20', '2026-08-12 22:44:53', '2026-08-12 22:44:53', 5, 15.00, 'TL'),
(27, 'turkish', '33333', 'ahmed ziraat', NULL, NULL, '2026-08-12 21:47:40', '2026-08-12 23:22:23', '2026-08-12 23:22:23', 5, 15.00, 'TL'),
(28, 'turkish', '1111', 'ahmed ziraat', NULL, NULL, '2026-08-12 21:48:18', '2026-08-12 21:49:18', '2026-08-12 21:49:18', 5, 11.00, 'TL'),
(29, 'turkish', '33333', 'ahmed ziraat', NULL, NULL, '2026-08-12 21:48:53', '2026-08-12 21:49:12', NULL, 5, 11.00, 'TL'),
(30, 'shein', '5555', 'Ahmed (FIB)', 656569, NULL, '2026-08-12 21:52:03', '2026-08-12 22:51:00', '2026-08-12 22:51:00', 4, 656569.00, 'IQD'),
(31, 'shein', '252525', 'Ahmed Serdar (zain)', 85558855, NULL, '2026-08-12 22:15:48', '2026-08-13 12:44:54', '2026-08-12 22:50:58', 3, 85558855.00, 'IQD');

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cache`
--

INSERT INTO `cache` (`key`, `value`, `expiration`) VALUES
('hmh-kargo-cache-setting:free_stores', 's:5:\"shein\";', 1786544982),
('hmh-kargo-cache-setting:service_fee_percent', 's:1:\"0\";', 1786544982),
('hmh-kargo-cache-setting:shipping_usd', 's:1:\"2\";', 1786544982);

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `carts`
--

CREATE TABLE `carts` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `carts`
--

INSERT INTO `carts` (`id`, `user_id`, `created_at`, `updated_at`) VALUES
(1, 1, '2026-07-04 10:27:49', '2026-07-04 10:27:49'),
(2, 2, '2026-07-04 14:30:02', '2026-07-04 14:30:02'),
(3, 3, '2026-07-04 14:32:02', '2026-07-04 14:32:02'),
(4, 4, '2026-07-05 12:25:17', '2026-07-05 12:25:17'),
(5, 5, '2026-07-07 08:37:46', '2026-07-07 08:37:46'),
(6, 6, '2026-07-09 08:58:57', '2026-07-09 08:58:57'),
(7, 7, '2026-07-09 09:14:09', '2026-07-09 09:14:09'),
(8, 8, '2026-07-09 09:21:15', '2026-07-09 09:21:15'),
(9, 9, '2026-07-14 14:42:05', '2026-07-14 14:42:05'),
(10, 13, '2026-08-08 10:50:42', '2026-08-08 10:50:42'),
(11, 14, '2026-08-08 11:53:17', '2026-08-08 11:53:17');

-- --------------------------------------------------------

--
-- Table structure for table `cart_items`
--

CREATE TABLE `cart_items` (
  `id` bigint UNSIGNED NOT NULL,
  `cart_id` bigint UNSIGNED NOT NULL,
  `store_id` bigint UNSIGNED DEFAULT NULL,
  `source_url` varchar(1024) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_url` varchar(1024) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `source_price` decimal(12,2) NOT NULL,
  `source_currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USD',
  `charge_currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'IQD',
  `iqd_price` decimal(14,2) NOT NULL DEFAULT '0.00',
  `color` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `size` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sku` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `qty` int UNSIGNED NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cart_items`
--

INSERT INTO `cart_items` (`id`, `cart_id`, `store_id`, `source_url`, `title`, `image_url`, `source_price`, `source_currency`, `charge_currency`, `iqd_price`, `color`, `size`, `sku`, `note`, `qty`, `created_at`, `updated_at`) VALUES
(142, 11, 7, 'https://www.trendyol.com/icollagen/kolajen-ve-prebiyotik-tablet-p-752356123?boutiqueId=61&merchantId=1013507', 'icollagen Kolajen Ve Prebiyotik Tablet', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1000406/product/media/images/prod/PIM/20260616/14/05dbc866-fefa-461e-b2ba-542bc959ae33/1_org_zoom.jpg', 350.00, 'TRY', 'USD', 8.25, NULL, NULL, NULL, NULL, 1, '2026-08-08 14:50:33', '2026-08-08 14:50:33'),
(148, 3, 7, 'https://www.trendyol.com/momordica/coconut-mix-250-ml-p-974364895?boutiqueId=61&merchantId=1024688', 'MOMORDİCA Coconut Mix - 250 ml', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1000032/product/media/images/prod/PIM/20251106/14/dadfe838-2bf9-4532-8f72-cb67720fafa8/1_org_zoom.jpg', 217.29, 'TRY', 'USD', 4.35, 'saat', '21', NULL, NULL, 1, '2026-08-11 14:42:41', '2026-08-11 14:42:41');

-- --------------------------------------------------------

--
-- Table structure for table `customer_status`
--

CREATE TABLE `customer_status` (
  `user_id` bigint UNSIGNED NOT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `blocked_at` timestamp NULL DEFAULT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `customer_status`
--

INSERT INTO `customer_status` (`user_id`, `verified_at`, `blocked_at`, `note`, `updated_at`) VALUES
(8, '2026-07-09 14:27:42', NULL, NULL, '2026-07-09 14:27:42'),
(9, '2026-07-14 15:13:13', NULL, NULL, '2026-07-14 15:13:13');

-- --------------------------------------------------------

--
-- Table structure for table `device_tokens`
--

CREATE TABLE `device_tokens` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `platform` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT 'android',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `device_tokens`
--

INSERT INTO `device_tokens` (`id`, `user_id`, `token`, `platform`, `created_at`, `updated_at`) VALUES
(1, 13, 'fbfKBi4oSNeg-xQ_v9lnsK:APA91bEW2orn_oycgY7pnJYqVkQFncSrMyRV6Z9eIswoBYS2jAoEgDjdUoB_F5z5CgNHzUawJIzHAW-SMvZ4HJ_nY4WKPUAiYzBcGjLdQejYLwWofpCxiUI', 'android', '2026-08-08 10:51:33', '2026-08-08 10:51:33'),
(3, 14, 'e-g8iH2bTrW_57ib6PkWhs:APA91bGq257z0wMGBsLmqQQwIG6On4GQHyPM9fSn66_6ctfbKLJSWQk8DNpqfnUwPQA9LUXYMQtMI_lFWgi4KNMEHHC7C0o2Nbde3bYSpntBuLJ3ofuxtls', 'android', '2026-08-08 14:46:02', '2026-08-08 14:46:02'),
(4, 3, 'ey_ek6vBSqe-rG-Q52NtBg:APA91bFu0NJJdnyWsula8-k7mUdHQc6yYoalxYv_AiO6btO9PdF6l-3Cvh-URyuTfict_vbNePs6mwr2ASTqtmHvlCiG9Yt6cNcu_JaWDd_csPdj4R5mmic', 'android', '2026-08-12 17:28:42', '2026-08-12 17:28:42');

-- --------------------------------------------------------

--
-- Table structure for table `expenses`
--

CREATE TABLE `expenses` (
  `id` bigint UNSIGNED NOT NULL,
  `plan` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `account_id` bigint UNSIGNED DEFAULT NULL,
  `amount_iqd` bigint NOT NULL,
  `category` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `spent_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `expenses`
--

INSERT INTO `expenses` (`id`, `plan`, `account_id`, `amount_iqd`, `category`, `note`, `spent_at`, `created_at`) VALUES
(2, 'turkish', 7, 35000, 'shipew', 'noteee', '2026-07-30 15:33:10', '2026-07-30 15:33:10'),
(3, 'turkish', NULL, 51825, 'Stock', 'Stocked HM-20071', '2026-08-10 14:13:24', '2026-08-10 14:13:24'),
(4, 'turkish', 5, 2500, NULL, NULL, '2026-08-10 14:53:36', '2026-08-10 14:53:36'),
(5, 'turkish', 7, 10000, NULL, NULL, '2026-08-10 14:53:51', '2026-08-10 14:53:51'),
(6, 'turkish', NULL, 27000, 'Stock', 'Stocked HM-20071', '2026-08-10 14:57:35', '2026-08-10 14:57:35'),
(7, 'shein', NULL, 10422, 'Stock', 'Stocked HM-20115', '2026-08-12 16:53:07', '2026-08-12 16:53:07'),
(8, 'shein', NULL, 30551, 'Stock', 'Stocked HM-20118', '2026-08-13 12:44:54', '2026-08-13 12:44:54'),
(9, 'turkish', NULL, 56700, 'Stock', 'Stocked HM-20101', '2026-08-13 12:45:12', '2026-08-13 12:45:12'),
(10, 'turkish', NULL, 20196, 'Stock', 'Stocked HM-20100', '2026-08-13 12:45:17', '2026-08-13 12:45:17');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `favorites`
--

CREATE TABLE `favorites` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `item_key` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `store` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `store_id` bigint UNSIGNED DEFAULT NULL,
  `source_url` varchar(1024) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `iqd_price` bigint NOT NULL DEFAULT '0',
  `image_url` varchar(1024) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `favorites`
--

INSERT INTO `favorites` (`id`, `user_id`, `item_key`, `name`, `store`, `store_id`, `source_url`, `iqd_price`, `image_url`, `created_at`, `updated_at`) VALUES
(6, 3, 'web-461733061', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Women-s-Black-Large-Capacity-Tote-Bag-Minimalist-PU-Leather-Shoulder-Handbag-Button-Closure-Fashion-Commuter-Office-Bag-Suitable-For-Office-And-School-p-49563156.html?mallCode=1&imgRatio=3-4&pageFrom=page_flash_sale&src_module=all&src_tab_page_id=page_home1783427385428&src_identifier=on=CODE_IMAGE_COMPONENT`cn=policy`hz=-`jc=flashSale_`ps=2_2&detailBusinessFrom=0-2', 5750, 'https://img.ltwebstatic.com/v4/j/spmp/2026/03/09/f9/1773038443f673d71ea919286194cb382f4bc5eb3c_thumbnail_750x999.avif', '2026-07-07 12:29:57', '2026-07-07 12:29:57'),
(8, 3, 'web-689982399', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Black-Large-Capacity-Women-s-Tote-Bag-Minimalist-PU-Leather-Shoulder-Handbag-Button-Closure-Fashion-Commute-Office-School-Bag-p-60311929.html?detailBusinessFrom=0-2&imgRatio=3-4&isFromSwitchColor=1&main_attr=27_140&mallCode=1&pageFrom=page_flash_sale&sceneFlag=&src_identifier=on%3DCODE_IMAGE_COMPONENT%60cn%3Dpolicy%60hz%3D-%60jc%3DflashSale_%60ps%3D2_2&src_module=all&src_tab_page_id=page_home1783427385428', 24500, 'https://img.ltwebstatic.com/images3_spmp/2025/03/08/03/17414468957924757b36fb25008517536094c8cd8a_thumbnail_750x999.avif', '2026-07-07 12:30:32', '2026-07-07 12:30:32'),
(9, 3, 'web-1065095564', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Tween-Girls-Bowknot-Backless-Deep-V-Mesh-Princess-Dress-Suitable-For-Easter-Birthday-Parties-Pageants-Weddings-Formal-Occasions-p-37727135.html?attr_ids=109_59&detailBusinessFrom=0-1_37727135%257C0-2&imgRatio=3-4&isAppointMall=&mallCode=1&pageListType=4&showFeedbackRec=1&src_identifier=fc%253Dkids%2560sc%253DJust%2520for%2520You%2560tc%253DPicks%2520for%2520You%2560oc%253DTween%2520Girls%2520Partywear%2560ps%253Dtab04navbar01menu01dir2%2560jc%253Dreal_2382&src_module=cat&src_tab_page_id=page_real_class1783501531325', 60750, 'https://img.ltwebstatic.com/v4/j/spmp/2026/05/19/4d/1779181097f491a4ddf985df564257679b777ee1fc_thumbnail_750x999.webp', '2026-07-08 09:06:32', '2026-07-08 09:06:32'),
(10, 3, 'web-211029430', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Men-s-Lightweight-Drawstring-Waist-Slant-Pocket-Solid-Color-Casual-Pants-p-97014220.html?mallCode=1&imgRatio=3-4&pageFrom=page_super_deals&src_module=all&src_tab_page_id=page_home1783517788049&src_identifier=on=FLEXIBLE_LAYOUT_COMPONENT`cn=superdeals`hz=refresh_0`jc=thriftyFind_`ps=4_1_3&detailBusinessFrom=0-2', 17750, 'https://img.ltwebstatic.com/v4/p/spmp/2025/11/10/5c/176277424536d7565b0165101a931d176aa1e0e589_thumbnail_750x999.avif', '2026-07-08 13:36:45', '2026-07-08 13:36:45'),
(12, 3, 'web-784200109', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/-Size-Runs-Small-Casual-Men-s-Random-Print-Low-Top-Flat-Sports-Sneakers-Fashionable-Comfortable-Versatile-Outdoor-Hiking-Shoes-Valentines-Perfect-With-Sports-Jeans-Look-p-39661952.html?attr_ids=&detailBusinessFrom=0-1_39661952%257C0-2&imgRatio=3-4&isAppointMall=&mallCode=1&pageListType=4&showFeedbackRec=1&src_identifier=st%253D4%2560sc%253DShoes%2520For%2520Men%2560sr%253D0%2560ps%253D2&src_module=search&src_tab_page_id=page_pre_search1783520484803', 50750, 'https://img.ltwebstatic.com/images3_spmp/2024/07/24/74/1721822306aaf71e63219934b1ff8c2a9c2c830bf6_thumbnail_750x999.avif', '2026-07-08 14:21:39', '2026-07-08 14:21:39'),
(13, 3, 'web-630310780', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/?ref=www&rep=dir&ret=m', 34250, 'https://img.ltwebstatic.com/v4/p/ccc/2025/03/12/42/17417727382f2224f1d84011c722cd969674a569e2_thumbnail_720x.avif', '2026-07-08 14:49:33', '2026-07-08 14:49:33'),
(14, 3, 'web-217727324', 'Mavi Tişört Erkek Beyaz Miav Baskılı Regular Fit / Normal Kesim Fiyatı, Yorumları - Trendyol', 'Trendyol', 7, 'https://www.trendyol.com/mavi/miav-baskili-beyaz-tisort-regular-fit-normal-kesim-067153-620-p-121786502?boutiqueId=61&merchantId=63', 18500, 'https://cdn.dsmcdn.com/mnresize/420/620/ty1923/prod/QC_ENRICHMENT/20260706/05/e1971562-8b2b-3f8f-8da9-bbff56162ba4/1_org_zoom.jpg', '2026-07-08 14:57:17', '2026-07-08 14:57:17'),
(15, 6, 'web-1065095564', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Tween-Girls-Bowknot-Backless-Deep-V-Mesh-Princess-Dress-Suitable-For-Easter-Birthday-Parties-Pageants-Weddings-Formal-Occasions-p-37727135.html?attr_ids=109_59&detailBusinessFrom=0-1_37727135%257C0-2&imgRatio=3-4&isAppointMall=&mallCode=1&pageListType=4&showFeedbackRec=1&src_identifier=fc%253Dkids%2560sc%253DJust%2520for%2520You%2560tc%253DPicks%2520for%2520You%2560oc%253DTween%2520Girls%2520Partywear%2560ps%253Dtab04navbar01menu01dir2%2560jc%253Dreal_2382&src_module=cat&src_tab_page_id=page_real_class1783501531325', 60750, 'https://img.ltwebstatic.com/v4/j/spmp/2026/05/19/4d/1779181097f491a4ddf985df564257679b777ee1fc_thumbnail_750x999.webp', '2026-07-09 08:59:00', '2026-07-09 08:59:00'),
(16, 6, 'web-689982399', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Black-Large-Capacity-Women-s-Tote-Bag-Minimalist-PU-Leather-Shoulder-Handbag-Button-Closure-Fashion-Commute-Office-School-Bag-p-60311929.html?detailBusinessFrom=0-2&imgRatio=3-4&isFromSwitchColor=1&main_attr=27_140&mallCode=1&pageFrom=page_flash_sale&sceneFlag=&src_identifier=on%3DCODE_IMAGE_COMPONENT%60cn%3Dpolicy%60hz%3D-%60jc%3DflashSale_%60ps%3D2_2&src_module=all&src_tab_page_id=page_home1783427385428', 24500, 'https://img.ltwebstatic.com/images3_spmp/2025/03/08/03/17414468957924757b36fb25008517536094c8cd8a_thumbnail_750x999.avif', '2026-07-09 08:59:00', '2026-07-09 08:59:00'),
(17, 6, 'web-461733061', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Women-s-Black-Large-Capacity-Tote-Bag-Minimalist-PU-Leather-Shoulder-Handbag-Button-Closure-Fashion-Commuter-Office-Bag-Suitable-For-Office-And-School-p-49563156.html?mallCode=1&imgRatio=3-4&pageFrom=page_flash_sale&src_module=all&src_tab_page_id=page_home1783427385428&src_identifier=on=CODE_IMAGE_COMPONENT`cn=policy`hz=-`jc=flashSale_`ps=2_2&detailBusinessFrom=0-2', 5750, 'https://img.ltwebstatic.com/v4/j/spmp/2026/03/09/f9/1773038443f673d71ea919286194cb382f4bc5eb3c_thumbnail_750x999.avif', '2026-07-09 08:59:00', '2026-07-09 08:59:00'),
(18, 6, 'web-211029430', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Men-s-Lightweight-Drawstring-Waist-Slant-Pocket-Solid-Color-Casual-Pants-p-97014220.html?mallCode=1&imgRatio=3-4&pageFrom=page_super_deals&src_module=all&src_tab_page_id=page_home1783517788049&src_identifier=on=FLEXIBLE_LAYOUT_COMPONENT`cn=superdeals`hz=refresh_0`jc=thriftyFind_`ps=4_1_3&detailBusinessFrom=0-2', 17750, 'https://img.ltwebstatic.com/v4/p/spmp/2025/11/10/5c/176277424536d7565b0165101a931d176aa1e0e589_thumbnail_750x999.avif', '2026-07-09 08:59:00', '2026-07-09 08:59:00'),
(19, 6, 'web-784200109', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/-Size-Runs-Small-Casual-Men-s-Random-Print-Low-Top-Flat-Sports-Sneakers-Fashionable-Comfortable-Versatile-Outdoor-Hiking-Shoes-Valentines-Perfect-With-Sports-Jeans-Look-p-39661952.html?attr_ids=&detailBusinessFrom=0-1_39661952%257C0-2&imgRatio=3-4&isAppointMall=&mallCode=1&pageListType=4&showFeedbackRec=1&src_identifier=st%253D4%2560sc%253DShoes%2520For%2520Men%2560sr%253D0%2560ps%253D2&src_module=search&src_tab_page_id=page_pre_search1783520484803', 50750, 'https://img.ltwebstatic.com/images3_spmp/2024/07/24/74/1721822306aaf71e63219934b1ff8c2a9c2c830bf6_thumbnail_750x999.avif', '2026-07-09 08:59:01', '2026-07-09 08:59:01'),
(20, 6, 'web-630310780', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/?ref=www&rep=dir&ret=m', 34250, 'https://img.ltwebstatic.com/v4/p/ccc/2025/03/12/42/17417727382f2224f1d84011c722cd969674a569e2_thumbnail_720x.avif', '2026-07-09 08:59:02', '2026-07-09 08:59:02'),
(21, 6, 'web-217727324', 'Mavi Tişört Erkek Beyaz Miav Baskılı Regular Fit / Normal Kesim Fiyatı, Yorumları - Trendyol', 'Trendyol', 7, 'https://www.trendyol.com/mavi/miav-baskili-beyaz-tisort-regular-fit-normal-kesim-067153-620-p-121786502?boutiqueId=61&merchantId=63', 18500, 'https://cdn.dsmcdn.com/mnresize/420/620/ty1923/prod/QC_ENRICHMENT/20260706/05/e1971562-8b2b-3f8f-8da9-bbff56162ba4/1_org_zoom.jpg', '2026-07-09 08:59:02', '2026-07-09 08:59:02'),
(22, 7, 'web-1065095564', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Tween-Girls-Bowknot-Backless-Deep-V-Mesh-Princess-Dress-Suitable-For-Easter-Birthday-Parties-Pageants-Weddings-Formal-Occasions-p-37727135.html?attr_ids=109_59&detailBusinessFrom=0-1_37727135%257C0-2&imgRatio=3-4&isAppointMall=&mallCode=1&pageListType=4&showFeedbackRec=1&src_identifier=fc%253Dkids%2560sc%253DJust%2520for%2520You%2560tc%253DPicks%2520for%2520You%2560oc%253DTween%2520Girls%2520Partywear%2560ps%253Dtab04navbar01menu01dir2%2560jc%253Dreal_2382&src_module=cat&src_tab_page_id=page_real_class1783501531325', 60750, 'https://img.ltwebstatic.com/v4/j/spmp/2026/05/19/4d/1779181097f491a4ddf985df564257679b777ee1fc_thumbnail_750x999.webp', '2026-07-09 09:14:12', '2026-07-09 09:14:12'),
(23, 7, 'web-689982399', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Black-Large-Capacity-Women-s-Tote-Bag-Minimalist-PU-Leather-Shoulder-Handbag-Button-Closure-Fashion-Commute-Office-School-Bag-p-60311929.html?detailBusinessFrom=0-2&imgRatio=3-4&isFromSwitchColor=1&main_attr=27_140&mallCode=1&pageFrom=page_flash_sale&sceneFlag=&src_identifier=on%3DCODE_IMAGE_COMPONENT%60cn%3Dpolicy%60hz%3D-%60jc%3DflashSale_%60ps%3D2_2&src_module=all&src_tab_page_id=page_home1783427385428', 24500, 'https://img.ltwebstatic.com/images3_spmp/2025/03/08/03/17414468957924757b36fb25008517536094c8cd8a_thumbnail_750x999.avif', '2026-07-09 09:14:12', '2026-07-09 09:14:12'),
(24, 7, 'web-461733061', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Women-s-Black-Large-Capacity-Tote-Bag-Minimalist-PU-Leather-Shoulder-Handbag-Button-Closure-Fashion-Commuter-Office-Bag-Suitable-For-Office-And-School-p-49563156.html?mallCode=1&imgRatio=3-4&pageFrom=page_flash_sale&src_module=all&src_tab_page_id=page_home1783427385428&src_identifier=on=CODE_IMAGE_COMPONENT`cn=policy`hz=-`jc=flashSale_`ps=2_2&detailBusinessFrom=0-2', 5750, 'https://img.ltwebstatic.com/v4/j/spmp/2026/03/09/f9/1773038443f673d71ea919286194cb382f4bc5eb3c_thumbnail_750x999.avif', '2026-07-09 09:14:12', '2026-07-09 09:14:12'),
(25, 7, 'web-211029430', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Men-s-Lightweight-Drawstring-Waist-Slant-Pocket-Solid-Color-Casual-Pants-p-97014220.html?mallCode=1&imgRatio=3-4&pageFrom=page_super_deals&src_module=all&src_tab_page_id=page_home1783517788049&src_identifier=on=FLEXIBLE_LAYOUT_COMPONENT`cn=superdeals`hz=refresh_0`jc=thriftyFind_`ps=4_1_3&detailBusinessFrom=0-2', 17750, 'https://img.ltwebstatic.com/v4/p/spmp/2025/11/10/5c/176277424536d7565b0165101a931d176aa1e0e589_thumbnail_750x999.avif', '2026-07-09 09:14:13', '2026-07-09 09:14:13'),
(26, 7, 'web-784200109', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/-Size-Runs-Small-Casual-Men-s-Random-Print-Low-Top-Flat-Sports-Sneakers-Fashionable-Comfortable-Versatile-Outdoor-Hiking-Shoes-Valentines-Perfect-With-Sports-Jeans-Look-p-39661952.html?attr_ids=&detailBusinessFrom=0-1_39661952%257C0-2&imgRatio=3-4&isAppointMall=&mallCode=1&pageListType=4&showFeedbackRec=1&src_identifier=st%253D4%2560sc%253DShoes%2520For%2520Men%2560sr%253D0%2560ps%253D2&src_module=search&src_tab_page_id=page_pre_search1783520484803', 50750, 'https://img.ltwebstatic.com/images3_spmp/2024/07/24/74/1721822306aaf71e63219934b1ff8c2a9c2c830bf6_thumbnail_750x999.avif', '2026-07-09 09:14:14', '2026-07-09 09:14:14'),
(27, 7, 'web-630310780', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/?ref=www&rep=dir&ret=m', 34250, 'https://img.ltwebstatic.com/v4/p/ccc/2025/03/12/42/17417727382f2224f1d84011c722cd969674a569e2_thumbnail_720x.avif', '2026-07-09 09:14:14', '2026-07-09 09:14:14'),
(28, 7, 'web-217727324', 'Mavi Tişört Erkek Beyaz Miav Baskılı Regular Fit / Normal Kesim Fiyatı, Yorumları - Trendyol', 'Trendyol', 7, 'https://www.trendyol.com/mavi/miav-baskili-beyaz-tisort-regular-fit-normal-kesim-067153-620-p-121786502?boutiqueId=61&merchantId=63', 18500, 'https://cdn.dsmcdn.com/mnresize/420/620/ty1923/prod/QC_ENRICHMENT/20260706/05/e1971562-8b2b-3f8f-8da9-bbff56162ba4/1_org_zoom.jpg', '2026-07-09 09:14:14', '2026-07-09 09:14:14'),
(29, 8, 'web-1065095564', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Tween-Girls-Bowknot-Backless-Deep-V-Mesh-Princess-Dress-Suitable-For-Easter-Birthday-Parties-Pageants-Weddings-Formal-Occasions-p-37727135.html?attr_ids=109_59&detailBusinessFrom=0-1_37727135%257C0-2&imgRatio=3-4&isAppointMall=&mallCode=1&pageListType=4&showFeedbackRec=1&src_identifier=fc%253Dkids%2560sc%253DJust%2520for%2520You%2560tc%253DPicks%2520for%2520You%2560oc%253DTween%2520Girls%2520Partywear%2560ps%253Dtab04navbar01menu01dir2%2560jc%253Dreal_2382&src_module=cat&src_tab_page_id=page_real_class1783501531325', 60750, 'https://img.ltwebstatic.com/v4/j/spmp/2026/05/19/4d/1779181097f491a4ddf985df564257679b777ee1fc_thumbnail_750x999.webp', '2026-07-09 09:21:27', '2026-07-09 09:21:27'),
(30, 8, 'web-689982399', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Black-Large-Capacity-Women-s-Tote-Bag-Minimalist-PU-Leather-Shoulder-Handbag-Button-Closure-Fashion-Commute-Office-School-Bag-p-60311929.html?detailBusinessFrom=0-2&imgRatio=3-4&isFromSwitchColor=1&main_attr=27_140&mallCode=1&pageFrom=page_flash_sale&sceneFlag=&src_identifier=on%3DCODE_IMAGE_COMPONENT%60cn%3Dpolicy%60hz%3D-%60jc%3DflashSale_%60ps%3D2_2&src_module=all&src_tab_page_id=page_home1783427385428', 24500, 'https://img.ltwebstatic.com/images3_spmp/2025/03/08/03/17414468957924757b36fb25008517536094c8cd8a_thumbnail_750x999.avif', '2026-07-09 09:21:27', '2026-07-09 09:21:27'),
(31, 8, 'web-461733061', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Women-s-Black-Large-Capacity-Tote-Bag-Minimalist-PU-Leather-Shoulder-Handbag-Button-Closure-Fashion-Commuter-Office-Bag-Suitable-For-Office-And-School-p-49563156.html?mallCode=1&imgRatio=3-4&pageFrom=page_flash_sale&src_module=all&src_tab_page_id=page_home1783427385428&src_identifier=on=CODE_IMAGE_COMPONENT`cn=policy`hz=-`jc=flashSale_`ps=2_2&detailBusinessFrom=0-2', 5750, 'https://img.ltwebstatic.com/v4/j/spmp/2026/03/09/f9/1773038443f673d71ea919286194cb382f4bc5eb3c_thumbnail_750x999.avif', '2026-07-09 09:21:27', '2026-07-09 09:21:27'),
(32, 8, 'web-211029430', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Men-s-Lightweight-Drawstring-Waist-Slant-Pocket-Solid-Color-Casual-Pants-p-97014220.html?mallCode=1&imgRatio=3-4&pageFrom=page_super_deals&src_module=all&src_tab_page_id=page_home1783517788049&src_identifier=on=FLEXIBLE_LAYOUT_COMPONENT`cn=superdeals`hz=refresh_0`jc=thriftyFind_`ps=4_1_3&detailBusinessFrom=0-2', 17750, 'https://img.ltwebstatic.com/v4/p/spmp/2025/11/10/5c/176277424536d7565b0165101a931d176aa1e0e589_thumbnail_750x999.avif', '2026-07-09 09:21:28', '2026-07-09 09:21:28'),
(33, 8, 'web-784200109', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/-Size-Runs-Small-Casual-Men-s-Random-Print-Low-Top-Flat-Sports-Sneakers-Fashionable-Comfortable-Versatile-Outdoor-Hiking-Shoes-Valentines-Perfect-With-Sports-Jeans-Look-p-39661952.html?attr_ids=&detailBusinessFrom=0-1_39661952%257C0-2&imgRatio=3-4&isAppointMall=&mallCode=1&pageListType=4&showFeedbackRec=1&src_identifier=st%253D4%2560sc%253DShoes%2520For%2520Men%2560sr%253D0%2560ps%253D2&src_module=search&src_tab_page_id=page_pre_search1783520484803', 50750, 'https://img.ltwebstatic.com/images3_spmp/2024/07/24/74/1721822306aaf71e63219934b1ff8c2a9c2c830bf6_thumbnail_750x999.avif', '2026-07-09 09:21:28', '2026-07-09 09:21:28'),
(34, 8, 'web-630310780', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/?ref=www&rep=dir&ret=m', 34250, 'https://img.ltwebstatic.com/v4/p/ccc/2025/03/12/42/17417727382f2224f1d84011c722cd969674a569e2_thumbnail_720x.avif', '2026-07-09 09:21:28', '2026-07-09 09:21:28'),
(35, 8, 'web-217727324', 'Mavi Tişört Erkek Beyaz Miav Baskılı Regular Fit / Normal Kesim Fiyatı, Yorumları - Trendyol', 'Trendyol', 7, 'https://www.trendyol.com/mavi/miav-baskili-beyaz-tisort-regular-fit-normal-kesim-067153-620-p-121786502?boutiqueId=61&merchantId=63', 18500, 'https://cdn.dsmcdn.com/mnresize/420/620/ty1923/prod/QC_ENRICHMENT/20260706/05/e1971562-8b2b-3f8f-8da9-bbff56162ba4/1_org_zoom.jpg', '2026-07-09 09:21:28', '2026-07-09 09:21:28'),
(36, 8, 'web-649229272', 'Volanlı çizgili elbise - Kadın | MANGO Türkiye', 'Mango', 4, 'https://shop.mango.com/tr/tr/p/kad%C4%B1n/elbise-ve-tulum/casual/volanl%C4%B1-cizgili-elbise/27017946/52/00', 170250, 'https://media.mango.com/is/image/punto/27017946-52-002?wid=1024', '2026-07-09 14:10:22', '2026-07-09 14:10:22'),
(37, 8, 'web-482432519', 'Karaca Home Rocco Fotoğraf Çerçevesi Yeşil 10x15 cm', 'Karaca', 6, 'https://www.karaca-home.com/urun/karaca-home-rocco-fotograf-cercevesi-yesil-13x18-cm', 23000, 'https://cdn.karaca.com/rcman/cw545h545q90gm/image/000001000232629003/karaca-home-rocco-fotograf-cercevesi-yesil-13x18-cm-000001000232629003-1.jpg', '2026-07-11 09:21:34', '2026-07-11 09:21:34'),
(39, 8, 'web-54080773', '%100 KETEN RELAXED FIT BERMUDA', 'Zara', 3, 'https://www.zara.com/tr/tr/100-keten-relaxed-fit-bermuda-p05070903.html?v1=545461023&v2=2630190', 114750, 'https://static.zara.net/assets/public/df7f/2e9d/3de242c8b69b/c08079a10ad0/05070903800-p/05070903800-p.jpg?ts=1766397849458&w=688&f=auto', '2026-07-11 12:29:38', '2026-07-11 12:29:38'),
(40, 3, 'web-649229272', 'Volanlı çizgili elbise - Kadın | MANGO Türkiye', 'Mango', 4, 'https://shop.mango.com/tr/tr/p/kad%C4%B1n/elbise-ve-tulum/casual/volanl%C4%B1-cizgili-elbise/27017946/52/00', 170250, 'https://media.mango.com/is/image/punto/27017946-52-002?wid=1024', '2026-07-11 13:02:03', '2026-07-11 13:02:03'),
(41, 3, 'web-482432519', 'Karaca Home Rocco Fotoğraf Çerçevesi Yeşil 10x15 cm', 'Karaca', 6, 'https://www.karaca-home.com/urun/karaca-home-rocco-fotograf-cercevesi-yesil-13x18-cm', 23000, 'https://cdn.karaca.com/rcman/cw545h545q90gm/image/000001000232629003/karaca-home-rocco-fotograf-cercevesi-yesil-13x18-cm-000001000232629003-1.jpg', '2026-07-11 13:02:05', '2026-07-11 13:02:05'),
(42, 3, 'web-54080773', '%100 KETEN RELAXED FIT BERMUDA', 'Zara', 3, 'https://www.zara.com/tr/tr/100-keten-relaxed-fit-bermuda-p05070903.html?v1=545461023&v2=2630190', 114750, 'https://static.zara.net/assets/public/df7f/2e9d/3de242c8b69b/c08079a10ad0/05070903800-p/05070903800-p.jpg?ts=1766397849458&w=688&f=auto', '2026-07-11 13:02:06', '2026-07-11 13:02:06'),
(45, 3, 'web-361545014', 'Paçası yırtmaçlı kapri pantolon', 'Bershka', 9, 'https://www.bershka.com/tr/pa%C3%A7as%C4%B1-y%C4%B1rtma%C3%A7l%C4%B1-kapri-pantolon-c0p227994908.html?colorId=716', 59500, 'https://static.bershka.net/assets/public/3876/a520/198f4f45bd47/77ecc99b6164/01120232716-p/01120232716-p.jpg?ts=1783075543917&w=850', '2026-07-11 14:59:12', '2026-07-11 14:59:12'),
(46, 3, 'web-188178089', 'Skater desenli bermuda şort', 'Bershka', 9, 'https://www.bershka.com/tr/skater-desenli-bermuda-%C5%9Fort-c0p234324870.html?colorId=548&stylismId=1', 91750, 'https://static.bershka.net/assets/public/559f/21d4/b6734817bae9/1a551eae03ee/03303335548-p/03303335548-p.jpg?ts=1783584555248&w=1920', '2026-07-14 12:24:43', '2026-07-14 12:24:43'),
(47, 9, 'web-1065095564', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Tween-Girls-Bowknot-Backless-Deep-V-Mesh-Princess-Dress-Suitable-For-Easter-Birthday-Parties-Pageants-Weddings-Formal-Occasions-p-37727135.html?attr_ids=109_59&detailBusinessFrom=0-1_37727135%257C0-2&imgRatio=3-4&isAppointMall=&mallCode=1&pageListType=4&showFeedbackRec=1&src_identifier=fc%253Dkids%2560sc%253DJust%2520for%2520You%2560tc%253DPicks%2520for%2520You%2560oc%253DTween%2520Girls%2520Partywear%2560ps%253Dtab04navbar01menu01dir2%2560jc%253Dreal_2382&src_module=cat&src_tab_page_id=page_real_class1783501531325', 60750, 'https://img.ltwebstatic.com/v4/j/spmp/2026/05/19/4d/1779181097f491a4ddf985df564257679b777ee1fc_thumbnail_750x999.webp', '2026-07-14 14:42:26', '2026-07-14 14:42:26'),
(48, 9, 'web-689982399', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Black-Large-Capacity-Women-s-Tote-Bag-Minimalist-PU-Leather-Shoulder-Handbag-Button-Closure-Fashion-Commute-Office-School-Bag-p-60311929.html?detailBusinessFrom=0-2&imgRatio=3-4&isFromSwitchColor=1&main_attr=27_140&mallCode=1&pageFrom=page_flash_sale&sceneFlag=&src_identifier=on%3DCODE_IMAGE_COMPONENT%60cn%3Dpolicy%60hz%3D-%60jc%3DflashSale_%60ps%3D2_2&src_module=all&src_tab_page_id=page_home1783427385428', 24500, 'https://img.ltwebstatic.com/images3_spmp/2025/03/08/03/17414468957924757b36fb25008517536094c8cd8a_thumbnail_750x999.avif', '2026-07-14 14:42:27', '2026-07-14 14:42:27'),
(49, 9, 'web-461733061', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Women-s-Black-Large-Capacity-Tote-Bag-Minimalist-PU-Leather-Shoulder-Handbag-Button-Closure-Fashion-Commuter-Office-Bag-Suitable-For-Office-And-School-p-49563156.html?mallCode=1&imgRatio=3-4&pageFrom=page_flash_sale&src_module=all&src_tab_page_id=page_home1783427385428&src_identifier=on=CODE_IMAGE_COMPONENT`cn=policy`hz=-`jc=flashSale_`ps=2_2&detailBusinessFrom=0-2', 5750, 'https://img.ltwebstatic.com/v4/j/spmp/2026/03/09/f9/1773038443f673d71ea919286194cb382f4bc5eb3c_thumbnail_750x999.avif', '2026-07-14 14:42:27', '2026-07-14 14:42:27'),
(50, 9, 'web-211029430', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Men-s-Lightweight-Drawstring-Waist-Slant-Pocket-Solid-Color-Casual-Pants-p-97014220.html?mallCode=1&imgRatio=3-4&pageFrom=page_super_deals&src_module=all&src_tab_page_id=page_home1783517788049&src_identifier=on=FLEXIBLE_LAYOUT_COMPONENT`cn=superdeals`hz=refresh_0`jc=thriftyFind_`ps=4_1_3&detailBusinessFrom=0-2', 17750, 'https://img.ltwebstatic.com/v4/p/spmp/2025/11/10/5c/176277424536d7565b0165101a931d176aa1e0e589_thumbnail_750x999.avif', '2026-07-14 14:42:27', '2026-07-14 14:42:27'),
(51, 9, 'web-784200109', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/-Size-Runs-Small-Casual-Men-s-Random-Print-Low-Top-Flat-Sports-Sneakers-Fashionable-Comfortable-Versatile-Outdoor-Hiking-Shoes-Valentines-Perfect-With-Sports-Jeans-Look-p-39661952.html?attr_ids=&detailBusinessFrom=0-1_39661952%257C0-2&imgRatio=3-4&isAppointMall=&mallCode=1&pageListType=4&showFeedbackRec=1&src_identifier=st%253D4%2560sc%253DShoes%2520For%2520Men%2560sr%253D0%2560ps%253D2&src_module=search&src_tab_page_id=page_pre_search1783520484803', 50750, 'https://img.ltwebstatic.com/images3_spmp/2024/07/24/74/1721822306aaf71e63219934b1ff8c2a9c2c830bf6_thumbnail_750x999.avif', '2026-07-14 14:42:27', '2026-07-14 14:42:27'),
(52, 9, 'web-630310780', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/?ref=www&rep=dir&ret=m', 34250, 'https://img.ltwebstatic.com/v4/p/ccc/2025/03/12/42/17417727382f2224f1d84011c722cd969674a569e2_thumbnail_720x.avif', '2026-07-14 14:42:27', '2026-07-14 14:42:27'),
(53, 9, 'web-217727324', 'Mavi Tişört Erkek Beyaz Miav Baskılı Regular Fit / Normal Kesim Fiyatı, Yorumları - Trendyol', 'Trendyol', 7, 'https://www.trendyol.com/mavi/miav-baskili-beyaz-tisort-regular-fit-normal-kesim-067153-620-p-121786502?boutiqueId=61&merchantId=63', 18500, 'https://cdn.dsmcdn.com/mnresize/420/620/ty1923/prod/QC_ENRICHMENT/20260706/05/e1971562-8b2b-3f8f-8da9-bbff56162ba4/1_org_zoom.jpg', '2026-07-14 14:42:27', '2026-07-14 14:42:27'),
(54, 9, 'web-649229272', 'Volanlı çizgili elbise - Kadın | MANGO Türkiye', 'Mango', 4, 'https://shop.mango.com/tr/tr/p/kad%C4%B1n/elbise-ve-tulum/casual/volanl%C4%B1-cizgili-elbise/27017946/52/00', 170250, 'https://media.mango.com/is/image/punto/27017946-52-002?wid=1024', '2026-07-14 14:42:27', '2026-07-14 14:42:27'),
(55, 9, 'web-482432519', 'Karaca Home Rocco Fotoğraf Çerçevesi Yeşil 10x15 cm', 'Karaca', 6, 'https://www.karaca-home.com/urun/karaca-home-rocco-fotograf-cercevesi-yesil-13x18-cm', 23000, 'https://cdn.karaca.com/rcman/cw545h545q90gm/image/000001000232629003/karaca-home-rocco-fotograf-cercevesi-yesil-13x18-cm-000001000232629003-1.jpg', '2026-07-14 14:42:28', '2026-07-14 14:42:28'),
(56, 9, 'web-54080773', '%100 KETEN RELAXED FIT BERMUDA', 'Zara', 3, 'https://www.zara.com/tr/tr/100-keten-relaxed-fit-bermuda-p05070903.html?v1=545461023&v2=2630190', 114750, 'https://static.zara.net/assets/public/df7f/2e9d/3de242c8b69b/c08079a10ad0/05070903800-p/05070903800-p.jpg?ts=1766397849458&w=688&f=auto', '2026-07-14 14:42:28', '2026-07-14 14:42:28'),
(57, 9, 'web-361545014', 'Paçası yırtmaçlı kapri pantolon', 'Bershka', 9, 'https://www.bershka.com/tr/pa%C3%A7as%C4%B1-y%C4%B1rtma%C3%A7l%C4%B1-kapri-pantolon-c0p227994908.html?colorId=716', 59500, 'https://static.bershka.net/assets/public/3876/a520/198f4f45bd47/77ecc99b6164/01120232716-p/01120232716-p.jpg?ts=1783075543917&w=850', '2026-07-14 14:42:28', '2026-07-14 14:42:28'),
(58, 9, 'web-188178089', 'Skater desenli bermuda şort', 'Bershka', 9, 'https://www.bershka.com/tr/skater-desenli-bermuda-%C5%9Fort-c0p234324870.html?colorId=548&stylismId=1', 91750, 'https://static.bershka.net/assets/public/559f/21d4/b6734817bae9/1a551eae03ee/03303335548-p/03303335548-p.jpg?ts=1783584555248&w=1920', '2026-07-14 14:42:28', '2026-07-14 14:42:28'),
(59, 13, 'web-188178089', 'Skater desenli bermuda şort', 'Bershka', 9, 'https://www.bershka.com/tr/skater-desenli-bermuda-%C5%9Fort-c0p234324870.html?colorId=548&stylismId=1', 91750, 'https://static.bershka.net/assets/public/559f/21d4/b6734817bae9/1a551eae03ee/03303335548-p/03303335548-p.jpg?ts=1783584555248&w=1920', '2026-08-08 10:50:53', '2026-08-08 10:50:53'),
(60, 13, 'web-361545014', 'Paçası yırtmaçlı kapri pantolon', 'Bershka', 9, 'https://www.bershka.com/tr/pa%C3%A7as%C4%B1-y%C4%B1rtma%C3%A7l%C4%B1-kapri-pantolon-c0p227994908.html?colorId=716', 59500, 'https://static.bershka.net/assets/public/3876/a520/198f4f45bd47/77ecc99b6164/01120232716-p/01120232716-p.jpg?ts=1783075543917&w=850', '2026-08-08 10:50:53', '2026-08-08 10:50:53'),
(61, 13, 'web-54080773', '%100 KETEN RELAXED FIT BERMUDA', 'Zara', 3, 'https://www.zara.com/tr/tr/100-keten-relaxed-fit-bermuda-p05070903.html?v1=545461023&v2=2630190', 114750, 'https://static.zara.net/assets/public/df7f/2e9d/3de242c8b69b/c08079a10ad0/05070903800-p/05070903800-p.jpg?ts=1766397849458&w=688&f=auto', '2026-08-08 10:50:54', '2026-08-08 10:50:54'),
(62, 13, 'web-482432519', 'Karaca Home Rocco Fotoğraf Çerçevesi Yeşil 10x15 cm', 'Karaca', 6, 'https://www.karaca-home.com/urun/karaca-home-rocco-fotograf-cercevesi-yesil-13x18-cm', 23000, 'https://cdn.karaca.com/rcman/cw545h545q90gm/image/000001000232629003/karaca-home-rocco-fotograf-cercevesi-yesil-13x18-cm-000001000232629003-1.jpg', '2026-08-08 10:50:54', '2026-08-08 10:50:54'),
(63, 13, 'web-649229272', 'Volanlı çizgili elbise - Kadın | MANGO Türkiye', 'Mango', 4, 'https://shop.mango.com/tr/tr/p/kad%C4%B1n/elbise-ve-tulum/casual/volanl%C4%B1-cizgili-elbise/27017946/52/00', 170250, 'https://media.mango.com/is/image/punto/27017946-52-002?wid=1024', '2026-08-08 10:50:54', '2026-08-08 10:50:54'),
(64, 13, 'web-217727324', 'Mavi Tişört Erkek Beyaz Miav Baskılı Regular Fit / Normal Kesim Fiyatı, Yorumları - Trendyol', 'Trendyol', 7, 'https://www.trendyol.com/mavi/miav-baskili-beyaz-tisort-regular-fit-normal-kesim-067153-620-p-121786502?boutiqueId=61&merchantId=63', 18500, 'https://cdn.dsmcdn.com/mnresize/420/620/ty1923/prod/QC_ENRICHMENT/20260706/05/e1971562-8b2b-3f8f-8da9-bbff56162ba4/1_org_zoom.jpg', '2026-08-08 10:50:54', '2026-08-08 10:50:54'),
(65, 13, 'web-630310780', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/?ref=www&rep=dir&ret=m', 34250, 'https://img.ltwebstatic.com/v4/p/ccc/2025/03/12/42/17417727382f2224f1d84011c722cd969674a569e2_thumbnail_720x.avif', '2026-08-08 10:50:54', '2026-08-08 10:50:54'),
(66, 13, 'web-784200109', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/-Size-Runs-Small-Casual-Men-s-Random-Print-Low-Top-Flat-Sports-Sneakers-Fashionable-Comfortable-Versatile-Outdoor-Hiking-Shoes-Valentines-Perfect-With-Sports-Jeans-Look-p-39661952.html?attr_ids=&detailBusinessFrom=0-1_39661952%257C0-2&imgRatio=3-4&isAppointMall=&mallCode=1&pageListType=4&showFeedbackRec=1&src_identifier=st%253D4%2560sc%253DShoes%2520For%2520Men%2560sr%253D0%2560ps%253D2&src_module=search&src_tab_page_id=page_pre_search1783520484803', 50750, 'https://img.ltwebstatic.com/images3_spmp/2024/07/24/74/1721822306aaf71e63219934b1ff8c2a9c2c830bf6_thumbnail_750x999.avif', '2026-08-08 10:50:54', '2026-08-08 10:50:54'),
(67, 13, 'web-211029430', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Men-s-Lightweight-Drawstring-Waist-Slant-Pocket-Solid-Color-Casual-Pants-p-97014220.html?mallCode=1&imgRatio=3-4&pageFrom=page_super_deals&src_module=all&src_tab_page_id=page_home1783517788049&src_identifier=on=FLEXIBLE_LAYOUT_COMPONENT`cn=superdeals`hz=refresh_0`jc=thriftyFind_`ps=4_1_3&detailBusinessFrom=0-2', 17750, 'https://img.ltwebstatic.com/v4/p/spmp/2025/11/10/5c/176277424536d7565b0165101a931d176aa1e0e589_thumbnail_750x999.avif', '2026-08-08 10:50:54', '2026-08-08 10:50:54'),
(68, 13, 'web-1065095564', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Tween-Girls-Bowknot-Backless-Deep-V-Mesh-Princess-Dress-Suitable-For-Easter-Birthday-Parties-Pageants-Weddings-Formal-Occasions-p-37727135.html?attr_ids=109_59&detailBusinessFrom=0-1_37727135%257C0-2&imgRatio=3-4&isAppointMall=&mallCode=1&pageListType=4&showFeedbackRec=1&src_identifier=fc%253Dkids%2560sc%253DJust%2520for%2520You%2560tc%253DPicks%2520for%2520You%2560oc%253DTween%2520Girls%2520Partywear%2560ps%253Dtab04navbar01menu01dir2%2560jc%253Dreal_2382&src_module=cat&src_tab_page_id=page_real_class1783501531325', 60750, 'https://img.ltwebstatic.com/v4/j/spmp/2026/05/19/4d/1779181097f491a4ddf985df564257679b777ee1fc_thumbnail_750x999.webp', '2026-08-08 10:50:55', '2026-08-08 10:50:55'),
(69, 13, 'web-689982399', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Black-Large-Capacity-Women-s-Tote-Bag-Minimalist-PU-Leather-Shoulder-Handbag-Button-Closure-Fashion-Commute-Office-School-Bag-p-60311929.html?detailBusinessFrom=0-2&imgRatio=3-4&isFromSwitchColor=1&main_attr=27_140&mallCode=1&pageFrom=page_flash_sale&sceneFlag=&src_identifier=on%3DCODE_IMAGE_COMPONENT%60cn%3Dpolicy%60hz%3D-%60jc%3DflashSale_%60ps%3D2_2&src_module=all&src_tab_page_id=page_home1783427385428', 24500, 'https://img.ltwebstatic.com/images3_spmp/2025/03/08/03/17414468957924757b36fb25008517536094c8cd8a_thumbnail_750x999.avif', '2026-08-08 10:50:55', '2026-08-08 10:50:55'),
(70, 13, 'web-461733061', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Women-s-Black-Large-Capacity-Tote-Bag-Minimalist-PU-Leather-Shoulder-Handbag-Button-Closure-Fashion-Commuter-Office-Bag-Suitable-For-Office-And-School-p-49563156.html?mallCode=1&imgRatio=3-4&pageFrom=page_flash_sale&src_module=all&src_tab_page_id=page_home1783427385428&src_identifier=on=CODE_IMAGE_COMPONENT`cn=policy`hz=-`jc=flashSale_`ps=2_2&detailBusinessFrom=0-2', 5750, 'https://img.ltwebstatic.com/v4/j/spmp/2026/03/09/f9/1773038443f673d71ea919286194cb382f4bc5eb3c_thumbnail_750x999.avif', '2026-08-08 10:50:55', '2026-08-08 10:50:55'),
(71, 14, 'web-1065095564', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Tween-Girls-Bowknot-Backless-Deep-V-Mesh-Princess-Dress-Suitable-For-Easter-Birthday-Parties-Pageants-Weddings-Formal-Occasions-p-37727135.html?attr_ids=109_59&detailBusinessFrom=0-1_37727135%257C0-2&imgRatio=3-4&isAppointMall=&mallCode=1&pageListType=4&showFeedbackRec=1&src_identifier=fc%253Dkids%2560sc%253DJust%2520for%2520You%2560tc%253DPicks%2520for%2520You%2560oc%253DTween%2520Girls%2520Partywear%2560ps%253Dtab04navbar01menu01dir2%2560jc%253Dreal_2382&src_module=cat&src_tab_page_id=page_real_class1783501531325', 60750, 'https://img.ltwebstatic.com/v4/j/spmp/2026/05/19/4d/1779181097f491a4ddf985df564257679b777ee1fc_thumbnail_750x999.webp', '2026-08-10 17:09:58', '2026-08-10 17:09:58'),
(72, 14, 'web-689982399', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Black-Large-Capacity-Women-s-Tote-Bag-Minimalist-PU-Leather-Shoulder-Handbag-Button-Closure-Fashion-Commute-Office-School-Bag-p-60311929.html?detailBusinessFrom=0-2&imgRatio=3-4&isFromSwitchColor=1&main_attr=27_140&mallCode=1&pageFrom=page_flash_sale&sceneFlag=&src_identifier=on%3DCODE_IMAGE_COMPONENT%60cn%3Dpolicy%60hz%3D-%60jc%3DflashSale_%60ps%3D2_2&src_module=all&src_tab_page_id=page_home1783427385428', 24500, 'https://img.ltwebstatic.com/images3_spmp/2025/03/08/03/17414468957924757b36fb25008517536094c8cd8a_thumbnail_750x999.avif', '2026-08-10 17:09:59', '2026-08-10 17:09:59'),
(73, 14, 'web-461733061', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Women-s-Black-Large-Capacity-Tote-Bag-Minimalist-PU-Leather-Shoulder-Handbag-Button-Closure-Fashion-Commuter-Office-Bag-Suitable-For-Office-And-School-p-49563156.html?mallCode=1&imgRatio=3-4&pageFrom=page_flash_sale&src_module=all&src_tab_page_id=page_home1783427385428&src_identifier=on=CODE_IMAGE_COMPONENT`cn=policy`hz=-`jc=flashSale_`ps=2_2&detailBusinessFrom=0-2', 5750, 'https://img.ltwebstatic.com/v4/j/spmp/2026/03/09/f9/1773038443f673d71ea919286194cb382f4bc5eb3c_thumbnail_750x999.avif', '2026-08-10 17:09:59', '2026-08-10 17:09:59'),
(74, 14, 'web-54080773', '%100 KETEN RELAXED FIT BERMUDA', 'Zara', 3, 'https://www.zara.com/tr/tr/100-keten-relaxed-fit-bermuda-p05070903.html?v1=545461023&v2=2630190', 114750, 'https://static.zara.net/assets/public/df7f/2e9d/3de242c8b69b/c08079a10ad0/05070903800-p/05070903800-p.jpg?ts=1766397849458&w=688&f=auto', '2026-08-10 17:09:59', '2026-08-10 17:09:59'),
(75, 14, 'web-482432519', 'Karaca Home Rocco Fotoğraf Çerçevesi Yeşil 10x15 cm', 'Karaca', 6, 'https://www.karaca-home.com/urun/karaca-home-rocco-fotograf-cercevesi-yesil-13x18-cm', 23000, 'https://cdn.karaca.com/rcman/cw545h545q90gm/image/000001000232629003/karaca-home-rocco-fotograf-cercevesi-yesil-13x18-cm-000001000232629003-1.jpg', '2026-08-10 17:10:00', '2026-08-10 17:10:00'),
(76, 14, 'web-649229272', 'Volanlı çizgili elbise - Kadın | MANGO Türkiye', 'Mango', 4, 'https://shop.mango.com/tr/tr/p/kad%C4%B1n/elbise-ve-tulum/casual/volanl%C4%B1-cizgili-elbise/27017946/52/00', 170250, 'https://media.mango.com/is/image/punto/27017946-52-002?wid=1024', '2026-08-10 17:10:00', '2026-08-10 17:10:00'),
(77, 14, 'web-217727324', 'Mavi Tişört Erkek Beyaz Miav Baskılı Regular Fit / Normal Kesim Fiyatı, Yorumları - Trendyol', 'Trendyol', 7, 'https://www.trendyol.com/mavi/miav-baskili-beyaz-tisort-regular-fit-normal-kesim-067153-620-p-121786502?boutiqueId=61&merchantId=63', 18500, 'https://cdn.dsmcdn.com/mnresize/420/620/ty1923/prod/QC_ENRICHMENT/20260706/05/e1971562-8b2b-3f8f-8da9-bbff56162ba4/1_org_zoom.jpg', '2026-08-10 17:10:00', '2026-08-10 17:10:00'),
(78, 14, 'web-630310780', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/?ref=www&rep=dir&ret=m', 34250, 'https://img.ltwebstatic.com/v4/p/ccc/2025/03/12/42/17417727382f2224f1d84011c722cd969674a569e2_thumbnail_720x.avif', '2026-08-10 17:10:00', '2026-08-10 17:10:00'),
(79, 14, 'web-784200109', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/-Size-Runs-Small-Casual-Men-s-Random-Print-Low-Top-Flat-Sports-Sneakers-Fashionable-Comfortable-Versatile-Outdoor-Hiking-Shoes-Valentines-Perfect-With-Sports-Jeans-Look-p-39661952.html?attr_ids=&detailBusinessFrom=0-1_39661952%257C0-2&imgRatio=3-4&isAppointMall=&mallCode=1&pageListType=4&showFeedbackRec=1&src_identifier=st%253D4%2560sc%253DShoes%2520For%2520Men%2560sr%253D0%2560ps%253D2&src_module=search&src_tab_page_id=page_pre_search1783520484803', 50750, 'https://img.ltwebstatic.com/images3_spmp/2024/07/24/74/1721822306aaf71e63219934b1ff8c2a9c2c830bf6_thumbnail_750x999.avif', '2026-08-10 17:10:00', '2026-08-10 17:10:00'),
(80, 14, 'web-211029430', 'Women\'s Clothing | Fashion Clothes for Men, Women & Kids Online | SHEIN', 'Shein', 1, 'https://m.shein.com/Men-s-Lightweight-Drawstring-Waist-Slant-Pocket-Solid-Color-Casual-Pants-p-97014220.html?mallCode=1&imgRatio=3-4&pageFrom=page_super_deals&src_module=all&src_tab_page_id=page_home1783517788049&src_identifier=on=FLEXIBLE_LAYOUT_COMPONENT`cn=superdeals`hz=refresh_0`jc=thriftyFind_`ps=4_1_3&detailBusinessFrom=0-2', 17750, 'https://img.ltwebstatic.com/v4/p/spmp/2025/11/10/5c/176277424536d7565b0165101a931d176aa1e0e589_thumbnail_750x999.avif', '2026-08-10 17:10:00', '2026-08-10 17:10:00'),
(81, 14, 'web-188178089', 'Skater desenli bermuda şort', 'Bershka', 9, 'https://www.bershka.com/tr/skater-desenli-bermuda-%C5%9Fort-c0p234324870.html?colorId=548&stylismId=1', 91750, 'https://static.bershka.net/assets/public/559f/21d4/b6734817bae9/1a551eae03ee/03303335548-p/03303335548-p.jpg?ts=1783584555248&w=1920', '2026-08-10 17:10:01', '2026-08-10 17:10:01'),
(82, 14, 'web-361545014', 'Paçası yırtmaçlı kapri pantolon', 'Bershka', 9, 'https://www.bershka.com/tr/pa%C3%A7as%C4%B1-y%C4%B1rtma%C3%A7l%C4%B1-kapri-pantolon-c0p227994908.html?colorId=716', 59500, 'https://static.bershka.net/assets/public/3876/a520/198f4f45bd47/77ecc99b6164/01120232716-p/01120232716-p.jpg?ts=1783075543917&w=850', '2026-08-10 17:10:01', '2026-08-10 17:10:01');

-- --------------------------------------------------------

--
-- Table structure for table `fx_rates`
--

CREATE TABLE `fx_rates` (
  `id` bigint UNSIGNED NOT NULL,
  `currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rate_to_iqd` decimal(14,4) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `fx_rates`
--

INSERT INTO `fx_rates` (`id`, `currency`, `rate_to_iqd`, `updated_at`, `created_at`) VALUES
(1, 'USD', 1350.0000, '2026-08-12 17:24:19', '2026-07-04 10:27:47'),
(2, 'TRY', 28.4211, '2026-08-12 17:24:19', '2026-07-04 10:27:48'),
(3, 'EUR', 1600.0000, '2026-07-07 15:43:37', '2026-07-04 10:27:48');

-- --------------------------------------------------------

--
-- Table structure for table `fx_rate_history`
--

CREATE TABLE `fx_rate_history` (
  `id` bigint UNSIGNED NOT NULL,
  `currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rate_to_iqd` decimal(14,4) NOT NULL,
  `effective_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `fx_rate_history`
--

INSERT INTO `fx_rate_history` (`id`, `currency`, `rate_to_iqd`, `effective_at`, `created_at`) VALUES
(1, 'USD', 1500.0000, '2026-08-10 14:50:58', '2026-08-10 14:50:58'),
(2, 'TRY', 30.0000, '2026-08-10 14:50:58', '2026-08-10 14:50:58'),
(3, 'EUR', 1600.0000, '2026-08-10 14:50:58', '2026-08-10 14:50:58'),
(4, 'USD', 1350.0000, '2026-08-12 16:30:25', '2026-08-12 16:30:25'),
(5, 'TRY', 28.4211, '2026-08-12 16:30:26', '2026-08-12 16:30:26'),
(6, 'USD', 1350.0000, '2026-08-12 17:24:19', '2026-08-12 17:24:19'),
(7, 'TRY', 28.4211, '2026-08-12 17:24:19', '2026-08-12 17:24:19');

-- --------------------------------------------------------

--
-- Table structure for table `item_approvals`
--

CREATE TABLE `item_approvals` (
  `id` bigint UNSIGNED NOT NULL,
  `item_id` bigint UNSIGNED NOT NULL,
  `order_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `plan` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'shein',
  `old_shipping` decimal(12,2) DEFAULT NULL,
  `new_shipping` decimal(12,2) NOT NULL DEFAULT '0.00',
  `currency` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USD',
  `status` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `note` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `requested_at` timestamp NULL DEFAULT NULL,
  `responded_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `item_approvals`
--

INSERT INTO `item_approvals` (`id`, `item_id`, `order_id`, `user_id`, `plan`, `old_shipping`, `new_shipping`, `currency`, `status`, `note`, `requested_at`, `responded_at`) VALUES
(1, 61, 50, 3, 'turkish', 2.00, 4.00, 'USD', 'accepted', NULL, '2026-07-21 14:55:37', '2026-07-23 12:42:58'),
(2, 69, 56, 3, 'turkish', 2.00, 2.50, 'USD', 'rejected', NULL, '2026-07-23 12:44:08', '2026-07-23 12:53:20'),
(3, 72, 57, 3, 'turkish', 2.00, 5.00, 'USD', 'rejected', NULL, '2026-07-23 13:00:59', '2026-07-23 13:18:25'),
(4, 71, 57, 3, 'turkish', 2.00, 6.00, 'USD', 'rejected', NULL, '2026-07-23 13:01:03', '2026-07-23 13:17:36'),
(5, 67, 55, 3, 'turkish', 2.00, 9.00, 'USD', 'rejected', NULL, '2026-07-23 13:20:08', '2026-07-23 13:24:22'),
(6, 67, 55, 3, 'turkish', 9.00, 7.00, 'USD', 'rejected', NULL, '2026-07-23 13:26:19', '2026-07-23 13:30:55'),
(7, 73, 58, 3, 'turkish', 2.00, 5.00, 'USD', 'rejected', NULL, '2026-07-23 13:43:24', '2026-07-23 16:44:40'),
(8, 65, 54, 3, 'turkish', 2.00, 6.00, 'USD', 'rejected', NULL, '2026-07-23 13:43:40', '2026-07-23 16:44:42'),
(9, 69, 56, 3, 'turkish', 2.50, 3.00, 'USD', 'accepted', NULL, '2026-07-23 13:45:47', '2026-07-23 16:46:11'),
(10, 73, 58, 3, 'turkish', 5.00, 3.50, 'USD', 'accepted', NULL, '2026-07-23 14:23:51', '2026-07-30 12:10:35'),
(11, 66, 55, 3, 'turkish', 2.00, 7.00, 'USD', 'rejected', NULL, '2026-07-23 14:23:57', '2026-07-26 18:33:03'),
(12, 83, 68, 10, 'turkish', 2.00, 7.80, 'USD', 'superseded', NULL, '2026-07-25 08:47:01', '2026-08-01 08:26:58'),
(13, 64, 53, 3, 'turkish', 2.00, 4.00, 'USD', 'rejected', NULL, '2026-07-25 13:16:38', '2026-07-26 18:33:01'),
(14, 94, 79, 11, 'turkish', 2.00, 3.00, 'USD', 'superseded', NULL, '2026-07-29 15:16:07', '2026-08-01 08:26:52'),
(15, 64, 53, 3, 'turkish', 4.00, 4.00, 'USD', 'accepted', NULL, '2026-08-05 15:44:48', '2026-08-08 10:48:32'),
(16, 101, 86, 13, 'turkish', 2.00, 4.00, 'USD', 'accepted', NULL, '2026-08-08 08:01:33', '2026-08-08 11:01:54'),
(17, 103, 87, 13, 'turkish', 2.00, 3.00, 'USD', 'accepted', NULL, '2026-08-08 08:26:04', '2026-08-08 11:29:45'),
(18, 103, 87, 13, 'turkish', 3.00, 7.00, 'USD', 'accepted', NULL, '2026-08-08 08:30:06', '2026-08-08 11:30:30'),
(19, 108, 90, 14, 'turkish', 2.00, 6.00, 'USD', 'accepted', NULL, '2026-08-08 09:03:41', '2026-08-08 12:05:17'),
(20, 108, 90, 14, 'turkish', 6.00, 7.00, 'USD', 'accepted', NULL, '2026-08-08 09:05:55', '2026-08-08 12:06:37'),
(21, 109, 91, 13, 'turkish', 2.00, 5.00, 'USD', 'accepted', NULL, '2026-08-08 09:35:03', '2026-08-08 12:35:36');

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` smallint UNSIGNED NOT NULL,
  `reserved_at` int UNSIGNED DEFAULT NULL,
  `available_at` int UNSIGNED NOT NULL,
  `created_at` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_07_04_000001_create_stores_table', 1),
(5, '2026_07_04_000002_create_addresses_table', 1),
(6, '2026_07_04_000003_create_otp_codes_table', 1),
(7, '2026_07_04_000004_create_settings_table', 1),
(8, '2026_07_04_000005_create_fx_rates_table', 1),
(9, '2026_07_04_000006_create_wallets_table', 1),
(10, '2026_07_04_000007_create_wallet_transactions_table', 1),
(11, '2026_07_04_000008_create_carts_table', 1),
(12, '2026_07_04_000009_create_cart_items_table', 1),
(13, '2026_07_04_000010_create_orders_table', 1),
(14, '2026_07_04_000011_create_order_items_table', 1),
(15, '2026_07_04_000012_create_order_events_table', 1),
(16, '2026_07_04_130539_create_personal_access_tokens_table', 1);

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` bigint UNSIGNED NOT NULL,
  `code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `source` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'app',
  `user_id` bigint UNSIGNED NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'placed',
  `items_total_iqd` decimal(14,2) NOT NULL DEFAULT '0.00',
  `shipping_iqd` decimal(14,2) NOT NULL DEFAULT '0.00',
  `service_fee_iqd` decimal(14,2) NOT NULL DEFAULT '0.00',
  `total_iqd` decimal(14,2) NOT NULL DEFAULT '0.00',
  `currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'IQD',
  `payment_method` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'wallet',
  `address` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `placed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `code`, `source`, `user_id`, `status`, `items_total_iqd`, `shipping_iqd`, `service_fee_iqd`, `total_iqd`, `currency`, `payment_method`, `address`, `placed_at`, `created_at`, `updated_at`) VALUES
(47, 'HM-20047', 'app', 3, 'cancelled', 12250.00, 0.00, 0.00, 12250.00, 'IQD', 'wallet', '{\"recipient_name\":\"shimal\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zako\",\"phone\":\"7504848085\"}', '2026-07-15 08:41:09', '2026-07-15 08:41:09', '2026-07-23 09:44:12'),
(48, 'HM-20048', 'app', 3, 'cancelled', 10.75, 2.00, 0.00, 12.75, 'USD', 'wallet', '{\"recipient_name\":\"shimal\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zako\",\"phone\":\"7504848085\"}', '2026-07-15 09:19:14', '2026-07-15 09:19:14', '2026-07-23 09:43:59'),
(49, 'HM-20049', 'app', 3, 'cancelled', 25.25, 2.00, 0.00, 27.25, 'USD', 'wallet', '{\"recipient_name\":\"shimal\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zako\",\"phone\":\"7504848085\"}', '2026-07-15 12:09:26', '2026-07-15 12:09:26', '2026-07-23 09:44:03'),
(50, 'HM-20050', 'app', 3, 'placed', 10.75, 2.00, 0.00, 12.75, 'USD', 'wallet', '{\"recipient_name\":\"shimal\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zako\",\"phone\":\"7504848085\"}', '2026-07-15 12:22:16', '2026-07-15 12:22:16', '2026-07-23 09:44:14'),
(51, 'HM-20051', 'app', 3, 'cancelled', 30.50, 2.00, 0.00, 32.50, 'USD', 'wallet', '{\"recipient_name\":\"shimal\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zako\",\"phone\":\"7504848085\"}', '2026-07-15 15:54:44', '2026-07-15 15:54:44', '2026-07-23 09:44:15'),
(52, 'HM-20052', 'app', 3, 'cancelled', 160500.00, 0.00, 0.00, 160500.00, 'IQD', 'wallet', '{\"recipient_name\":\"shimal\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zako\",\"phone\":\"7504848085\"}', '2026-07-16 13:41:07', '2026-07-16 13:41:07', '2026-07-23 09:44:20'),
(53, 'HM-20053', 'app', 3, 'cancelled', 10.75, 2.00, 0.00, 12.75, 'USD', 'wallet', '{\"recipient_name\":\"shimal\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zako\",\"phone\":\"7504848085\"}', '2026-07-23 09:41:00', '2026-07-23 09:41:00', '2026-07-23 09:44:22'),
(54, 'HM-20054', 'app', 3, 'cancelled', 10.75, 2.00, 0.00, 12.75, 'USD', 'wallet', '{\"recipient_name\":\"shimal\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zako\",\"phone\":\"7504848085\"}', '2026-07-23 10:11:07', '2026-07-23 10:11:07', '2026-07-23 16:44:42'),
(55, 'HM-20055', 'app', 3, 'cancelled', 0.50, 0.00, 0.00, 0.50, 'USD', 'wallet', '{\"recipient_name\":\"shimal\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zako\",\"phone\":\"7504848085\"}', '2026-07-23 11:52:15', '2026-07-23 11:52:15', '2026-07-26 18:33:03'),
(56, 'HM-20056', 'app', 3, 'placed', 10.75, 2.00, 0.00, 12.75, 'USD', 'wallet', '{\"recipient_name\":\"shimal\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zako\",\"phone\":\"7504848085\"}', '2026-07-23 12:42:29', '2026-07-23 12:42:29', '2026-07-23 16:46:47'),
(57, 'HM-20057', 'app', 3, 'placed', 10.75, 2.00, 0.00, 12.75, 'USD', 'wallet', '{\"recipient_name\":\"shimal\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zako\",\"phone\":\"7504848085\"}', '2026-07-23 12:58:04', '2026-07-23 12:58:04', '2026-07-23 13:18:25'),
(58, 'HM-20058', 'app', 3, 'cancelled', 10.75, 2.00, 0.00, 12.75, 'USD', 'wallet', '{\"recipient_name\":\"shimal\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zako\",\"phone\":\"7504848085\"}', '2026-07-23 16:35:25', '2026-07-23 16:35:25', '2026-07-23 16:44:40'),
(59, 'HM-20059', 'admin', 5, 'placed', 0.00, 0.00, 0.00, 0.00, 'IQD', 'cod', NULL, '2026-07-23 15:54:16', '2026-07-23 15:54:16', '2026-07-23 15:54:16'),
(60, 'HM-20060', 'admin', 5, 'placed', 0.00, 0.00, 0.00, 0.00, 'USD', 'cod', NULL, '2026-07-25 07:37:46', '2026-07-25 07:37:46', '2026-07-25 07:37:46'),
(61, 'HM-20061', 'admin', 10, 'placed', 0.00, 0.00, 0.00, 0.00, 'USD', 'cod', NULL, '2026-07-25 07:39:44', '2026-07-25 07:39:44', '2026-07-25 07:39:44'),
(62, 'HM-20062', 'admin', 6, 'placed', 0.00, 0.00, 0.00, 0.00, 'IQD', 'cod', NULL, '2026-07-25 07:57:27', '2026-07-25 07:57:27', '2026-07-25 07:57:27'),
(63, 'HM-20063', 'admin', 7, 'placed', 0.00, 0.00, 0.00, 0.00, 'USD', 'cod', NULL, '2026-07-25 08:04:09', '2026-07-25 08:04:09', '2026-07-25 08:04:09'),
(64, 'HM-20064', 'admin', 3, 'placed', 0.00, 0.00, 0.00, 0.00, 'USD', 'cod', NULL, '2026-07-25 08:09:01', '2026-07-25 08:09:01', '2026-07-25 08:09:01'),
(65, 'HM-20065', 'admin', 7, 'placed', 0.00, 0.00, 0.00, 0.00, 'USD', 'cod', NULL, '2026-07-25 08:15:05', '2026-07-25 08:15:05', '2026-07-25 08:15:05'),
(66, 'HM-20066', 'admin', 10, 'placed', 0.00, 0.00, 0.00, 0.00, 'USD', 'cod', NULL, '2026-07-25 08:27:41', '2026-07-25 08:27:41', '2026-07-25 08:27:41'),
(67, 'HM-20067', 'admin', 7, 'placed', 2317.31, 0.00, 0.00, 2317.31, 'USD', 'cod', NULL, '2026-07-25 08:31:21', '2026-07-25 08:31:21', '2026-07-25 08:31:21'),
(68, 'HM-20068', 'admin', 10, 'placed', 34.64, 0.00, 0.00, 34.64, 'USD', 'cod', NULL, '2026-07-25 08:46:37', '2026-07-25 08:46:37', '2026-07-25 08:46:37'),
(69, 'HM-20069', 'admin', 10, 'placed', 7.17, 0.00, 0.00, 7.17, 'USD', 'cod', NULL, '2026-07-25 09:08:49', '2026-07-25 09:08:49', '2026-07-25 09:08:49'),
(70, 'HM-20070', 'admin', 10, 'placed', 32.75, 0.00, 0.00, 32.75, 'USD', 'cod', NULL, '2026-07-25 09:55:37', '2026-07-25 09:55:37', '2026-07-25 09:55:37'),
(71, 'HM-20071', 'admin', 5, 'placed', 32.55, 0.00, 0.00, 32.55, 'USD', 'cod', NULL, '2026-07-25 09:57:12', '2026-07-25 09:57:12', '2026-07-25 09:57:12'),
(72, 'HM-20072', 'admin', 5, 'placed', 20.77, 0.00, 0.00, 20.77, 'USD', 'cod', NULL, '2026-07-25 12:22:01', '2026-07-25 12:22:01', '2026-07-25 12:22:01'),
(73, 'HM-20073', 'admin', 11, 'placed', 19.27, 0.00, 0.00, 19.27, 'USD', 'cod', NULL, '2026-07-25 12:29:16', '2026-07-25 12:29:16', '2026-07-25 12:29:16'),
(74, 'HM-20074', 'admin', 5, 'placed', 17.27, 0.00, 0.00, 17.27, 'USD', 'cod', NULL, '2026-07-25 13:21:14', '2026-07-25 13:21:14', '2026-07-25 13:21:14'),
(75, 'HM-20075', 'admin', 11, 'placed', 17.27, 0.00, 0.00, 17.27, 'USD', 'cod', NULL, '2026-07-25 13:22:17', '2026-07-25 13:22:17', '2026-07-25 13:22:17'),
(79, 'HM-20076', 'admin', 11, 'placed', 16.85, 0.00, 0.00, 16.85, 'USD', 'cod', NULL, '2026-07-28 13:59:20', '2026-07-28 13:59:20', '2026-07-28 13:59:20'),
(80, 'HM-20077', 'admin', 11, 'placed', 16.85, 0.00, 0.00, 16.85, 'USD', 'cod', NULL, '2026-07-29 12:50:01', '2026-07-29 12:50:01', '2026-07-29 12:50:01'),
(81, 'HM-20081', 'app', 3, 'placed', 0.50, 2.00, 0.00, 2.50, 'USD', 'wallet', '{\"recipient_name\":\"shimal\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zako\",\"phone\":\"7504848085\"}', '2026-07-30 11:50:58', '2026-07-30 11:50:58', '2026-07-30 11:50:58'),
(82, 'HM-20082', 'admin', 12, 'placed', 12417.24, 0.00, 0.00, 12417.24, 'IQD', 'cod', NULL, '2026-08-02 17:59:15', '2026-08-02 17:59:15', '2026-08-02 17:59:15'),
(83, 'HM-20083', 'admin', 11, 'placed', 6.71, 0.00, 0.00, 6.71, 'USD', 'cod', NULL, '2026-08-04 19:01:40', '2026-08-04 19:01:40', '2026-08-04 19:01:40'),
(84, 'HM-20084', 'admin', 11, 'placed', 15602.10, 0.00, 0.00, 15602.10, 'IQD', 'cod', NULL, '2026-08-06 12:53:08', '2026-08-06 12:53:08', '2026-08-06 12:53:08'),
(85, 'HM-20085', 'app', 13, 'placed', 9500.00, 0.00, 0.00, 9500.00, 'IQD', 'wallet', '{\"recipient_name\":\"shimal sendi\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zakhi\",\"phone\":\"7504845522\"}', '2026-08-08 10:51:32', '2026-08-08 10:51:32', '2026-08-08 10:51:32'),
(86, 'HM-20086', 'app', 13, 'placed', 0.50, 4.00, 0.00, 4.50, 'USD', 'wallet', '{\"recipient_name\":\"shimal sendi\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zakhi\",\"phone\":\"7504845522\"}', '2026-08-08 10:58:29', '2026-08-08 10:58:29', '2026-08-08 11:03:59'),
(87, 'HM-20087', 'app', 13, 'cancelled', 27.25, 4.00, 0.00, 31.25, 'USD', 'wallet', '{\"recipient_name\":\"shimal sendi\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zakhi\",\"phone\":\"7504845522\"}', '2026-08-08 11:25:53', '2026-08-08 11:25:53', '2026-08-08 12:32:56'),
(88, 'HM-20088', 'app', 13, 'cancelled', 1750.00, 0.00, 0.00, 1750.00, 'IQD', 'wallet', '{\"recipient_name\":\"shimal sendi\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zakhi\",\"phone\":\"7504845522\"}', '2026-08-08 11:27:07', '2026-08-08 11:27:07', '2026-08-08 11:32:12'),
(89, 'HM-20089', 'admin', 13, 'cancelled', 11.57, 0.00, 0.00, 11.57, 'USD', 'cod', NULL, '2026-08-08 08:27:22', '2026-08-08 08:27:22', '2026-08-08 12:28:24'),
(90, 'HM-20090', 'app', 14, 'placed', 9.75, 4.00, 0.00, 13.75, 'USD', 'wallet', '{\"recipient_name\":\"user1\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"kurnish\",\"phone\":\"7518016694\"}', '2026-08-08 12:02:27', '2026-08-08 12:02:27', '2026-08-08 12:02:27'),
(91, 'HM-20091', 'app', 13, 'placed', 3.50, 5.00, 0.00, 8.50, 'USD', 'wallet', '{\"recipient_name\":\"shimal sendi\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zakhi\",\"phone\":\"7504845522\"}', '2026-08-08 12:33:52', '2026-08-08 12:33:52', '2026-08-08 12:35:36'),
(93, 'HM-20092', 'admin', 11, 'placed', 10.98, 0.00, 0.00, 10.98, 'USD', 'cod', NULL, '2026-08-09 12:58:55', '2026-08-09 12:58:55', '2026-08-09 12:58:55'),
(97, 'HM-20097', 'app', 13, 'placed', 14.78, 2.00, 0.00, 16.78, 'USD', 'cod', '{\"recipient_name\":\"shimal sendi\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zakhi\",\"phone\":\"7504845522\"}', '2026-08-09 18:08:53', '2026-08-09 18:08:53', '2026-08-09 18:08:53'),
(98, 'HM-20098', 'admin', 11, 'placed', 10.98, 0.00, 0.00, 10.98, 'USD', 'cod', NULL, '2026-08-09 15:13:30', '2026-08-09 15:13:30', '2026-08-09 15:13:30'),
(99, 'HM-20099', 'app', 3, 'placed', 14.78, 2.00, 0.00, 16.78, 'USD', 'wallet', '{\"recipient_name\":\"shimal\",\"governorate\":\"\\u062f\\u0647\\u0648\\u0643\",\"city\":\"\\u0632\\u0627\\u062e\\u0648\",\"street\":\"New zako\",\"phone\":\"7504848085\"}', '2026-08-10 22:33:45', '2026-08-10 22:33:45', '2026-08-10 22:33:45'),
(100, 'HM-20100', 'admin', 11, 'placed', 12.96, 0.00, 0.00, 12.96, 'USD', 'cod', NULL, '2026-08-12 15:09:04', '2026-08-12 15:09:04', '2026-08-12 15:09:04'),
(101, 'HM-20101', 'admin', 14, 'placed', 40.00, 0.00, 0.00, 40.00, 'USD', 'cod', NULL, '2026-08-12 15:17:40', '2026-08-12 15:17:40', '2026-08-12 15:17:40'),
(102, 'HM-20102', 'admin', 12, 'placed', 40.00, 0.00, 0.00, 40.00, 'USD', 'cod', NULL, '2026-08-12 15:18:29', '2026-08-12 15:18:29', '2026-08-12 15:18:29'),
(103, 'HM-20103', 'admin', 14, 'placed', 10.65, 0.00, 0.00, 10.65, 'USD', 'cod', NULL, '2026-08-12 15:21:15', '2026-08-12 15:21:15', '2026-08-12 15:21:15'),
(104, 'HM-20104', 'admin', 14, 'placed', 10.65, 0.00, 0.00, 10.65, 'USD', 'cod', NULL, '2026-08-12 15:24:31', '2026-08-12 15:24:31', '2026-08-12 15:24:31'),
(105, 'HM-20105', 'admin', 12, 'placed', 10.65, 0.00, 0.00, 10.65, 'USD', 'cod', NULL, '2026-08-12 15:24:56', '2026-08-12 15:24:56', '2026-08-12 15:24:56'),
(106, 'HM-20106', 'admin', 11, 'placed', 29445.00, 0.00, 0.00, 29445.00, 'IQD', 'cod', NULL, '2026-08-12 15:28:50', '2026-08-12 15:28:50', '2026-08-12 15:28:50'),
(107, 'HM-20107', 'admin', 13, 'placed', 15975.00, 0.00, 0.00, 15975.00, 'IQD', 'cod', NULL, '2026-08-12 15:30:17', '2026-08-12 15:30:17', '2026-08-12 15:30:17'),
(108, 'HM-20108', 'admin', 14, 'placed', 11580.00, 0.00, 0.00, 11580.00, 'IQD', 'cod', NULL, '2026-08-12 15:34:48', '2026-08-12 15:34:48', '2026-08-12 15:34:48'),
(109, 'HM-20109', 'admin', 14, 'placed', 11580.00, 0.00, 0.00, 11580.00, 'IQD', 'cod', NULL, '2026-08-12 15:48:44', '2026-08-12 15:48:44', '2026-08-12 15:48:44'),
(110, 'HM-20110', 'admin', 14, 'placed', 29445.00, 0.00, 0.00, 29445.00, 'IQD', 'cod', NULL, '2026-08-12 16:07:54', '2026-08-12 16:07:54', '2026-08-12 16:07:54'),
(111, 'HM-20111', 'admin', 11, 'placed', 11580.00, 0.00, 0.00, 11580.00, 'IQD', 'cod', NULL, '2026-08-12 16:27:55', '2026-08-12 16:27:55', '2026-08-12 16:27:55'),
(112, 'HM-20112', 'admin', 12, 'placed', 10422.00, 0.00, 0.00, 10422.00, 'IQD', 'cod', NULL, '2026-08-12 16:35:22', '2026-08-12 16:35:22', '2026-08-12 16:35:22'),
(113, 'HM-20113', 'admin', 14, 'placed', 11286.00, 0.00, 0.00, 11286.00, 'IQD', 'cod', NULL, '2026-08-12 16:36:47', '2026-08-12 16:36:47', '2026-08-12 16:36:47'),
(114, 'HM-20114', 'admin', 14, 'placed', 10422.00, 0.00, 0.00, 10422.00, 'IQD', 'cod', NULL, '2026-08-12 16:39:20', '2026-08-12 16:39:20', '2026-08-12 16:39:20'),
(115, 'HM-20115', 'admin', 14, 'placed', 10422.00, 0.00, 0.00, 10422.00, 'IQD', 'cod', NULL, '2026-08-12 16:41:16', '2026-08-12 16:41:16', '2026-08-12 16:41:16'),
(116, 'HM-20116', 'admin', 14, 'placed', 13.64, 0.00, 0.00, 13.64, 'USD', 'cod', NULL, '2026-08-12 17:28:28', '2026-08-12 17:28:28', '2026-08-12 17:28:28'),
(117, 'HM-20117', 'admin', 14, 'placed', 4.57, 0.00, 0.00, 4.57, 'USD', 'cod', NULL, '2026-08-12 17:34:23', '2026-08-12 17:34:23', '2026-08-12 17:34:23'),
(118, 'HM-20118', 'admin', 14, 'placed', 30550.50, 0.00, 0.00, 30550.50, 'IQD', 'cod', NULL, '2026-08-12 21:58:19', '2026-08-12 21:58:19', '2026-08-12 21:58:19');

-- --------------------------------------------------------

--
-- Table structure for table `order_events`
--

CREATE TABLE `order_events` (
  `id` bigint UNSIGNED NOT NULL,
  `order_id` bigint UNSIGNED NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `happened_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_events`
--

INSERT INTO `order_events` (`id`, `order_id`, `status`, `note`, `happened_at`, `created_at`, `updated_at`) VALUES
(50, 47, 'placed', 'Order placed', '2026-07-15 08:41:09', '2026-07-15 08:41:09', '2026-07-15 08:41:09'),
(51, 48, 'placed', 'Order placed', '2026-07-15 09:19:14', '2026-07-15 09:19:14', '2026-07-15 09:19:14'),
(52, 49, 'placed', 'Order placed', '2026-07-15 12:09:26', '2026-07-15 12:09:26', '2026-07-15 12:09:26'),
(53, 50, 'placed', 'Order placed', '2026-07-15 12:22:16', '2026-07-15 12:22:16', '2026-07-15 12:22:16'),
(54, 51, 'placed', 'Order placed', '2026-07-15 15:54:44', '2026-07-15 15:54:44', '2026-07-15 15:54:44'),
(55, 52, 'placed', 'Order placed', '2026-07-16 13:41:07', '2026-07-16 13:41:07', '2026-07-16 13:41:07'),
(56, 53, 'placed', 'Order placed', '2026-07-23 09:41:00', '2026-07-23 09:41:00', '2026-07-23 09:41:00'),
(57, 48, 'cancelled', 'Order cancelled by customer', '2026-07-23 09:43:59', '2026-07-23 09:43:59', '2026-07-23 09:43:59'),
(58, 49, 'cancelled', 'Order cancelled by customer', '2026-07-23 09:44:03', '2026-07-23 09:44:03', '2026-07-23 09:44:03'),
(59, 47, 'cancelled', 'Order cancelled by customer', '2026-07-23 09:44:12', '2026-07-23 09:44:12', '2026-07-23 09:44:12'),
(60, 50, 'cancelled', 'Order cancelled by customer', '2026-07-23 09:44:14', '2026-07-23 09:44:14', '2026-07-23 09:44:14'),
(61, 51, 'cancelled', 'Order cancelled by customer', '2026-07-23 09:44:15', '2026-07-23 09:44:15', '2026-07-23 09:44:15'),
(62, 52, 'cancelled', 'Order cancelled by customer', '2026-07-23 09:44:20', '2026-07-23 09:44:20', '2026-07-23 09:44:20'),
(63, 53, 'cancelled', 'Order cancelled by customer', '2026-07-23 09:44:22', '2026-07-23 09:44:22', '2026-07-23 09:44:22'),
(64, 54, 'placed', 'Order placed', '2026-07-23 10:11:07', '2026-07-23 10:11:07', '2026-07-23 10:11:07'),
(65, 55, 'placed', 'Order placed', '2026-07-23 11:52:15', '2026-07-23 11:52:15', '2026-07-23 11:52:15'),
(66, 56, 'placed', 'Order placed', '2026-07-23 12:42:29', '2026-07-23 12:42:29', '2026-07-23 12:42:29'),
(67, 57, 'placed', 'Order placed', '2026-07-23 12:58:04', '2026-07-23 12:58:04', '2026-07-23 12:58:04'),
(68, 57, 'placed', 'Item removed (shipping rejected): Mavi Logo Baskılı Siyah Tişört Loose Fit / Bol Rahat Kesim 1611309-900', '2026-07-23 13:17:36', '2026-07-23 13:17:36', '2026-07-23 13:17:36'),
(69, 57, 'placed', 'Item removed (shipping rejected): Skechers D\'lİtes - GOOD NEUTRAL Kadın Beyaz Sneakers 149807 WHT', '2026-07-23 13:18:25', '2026-07-23 13:18:25', '2026-07-23 13:18:25'),
(70, 55, 'placed', 'Item removed (shipping rejected): Skechers D\'lİtes - GOOD NEUTRAL Kadın Beyaz Sneakers 149807 WHT', '2026-07-23 13:24:22', '2026-07-23 13:24:22', '2026-07-23 13:24:22'),
(71, 55, 'placed', 'Item removed (shipping rejected): Skechers D\'lİtes - GOOD NEUTRAL Kadın Beyaz Sneakers 149807 WHT', '2026-07-23 13:30:55', '2026-07-23 13:30:55', '2026-07-23 13:30:55'),
(72, 58, 'placed', 'Order placed', '2026-07-23 16:35:25', '2026-07-23 16:35:25', '2026-07-23 16:35:25'),
(73, 58, 'cancelled', 'Order cancelled — item rejected after shipping change', '2026-07-23 16:44:40', '2026-07-23 16:44:40', '2026-07-23 16:44:40'),
(74, 54, 'cancelled', 'Order cancelled — item rejected after shipping change', '2026-07-23 16:44:42', '2026-07-23 16:44:42', '2026-07-23 16:44:42'),
(75, 56, 'placed', 'Item cancelled: Nike Erkek Spor Ayakkabı REVOLUTION 8 Koşu Ayakkabısı Günlük Spor Ayakkabı Rahat', '2026-07-23 16:46:47', '2026-07-23 16:46:47', '2026-07-23 16:46:47'),
(76, 59, 'placed', 'Order placed by admin', '2026-07-23 15:54:16', '2026-07-23 15:54:16', '2026-07-23 15:54:16'),
(77, 60, 'placed', 'Order placed by admin', '2026-07-25 07:37:46', '2026-07-25 07:37:46', '2026-07-25 07:37:46'),
(78, 61, 'placed', 'Order placed by admin', '2026-07-25 07:39:44', '2026-07-25 07:39:44', '2026-07-25 07:39:44'),
(79, 62, 'placed', 'Order placed by admin', '2026-07-25 07:57:27', '2026-07-25 07:57:27', '2026-07-25 07:57:27'),
(80, 63, 'placed', 'Order placed by admin', '2026-07-25 08:04:09', '2026-07-25 08:04:09', '2026-07-25 08:04:09'),
(81, 64, 'placed', 'Order placed by admin', '2026-07-25 08:09:01', '2026-07-25 08:09:01', '2026-07-25 08:09:01'),
(82, 65, 'placed', 'Order placed by admin', '2026-07-25 08:15:05', '2026-07-25 08:15:05', '2026-07-25 08:15:05'),
(83, 66, 'placed', 'Order placed by admin', '2026-07-25 08:27:41', '2026-07-25 08:27:41', '2026-07-25 08:27:41'),
(84, 67, 'placed', 'Order placed by admin', '2026-07-25 08:31:21', '2026-07-25 08:31:21', '2026-07-25 08:31:21'),
(85, 68, 'placed', 'Order placed by admin', '2026-07-25 08:46:37', '2026-07-25 08:46:37', '2026-07-25 08:46:37'),
(86, 69, 'placed', 'Order placed by admin', '2026-07-25 09:08:49', '2026-07-25 09:08:49', '2026-07-25 09:08:49'),
(87, 70, 'placed', 'Order placed by admin', '2026-07-25 09:55:37', '2026-07-25 09:55:37', '2026-07-25 09:55:37'),
(88, 71, 'placed', 'Order placed by admin', '2026-07-25 09:57:12', '2026-07-25 09:57:12', '2026-07-25 09:57:12'),
(89, 72, 'placed', 'Order placed by admin', '2026-07-25 12:22:01', '2026-07-25 12:22:01', '2026-07-25 12:22:01'),
(90, 73, 'placed', 'Order placed by admin', '2026-07-25 12:29:16', '2026-07-25 12:29:16', '2026-07-25 12:29:16'),
(91, 74, 'placed', 'Order placed by admin', '2026-07-25 13:21:14', '2026-07-25 13:21:14', '2026-07-25 13:21:14'),
(92, 75, 'placed', 'Order placed by admin', '2026-07-25 13:22:17', '2026-07-25 13:22:17', '2026-07-25 13:22:17'),
(93, 53, 'cancelled', 'Order cancelled — item rejected after shipping change', '2026-07-26 18:33:01', '2026-07-26 18:33:01', '2026-07-26 18:33:01'),
(94, 55, 'cancelled', 'Order cancelled — item rejected after shipping change', '2026-07-26 18:33:03', '2026-07-26 18:33:03', '2026-07-26 18:33:03'),
(95, 79, 'placed', 'Order placed by admin', '2026-07-28 13:59:20', '2026-07-28 13:59:20', '2026-07-28 13:59:20'),
(96, 80, 'placed', 'Order placed by admin', '2026-07-29 12:50:01', '2026-07-29 12:50:01', '2026-07-29 12:50:01'),
(97, 81, 'placed', 'Order placed', '2026-07-30 11:50:58', '2026-07-30 11:50:58', '2026-07-30 11:50:58'),
(98, 82, 'placed', 'Order placed by admin', '2026-08-02 17:59:15', '2026-08-02 17:59:15', '2026-08-02 17:59:15'),
(99, 83, 'placed', 'Order placed by admin', '2026-08-04 19:01:40', '2026-08-04 19:01:40', '2026-08-04 19:01:40'),
(100, 84, 'placed', 'Order placed by admin', '2026-08-06 12:53:08', '2026-08-06 12:53:08', '2026-08-06 12:53:08'),
(101, 85, 'placed', 'Order placed', '2026-08-08 10:51:32', '2026-08-08 10:51:32', '2026-08-08 10:51:32'),
(102, 86, 'placed', 'Order placed', '2026-08-08 10:58:29', '2026-08-08 10:58:29', '2026-08-08 10:58:29'),
(103, 86, 'placed', 'Item cancelled: Embeauty Dökülme Karşıtı Şok Bakım & Saç Vitamini 5li Ampul', '2026-08-08 11:03:59', '2026-08-08 11:03:59', '2026-08-08 11:03:59'),
(104, 87, 'placed', 'Order placed', '2026-08-08 11:25:53', '2026-08-08 11:25:53', '2026-08-08 11:25:53'),
(105, 88, 'placed', 'Order placed', '2026-08-08 11:27:07', '2026-08-08 11:27:07', '2026-08-08 11:27:07'),
(106, 89, 'placed', 'Order placed by admin', '2026-08-08 08:27:22', '2026-08-08 08:27:22', '2026-08-08 08:27:22'),
(107, 88, 'cancelled', 'Order cancelled by customer', '2026-08-08 11:32:12', '2026-08-08 11:32:12', '2026-08-08 11:32:12'),
(108, 90, 'placed', 'Order placed', '2026-08-08 12:02:27', '2026-08-08 12:02:27', '2026-08-08 12:02:27'),
(109, 89, 'cancelled', 'Order cancelled by customer', '2026-08-08 12:28:24', '2026-08-08 12:28:24', '2026-08-08 12:28:24'),
(110, 87, 'cancelled', 'Order cancelled by customer', '2026-08-08 12:32:56', '2026-08-08 12:32:56', '2026-08-08 12:32:56'),
(111, 91, 'placed', 'Order placed', '2026-08-08 12:33:52', '2026-08-08 12:33:52', '2026-08-08 12:33:52'),
(112, 93, 'placed', 'Order placed by admin', '2026-08-09 12:58:55', '2026-08-09 12:58:55', '2026-08-09 12:58:55'),
(113, 97, 'placed', 'Order placed', '2026-08-09 18:08:53', '2026-08-09 18:08:53', '2026-08-09 18:08:53'),
(114, 98, 'placed', 'Order placed by admin', '2026-08-09 15:13:30', '2026-08-09 15:13:30', '2026-08-09 15:13:30'),
(115, 99, 'placed', 'Order placed', '2026-08-10 22:33:45', '2026-08-10 22:33:45', '2026-08-10 22:33:45'),
(116, 100, 'placed', 'Order placed by admin', '2026-08-12 15:09:04', '2026-08-12 15:09:04', '2026-08-12 15:09:04'),
(117, 101, 'placed', 'Order placed by admin', '2026-08-12 15:17:40', '2026-08-12 15:17:40', '2026-08-12 15:17:40'),
(118, 102, 'placed', 'Order placed by admin', '2026-08-12 15:18:29', '2026-08-12 15:18:29', '2026-08-12 15:18:29'),
(119, 103, 'placed', 'Order placed by admin', '2026-08-12 15:21:15', '2026-08-12 15:21:15', '2026-08-12 15:21:15'),
(120, 104, 'placed', 'Order placed by admin', '2026-08-12 15:24:31', '2026-08-12 15:24:31', '2026-08-12 15:24:31'),
(121, 105, 'placed', 'Order placed by admin', '2026-08-12 15:24:56', '2026-08-12 15:24:56', '2026-08-12 15:24:56'),
(122, 106, 'placed', 'Order placed by admin', '2026-08-12 15:28:51', '2026-08-12 15:28:51', '2026-08-12 15:28:51'),
(123, 107, 'placed', 'Order placed by admin', '2026-08-12 15:30:17', '2026-08-12 15:30:17', '2026-08-12 15:30:17'),
(124, 108, 'placed', 'Order placed by admin', '2026-08-12 15:34:48', '2026-08-12 15:34:48', '2026-08-12 15:34:48'),
(125, 109, 'placed', 'Order placed by admin', '2026-08-12 15:48:44', '2026-08-12 15:48:44', '2026-08-12 15:48:44'),
(126, 110, 'placed', 'Order placed by admin', '2026-08-12 16:07:54', '2026-08-12 16:07:54', '2026-08-12 16:07:54'),
(127, 111, 'placed', 'Order placed by admin', '2026-08-12 16:27:55', '2026-08-12 16:27:55', '2026-08-12 16:27:55'),
(128, 112, 'placed', 'Order placed by admin', '2026-08-12 16:35:22', '2026-08-12 16:35:22', '2026-08-12 16:35:22'),
(129, 113, 'placed', 'Order placed by admin', '2026-08-12 16:36:47', '2026-08-12 16:36:47', '2026-08-12 16:36:47'),
(130, 114, 'placed', 'Order placed by admin', '2026-08-12 16:39:20', '2026-08-12 16:39:20', '2026-08-12 16:39:20'),
(131, 115, 'placed', 'Order placed by admin', '2026-08-12 16:41:16', '2026-08-12 16:41:16', '2026-08-12 16:41:16'),
(132, 116, 'placed', 'Order placed by admin', '2026-08-12 17:28:28', '2026-08-12 17:28:28', '2026-08-12 17:28:28'),
(133, 117, 'placed', 'Order placed by admin', '2026-08-12 17:34:23', '2026-08-12 17:34:23', '2026-08-12 17:34:23'),
(134, 118, 'placed', 'Order placed by admin', '2026-08-12 21:58:19', '2026-08-12 21:58:19', '2026-08-12 21:58:19');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` bigint UNSIGNED NOT NULL,
  `order_id` bigint UNSIGNED NOT NULL,
  `store_id` bigint UNSIGNED DEFAULT NULL,
  `store_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `source_url` varchar(1024) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_url` varchar(1024) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `source_price` decimal(12,2) NOT NULL,
  `source_currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USD',
  `charge_currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'IQD',
  `iqd_price` decimal(14,2) NOT NULL DEFAULT '0.00',
  `cust_usd` decimal(12,2) DEFAULT NULL,
  `shipping` decimal(12,2) DEFAULT NULL,
  `approval` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `step` varchar(24) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `box_id` bigint UNSIGNED DEFAULT NULL,
  `paid_at` timestamp NULL DEFAULT NULL,
  `color` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `size` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sku` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `qty` int UNSIGNED NOT NULL DEFAULT '1',
  `purchased_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `ship_box_id` bigint UNSIGNED DEFAULT NULL,
  `parcel_id` bigint UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `store_id`, `store_name`, `source_url`, `title`, `image_url`, `source_price`, `source_currency`, `charge_currency`, `iqd_price`, `cust_usd`, `shipping`, `approval`, `step`, `box_id`, `paid_at`, `color`, `size`, `sku`, `note`, `qty`, `purchased_at`, `created_at`, `updated_at`, `ship_box_id`, `parcel_id`) VALUES
(58, 47, 1, 'Shein', 'https://m.shein.com/ar-en/Men-s-Lightweight-Drawstring-Waist-Slant-Pocket-Solid-Color-Casual-Pants-p-43328251.html?mallCode=1&imgRatio=3-4&pageFrom=page_super_deals&src_module=all&src_tab_page_id=page_home1784104833776&src_identifier=on=FLEXIBLE_LAYOUT_COMPONENT`cn=superdeals`hz=refresh_0`jc=thriftyFind_`ps=4_1_2&detailBusinessFrom=0-2', 'SHEIN | Women\'s Fashion Online Shopping | Shop Seasonal Best Selling Dresses, Shoes & Bags', 'https://img.ltwebstatic.com/v4/p/spmp/2025/11/10/7e/176277411636423fda5cf9e80d6d87ad7663e1a5b2_thumbnail_750x999.avif', 7.08, 'USD', 'IQD', 12250.00, NULL, NULL, NULL, 'bought', 1, NULL, 'Grey', 'M', 'sm2305109193553070', NULL, 1, NULL, '2026-07-15 08:41:09', '2026-08-09 13:44:15', NULL, NULL),
(59, 48, 7, 'Trendyol', 'https://www.trendyol.com/icollagen/kolajen-ve-prebiyotik-tablet-p-752356123?boutiqueId=61&merchantId=1013507', 'icollagen Kolajen Ve Prebiyotik Tablet', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1000406/product/media/images/prod/PIM/20260616/14/05dbc866-fefa-461e-b2ba-542bc959ae33/1_org_zoom.jpg', 350.00, 'TRY', 'USD', 10.75, NULL, NULL, NULL, 'delivery', 14, '2026-08-08 07:32:01', NULL, NULL, '752356123', NULL, 1, NULL, '2026-07-15 09:19:14', '2026-08-08 07:32:01', 6, 14),
(60, 49, 8, 'Hepsiburada', 'https://www.hepsiburada.com/neeko-phonix-mobil-stick-telefon-kontrol-oda-aydinlatma-sistemi-full-rgb-full-renk-cok-ozellik-kumandasiz-120-cm-p-HBCV000015T39D', 'Neeko Phonix Mobıl Stıck Telefon Kontrol Oda Aydınlatma Sistemi Full Rgb Full Renk Çok Özellik', 'https://productimages.hepsiburada.net/s/777/375-500/110001869587927.jpg', 819.90, 'TRY', 'USD', 25.25, NULL, NULL, NULL, 'delivery', 14, '2026-08-08 07:32:01', 'Parlak Siyah', NULL, NULL, NULL, 1, NULL, '2026-07-15 12:09:26', '2026-08-08 07:32:01', 6, 14),
(61, 50, 10, 'Stradivarius', 'https://www.stradivarius.com/tr/ecocell-cift-katmanl%C4%B1-tshirt-l02778401?categoryId=1020486163&colorId=003&pelement=484659180', 'Ecocell çift katmanlı t-shirt', 'https://static.e-stradivarius.net/assets/public/4afb/ed28/802e4b2db652/df1cc894ec89/02778401001-a15/02778401001-a15.jpg?ts=1775556064216&w=720&f=auto', 350.00, 'TRY', 'USD', 10.75, 14.75, 4.00, 'accepted', 'company', 9, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-15 12:22:16', '2026-08-12 21:46:38', 7, 18),
(62, 51, 10, 'Stradivarius', 'https://www.stradivarius.com/tr/dokumlu-pareo-pantolon-l01207633?categoryId=1020486173&colorId=433&pelement=485769285', 'Dökümlü pareo pantolon', 'https://static.e-stradivarius.net/assets/public/63ad/3f3f/aba84707a16d/d4eb7ba4e942/01207485433-a15/01207485433-a15.jpg?ts=1782464861622&w=720&f=auto', 990.00, 'TRY', 'USD', 30.50, 35.00, 4.50, NULL, 'returned', 10, NULL, NULL, 'xs', NULL, NULL, 1, NULL, '2026-07-15 15:54:44', '2026-08-02 17:46:56', NULL, NULL),
(63, 52, 1, 'Shein', 'https://m.shein.com/ar-en/trends-channel?fixed_entry=1&is_women_channel=0&page_from=block_main_entrance&channel_tab=trends_channel&enter_page_scene=0&fromPageType=home&src_module=all&src_identifier=on%3DFLEXIBLE_LAYOUT_COMPONENT%60cn%3Dtoptrends%60hz%3Drefresh_0%60jc%3Dtrends%60ps%3D4_2_1&src_tab_page_id=page_home1784209232496&ici=CCCSN%3Dall_ON%3DFLEXIBLE_LAYOUT_COMPONENT_OI%3D0_CN%3DFLEXIBLE_LAYOUT_FOR_SALEZONE_TI%3D50001_aod%3D0_PS%3D4-2_1_ABT%3D0&contentCarrierId_adp=50087684_395382387%2C2125777_391858904&top_goods_id=395382387%2C391858904&trend_word_id=8187%2C3307&scroll_top_x=209.875', 'SHEIN | Women\'s Fashion Online Shopping | Shop Seasonal Best Selling Dresses, Shoes & Bags', 'https://img.ltwebstatic.com/images3_pi/2024/08/26/62/1724642226c690dd85c0cb7cf35e067fa8e1aca430_thumbnail_336x.avif', 93.00, 'USD', 'IQD', 160500.00, NULL, NULL, NULL, 'company', 1, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-16 13:41:07', '2026-08-12 23:03:29', NULL, NULL),
(64, 53, 7, 'Trendyol', 'https://www.trendyol.com/icollagen/kolajen-ve-prebiyotik-tablet-p-752356123?boutiqueId=61&merchantId=1013507', 'icollagen Kolajen Ve Prebiyotik Tablet', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1000406/product/media/images/prod/PIM/20260616/14/05dbc866-fefa-461e-b2ba-542bc959ae33/1_org_zoom.jpg', 350.00, 'TRY', 'USD', 10.75, 14.75, 4.00, 'accepted', 'bought', 21, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-23 09:41:00', '2026-08-12 17:40:00', NULL, NULL),
(65, 54, 7, 'Trendyol', 'https://www.trendyol.com/mavi/logo-baskili-siyah-tisort-loose-fit-bol-rahat-kesim-1611309-900-p-355894678?boutiqueId=61&merchantId=63&v=l', 'Mavi Logo Baskılı Siyah Tişört Loose Fit / Bol Rahat Kesim 1611309-900 - Fiyatı, Yorumları', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1933/prod/QC_ENRICHMENT/20260720/06/6acb0b7c-cfbc-3877-9a8a-b2375606a689/1_org_zoom.jpg', 349.99, 'TRY', 'USD', 10.75, 16.75, 6.00, 'rejected', 'cancelled', NULL, NULL, 'Siyah-900', 'L', NULL, NULL, 1, NULL, '2026-07-23 10:11:07', '2026-08-01 13:41:29', NULL, NULL),
(66, 55, 7, 'Trendyol', 'https://www.trendyol.com/mavi/logo-baskili-interlok-gri-tisort-regular-fit-normal-kesim-1612829-89201-p-903166643?boutiqueId=61&merchantId=63', 'Mavi Logo Baskılı İnterlok Gri Tişört Regular Fit / Normal Kesim 1612829-89201 - Fiyatı, Yorumları', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1937/prod/QC_ENRICHMENT/20260720/05/b50c4ddc-7c83-3acd-93e8-6f45a1a3ef1d/1_org_zoom.jpg', 10.00, 'TRY', 'USD', 0.50, 7.50, 7.00, 'rejected', 'cancelled', NULL, NULL, 'Beyaz-89201', 'L', NULL, NULL, 1, NULL, '2026-07-23 11:52:15', '2026-08-01 13:41:27', NULL, NULL),
(67, 55, 7, 'Trendyol', 'https://www.trendyol.com/skechers/d-lites-good-neutral-kadin-beyaz-sneakers-149807-wht-p-854124225?boutiqueId=61&merchantId=658470&v=41', 'Skechers D\'lİtes - GOOD NEUTRAL Kadın Beyaz Sneakers 149807 WHT', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1788/prod/QC_PREP/20251117/04/2e140da1-ce8a-3e1c-9de1-8beb37167749/1_org_zoom.jpg', 5122.00, 'TRY', 'USD', 157.25, 164.25, 7.00, 'rejected', 'cancelled', NULL, NULL, 'Beyaz,', NULL, NULL, NULL, 1, NULL, '2026-07-23 11:52:15', '2026-07-23 13:31:24', NULL, NULL),
(68, 56, 7, 'Trendyol', 'https://www.trendyol.com/mavi/logo-baskili-siyah-tisort-loose-fit-bol-rahat-kesim-1611309-900-p-355894678?boutiqueId=61&merchantId=63&v=l', 'Mavi Logo Baskılı Siyah Tişört Loose Fit / Bol Rahat Kesim 1611309-900 - Fiyatı, Yorumları', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1933/prod/QC_ENRICHMENT/20260720/06/6acb0b7c-cfbc-3877-9a8a-b2375606a689/1_org_zoom.jpg', 349.99, 'TRY', 'USD', 10.75, NULL, 2.00, NULL, 'company', 13, NULL, 'Siyah-900', 'L', NULL, NULL, 1, NULL, '2026-07-23 12:42:29', '2026-08-12 21:46:38', 7, 18),
(70, 57, 7, 'Trendyol', 'https://www.trendyol.com/icollagen/kolajen-ve-prebiyotik-tablet-p-752356123?boutiqueId=61&merchantId=1013507', 'icollagen Kolajen Ve Prebiyotik Tablet', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1000406/product/media/images/prod/PIM/20260616/14/05dbc866-fefa-461e-b2ba-542bc959ae33/1_org_zoom.jpg', 350.00, 'TRY', 'USD', 10.75, NULL, 2.00, NULL, 'buying', 13, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-23 12:58:04', '2026-08-06 13:04:27', NULL, NULL),
(73, 58, 7, 'Trendyol', 'https://www.trendyol.com/mavi/logo-baskili-siyah-tisort-loose-fit-bol-rahat-kesim-1611309-900-p-355894678?boutiqueId=61&merchantId=63&v=l', 'Mavi Logo Baskılı Siyah Tişört Loose Fit / Bol Rahat Kesim 1611309-900 - Fiyatı, Yorumları', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1933/prod/QC_ENRICHMENT/20260720/06/6acb0b7c-cfbc-3877-9a8a-b2375606a689/1_org_zoom.jpg', 349.99, 'TRY', 'USD', 10.75, 14.25, 3.50, 'accepted', 'company', 7, NULL, 'Siyah-900', 'L', NULL, NULL, 1, NULL, '2026-07-23 16:35:25', '2026-08-12 21:46:38', 7, 18),
(74, 59, 8, 'Hepsiburada', 'https://www.hepsiburada.com/yaya-by-hotic-erkek-deri-siyah-hafif-tabanli-klasik-ayakkabi-p-HBCV00008AJ08Z?magaza=Yaya%20By%20Hoti%C3%A7', 'Yaya By Hotiç Erkek Deri Siyah Hafif Tabanlı Klasik Ayakkabı', 'https://productimages.hepsiburada.net/s/777/375/110000962991218.jpg/format:webp', 3998.00, 'TRY', 'IQD', 0.00, NULL, NULL, NULL, 'buying', 13, NULL, NULL, NULL, '445566', NULL, 1, NULL, '2026-07-23 15:54:16', '2026-08-06 13:04:24', NULL, NULL),
(75, 60, NULL, 'trendyol', 'https://www.trendyol.com/jeven-brus/libido-erkek-parfum-extrait-de-parfum-50-ml-p-875712530?boutiqueId=61', 'Jeven Brus Libido Erkek Parfüm - Extrait de Parfum 50 ml - Fiyatı, Yorumları', 'https://cdn.dsmcdn.com/ty1757/prod/QC_ENRICHMENT/20250918/13/81b54010-88ce-3a9f-819b-23c4690e4ba1/1_org_zoom.jpg', 1490.00, 'TRY', 'USD', 0.00, NULL, NULL, NULL, 'returned', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-25 07:37:46', '2026-08-04 15:12:01', NULL, NULL),
(76, 61, NULL, 'hepsiburada', 'https://www.hepsiburada.com/hellobaby-basic-elbise-p-HBCV00008L4NEQ', 'Hellobaby Basic Elbise Fiyatı, Taksit Seçenekleri ile Satın Al', 'https://productimages.hepsiburada.net/s/777/375/110001002907884.jpg/format:webp', 268.79, 'TRY', 'USD', 0.00, NULL, NULL, NULL, 'cancelled', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-25 07:39:44', '2026-08-01 13:57:07', NULL, NULL),
(77, 62, NULL, 'hepsiburada', 'https://www.hepsiburada.com/hellobaby-2li-atlet-body-p-HBCV0000EYZGJN', 'Hellobaby 2li Atlet Body Fiyatı, Taksit Seçenekleri ile Satın Al', 'https://productimages.hepsiburada.net/s/777/375/110001764658555.jpg/format:webp', 258.71, 'TRY', 'IQD', 0.00, NULL, NULL, NULL, 'cancelled', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-25 07:57:27', '2026-08-01 13:57:05', NULL, NULL),
(78, 63, NULL, 'hepsiburada', 'https://www.hepsiburada.com/hellobaby-kiz-bebek-body-citcitli-yaka-short-sleeve-p-HBCV0000DVV2HN', 'Hellobaby Kız Bebek Body Çıtçıtlı Yaka Short Sleeve Fiyatı', 'https://productimages.hepsiburada.net/s/777/375/110001638460620.jpg/format:webp', 120.95, 'TRY', 'USD', 0.00, NULL, NULL, NULL, 'cancelled', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-25 08:04:09', '2026-08-01 13:57:03', NULL, NULL),
(79, 64, NULL, 'hepsiburada', 'https://www.hepsiburada.com/koctas-uo-curacao-sezlong-su-mavisi-polyester-ve-metal-malzeme-ile-tasinabilir-konforlu-tasarim-p-HBCV0000D7G48D', 'Koçtaş UO Çuraçao Şezlong Su Mavisi Polyester ve Metal Fiyatı', 'https://productimages.hepsiburada.net/s/777/375/110001560057245.jpg/format:webp', 1299.00, 'TRY', 'USD', 0.00, NULL, NULL, NULL, 'returned', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-25 08:09:01', '2026-08-01 13:41:51', NULL, NULL),
(80, 65, NULL, 'hepsiburada', 'https://www.hepsiburada.com/hypn-se-drama-aninda-dolgunluk-ve-hacim-etkili-maskara-01-p-HBCV00006L03LN', 'Hypnôse Drama Anında Dolgunluk Ve Hacim Etkili Maskara 01 Fiyatı', 'https://productimages.hepsiburada.net/s/777/375/110000776488651.jpg/format:webp', 1450.00, 'TRY', 'USD', 0.00, NULL, NULL, NULL, 'returned', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-25 08:15:05', '2026-08-01 13:42:22', NULL, NULL),
(81, 66, NULL, 'hepsiburada', 'https://www.hepsiburada.com/hellobaby-basic-elbise-p-HBCV00008L4NEQ', 'Hellobaby Basic Elbise Fiyatı, Taksit Seçenekleri ile Satın Al', 'https://productimages.hepsiburada.net/s/777/375/110001002907884.jpg/format:webp', 268.79, 'TRY', 'USD', 0.00, NULL, NULL, NULL, 'returned', NULL, NULL, 'WHITE', '4-5', NULL, NULL, 1, NULL, '2026-07-25 08:27:41', '2026-08-01 13:41:04', NULL, NULL),
(82, 67, NULL, 'hepsiburada', 'https://www.hepsiburada.com/roborock-qrevo-c-pro-akilli-robot-supurge-18-500-pa-beyaz-p-HBCV0000CF78N7', 'Roborock Qrevo C Pro Akıllı Robot Süpürge 18.500 Pa - Beyaz Fiyatı', 'https://productimages.hepsiburada.net/s/777/375/110001653175569.jpg/format:webp', 86899.00, 'TRY', 'USD', 2317.31, NULL, NULL, NULL, 'returned', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-25 08:31:21', '2026-08-01 13:40:57', NULL, NULL),
(83, 68, NULL, 'hepsiburada', 'https://www.hepsiburada.com/koctas-uo-curacao-sezlong-su-mavisi-polyester-ve-metal-malzeme-ile-tasinabilir-konforlu-tasarim-p-HBCV0000D7G48D', 'Koçtaş UO Çuraçao Şezlong Su Mavisi Polyester ve Metal Fiyatı', 'https://productimages.hepsiburada.net/s/777/375/110001560057245.jpg/format:webp', 1299.00, 'TRY', 'USD', 34.64, 42.44, 7.80, NULL, 'company', 7, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-25 08:46:37', '2026-08-12 21:46:38', 7, 18),
(84, 69, NULL, 'hepsiburada', 'https://www.hepsiburada.com/hellobaby-basic-elbise-p-HBCV00008L4NEQ', 'Hellobaby Basic Elbise Fiyatı, Taksit Seçenekleri ile Satın Al', 'https://productimages.hepsiburada.net/s/777/375/110001002907884.jpg/format:webp', 268.79, 'TRY', 'USD', 7.17, 9.17, 2.00, NULL, 'delivery', 7, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-25 09:08:49', '2026-08-09 15:42:05', 3, 17),
(85, 70, NULL, 'hepsiburada', 'https://www.hepsiburada.com/hypn-se-drama-aninda-dolgunluk-ve-hacim-etkili-maskara-01-p-HBCV00006L03LN', 'Hypnôse Drama Anında Dolgunluk Ve Hacim Etkili Maskara 01 Fiyatı', 'https://productimages.hepsiburada.net/s/777/375/110000776488651.jpg/format:webp', 1450.00, 'TRY', 'USD', 32.75, 34.75, 2.00, NULL, 'delivery', 6, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-25 09:55:37', '2026-08-09 15:42:05', 1, 17),
(86, 71, NULL, 'hepsiburada', 'https://www.hepsiburada.com/hypn-se-drama-aninda-dolgunluk-ve-hacim-etkili-maskara-01-p-HBCV00006L03LN', 'Hypnôse Drama Anında Dolgunluk Ve Hacim Etkili Maskara 01 Fiyatı', 'https://productimages.hepsiburada.net/s/777/375/110000776488651.jpg/format:webp', 1450.00, 'TRY', 'USD', 32.55, 35.00, 2.00, NULL, 'delivery', 2, '2026-08-10 14:58:02', NULL, NULL, NULL, NULL, 1, NULL, '2026-07-25 09:57:12', '2026-08-10 14:58:02', 3, NULL),
(87, 72, NULL, 'hepsiburada', 'https://www.hepsiburada.com/barcar-deri-oto-bagaj-organizeri-sivi-gecirmez-cok-bolmeli-50x30x31-cm-arac-ev-ve-ofis-duzeni-icin-pm-HBC00007CTNFL', 'Barcar Deri Oto Bagaj Organizeri – Sıvı Geçirmez, Çok Fiyatı', 'https://productimages.hepsiburada.net/s/777/375/110000820774432.jpg/format:webp', 819.90, 'TRY', 'USD', 20.77, 22.77, 2.00, NULL, 'delivery', 2, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-25 12:22:01', '2026-08-08 08:06:48', 3, 16),
(88, 73, NULL, 'hepsiburada', 'https://www.hepsiburada.com/barcar-deri-oto-bagaj-organizeri-sivi-gecirmez-cok-bolmeli-50x30x31-cm-arac-ev-ve-ofis-duzeni-icin-pm-HBC00007CTNFL', 'Barcar Deri Oto Bagaj Organizeri – Sıvı Geçirmez, Çok Fiyatı', 'https://productimages.hepsiburada.net/s/777/375/110000820774432.jpg/format:webp', 819.90, 'TRY', 'USD', 19.27, 21.77, 2.50, NULL, 'delivery', 2, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-25 12:29:16', '2026-08-08 07:40:04', 1, 15),
(89, 74, NULL, 'hepsiburada', 'https://www.hepsiburada.com/barcar-deri-oto-bagaj-organizeri-sivi-gecirmez-cok-bolmeli-50x30x31-cm-arac-ev-ve-ofis-duzeni-icin-pm-HBC00007CTNFL', 'Barcar Deri Oto Bagaj Organizeri – Sıvı Geçirmez, Çok Fiyatı', 'https://productimages.hepsiburada.net/s/777/375/110000820774432.jpg/format:webp', 819.90, 'TRY', 'USD', 17.27, 19.27, 2.00, NULL, 'delivery', 2, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-25 13:21:14', '2026-08-08 08:06:48', 3, 16),
(90, 75, NULL, 'hepsiburada', 'https://www.hepsiburada.com/barcar-deri-oto-bagaj-organizeri-sivi-gecirmez-cok-bolmeli-50x30x31-cm-arac-ev-ve-ofis-duzeni-icin-pm-HBC00007CTNFL', 'Barcar Deri Oto Bagaj Organizeri – Sıvı Geçirmez, Çok Fiyatı', 'https://productimages.hepsiburada.net/s/777/375/110000820774432.jpg/format:webp', 819.90, 'TRY', 'USD', 17.27, 38.27, 21.00, NULL, 'delivery', 5, NULL, NULL, NULL, '23456789', NULL, 1, NULL, '2026-07-25 13:22:17', '2026-08-08 07:40:04', 3, 15),
(94, 79, NULL, 'hepsiburada', 'https://www.hepsiburada.com/babokah-bisiklet-yaka-kisa-kol-ust-p-HBCV00009W0OHO', 'Babokah Bisiklet Yaka Kısa Kol Üst Fiyatı - Taksit Seçenekleri', 'https://productimages.hepsiburada.net/s/777/375/110001239631750.jpg/format:webp', 800.00, 'TRY', 'USD', 16.85, 19.85, 3.00, NULL, 'delivery', 8, NULL, NULL, NULL, '575757', NULL, 1, NULL, '2026-07-28 13:59:20', '2026-08-08 07:40:04', 2, 15),
(95, 80, NULL, 'hepsiburada', 'https://www.hepsiburada.com/babokah-bisiklet-yaka-kisa-kol-ust-p-HBCV00009W0OHO', 'Babokah Bisiklet Yaka Kısa Kol Üst Fiyatı - Taksit Seçenekleri', 'https://productimages.hepsiburada.net/s/777/375/110001239631750.jpg/format:webp', 800.00, 'TRY', 'USD', 16.85, 19.35, 2.50, NULL, 'delivery', 3, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-29 12:50:01', '2026-08-08 07:25:27', 2, 13),
(96, 81, 7, 'Trendyol', 'https://www.trendyol.com/de/mavi/schwarzes-t-shirt-mit-logo-print-lockere-passform-1611309-900-p-355894678?v=l', 'Mavi Schwarzes T-Shirt mit Logo-Print, lockere Passform 1611309-900 - Preis und Bewertungen', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1939/prod/QC_ENRICHMENT/20260727/06/f4d660bb-5a9b-308e-a25e-4d41a1c7abf0/1_org_zoom.jpg', 14.99, 'TRY', 'USD', 0.50, NULL, 2.00, NULL, 'returned', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-07-30 11:50:58', '2026-08-01 13:40:50', NULL, NULL),
(97, 82, NULL, 'hepsiburada', 'https://www.hepsiburada.com/kiz-cocuk-fitilli-100-pamuklu-dugmeli-hirka-p-HBCV0000AD3V4K', 'Kız Çocuk Fitilli %100 Pamuklu Düğmeli Hırka Fiyatı', 'https://productimages.hepsiburada.net/s/777/375/110001235147135.jpg/format:webp', 449.90, 'TRY', 'IQD', 12417.24, 12421.24, 4.00, NULL, 'company', 12, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-08-02 17:59:15', '2026-08-12 21:46:38', 5, 18),
(98, 83, NULL, 'trendyol', 'https://www.trendyol.com/olalook/kadin-tas-ust-yirtmacli-bluz-alt-palazzo-fitilli-takim-tkm-19000180-p-637198414', 'Olalook Kadın Taş Üst Yırtmaçlı Bluz Alt Palazzo Fitilli Takım TKM-19000180 - Fiyatı, Yorumları', 'https://cdn.dsmcdn.com/ty1653/product/media/images/prod/PIM/20250327/13/817678fa-d41a-4433-89ec-7eef152e2113/1_org_zoom.jpg', 318.68, 'TRY', 'USD', 6.71, 8.71, 2.00, NULL, 'delivery', 11, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-08-04 19:01:40', '2026-08-08 07:25:27', 4, 13),
(99, 84, NULL, 'Shein', 'https://euqs.shein.com/Women-s-Casual-Top-Striped-Contrast-Ribbed-Fabric-Everyday-Wear-Spring-Autumn-Chic-Elegant-p-387841434.html?src_identifier=on%3DCATEGORY_RECOMMEND_COMPONENT%60cn%3DCATEGORY_RECOMMEND_COMPONENT_1%60hz%3D-%60jc%3Dreal_1766%60ps%3D2_2_4&src_module=all&src_tab_page_id=page_home1786018767940&mallCode=1&pageListType=4&detailBusinessFrom=0-1_387841434%7C0-2&imgRatio=3-4&detailBusinessFrom=0-1_387841434%7C0-2&pageListType=4', 'Women&#39;s Casual Top, Striped Contrast Ribbed Fabric, Everyday Wear, Spring/Autumn, Chic &amp; Elegant | SHEIN EUQS', 'https://img.ltwebstatic.com/v4/j/spmp/2026/06/08/7a/17809019123768295de7dfe0180a969d455be0e780_thumbnail_900x.webp', 11.91, 'USD', 'IQD', 15602.10, 15602.10, 0.00, NULL, 'delivery', 4, NULL, 'Rose Red', NULL, '387841434', NULL, 1, NULL, '2026-08-06 12:53:08', '2026-08-09 14:06:12', NULL, NULL),
(100, 85, 1, 'Shein', 'https://m.shein.com/ar-en/Men-s-Lightweight-Drawstring-Waist-Slant-Pocket-Solid-Color-Casual-Pants-p-43328251.html?mallCode=1&imgRatio=3-4&pageFrom=page_super_deals&src_module=all&src_tab_page_id=page_home1784104833776&src_identifier=on=FLEXIBLE_LAYOUT_COMPONENT%60cn=superdeals%60hz=refresh_0%60jc=thriftyFind_%60ps=4_1_2&detailBusinessFrom=0-2', 'Men\'s Lightweight Drawstring Waist Slant Pocket Solid Color Casual Pants', 'https://img.ltwebstatic.com/v4/p/spmp/2025/11/10/7e/176277411636423fda5cf9e80d6d87ad7663e1a5b2_thumbnail_750x999.avif', 6.25, 'USD', 'IQD', 9500.00, NULL, 0.00, NULL, 'company', 4, NULL, 'Grey', 'XL', 'I32ztl0y8k60', NULL, 1, NULL, '2026-08-08 10:51:32', '2026-08-12 23:03:26', NULL, NULL),
(101, 86, 7, 'Trendyol', 'https://www.trendyol.com/de/mavi/schwarzes-t-shirt-mit-logo-print-lockere-passform-1611309-900-p-355894678?v=l', 'Mavi Schwarzes T-Shirt mit Logo-Print, lockere Passform 1611309-900 - Preis und Bewertungen', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1939/prod/QC_ENRICHMENT/20260727/06/f4d660bb-5a9b-308e-a25e-4d41a1c7abf0/1_org_zoom.jpg', 14.99, 'TRY', 'USD', 0.50, 4.50, 4.00, 'accepted', 'cancelled', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-08-08 10:58:29', '2026-08-08 08:02:54', NULL, NULL),
(103, 87, 7, 'Trendyol', 'https://www.trendyol.com/mavi/miav-baskili-tisort-regular-fit-normal-kesim-067153-70722-p-684092731?boutiqueId=61&merchantId=63', 'Mavi Miav Baskılı Tişört Regular Fit / Normal Kesim 067153-70722 - Fiyatı, Yorumları', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1900/prod/QC_ENRICHMENT/20260727/06/82349660-1791-3558-864f-ae59ab46d27e/1_org_zoom.jpg', 399.99, 'TRY', 'USD', 9.75, 16.75, 7.00, 'accepted', 'pending', NULL, NULL, 'Lacivert,', 'M', NULL, NULL, 1, NULL, '2026-08-08 11:25:53', '2026-08-08 08:40:54', NULL, NULL),
(104, 87, 7, 'Trendyol', 'https://www.trendyol.com/u-s-polo-assn/kadin-beyaz-uzun-kollu-basic-gomlek-50324791-vr013-p-905066889?boutiqueId=61&merchantId=163', 'U.S. Polo Assn. Kadın Beyaz Uzun Kollu Basic Gömlek 50324791-VR013 - Fiyatı, Yorumları', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1939/prod/QC_PREP/20260515/18/63eaefc5-0056-3282-8b7a-5954c1b8cdab/1_org_zoom.jpg', 719.98, 'TRY', 'USD', 17.50, NULL, 2.00, NULL, 'cancelled', NULL, NULL, 'Beyaz', '34', NULL, NULL, 1, NULL, '2026-08-08 11:25:53', '2026-08-08 08:26:30', NULL, NULL),
(105, 88, 1, 'Shein', 'https://m.shein.com/ar-en/12pcs-10pcs-6pcs-4pcs-1pc-Random-Color-Peach-Push-Button-Ballpoint-Pens-Cute-Pink-Neutral-0-5mm-Black-Ink-Pens-Essential-School-Office-Supplies-Signature-Marking-Pens-Back-To-School-p-37123778.html?mallCode=1&imgRatio=3-4&pageFrom=page_super_deals&src_module=all&src_tab_page_id=page_home1786177565355&src_identifier=on=FLEXIBLE_LAYOUT_COMPONENT%60cn=superdeals%60hz=refresh_0%60jc=thriftyFind_%60ps=4_1_2&detailBusinessFrom=0-2', '12pcs/10pcs/6pcs/4pcs/1pc Random Color Peach Push-Button Ballpoint Pens, Cute Pink Neutral 0.5mm Black Ink Pens, Essential School & Office Supplies, Signature & Marking Pens, Back To School', 'https://img.ltwebstatic.com/images3_spmp/2024/09/18/b0/1726628918f2211ced41045a90b493c2d989486f71_thumbnail_750x999.avif', 1.06, 'USD', 'IQD', 1750.00, NULL, 0.00, NULL, 'cancelled', NULL, NULL, 'and', NULL, 'I3x2l3obo1bb', NULL, 1, NULL, '2026-08-08 11:27:07', '2026-08-08 08:43:58', NULL, NULL),
(106, 89, NULL, 'trendyol', 'https://www.trendyol.com/je-tu/etegi-kat-kat-volanli-mini-elbise-jt9186-p-1141595785?boutiqueId=61&merchantId=1110546', 'JE-TU Eteği Kat Kat Volanlı Mini Elbise JT9186 - Fiyatı, Yorumları', 'https://cdn.dsmcdn.com/mnresize/620/920/ty1906/prod/QC_PREP/20260503/18/00730fa8-4db2-3f98-bd7c-17ba918f00da/1_org_zoom.jpg', 549.00, 'TRY', 'USD', 11.57, 13.57, 2.00, NULL, 'company', 15, NULL, NULL, 'XS', '1141595785', NULL, 1, NULL, '2026-08-08 08:27:22', '2026-08-12 21:46:38', 7, 18),
(107, 90, 7, 'Trendyol', 'https://www.trendyol.com/embeauty/ultra-siyah-dolgunlastirici-maskara-hacim-ve-uzunluk-etkili-p-1016742922?boutiqueId=61&merchantId=1279865', 'Embeauty Ultra Siyah Dolgunlaştırıcı Maskara – Hacim ve Uzunluk Etkili', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1785/prod/QC_ENRICHMENT/20251108/13/65110fe4-dbaa-3c9b-bc1f-3f970801c9eb/1_org_zoom.jpg', 249.00, 'TRY', 'USD', 6.25, NULL, 2.00, NULL, 'bought', 19, NULL, 'Siyah', NULL, NULL, NULL, 1, NULL, '2026-08-08 12:02:27', '2026-08-12 17:39:08', NULL, NULL),
(108, 90, 7, 'Trendyol', 'https://www.trendyol.com/s-w-sweet-women/izbirakmaz-etkili-toparlayici-lazer-kesim-iz-yapmayan-hayalet-pacali-korse-4401-p-775035969?boutiqueId=61&merchantId=204106', 'S&W SWEET WOMEN #izbırakmaz Etkili Toparlayıcı Lazer Kesim iz Yapmayan Hayalet Paçalı Korse 4401', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1741/prod/QC_ENRICHMENT/20250830/13/9c81bae1-c58c-37b9-bac4-71b5937789ad/1_org_zoom.jpg', 142.59, 'TRY', 'USD', 3.50, 10.50, 7.00, 'accepted', NULL, NULL, NULL, 'Bej,', '59', NULL, NULL, 1, NULL, '2026-08-08 12:02:27', '2026-08-08 12:06:37', NULL, NULL),
(109, 91, 7, 'Trendyol', 'https://www.trendyol.com/s-w-sweet-women/izbirakmaz-etkili-toparlayici-lazer-kesim-iz-yapmayan-hayalet-pacali-korse-4401-p-775035969?boutiqueId=61&merchantId=204106', 'S&W SWEET WOMEN #izbırakmaz Etkili Toparlayıcı Lazer Kesim iz Yapmayan Hayalet Paçalı Korse 4401', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1741/prod/QC_ENRICHMENT/20250830/13/9c81bae1-c58c-37b9-bac4-71b5937789ad/1_org_zoom.jpg', 142.59, 'TRY', 'USD', 3.50, 8.50, 5.00, 'accepted', NULL, NULL, NULL, 'Bej,', 'XL', NULL, NULL, 1, NULL, '2026-08-08 12:33:52', '2026-08-08 12:35:36', NULL, NULL),
(111, 93, NULL, 'trendyol', 'https://www.trendyol.com/je-tu/etegi-kat-kat-volanli-mini-elbise-jt9186-p-1141595785?boutiqueId=61&merchantId=1110546', 'JE-TU Eteği Kat Kat Volanlı Mini Elbise JT9186 - Fiyatı, Yorumları', 'https://cdn.dsmcdn.com/mnresize/620/920/ty1906/prod/QC_PREP/20260503/18/00730fa8-4db2-3f98-bd7c-17ba918f00da/1_org_zoom.jpg', 549.00, 'TRY', 'USD', 10.98, 12.98, 2.00, NULL, 'bought', 29, NULL, NULL, 'XS', '1141595785', NULL, 1, NULL, '2026-08-09 12:58:55', '2026-08-12 21:49:12', NULL, NULL),
(115, 97, 7, 'Trendyol', 'https://www.trendyol.com/mavi/logo-baskili-siyah-tisort-loose-fit-bol-rahat-kesim-1611309-900-p-355894678?v=l', 'Mavi Logo Baskılı Siyah Tişört Loose Fit / Bol Rahat Kesim 1611309-900 - Fiyatı, Yorumları', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1939/prod/QC_ENRICHMENT/20260727/06/f4d660bb-5a9b-308e-a25e-4d41a1c7abf0/1_org_zoom.jpg', 739.00, 'TRY', 'USD', 14.78, NULL, 2.00, NULL, 'turkey', 27, NULL, 'Siyah-900', 'L', NULL, NULL, 1, NULL, '2026-08-09 18:08:53', '2026-08-12 23:22:23', NULL, NULL),
(116, 98, NULL, 'trendyol', 'https://www.trendyol.com/je-tu/etegi-kat-kat-volanli-mini-elbise-jt9186-p-1141595785?boutiqueId=61&merchantId=1110546', 'JE-TU Eteği Kat Kat Volanlı Mini Elbise JT9186 - Fiyatı, Yorumları', 'https://cdn.dsmcdn.com/mnresize/620/920/ty1906/prod/QC_PREP/20260503/18/00730fa8-4db2-3f98-bd7c-17ba918f00da/1_org_zoom.jpg', 549.00, 'TRY', 'USD', 10.98, 12.98, 2.00, NULL, 'company', 28, NULL, NULL, 'XS', '1141595785', NULL, 1, NULL, '2026-08-09 15:13:30', '2026-08-12 21:51:09', 9, 18),
(117, 99, 7, 'Trendyol', 'https://www.trendyol.com/mavi/logo-baskili-siyah-tisort-loose-fit-bol-rahat-kesim-1611309-900-p-355894678?v=l', 'Mavi Logo Baskılı Siyah Tişört Loose Fit / Bol Rahat Kesim 1611309-900 - Fiyatı, Yorumları', 'https://cdn.dsmcdn.com/mnresize/420/620/ty1939/prod/QC_ENRICHMENT/20260727/06/f4d660bb-5a9b-308e-a25e-4d41a1c7abf0/1_org_zoom.jpg', 739.00, 'TRY', 'USD', 14.78, NULL, 2.00, NULL, 'turkey', 26, NULL, 'Siyah-900', 'L', NULL, NULL, 1, NULL, '2026-08-10 22:33:45', '2026-08-12 22:44:53', NULL, NULL),
(118, 100, NULL, 'trendyol', 'https://www.trendyol.com/u-s-polo-assn/kadin-beyaz-uzun-kollu-basic-gomlek-50324791-vr013-p-905066889?boutiqueId=61&merchantId=163', 'U.S. Polo Assn. Kadın Beyaz Uzun Kollu Basic Gömlek 50324791-VR013 - Fiyatı, Yorumları', 'https://cdn.dsmcdn.com/mnresize/620/920/ty1939/prod/QC_ENRICHMENT/20260730/21/63eaefc5-0056-3282-8b7a-5954c1b8cdab/1_org_zoom.jpg', 647.98, 'TRY', 'USD', 12.96, 14.96, 2.00, NULL, 'stock', 25, NULL, NULL, '34', '905066889', NULL, 1, NULL, '2026-08-12 15:09:04', '2026-08-13 12:45:17', 8, 18),
(119, 101, NULL, 'ar', 'https://ar.shein.com/Solid-Color-High-Waist-Straight-Leg-Pants-Minimalist-Sports-Sweatpants-Versatile-Elastic-Waist-Drawstring-Wide-Leg-Casual-Trousers-All-Season-Spring-p-115643936.html?mallCode=1&pageListType=4&detailBusinessFrom=0-1_115643936%7C0-2', 'بنطلون ذو خصر عالي وساق مستقيمة، بنطلون رياضي بسيط، بنطلون كاجوال ذو خصر مطاطي وسحاب، متعدد الاستخدامات لجميع المواسم | شي إن', 'https://img.ltwebstatic.com/v4/j/spmp/2025/06/23/89/1750686919b41fc757cf68af5036f50d3960ff5826_thumbnail_405x552.jpg', 40.00, 'USD', 'USD', 40.00, 42.00, 2.00, NULL, 'stock', 24, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-08-12 15:17:40', '2026-08-13 12:45:12', 8, 18),
(120, 102, NULL, 'ar', 'https://ar.shein.com/Solid-Color-High-Waist-Straight-Leg-Pants-Minimalist-Sports-Sweatpants-Versatile-Elastic-Waist-Drawstring-Wide-Leg-Casual-Trousers-All-Season-Spring-p-115643936.html?mallCode=1&pageListType=4&detailBusinessFrom=0-1_115643936%7C0-2', 'بنطلون ذو خصر عالي وساق مستقيمة، بنطلون رياضي بسيط، بنطلون كاجوال ذو خصر مطاطي وسحاب، متعدد الاستخدامات لجميع المواسم | شي إن', 'https://img.ltwebstatic.com/v4/j/spmp/2025/06/23/89/1750686919b41fc757cf68af5036f50d3960ff5826_thumbnail_405x552.jpg', 40.00, 'USD', 'USD', 40.00, 42.00, 2.00, NULL, 'delivery', 23, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-08-12 15:18:29', '2026-08-12 21:51:23', 8, 18),
(121, 103, NULL, 'ar', 'https://ar.shein.com/Solid-Color-High-Waist-Straight-Leg-Pants-Minimalist-Sports-Sweatpants-Versatile-Elastic-Waist-Drawstring-Wide-Leg-Casual-Trousers-All-Season-Spring-p-115643936.html?_t=1786548057386&detailBusinessFrom=0-1_115643936%7C0-2&mallCode=1&pageListType=4', 'بنطلون ذو خصر عالي وساق مستقيمة، بنطلون رياضي بسيط، بنطلون كاجوال ذو خصر مطاطي وسحاب، متعدد الاستخدامات لجميع المواسم | شي إن', 'https://img.ltwebstatic.com/v4/j/spmp/2025/06/23/89/1750686919b41fc757cf68af5036f50d3960ff5826_thumbnail_405x552.jpg', 10.65, 'USD', 'USD', 10.65, 12.65, 2.00, NULL, 'delivery', 22, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-08-12 15:21:15', '2026-08-12 21:51:18', 8, 18),
(122, 104, NULL, 'ar', 'https://ar.shein.com/Solid-Color-High-Waist-Straight-Leg-Pants-Minimalist-Sports-Sweatpants-Versatile-Elastic-Waist-Drawstring-Wide-Leg-Casual-Trousers-All-Season-Spring-p-115643936.html?_t=1786548057386&detailBusinessFrom=0-1_115643936%7C0-2&mallCode=1&pageListType=4', 'بنطلون ذو خصر عالي وساق مستقيمة، بنطلون رياضي بسيط، بنطلون كاجوال ذو خصر مطاطي وسحاب، متعدد الاستخدامات لجميع المواسم | شي إن', 'https://img.ltwebstatic.com/v4/j/spmp/2025/06/23/89/1750686919b41fc757cf68af5036f50d3960ff5826_thumbnail_405x552.jpg', 10.65, 'USD', 'USD', 10.65, 12.65, 2.00, NULL, 'delivery', 20, NULL, NULL, NULL, '353535', NULL, 1, NULL, '2026-08-12 15:24:31', '2026-08-12 21:51:14', 8, 18),
(123, 105, NULL, 'ar', 'https://ar.shein.com/Solid-Color-High-Waist-Straight-Leg-Pants-Minimalist-Sports-Sweatpants-Versatile-Elastic-Waist-Drawstring-Wide-Leg-Casual-Trousers-All-Season-Spring-p-115643936.html?_t=1786548057386&detailBusinessFrom=0-1_115643936%7C0-2&mallCode=1&pageListType=4', 'بنطلون ذو خصر عالي وساق مستقيمة، بنطلون رياضي بسيط، بنطلون كاجوال ذو خصر مطاطي وسحاب، متعدد الاستخدامات لجميع المواسم | شي إن', 'https://img.ltwebstatic.com/v4/j/spmp/2025/06/23/89/1750686919b41fc757cf68af5036f50d3960ff5826_thumbnail_405x552.jpg', 10.65, 'USD', 'USD', 10.65, 12.65, 2.00, NULL, 'delivery', 20, NULL, NULL, NULL, NULL, NULL, 1, NULL, '2026-08-12 15:24:56', '2026-08-12 21:46:45', 8, 18),
(124, 106, NULL, 'Shein', 'https://euqs.shein.com/Plus-Size-Women-s-New-Arrival-Fashion-Elegant-Vacation-Bow-Tie-Long-Sleeve-Plaid-Casual-Shirt-Minimalist-For-Commute-Daily-Wear-Tea-Party-All-Seasons-Spring-p-423824287.html?_t=1786548462304&detailBusinessFrom=0-1_423824287%7C0-2&mallCode=1&pageListType=4', 'Plus Size Women&#39;s New Arrival Fashion Elegant Vacation Bow Tie Long Sleeve Plaid Casual Shirt, Minimalist For Commute, Daily Wear, Tea Party, All Seasons Spring | SHEIN EUQS', 'https://img.ltwebstatic.com/v4/j/spmp/2026/03/01/fa/1772354534b4d282d141e6c4b77ef5cbd0100d171b_thumbnail_900x.webp', 19.63, 'USD', 'IQD', 29445.00, 29445.00, 0.00, NULL, 'company', 30, NULL, NULL, NULL, '423824287', NULL, 1, NULL, '2026-08-12 15:28:50', '2026-08-12 22:51:00', NULL, NULL),
(125, 107, NULL, 'Shein', 'https://ar.shein.com/Solid-Color-High-Waist-Straight-Leg-Pants-Minimalist-Sports-Sweatpants-Versatile-Elastic-Waist-Drawstring-Wide-Leg-Casual-Trousers-All-Season-Black-Spring-p-230189325.html?_t=1786548057386&detailBusinessFrom=0-1_115643936%7C0-2&mallCode=1&pageListType=4&main_attr=27_336', 'بنطلون ذو خصر عالي وساق مستقيمة، بنطلون رياضي بسيط، بنطلون كاجوال ذو خصر مطاطي وسحاب، متعدد الاستخدامات لجميع المواسم | شي إن', 'https://img.ltwebstatic.com/v4/j/spmp/2025/11/17/c7/17633706110f5ecac4e54f832d249534d139d576a6_thumbnail_900x.webp', 10.65, 'USD', 'IQD', 15975.00, 15975.00, 0.00, NULL, 'company', 16, NULL, 'الأسود', 'S', '230189325', NULL, 1, NULL, '2026-08-12 15:30:17', '2026-08-12 22:01:28', NULL, NULL),
(126, 108, NULL, 'Shein', 'https://ar.shein.com/SHEIN-Girlism-Tween-Girl-Casual-Grey-Drawstring-Waist-Wide-Leg-Sweatpants-p-43443325.html?src_identifier=on%3DCATEGORY_RECOMMEND_COMPONENT%60cn%3DCATEGORY_RECOMMEND_COMPONENT_1%60hz%3D-%60jc%3Dreal_2031%60ps%3D2_1_3&src_module=all&src_tab_page_id=page_home1786548827575&mallCode=1&pageListType=4&detailBusinessFrom=0-1_43443325%7C0-2&imgRatio=1-1&detailBusinessFrom=0-1_43443325%7C0-2&pageListType=4', 'SHEIN Girlism بنطلون رياضي واسع الساق بخصر مربوط بسحاب للفتيات المراهقات، لون رمادي | شي إن', 'https://img.ltwebstatic.com/images3_pi/2024/10/12/15/17287237323b0dd27d466859cdfffe7ec99d8ea392_thumbnail_900x.webp', 7.72, 'USD', 'IQD', 11580.00, 11580.00, 0.00, NULL, 'company', 16, NULL, NULL, NULL, '43443325', NULL, 1, NULL, '2026-08-12 15:34:48', '2026-08-12 22:01:27', NULL, NULL),
(127, 109, NULL, 'Shein', 'https://ar.shein.com/SHEIN-Girlism-Tween-Girl-Casual-Grey-Drawstring-Waist-Wide-Leg-Sweatpants-p-43443325.html?src_identifier=on%3DCATEGORY_RECOMMEND_COMPONENT%60cn%3DCATEGORY_RECOMMEND_COMPONENT_1%60hz%3D-%60jc%3Dreal_2031%60ps%3D2_1_3&src_module=all&src_tab_page_id=page_home1786548827575&mallCode=1&pageListType=4&detailBusinessFrom=0-1_43443325%7C0-2&imgRatio=1-1&detailBusinessFrom=0-1_43443325%7C0-2&pageListType=4', 'SHEIN Girlism بنطلون رياضي واسع الساق بخصر مربوط بسحاب للفتيات المراهقات، لون رمادي | شي إن', 'https://img.ltwebstatic.com/images3_pi/2024/10/12/15/17287237323b0dd27d466859cdfffe7ec99d8ea392_thumbnail_900x.webp', 7.72, 'USD', 'IQD', 11580.00, 11580.00, 0.00, NULL, 'company', 30, NULL, NULL, NULL, '43443325', NULL, 1, NULL, '2026-08-12 15:48:44', '2026-08-12 21:59:49', NULL, NULL),
(128, 110, NULL, 'Shein', 'https://euqs.shein.com/Plus-Size-Women-s-New-Arrival-Fashion-Elegant-Vacation-Bow-Tie-Long-Sleeve-Plaid-Casual-Shirt-Minimalist-For-Commute-Daily-Wear-Tea-Party-All-Seasons-Spring-p-423824287.html?_t=1786548462304&detailBusinessFrom=0-1_423824287%7C0-2&mallCode=1&pageListType=4', 'Plus Size Women&#39;s New Arrival Fashion Elegant Vacation Bow Tie Long Sleeve Plaid Casual Shirt, Minimalist For Commute, Daily Wear, Tea Party, All Seasons Spring | SHEIN EUQS', 'https://img.ltwebstatic.com/v4/j/spmp/2026/03/01/fa/1772354534b4d282d141e6c4b77ef5cbd0100d171b_thumbnail_900x.webp', 19.63, 'USD', 'IQD', 29445.00, 29445.00, 0.00, NULL, 'company', 17, NULL, NULL, NULL, 'sz260301163716844441305', NULL, 1, NULL, '2026-08-12 16:07:54', '2026-08-12 21:57:29', NULL, NULL),
(129, 111, NULL, 'Shein', 'https://ar.shein.com/SHEIN-Girlism-Tween-Girl-Casual-Grey-Drawstring-Waist-Wide-Leg-Sweatpants-p-43443325.html?src_identifier=on%3DCATEGORY_RECOMMEND_COMPONENT%60cn%3DCATEGORY_RECOMMEND_COMPONENT_1%60hz%3D-%60jc%3Dreal_2031%60ps%3D2_1_3&src_module=all&src_tab_page_id=page_home1786548827575&mallCode=1&pageListType=4&detailBusinessFrom=0-1_43443325%7C0-2&imgRatio=1-1&detailBusinessFrom=0-1_43443325%7C0-2&pageListType=4', 'SHEIN Girlism بنطلون رياضي واسع الساق بخصر مربوط بسحاب للفتيات المراهقات، لون رمادي | شي إن', 'https://img.ltwebstatic.com/images3_pi/2024/10/12/15/17287237323b0dd27d466859cdfffe7ec99d8ea392_thumbnail_900x.webp', 7.72, 'USD', 'IQD', 11580.00, 11580.00, 0.00, NULL, 'delivery', 17, NULL, NULL, NULL, 'sk2408162878081385', NULL, 1, NULL, '2026-08-12 16:27:55', '2026-08-12 21:54:44', NULL, NULL),
(130, 112, NULL, 'Shein', 'https://ar.shein.com/SHEIN-Girlism-Tween-Girl-Casual-Grey-Drawstring-Waist-Wide-Leg-Sweatpants-p-43443325.html?src_identifier=on%3DCATEGORY_RECOMMEND_COMPONENT%60cn%3DCATEGORY_RECOMMEND_COMPONENT_1%60hz%3D-%60jc%3Dreal_2031%60ps%3D2_1_3&src_module=all&src_tab_page_id=page_home1786548827575&mallCode=1&pageListType=4&detailBusinessFrom=0-1_43443325%7C0-2&imgRatio=1-1&detailBusinessFrom=0-1_43443325%7C0-2&pageListType=4', 'SHEIN Girlism بنطلون رياضي واسع الساق بخصر مربوط بسحاب للفتيات المراهقات، لون رمادي | شي إن', 'https://img.ltwebstatic.com/images3_pi/2024/10/12/15/17287237323b0dd27d466859cdfffe7ec99d8ea392_thumbnail_900x.webp', 7.72, 'USD', 'IQD', 10422.00, 10422.00, 0.00, NULL, 'delivery', 17, NULL, NULL, '8Y (122-128 cm)', 'sk2408162878081385', NULL, 1, NULL, '2026-08-12 16:35:22', '2026-08-12 21:54:21', NULL, NULL),
(131, 113, NULL, 'Shein', 'https://ar.shein.com/Medium-And-Large-Size-Hooded-Zip-Up-Sweatshirts-For-Teenage-Girls-With-Pockets-Suitable-For-Autumn-Winter-Versatile-And-Minimalist-Design-p-45102539.html?mallCode=1&detailBusinessFrom=0-2&imgRatio=3-4&detailBusinessFrom=0-2', 'سترات هودي مقاس متوسط وكبير مزودة بسحاب وجيوب للبنات المراهقات، مناسبة للخريف والشتاء، تصميم متعدد الاستخدامات وبسيط | شي إن', 'https://img.ltwebstatic.com/v4/j/spmp/2025/08/29/b9/175646461979ecf6368021725159f9557c123f7cf6_thumbnail_900x.webp', 8.36, 'USD', 'IQD', 11286.00, 11286.00, 0.00, NULL, 'company', 17, NULL, 'رمادي', '10Y (134-140 cm)', 'sk2410060005051261', NULL, 1, NULL, '2026-08-12 16:36:47', '2026-08-12 21:52:52', NULL, NULL),
(132, 114, NULL, 'Shein', 'https://ar.shein.com/SHEIN-Girlism-Tween-Girl-Casual-Grey-Drawstring-Waist-Wide-Leg-Sweatpants-p-43443325.html?src_identifier=on%3DCATEGORY_RECOMMEND_COMPONENT%60cn%3DCATEGORY_RECOMMEND_COMPONENT_1%60hz%3D-%60jc%3Dreal_2031%60ps%3D2_1_3&src_module=all&src_tab_page_id=page_home1786548827575&mallCode=1&pageListType=4&detailBusinessFrom=0-1_43443325%7C0-2&imgRatio=1-1&detailBusinessFrom=0-1_43443325%7C0-2&pageListType=4', 'SHEIN Girlism بنطلون رياضي واسع الساق بخصر مربوط بسحاب للفتيات المراهقات، لون رمادي | شي إن', 'https://img.ltwebstatic.com/images3_pi/2024/10/12/15/17287237323b0dd27d466859cdfffe7ec99d8ea392_thumbnail_900x.webp', 7.72, 'USD', 'IQD', 10422.00, 10422.00, 0.00, NULL, 'delivery', 30, NULL, NULL, '11Y (140-146 cm)', 'sk2408162878081385', NULL, 1, NULL, '2026-08-12 16:39:20', '2026-08-12 21:53:03', NULL, NULL),
(133, 115, NULL, 'Shein', 'https://ar.shein.com/SHEIN-Girlism-Tween-Girl-Casual-Grey-Drawstring-Waist-Wide-Leg-Sweatpants-p-43443325.html?src_identifier=on%3DCATEGORY_RECOMMEND_COMPONENT%60cn%3DCATEGORY_RECOMMEND_COMPONENT_1%60hz%3D-%60jc%3Dreal_2031%60ps%3D2_1_3&src_module=all&src_tab_page_id=page_home1786548827575&mallCode=1&pageListType=4&detailBusinessFrom=0-1_43443325%7C0-2&imgRatio=1-1&detailBusinessFrom=0-1_43443325%7C0-2&pageListType=4', 'SHEIN Girlism بنطلون رياضي واسع الساق بخصر مربوط بسحاب للفتيات المراهقات، لون رمادي | شي إن', 'https://img.ltwebstatic.com/images3_pi/2024/10/12/15/17287237323b0dd27d466859cdfffe7ec99d8ea392_thumbnail_900x.webp', 7.72, 'USD', 'IQD', 10422.00, 10422.00, 0.00, NULL, 'delivery', 17, '2026-08-12 16:53:33', NULL, '11Y (140-146 cm)', 'sk2408162878081385', NULL, 1, NULL, '2026-08-12 16:41:16', '2026-08-12 21:52:59', NULL, NULL),
(134, 116, NULL, 'trendyol', 'https://www.trendyol.com/u-s-polo-assn/kadin-beyaz-uzun-kollu-basic-gomlek-50324791-vr013-p-905066889?merchantId=163&boutiqueId=61&v=36', 'U.S. Polo Assn. Kadın Beyaz Uzun Kollu Basic Gömlek 50324791-VR013 - Fiyatı, Yorumları', 'https://cdn.dsmcdn.com/mnresize/620/920/ty1939/prod/QC_ENRICHMENT/20260730/21/63eaefc5-0056-3282-8b7a-5954c1b8cdab/1_org_zoom.jpg', 647.98, 'TRY', 'USD', 13.64, 15.00, 1.36, NULL, 'delivery', 18, NULL, NULL, '36', '12125', NULL, 1, NULL, '2026-08-12 17:28:28', '2026-08-12 17:43:28', 7, NULL),
(135, 117, NULL, 'trendyol', 'https://www.trendyol.com/momordica/coconut-mix-250-ml-p-974364895?boutiqueId=61&merchantId=1024688', 'MOMORDİCA Coconut Mix - 250 ml - Fiyatı, Yorumları', 'https://video-content-img.dsmcdn.com/prod/thumb/2018925/2030889/2046841/c6477464-547f-40b2-8339-36e57377e1f6.jpg', 217.29, 'TRY', 'USD', 4.57, 6.57, 2.00, NULL, 'delivery', 20, NULL, NULL, NULL, '974364895', NULL, 1, NULL, '2026-08-12 17:34:23', '2026-08-12 21:46:43', 8, 18),
(136, 118, NULL, 'Shein', 'https://ar.shein.com/EASEVO-3pcs-Set-Men-Plus-Size-Solid-Color-Fitted-Crew-Neck-Short-Sleeve-T-Shirts-Suitable-For-Summer-Daily-Wear-Vacation-Father-s-Day-Gifts-Football-p-40377444.html?mallCode=1&pageListType=4&detailBusinessFrom=0-1_40377444%7C0-2&imgRatio=3-4&detailBusinessFrom=0-1_40377444%7C0-2&pageListType=4', 'EASEVO 3 قطع/مجموعة تي شيرتات رجالية مقاس كبير بلون موحد وياقة طاقم وأكمام قصيرة مناسبة للارتداء اليومي في الصيف، العطلات، هدايا عيد الأب، كرة القدم | شي إن', 'https://img.ltwebstatic.com/v4/j/pi/2025/10/31/a8/17618750593f6ab8febd9f5ff1bcdbc8a96be23333_thumbnail_900x.webp', 22.63, 'USD', 'IQD', 30550.50, 30550.50, 0.00, NULL, 'stock', 31, NULL, 'رمادي', NULL, 'sm2404172940092699', NULL, 1, NULL, '2026-08-12 21:58:19', '2026-08-13 12:44:54', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `order_workflow`
--

CREATE TABLE `order_workflow` (
  `order_id` bigint UNSIGNED NOT NULL,
  `plan` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `step` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `box_id` bigint UNSIGNED DEFAULT NULL,
  `barcode` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `buy_tl` decimal(12,2) DEFAULT NULL,
  `buy_usd` decimal(12,2) DEFAULT NULL,
  `paid_iqd` bigint DEFAULT NULL,
  `cust_iqd` bigint DEFAULT NULL,
  `cust_usd` decimal(12,2) DEFAULT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `returned_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `paid_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_workflow`
--

INSERT INTO `order_workflow` (`order_id`, `plan`, `step`, `box_id`, `barcode`, `buy_tl`, `buy_usd`, `paid_iqd`, `cust_iqd`, `cust_usd`, `note`, `cancelled_at`, `returned_at`, `updated_at`, `paid_at`) VALUES
(1, 'shein', 'buying', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-11 12:31:18', NULL),
(4, 'shein', 'buying', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-11 12:31:18', NULL),
(5, 'shein', 'bought', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-14 14:49:50', NULL),
(6, 'shein', 'bought', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-11 12:33:07', NULL),
(7, 'shein', 'company', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-14 08:30:57', NULL),
(8, 'shein', 'buying', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-11 12:31:18', NULL),
(9, 'shein', 'bought', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-14 14:49:50', NULL),
(10, 'shein', 'buying', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-11 12:31:18', NULL),
(12, 'shein', 'buying', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-11 12:31:18', NULL),
(14, 'shein', 'pending', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-11 09:18:14', NULL),
(19, 'shein', 'delivery', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-14 13:47:59', NULL),
(20, 'shein', 'company', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-14 14:53:39', NULL),
(21, 'turkish', 'buying', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-14 12:07:34', NULL),
(22, 'shein', 'buying', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-11 12:31:18', NULL),
(23, 'shein', 'company', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-14 14:53:36', NULL),
(24, 'shein', 'company', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-14 14:53:35', NULL),
(25, 'turkish', 'buying', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-14 12:23:10', NULL),
(26, 'turkish', 'bought', 5, NULL, NULL, NULL, NULL, NULL, 6.00, NULL, NULL, NULL, '2026-07-14 15:06:59', NULL),
(29, 'turkish', 'buying', 3, NULL, NULL, NULL, NULL, NULL, 28.00, NULL, NULL, NULL, '2026-07-14 09:20:09', NULL),
(51, 'turkish', 'pending', NULL, NULL, NULL, NULL, NULL, NULL, 35.00, NULL, NULL, NULL, '2026-07-21 14:19:55', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `otp_codes`
--

CREATE TABLE `otp_codes` (
  `id` bigint UNSIGNED NOT NULL,
  `identifier` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `channel` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `purpose` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'login',
  `attempts` tinyint UNSIGNED NOT NULL DEFAULT '0',
  `expires_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `consumed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `otp_codes`
--

INSERT INTO `otp_codes` (`id`, `identifier`, `channel`, `code_hash`, `purpose`, `attempts`, `expires_at`, `consumed_at`, `created_at`, `updated_at`) VALUES
(1, '07701234567', 'whatsapp', '$2y$12$ot01n1QiDsnu5SvD8FsT6uoA58vcXMuyT7dRCtDZ0hpNOm4qETjvi', 'register', 0, '2026-07-04 14:30:02', '2026-07-04 14:30:02', '2026-07-04 14:30:01', '2026-07-04 14:30:02'),
(2, '7504848085', 'whatsapp', '$2y$12$C1EDBgkblUUbcm66ag.Z/OQ7NYymeMNR/Qjr4aAsCZUrBWTOlbrQO', 'register', 0, '2026-07-04 14:32:02', '2026-07-04 14:32:02', '2026-07-04 14:31:57', '2026-07-04 14:32:02'),
(3, '7504848085', 'whatsapp', '$2y$12$M3aAxoJLbYUhqaI32xQiOeorAx3pLshE.WCmYxQL//PWZ1CcXIFPa', 'register', 0, '2026-07-05 07:29:44', '2026-07-05 07:29:44', '2026-07-05 07:29:38', '2026-07-05 07:29:44'),
(4, '7504848085', 'whatsapp', '$2y$12$imGowb6I0uWAgApaqc4zDu3/lzByy.yujakigU2Pn2k.vGNpl56qW', 'register', 0, '2026-07-05 08:05:23', '2026-07-05 08:05:23', '2026-07-05 08:05:18', '2026-07-05 08:05:23'),
(5, '7504848085', 'whatsapp', '$2y$12$D/dGDWi0ru8IjzXf//k4Z.cdMheb0ZYNANoG.jNvJ8RLfnSVDnNTu', 'login', 0, '2026-07-05 08:49:39', '2026-07-05 08:49:39', '2026-07-05 08:05:57', '2026-07-05 08:49:39'),
(6, '7504848085', 'whatsapp', '$2y$12$bZjdCkJHmgsMYmK1eCOjgu6uOxaW2ZCkAK3Vhf/YgWbfw/X0WK5Ja', 'login', 0, '2026-07-05 08:49:46', '2026-07-05 08:49:46', '2026-07-05 08:49:39', '2026-07-05 08:49:46'),
(7, '7504444444', 'whatsapp', '$2y$12$F2IRDVFNwQTMc8nh71Z8tuHtk29H1T4E/hho8KKW8eydDkCaEq9mO', 'register', 0, '2026-07-07 08:37:46', '2026-07-07 08:37:46', '2026-07-07 08:37:42', '2026-07-07 08:37:46'),
(8, '7504848085', 'whatsapp', '$2y$12$Gc1UhvQgRYfFglXiMwmc1edUJZBaMY9jw1fRbRx//R3MoIoQt65R.', 'login', 0, '2026-07-09 09:19:23', '2026-07-09 09:19:23', '2026-07-09 08:45:24', '2026-07-09 09:19:23'),
(9, '7504848082', 'whatsapp', '$2y$12$H2nsgJzM9p5nQWt41/ovduLA7RXeddLB31NPn3IsyqvSq5NYuu0LG', 'login', 0, '2026-07-09 09:02:17', NULL, '2026-07-09 08:57:17', '2026-07-09 08:57:17'),
(10, '750852588', 'whatsapp', '$2y$12$SPMGhSmbfnfzaU7180noXOeZMwsSZEKy2oAQ2C/KL624o/8TLgS8O', 'login', 0, '2026-07-09 08:58:57', '2026-07-09 08:58:57', '2026-07-09 08:58:51', '2026-07-09 08:58:57'),
(11, '7504848088', 'whatsapp', '$2y$12$61W9aHlU9Enn2qrYFpWOUOI4/lxo5qvFdjcC16hx1FC49x9cgJ90G', 'register', 0, '2026-07-09 09:14:09', '2026-07-09 09:14:09', '2026-07-09 09:14:04', '2026-07-09 09:14:09'),
(12, '7504848085', 'whatsapp', '$2y$12$ZH1FdSQa/V3bXBpUg6FnN.IKo4uLyO1daXRMipe3OBLxTnAhZfYwe', 'register', 0, '2026-07-09 09:19:36', '2026-07-09 09:19:36', '2026-07-09 09:19:23', '2026-07-09 09:19:36'),
(13, '7501122334', 'whatsapp', '$2y$12$je/4qO9V.ze82PF6L/b58elmGIPv9dAb0NpAVD8K/o6YV9Y5a1qdy', 'register', 0, '2026-07-09 09:21:15', '2026-07-09 09:21:15', '2026-07-09 09:21:11', '2026-07-09 09:21:15'),
(14, '750444444', 'whatsapp', '$2y$12$NCooKv0wJe3OjmzJxQI6ee5D9GdvuoEiY7YSk5mukJzcJx0RfhoFy', 'register', 0, '2026-07-14 14:42:05', '2026-07-14 14:42:05', '2026-07-14 14:41:59', '2026-07-14 14:42:05'),
(15, '7504848085', 'whatsapp', '$2y$12$KH6qUtBmwefQHtTvcRlB2.d89vSaEKAjEn4AiD1Q.n/QMDkdJwpIe', 'register', 0, '2026-08-08 07:49:53', '2026-08-08 10:49:53', '2026-08-08 10:49:49', '2026-08-08 10:49:53'),
(16, '7504845522', 'whatsapp', '$2y$12$bpvayqGHaVdhl92z8THQCObqtD0ReCg4u5kTZHayQ2WZV.J9zIvSC', 'register', 0, '2026-08-08 07:50:42', '2026-08-08 10:50:42', '2026-08-08 10:50:38', '2026-08-08 10:50:42'),
(17, '7518016694', 'whatsapp', '$2y$12$qkCq3afnah3Q5sPTT6aLp.GFfk3FqEP2sgqQsq5K.uGLq0oN3SQlS', 'register', 0, '2026-08-08 08:53:17', '2026-08-08 11:53:17', '2026-08-08 11:51:14', '2026-08-08 11:53:17'),
(18, '7504848085', 'whatsapp', '$2y$12$5mUQH0XU.g0mMHbrbtLKsuz0DIW4XILbHRsP2sdJ1x2gCYpSqebVO', 'reset', 0, '2026-08-10 13:53:17', '2026-08-10 16:53:17', '2026-08-10 16:52:56', '2026-08-10 16:53:17'),
(19, '7518016694', 'whatsapp', '$2y$12$44yIeJ2/.YSQ00w/.aJR9.XhhiBl/g/IJ/fAvRbQqwH4l.6lnxOu2', 'register', 1, '2026-08-10 13:56:36', '2026-08-10 16:56:36', '2026-08-10 16:55:35', '2026-08-10 16:56:36'),
(20, '7518016694', 'whatsapp', '$2y$12$Yk/lf3vPRQ.tdptiPIQZlunj1CLzRrcr5Bml8rB.zfBEI5iwMD5yu', 'register', 0, '2026-08-10 13:56:46', '2026-08-10 16:56:46', '2026-08-10 16:56:36', '2026-08-10 16:56:46'),
(21, '7504848085', 'whatsapp', '$2y$12$3vQqEtY6hnud1APIqXh88O5VyHLswq2Vo/mxiyYPo3nOJijhAplEW', 'reset', 0, '2026-08-10 14:11:01', '2026-08-10 17:11:01', '2026-08-10 17:10:27', '2026-08-10 17:11:01'),
(22, '7514848085', 'whatsapp', '$2y$12$UaJFtgVp495HIr7bUpphCOmImhncYci93j3PmWMXEWSk2wlD7GGWa', 'register', 0, '2026-08-10 17:16:21', NULL, '2026-08-10 17:11:21', '2026-08-10 17:11:21'),
(23, '7501234567', 'whatsapp', '$2y$12$g5MLDxla9bV5vVk7PM53EeyC.suqTD5iH1RbQxMhvcFG4V53b5epW', 'register', 0, '2026-08-11 17:18:16', NULL, '2026-08-11 17:13:16', '2026-08-11 17:13:16');

-- --------------------------------------------------------

--
-- Table structure for table `parcels`
--

CREATE TABLE `parcels` (
  `id` bigint UNSIGNED NOT NULL,
  `plan` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `parcels`
--

INSERT INTO `parcels` (`id`, `plan`, `code`, `delivered_at`, `created_at`, `updated_at`) VALUES
(13, 'turkish', 'PR-1000', '2026-08-08 07:26:10', '2026-08-08 07:25:07', '2026-08-08 07:26:10'),
(14, 'turkish', 'PR-1001', '2026-08-08 07:32:01', '2026-08-08 07:30:35', '2026-08-08 07:32:01'),
(15, 'turkish', 'PR-1002', '2026-08-08 07:40:04', '2026-08-08 07:39:31', '2026-08-08 07:40:04'),
(16, 'turkish', 'PR-1003', '2026-08-08 08:06:48', '2026-08-08 08:06:14', '2026-08-08 08:06:48'),
(17, 'turkish', 'PR-1004', '2026-08-09 15:42:05', '2026-08-09 15:41:06', '2026-08-09 15:42:05'),
(18, 'turkish', 'PR-1005', NULL, '2026-08-12 21:46:38', '2026-08-12 21:46:38');

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` bigint UNSIGNED NOT NULL,
  `plan` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `order_id` bigint UNSIGNED DEFAULT NULL,
  `item_id` bigint UNSIGNED DEFAULT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `account_id` bigint UNSIGNED DEFAULT NULL,
  `amount_iqd` bigint NOT NULL,
  `old_debt_iqd` bigint NOT NULL DEFAULT '0',
  `note` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`id`, `plan`, `order_id`, `item_id`, `user_id`, `account_id`, `amount_iqd`, `old_debt_iqd`, `note`, `created_at`) VALUES
(1, 'turkish', 48, 59, 3, 6, 11, 172902, NULL, '2026-08-08 07:32:01'),
(2, 'turkish', 49, 60, 3, 6, 25, 172891, NULL, '2026-08-08 07:32:01'),
(3, 'turkish', 71, 86, 5, 6, 35, 0, 'Stock sale', '2026-08-10 14:58:02'),
(4, 'shein', 115, 133, 14, 1, 10422, 0, 'Stock sale', '2026-08-12 16:53:33');

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint UNSIGNED NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 'App\\Models\\User', 2, 'mobile', 'e2bc7d1d8b708101bd251369666cf7e31d4e122288819338379b35a18f3e52d4', '[\"*\"]', NULL, NULL, '2026-07-04 14:30:02', '2026-07-04 14:30:02'),
(2, 'App\\Models\\User', 3, 'mobile', '65e3c017c591a0f643299c51595d95d34019f784667ab8eb6a1140616c5a7c72', '[\"*\"]', NULL, NULL, '2026-07-04 14:32:02', '2026-07-04 14:32:02'),
(3, 'App\\Models\\User', 3, 'mobile', '38016b1e0c745bf51a9ec8083feb0d5ad6ecd4de8d7dd943dfd6314b1622b1d3', '[\"*\"]', NULL, NULL, '2026-07-04 14:32:06', '2026-07-04 14:32:06'),
(4, 'App\\Models\\User', 3, 'mobile', '980de4b27723c839c81f3307923c3d7b9291a56e2cd226bd82f758070cae758f', '[\"*\"]', '2026-07-05 08:05:18', NULL, '2026-07-05 07:29:44', '2026-07-05 08:05:18'),
(6, 'App\\Models\\User', 3, 'mobile', 'efc0e6523ade1d5cd268291ddb847345d53e387f990108e0009e6c54cbd0eeae', '[\"*\"]', NULL, NULL, '2026-07-05 08:06:08', '2026-07-05 08:06:08'),
(7, 'App\\Models\\User', 3, 'mobile', 'd54c885a1897931be014b99181f51de1064f28d9d9a7577242889f26b17be070', '[\"*\"]', '2026-07-05 08:55:14', NULL, '2026-07-05 08:49:46', '2026-07-05 08:55:14'),
(8, 'App\\Models\\User', 3, 'mobile', '35e933c17440119cef1fd305a374883a1968825e29a1dba93008f32fa9916430', '[\"*\"]', '2026-07-05 09:14:21', NULL, '2026-07-05 09:14:17', '2026-07-05 09:14:21'),
(10, 'App\\Models\\User', 4, 'mobile', '0b9d22068a39816673888e544973656112e2eb3074dd37819ff173b4126fb57e', '[\"*\"]', '2026-07-05 12:25:18', NULL, '2026-07-05 12:25:17', '2026-07-05 12:25:18'),
(11, 'App\\Models\\User', 3, 'mobile', 'dce57cb0ccfffca31109410b1fedd3c0263fafcfeedcc4412fe7ccee3c7835ca', '[\"*\"]', '2026-07-05 12:36:24', NULL, '2026-07-05 12:35:10', '2026-07-05 12:36:24'),
(17, 'App\\Models\\User', 3, 'mobile', 'bc905b12135e513ee777db6ac2f45bfc15bf38d5639508d8d74daee551498027', '[\"*\"]', '2026-07-08 12:07:49', NULL, '2026-07-07 11:28:08', '2026-07-08 12:07:49'),
(26, 'App\\Models\\User', 8, 'mobile', '60d4a53db93117b8870cf0e4b2955112e6e860fe2eef2d140feb64dd02b1bbab', '[\"*\"]', '2026-07-11 12:30:31', NULL, '2026-07-09 09:21:15', '2026-07-11 12:30:31'),
(29, 'App\\Models\\User', 3, 'mobile', '2209ce4074a0710cc2be058ba45f97a3f5d3c8ad94a3030be4f8765a53722464', '[\"*\"]', '2026-07-23 16:58:53', NULL, '2026-07-14 14:43:22', '2026-07-23 16:58:53'),
(32, 'App\\Models\\User', 13, 'mobile', '56ccc0b433d443291f324856559972ebb45fc0ef3ffdde5320b57739fd5735e7', '[\"*\"]', '2026-08-08 10:56:11', NULL, '2026-08-08 10:50:42', '2026-08-08 10:56:11'),
(34, 'App\\Models\\User', 14, 'mobile', 'ca053fdf897ef00e2a3771b13458e77ebb21b036e55b062c35715373cb0c2c3a', '[\"*\"]', '2026-08-08 14:51:50', NULL, '2026-08-08 11:53:17', '2026-08-08 14:51:50'),
(38, 'App\\Models\\User', 3, 'mobile', 'b64583ae08e094136c999dad1d21caba8696b930d3dafdf26ce1f9b2002771c4', '[\"*\"]', NULL, NULL, '2026-08-10 17:11:01', '2026-08-10 17:11:01'),
(40, 'App\\Models\\User', 3, 'mobile', '41fe9b709404079dc37367a5184b556c16e04339acc263dfc51e39d999abfac7', '[\"*\"]', '2026-08-12 17:36:11', NULL, '2026-08-10 17:23:55', '2026-08-12 17:36:11');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `permissions` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('0KMBUpiMJ1EzamZWwhEAzwKUEmUv9MzwHifp3tuS', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiIyWU1XdEpQSk5NNklIUlFKMXZ5ZmlDZUhWcTdSYkFUZGNyeUpzdnk0IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786614121),
('0NZ4b98GEB8c67VxSrcoOlyFrzdWZTIQrktWcNZV', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJaWmxySlF2SENBQm1CTm1HNXA3NGVxeWJ5R3lnTUJ2ZzJYckREbzl0IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786606921),
('0qoUq1GGy32XU1JyAsgtnZ48QUizEe1mmUQa7TYI', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiIxcm9tNWRaRllwd0c4TnhXc3AwT2VtQ2RzYW1YNW9JOXQzU1VLSnRVIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786624081),
('2OKZ5hUKILrV9YjNYsaYtCs5w0HE61agXmTPxD7V', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJlM041ZUJWWW14RVVmeFdJcmpWZVBNQ3VycjhNd2xTNVQ3d3M5dDIwIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786600802),
('371RE28wyFJJKiQhRcUJFNI5DVjgEYEaDBSxIxNp', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiIyMTlqUHQ2NFVkM2NzRDFSd0RKNXE4OUFEZlJ5dnZUV2kxaFllWTdGIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786612441),
('46x5g5hFc96yo6EXsN7jBcb2TCfa8TkZSWOIsjAq', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJpZjFaWDI1ZDJRSDZFYWxOU2pnSFN0T3F6Z3pUd0dCRmRZUDZSRldrIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786622161),
('58PNfDzYZfVvLtzyXnbHe2m88dvRFr9SZ4GN9mvv', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJHZXZBaHZnYmZ4dHlDR2NwZ0ZndHVBV2U1MHdHazM3cHF4cFRlYk9xIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786597202),
('58YmQcmUyvbTXuKLPqai78bHawoxqvjZ8op8olBk', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJQNUdoamlRTkNiYzM0T3RVSU10clhtcWtRWEpjd3pYUWczU2JqV3YzIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786598881),
('5GZT73YEo62NHIN9MJKswHUvdmujAN7X4oTZVIyi', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJsYTE3dXUyQU5PS0ZSd2ZZc25wd0dySHo4UzljVmJPWXN3cE1uMlBuIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786609681),
('5HPq10NJEZSskGElDR9FXo5ghCznZ7OpGYasCoTK', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJIVDhVTTJ2aUpPQ2pjRU5FRGVjY3BzcmtFeVl2MzZYRmhFRzZSZVduIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786620481),
('6Edsa8IHn5XAkEbiXffYYfaiO4MDCgfx4WfZmxNx', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiI0UFo1a0hJeTUyY09abFhlMEFwWE9EdlRHaDBiUXphY0RaYTA4TEo0IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786596121),
('8gOIKh7PvdnIcf2gULy2ihBevg24mVicM7RG5JwV', NULL, '35.185.204.16', 'Mozilla/5.0 (compatible; CMS-Checker/1.0; +https://example.com)', 'eyJfdG9rZW4iOiJvRGJiUWIyVkxUNk9wYVpMUDBWSldRa3hzTjJoR3BaRDk0YlY4SFNYIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786624774),
('8l86k6PYuUjiimS7jGUZ9SyH57gu6jJ63LjDdr5Y', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiI1QmxQU1VSc1JMbHNaSDlMVjdPUm1jeVhaUThhTUdYaUt5RGZTNU1uIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786605242),
('AqDQiF9FjP5F1YIx1kSPoclkRTyl8jqZz4lufTMI', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiI5TXlETE1VM3NTTmN4ekQ3OHJ2TTZoUGNtSzU1MEJDRThQYkloWXJCIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786596962),
('b3h0phbrmn4QABo3VqPYcyLDwuoXdFpfYAgXCj43', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJaSmc2Vjd3MmM1c1NEbVNYOFl6RmJjTjdjWllBY3Jhd1R5eW5qQ1pJIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786587241),
('bGiLHVpbzow1TTAOanvs4LpFrvZUA9efSFCxBK28', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJFekl5MUxCTjhxckxMS0oyUjZMZzVkRnpkbTE1R2FSUzZZQXl4SFVVIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786586161),
('bWfddAxLxVNmsucz7bGAm80rxlWwvpRnBd01Mpi4', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJxUExDZDB3NWpidTh0YUIwS3UxTkZxaUxaREtuSE01SEg1R1dWWndXIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786618802),
('C990rAbgbVM2xaoPWpcuFmFxsu192BTqgHornHKq', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiI4Z1VUR2xUcDh4cXk0RlBVYlFvUXZOaUxkdTZQZ2EzTG03WTJjMDU5IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786619641),
('DdWYkl7UBeWbQ0ZJ4QJgjcK5OffAHeRe4VasGSuI', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJQanRrRXJMRHNoYTdmRjFTWW1ZQWVDbEVYMzJaamlIajZ4eE5ua293IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786615201),
('EPgHjAbcyFSOdJN1r7nATex5opPtxMNP5D4nzFYB', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJ2dHJIWEs0MEc4OHdybUoxV2FOdDVYc3lrakJvSW9hU2xxWnVUZDkzIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786598041),
('Fpo9WlnOXj81wCIxR6qbZC5dc5uTpsldqagrV2Gc', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiI0Mm1mWXhPVFBIQXZiREx6ZGxBaU5yNDVnSzFCQXFHbHk4R1RBdlRWIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786616882),
('fq2K2SU2jeohIV1KiAjOFVXuMzIueDQDa6IEJ8A5', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJkeHNwYWs4SU9QS2tCR0RsZEg0S3I0YmhlYnU2dFptZFYzZUlESGJvIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786603322),
('fTfjSlKlwQfgfmHk4ulpZTZiHAKF55BnIF1Whkaq', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiIzbWVpRGR1d0R2UmdXTHRDS3RSQ2x6NWt3OWpXQ3FjODh2T3g1WnZSIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786614961),
('gE0ySlJ6ypOLWtXVEFjLbxBzWjjUNWezwFBJ04r0', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJ4YUNLd09iM2luT3NtMnphdHVjREVqd1BHdnNLZE1Rc0M1YnhZenc1IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786624922),
('gKCjAuqMLiUOX4HweZmazO4QNpwRFsOyXqQKazlh', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJzSldOekJJTGkyWnF1V1RxZzI3NDlzZkpvY1hKZDVES3VlanZtUVhvIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786600561),
('gpSODKPpzdQfi7ma0Sln76qZqssxtdxUdzpBhpw1', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiI1N0wxa3RZVmd5a0ZmdTRaNzlMdTBBYzdzMUhmZGhXOHEyZTBWVDluIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786588922),
('HDUmnYX2RkevnFeUOLLZ4NL7tOgZTcgsgHNX4SpW', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJJRXVHWkxHNE1aR0R6akh2ckZidjJ4d3dBVXZ5SkFzUjBkSnlxTjNLIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786593362),
('HONUNSwA4EvfSkecbSQDYoJmxhIVoUMQOkpkjb7J', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJ5SW9WeTVtVlhkcWRjT2tpUURhOWJmNmlWOThaaE1pRWE3dDlmQ3JmIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786623241),
('hYmsAasIaeI5hu9y0IN6uB1tJErHNffUN7oDBCGK', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiI4c1k0Q1dRTGo5RGVHMnBzRVI2OWxQZEdzVENFWjJPUlJrRkpuOTZlIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786611601),
('IfoRhoeH1rwVo9dsJWNU3Fs7PLr1g8xT0cAkStg6', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJCRFQ2R0h4UDRqRnRWMEhqZUdXeHZ4QWtiWHQwSnVYVUZlb3BDNjZoIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786595281),
('iGSBwOS6LbGaK2YHcAv8V2oSi45SawLw1XqfvbQr', NULL, '89.116.146.65', 'Go-http-client/1.1', 'eyJfdG9rZW4iOiI0aW9jSHd1ZmRValEzd09lbW83TEFpMWJsM0JocUhhSDNMSUg4dUVnIiwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==', 1786597850),
('IIsxkHbOU7TVb5sL6YLPtNaxpdGSqsE3Jm5X26tK', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJmeTJoV2kydEVMa1VrMFdJNjl3NFpJRVVrT1NzMHVZb1ZoS2FOdTRHIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786611361),
('J6lUu6yUdLSkcdXuPNW7lcEisP1embOT10VJhplc', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJtY09mYjdXNURlWkg4bGsxVTJiRUJPb082Y3lIbHN2SXYzMkdEcUd4IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786622402),
('jgPhtw0qNPBh6hDrjGj7cuCrHp9v6ixGYvrp4739', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJndzE1aGZucHRjMDkwdjdFWnoyOVZaQkJzUGdwWTJ3OE5Zb1N4c0YxIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786608841),
('kEcOTxj0kT7SDUygZaFfbeydx5CQBXQvwV8TetWU', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJCaEowaHFRZkJtRnN0dlF1M0hvS0NqZFlPYTQ5aWdiNVkxaEVvbUFjIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786585321),
('Krq6ThdgV3wXQxXduR3341uB60uI8UlCwuEAzx7Z', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJoQzMzeTZzd3RjeXhzQ3hMbDdYcDdBWVc3SUJiTllrRG1pb3dSN2VJIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786601641),
('LAi6NwxxwKd6xvBZZ3XWZFVJMY6trQjSrxkDYwB4', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJtQ2F5Sm54QmxTSGRqVHVSZmlJQ1Zab0FwSk5sUFFGcVZnczRUNlczIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786591682),
('M26EwcNA0yfLe9ffy7eniNt3DMcKNDQrCqBvF1Ae', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJ4SVpyTzA3dHFCWVR2S0Y0azFLNzhXcm9ON1ZWdk84emlWQVNxanZRIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786617722),
('m3JfS0zCeCVnYD77p9zoVRsIkna8Rg5M5xRqVF5H', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJZamZuRWNtS0swVkxObzB6YzlWZ280VWpzclBOZWpuSVFpbEJyMEhiIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786586401),
('mb54yjl8BK1T1si2etgoHjjZHErTWDCsVhtQoAPN', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJ4VTFzWXdra2RIZ2FSWkdZenRudEcxUHNPWTM2ZWpJNGpLSjVTV05JIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786588081),
('Mbao7Bi6lCCp1aC43ma5l7j4bgm0L5VsNeFrvKyC', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJTclRoQUJBZVE5T0EyY3M1bWlnMFowOFJDbmJINmNtWmxzRFpSbTVMIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786604161),
('naDtcOYeTOj1s7z94E1GwNmLRr1RYbfCh6XugklT', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiI2S3JwY2ljUzZOZmZjRVNCeGFXU2lVMmxGaEFETEl1cHV0YkphbEtGIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786590841),
('nmKFQjrWveVUu9atuHv1KPXRhMVBkIVXBEcyPIxp', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJJQjBwTVlycDNpdVhFRG94RkNobWw0ak16SXFpOW41bVV0eDJhTlpWIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786606081),
('oaNb4ZFPEvDZBQGvamd17cWksZOz6qIPu9P9ucIm', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJOQTJMd29oU0ZTRjN6bTNnOFRUNU5zWFFzUXJVQU4xeDVEV044a0JjIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786590002),
('pmmsM90hkjv30t3Z9GUb6xRc8uvfN7EIT3biOMMj', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJta1V1cFBsak9ETmxaTmhpMW9GbjY0cGRVQU9icldRdnQ2eVNWd1k2IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786621321),
('pnpUgLBUUpNpTYejBjIbYv1LzuwTK5QOiB1LfyUu', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJGbmc4WlBSa2xiczVuV1VJcmtQSm93bUtNWVY5TjFka0RUQTV6bjFrIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786610521),
('QgLu6fnAxjUuZSeoMNMLPvJWvHJn2SsHGRgafKJw', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiI2NnU0S1hRVGNTZ09OZ2xNWjRrNjNMUmcySkN4OVdmNzVxTE9sTnMxIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786592521),
('Qoajcf3ipmvOvN1lBpUUhvZyyAmHi34Mga2OKQvM', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJwazlLZlJyWU9EazRuSDFVcTRQRzBQWGttWG5wVVFJTldJYTlBR3FKIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786608002),
('RmCU07PUJWkCtBRdwWY0jlYQLo9NBAgD3fgN6vkc', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJQZ1prNmVkVlk0OTBGenp4b05yd21aWGsxcEgyZkZvWlI1eHdRekJJIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786604402),
('tfmljv9C5dNAo0B4Wq8sbhweKRcsVqbgjxfBOcnr', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJXYmlJMGxBVHg5QjRnak4zZ1dzV3hBRlZlMHNpaWRZdEUyRENOa25NIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786616041),
('TGO1OhT3Md0n9iZrWyblsyMOLr8b6DFwRGGT2Rac', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiIydnBuMkFSRm81ZENHM1BFU2tiZUpTOTZJOHJYMFBNYlpRY1RGRFl2IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786593602),
('uk2DwwCUwDcmRrJZUO3rfOnmjtpSYOki2PXx5WeM', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJ1VVNtbGNiQktYeDVJTXMxVjZabFU2R1pzb1VraUFNZEgxT1ljTFlJIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786589761),
('UKH5E5KNBHP26QTzIrvQ7x2WgmNyBRAQOpQXOMQk', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJvU2dHNm5OZGsxOGcySDZaenZwUEJCaU9VQWQ5RnlWNWQxYWFlZk95IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786594441),
('wTeL0fnACRTqsdEov6ooUwnfyIwFogY3ZuE1pBu6', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJrcWdYa0JNdXRVVDk3WFhuNktzYm9zajhDS1JMTGF3cVJKYlZFRUlBIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786599721),
('x4UIy1ijejC28mjoI7ZNsRHraI9GCyHo5qpf4X8k', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJ0VGJnTjZBWkIwNHBuZXAzZHlValN4WGp3a255eXBueDh3dmN2NWdVIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786613281),
('xwBvuRZcAq2rNM44ope9GDK7WwZFcJSM5YGfxiFU', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiIxOXNRanNUU1ViNjRFcjV6dlYzemZ0aHVXTHFlS2h5akR1SWltRVpnIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786607761),
('Y8a1pSN1hvJekZuEnd7bgarGCPujqTcjRR2kFqMD', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJ0SzU3Y1hGOXV0YUxIMGNsRm1xNjRFYm1YNE5rVXljMjRVQTVQaFVzIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786618562),
('Zzob2y7DlHgJkCp50xV1875eGjH7ZAXP1xhQJxxV', NULL, '187.124.190.213', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36', 'eyJfdG9rZW4iOiJFQnFjcWE2eGJOMmQ5dnFiU3ZLcDZGOWxyYWVsd2trN3FFTnF0bTIyIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL3NoaXBwaW5nLmhlYW1hLXNvZnQuY29tIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786602482);

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`key`, `value`, `created_at`, `updated_at`) VALUES
('markup_percent', '0', NULL, NULL),
('rounding_step', '0', NULL, NULL),
('rounding_step_usd', '0.01', NULL, NULL),
('service_fee_percent', '0', '2026-07-04 10:27:47', '2026-07-04 10:27:47'),
('shipping_flat_iqd', '0', '2026-07-04 10:27:47', '2026-07-04 10:27:47'),
('shipping_usd', '2', '2026-07-15 08:13:52', '2026-07-15 08:13:52');

-- --------------------------------------------------------

--
-- Table structure for table `shipping_boxes`
--

CREATE TABLE `shipping_boxes` (
  `id` bigint UNSIGNED NOT NULL,
  `plan` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(190) COLLATE utf8mb4_unicode_ci NOT NULL,
  `shipped_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `shipping_boxes`
--

INSERT INTO `shipping_boxes` (`id`, `plan`, `name`, `shipped_at`, `created_at`, `updated_at`) VALUES
(1, 'turkish', 'T100', '2026-08-01 09:27:01', '2026-08-01 08:06:03', '2026-08-01 09:27:01'),
(2, 'turkish', 'T101', '2026-08-01 12:56:16', '2026-08-01 08:25:50', '2026-08-01 12:56:16'),
(3, 'turkish', 'tr1000', '2026-08-02 17:49:24', '2026-08-02 17:48:54', '2026-08-02 17:49:24'),
(4, 'turkish', 'tr500', '2026-08-05 15:17:04', '2026-08-02 18:04:39', '2026-08-05 15:17:04'),
(5, 'turkish', 'tr500', '2026-08-02 18:05:05', '2026-08-02 18:04:51', '2026-08-02 18:05:05'),
(6, 'turkish', 'kkkkk', '2026-08-07 07:52:46', '2026-08-07 07:51:20', '2026-08-07 07:52:46'),
(7, 'turkish', 'trt', '2026-08-12 17:42:31', '2026-08-07 09:07:59', '2026-08-12 17:42:31'),
(8, 'turkish', '2525', '2026-08-12 21:46:22', '2026-08-12 21:45:52', '2026-08-12 21:46:22'),
(9, 'turkish', '7777', '2026-08-12 21:50:49', '2026-08-12 21:46:08', '2026-08-12 21:50:49'),
(10, 'turkish', '45454', NULL, '2026-08-12 21:50:15', '2026-08-12 21:50:15');

-- --------------------------------------------------------

--
-- Table structure for table `stores`
--

CREATE TABLE `stores` (
  `id` bigint UNSIGNED NOT NULL,
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `glyph` varchar(4) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `glyph_color` varchar(9) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `category_key` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `base_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USD',
  `charge_currency` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipping_iqd` int UNSIGNED DEFAULT NULL,
  `capture_rules` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `sort_order` int UNSIGNED NOT NULL DEFAULT '0',
  `region` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'international',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ;

--
-- Dumping data for table `stores`
--

INSERT INTO `stores` (`id`, `key`, `name`, `glyph`, `glyph_color`, `category_key`, `base_url`, `currency`, `charge_currency`, `shipping_iqd`, `capture_rules`, `active`, `sort_order`, `region`, `created_at`, `updated_at`) VALUES
(1, 'shein', 'Shein', 'SH', '#000000', 'catFashion', 'https://ar.shein.com/', 'USD', 'IQD', 0, '{\"strategy\":\"og+jsonld\",\"title\":[\"meta[property=\'og:title\']@content\",\"h1\"],\"image\":[\"meta[property=\'og:image\']@content\"],\"price\":[\"meta[property=\'product:price:amount\']@content\",\"[itemprop=\'price\']@content\"],\"currency\":[\"meta[property=\'product:price:currency\']@content\",\"[itemprop=\'priceCurrency\']@content\"]}', 1, 1, 'international', '2026-07-04 10:27:48', '2026-07-04 10:27:48'),
(2, 'polo', 'Us polo turkey', 'PO', '#FF6A00', 'catEverything', 'https://tr.uspoloassn.com/', 'TRY', 'USD', NULL, '{\"strategy\":\"og+jsonld\",\"title\":[\"meta[property=\'og:title\']@content\",\"h1\"],\"image\":[\"meta[property=\'og:image\']@content\"],\"price\":[\"meta[property=\'product:price:amount\']@content\",\"[itemprop=\'price\']@content\"],\"currency\":[\"meta[property=\'product:price:currency\']@content\",\"[itemprop=\'priceCurrency\']@content\"]}', 1, 7, 'turkiye', '2026-07-04 10:27:48', '2026-07-04 10:27:48'),
(3, 'zara', 'Zara', 'ZA', '#1A1A1A', 'catApparel', 'https://www.zara.com/tr/tr/', 'TRY', 'USD', NULL, '{\"strategy\":\"og+jsonld\",\"title\":[\"meta[property=\'og:title\']@content\",\"h1\"],\"image\":[\"meta[property=\'og:image\']@content\"],\"price\":[\"meta[property=\'product:price:amount\']@content\",\"[itemprop=\'price\']@content\"],\"currency\":[\"meta[property=\'product:price:currency\']@content\",\"[itemprop=\'priceCurrency\']@content\"]}', 1, 3, 'turkiye', '2026-07-04 10:27:48', '2026-07-04 10:27:48'),
(4, 'mango', 'Mango', 'MN', '#E62E2E', 'catGadgets', 'https://shop.mango.com/', 'TRY', 'USD', NULL, '{\"strategy\":\"og+jsonld\",\"title\":[\"meta[property=\'og:title\']@content\",\"h1\"],\"image\":[\"meta[property=\'og:image\']@content\"],\"price\":[\"meta[property=\'product:price:amount\']@content\",\"[itemprop=\'price\']@content\"],\"currency\":[\"meta[property=\'product:price:currency\']@content\",\"[itemprop=\'priceCurrency\']@content\"]}', 1, 4, 'turkiye', '2026-07-04 10:27:48', '2026-07-04 10:27:48'),
(5, 'hm', 'H&M', 'HM', '#0530AD', 'catApparel', 'https://www2.hm.com/tr_tr/index.html?srsltid=AfmBOorS1n-7bYr2nhr6Iw4kTam6oWNpvGF4LQoqo5RxWTkVC69Rd2Zb', 'TRY', 'USD', NULL, '{\"strategy\":\"og+jsonld\",\"title\":[\"meta[property=\'og:title\']@content\",\"h1\"],\"image\":[\"meta[property=\'og:image\']@content\"],\"price\":[\"meta[property=\'product:price:amount\']@content\",\"[itemprop=\'price\']@content\"],\"currency\":[\"meta[property=\'product:price:currency\']@content\",\"[itemprop=\'priceCurrency\']@content\"]}', 1, 5, 'turkiye', '2026-07-04 10:27:48', '2026-07-04 10:27:48'),
(6, 'karaca', 'Karaca', 'KH', '#232F3E', 'catEverything', 'https://www.karaca-home.com/', 'TRY', 'USD', NULL, '{\"strategy\":\"og+jsonld\",\"title\":[\"meta[property=\'og:title\']@content\",\"h1\"],\"image\":[\"meta[property=\'og:image\']@content\"],\"price\":[\"meta[property=\'product:price:amount\']@content\",\"[itemprop=\'price\']@content\"],\"currency\":[\"meta[property=\'product:price:currency\']@content\",\"[itemprop=\'priceCurrency\']@content\"]}', 1, 6, 'turkiye', '2026-07-04 10:27:48', '2026-07-04 10:27:48'),
(7, 'trendyol', 'Trendyol', 'TR', '#FF6000', 'catFashion', 'https://www.trendyol.com', 'TRY', 'USD', 0, '{\"strategy\":\"og+jsonld\",\"title\":[\"meta[property=\'og:title\']@content\",\"h1\"],\"image\":[\"meta[property=\'og:image\']@content\"],\"price\":[\"meta[property=\'product:price:amount\']@content\",\"[itemprop=\'price\']@content\"],\"currency\":[\"meta[property=\'product:price:currency\']@content\",\"[itemprop=\'priceCurrency\']@content\"]}', 1, 2, 'turkiye', '2026-07-04 10:27:48', '2026-07-04 10:27:48'),
(8, 'hepsiburada', 'Hepsiburada', 'HB', '#F27A1A', 'catTech', 'https://www.hepsiburada.com', 'TRY', 'USD', NULL, '{\"strategy\":\"og+jsonld\",\"title\":[\"meta[property=\'og:title\']@content\",\"h1\"],\"image\":[\"meta[property=\'og:image\']@content\"],\"price\":[\"meta[property=\'product:price:amount\']@content\",\"[itemprop=\'price\']@content\"],\"currency\":[\"meta[property=\'product:price:currency\']@content\",\"[itemprop=\'priceCurrency\']@content\"]}', 1, 8, 'turkiye', '2026-07-04 10:27:48', '2026-07-04 10:27:48'),
(9, 'Bershka', 'Bershka', 'BS', '#2B2B2B', 'catApparel', 'https://www.bershka.com/tr/', 'TRY', 'USD', NULL, '{\"strategy\":\"og+jsonld\",\"title\":[\"meta[property=\'og:title\']@content\",\"h1\"],\"image\":[\"meta[property=\'og:image\']@content\"],\"price\":[\"meta[property=\'product:price:amount\']@content\",\"[itemprop=\'price\']@content\"],\"currency\":[\"meta[property=\'product:price:currency\']@content\",\"[itemprop=\'priceCurrency\']@content\"]}', 1, 9, 'turkiye', '2026-07-04 10:27:48', '2026-07-04 10:27:48'),
(10, 'stradivarius', 'Stradivarius', 'ST', '#2BA27F', 'catFashion', 'https://www.stradivarius.com/tr/', 'TRY', 'USD', NULL, '{\"strategy\":\"og+jsonld\",\"title\":[\"meta[property=\'og:title\']@content\",\"h1\"],\"image\":[\"meta[property=\'og:image\']@content\"],\"price\":[\"meta[property=\'product:price:amount\']@content\",\"[itemprop=\'price\']@content\"],\"currency\":[\"meta[property=\'product:price:currency\']@content\",\"[itemprop=\'priceCurrency\']@content\"]}', 1, 10, 'turkiye', '2026-07-04 10:27:48', '2026-07-04 10:27:48');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone_verified_at` timestamp NULL DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_admin` tinyint(1) NOT NULL DEFAULT '0',
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `credit_limit_iqd` decimal(14,2) NOT NULL DEFAULT '0.00',
  `credit_limit_usd` decimal(14,2) NOT NULL DEFAULT '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `phone`, `email`, `city`, `phone_verified_at`, `email_verified_at`, `password`, `is_admin`, `remember_token`, `created_at`, `updated_at`, `credit_limit_iqd`, `credit_limit_usd`) VALUES
(1, 'Heama Admin', NULL, 'admin@heama-soft.com', NULL, NULL, '2026-07-04 10:27:48', '$2y$12$0F2C4tsNZWh.R8wxDvy4Reld7izIVJwoQS7cP8o.I2q7w3hxEtEVa', 1, NULL, '2026-07-04 10:27:49', '2026-07-04 10:27:49', 0.00, 0.00),
(2, 'App Tester', '07701234567', NULL, 'Erbil', '2026-07-04 14:30:02', NULL, NULL, 0, NULL, '2026-07-04 14:30:02', '2026-07-04 14:30:02', 0.00, 0.00),
(3, 'shimal', '7504848085', NULL, 'Zakho, Duhok', '2026-08-10 17:11:01', NULL, '$2y$12$kdtkRdQYMj2tsQM6TZeDleR8P7uE2HRey/0nV9l6OoLsrJS4WZMxS', 0, NULL, '2026-07-04 14:32:02', '2026-08-10 17:11:01', 0.00, 0.00),
(4, 'Scrape Live', '07701239999', NULL, NULL, '2026-07-05 12:25:17', NULL, NULL, 0, NULL, '2026-07-05 12:25:17', '2026-07-05 12:25:17', 0.00, 0.00),
(5, 'kawa', '7504444444', NULL, 'Erbil', '2026-07-07 08:37:46', NULL, '$2y$12$QGjkXRZw5BG4BgxuSBFsI.MhpZDfuw.e4N.x9365QeGWjuiizsyFy', 0, NULL, '2026-07-07 08:37:46', '2026-07-07 08:37:55', 0.00, 0.00),
(6, 'Heama user', '750852588', NULL, NULL, '2026-07-09 08:58:57', NULL, NULL, 0, NULL, '2026-07-09 08:58:57', '2026-07-09 08:58:57', 0.00, 0.00),
(7, 'ahmed', '7504848088', NULL, 'دهۆک', '2026-07-09 09:14:09', NULL, '$2y$12$uMmnS9Nh19Ws3Lf3bPb8Yezc.ZWTFD/k2DdTKdG6zuLFdiErn37hG', 0, NULL, '2026-07-09 09:14:09', '2026-07-09 09:14:21', 0.00, 0.00),
(8, 'taha new', '7501122334', NULL, 'Shaqlawa, Erbil', '2026-07-09 09:21:15', NULL, '$2y$12$XZ4W4gU210Q0gzn/qMq1iOIc3mfoo9v0yCa.F1dm9TMYmD4nTRX.a', 0, NULL, '2026-07-09 09:21:15', '2026-07-09 11:14:23', 0.00, 0.00),
(9, 'ahh', '750444444', NULL, 'Zakho, Duhok', '2026-07-14 14:42:05', NULL, '$2y$12$t42pw.5tVs440Bj9JMrvMO0vzHYlm1KFOr9ReKMYsLvz7W.sDaYM.', 0, NULL, '2026-07-14 14:42:05', '2026-07-14 14:42:23', 0.00, 0.00),
(10, 'ahmed', '0750444', NULL, 'zakho', NULL, NULL, NULL, 0, NULL, '2026-07-25 07:39:44', '2026-07-25 07:39:44', 0.00, 0.00),
(11, 'salim mehdi', '02222', NULL, 'zzzzz', NULL, NULL, NULL, 0, NULL, '2026-07-25 12:29:16', '2026-07-29 13:02:01', 0.00, -500.00),
(12, 'ahmed rashed', '0755555', NULL, 'zakho', NULL, NULL, '$2y$10$obat9xJOX/QztoSEcS.DMuBrdDTJ2xBzR0pbDmiUCAJ1N2XSQ6kmu', 0, NULL, '2026-08-02 17:59:15', '2026-08-02 17:59:58', -1000000.00, -500.00),
(13, 'shimal sendi', '7504845522', NULL, 'Zakho, Duhok', '2026-08-08 10:50:42', NULL, '$2y$12$ySeV9vz7eV509sY760RTfeIXNQjr1/Q0Hdw5MF7VNYUiMgXprEZPq', 0, NULL, '2026-08-08 10:50:42', '2026-08-08 10:50:50', 0.00, 0.00),
(14, 'ahmed', '7518016694', NULL, 'Zakho, Duhok', '2026-08-10 16:56:46', NULL, '$2y$12$GyyZT7QZFbEGr5imnLNkWuUqTYwdTFweKPcHjwcW59bYm0Y28GXAm', 0, NULL, '2026-08-08 11:53:17', '2026-08-10 16:56:46', 0.00, 0.00);

-- --------------------------------------------------------

--
-- Table structure for table `wallets`
--

CREATE TABLE `wallets` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `balance_iqd` decimal(14,2) NOT NULL DEFAULT '0.00',
  `balance_usd` decimal(14,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `wallets`
--

INSERT INTO `wallets` (`id`, `user_id`, `balance_iqd`, `balance_usd`, `created_at`, `updated_at`) VALUES
(1, 1, 0.00, 0.00, '2026-07-04 10:27:49', '2026-07-04 10:27:49'),
(2, 2, 0.00, 0.00, '2026-07-04 14:30:02', '2026-07-04 14:30:02'),
(3, 3, 10116005.00, 47.22, '2026-07-04 14:32:02', '2026-08-10 22:33:45'),
(4, 4, 0.00, 0.00, '2026-07-05 12:25:17', '2026-07-05 12:25:17'),
(5, 5, 0.00, 34.55, '2026-07-07 08:37:46', '2026-08-10 14:57:35'),
(6, 6, 0.00, 0.00, '2026-07-09 08:58:57', '2026-07-09 08:58:57'),
(7, 7, 0.00, 0.00, '2026-07-09 09:14:09', '2026-07-09 09:14:09'),
(8, 8, 0.00, 0.00, '2026-07-09 09:21:15', '2026-07-11 11:41:47'),
(9, 9, 0.00, 0.00, '2026-07-14 14:42:05', '2026-07-14 14:42:05'),
(10, 11, -1627.00, 1.48, '2026-07-25 12:50:10', '2026-08-13 12:45:17'),
(11, 10, 200000.00, 600.00, '2026-07-30 12:28:25', '2026-08-10 15:09:17'),
(12, 12, -12841.00, -56.65, '2026-08-02 17:59:15', '2026-08-12 16:35:22'),
(13, 13, -25475.00, -16.21, '2026-08-08 10:50:42', '2026-08-12 15:30:17'),
(14, 14, 76688.00, -60.62, '2026-08-08 11:53:17', '2026-08-13 12:45:12');

-- --------------------------------------------------------

--
-- Table structure for table `wallet_transactions`
--

CREATE TABLE `wallet_transactions` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `currency` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'IQD',
  `amount_iqd` decimal(14,2) NOT NULL DEFAULT '0.00',
  `balance_after` decimal(14,2) NOT NULL DEFAULT '0.00',
  `order_id` bigint UNSIGNED DEFAULT NULL,
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `admin_id` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `amount_usd` decimal(14,2) NOT NULL DEFAULT '0.00',
  `balance_usd_after` decimal(14,2) NOT NULL DEFAULT '0.00',
  `order_code` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `account_id` bigint UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `wallet_transactions`
--

INSERT INTO `wallet_transactions` (`id`, `user_id`, `type`, `currency`, `amount_iqd`, `balance_after`, `order_id`, `note`, `admin_id`, `created_at`, `updated_at`, `amount_usd`, `balance_usd_after`, `order_code`, `account_id`) VALUES
(47, 3, 'debit', 'IQD', -12250.00, -12250.00, 47, 'Order HM-20047', NULL, '2026-07-15 08:41:09', '2026-07-15 08:41:09', 0.00, 0.00, NULL, NULL),
(48, 3, 'topup', 'IQD', 10000000.00, 0.00, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00, NULL, NULL),
(49, 3, 'exchange', 'IQD', -15000.00, 72750.00, NULL, 'Exchange to USD', NULL, '2026-07-15 09:15:46', '2026-07-15 09:15:46', 0.00, 0.00, NULL, NULL),
(50, 3, 'exchange', 'USD', 10.00, 10.00, NULL, 'Exchange from IQD', NULL, '2026-07-15 09:15:46', '2026-07-15 09:15:46', 0.00, 0.00, NULL, NULL),
(51, 3, 'exchange', 'USD', -8.00, 2.00, NULL, 'Exchange to IQD', NULL, '2026-07-15 09:15:55', '2026-07-15 09:15:55', 0.00, 0.00, NULL, NULL),
(52, 3, 'exchange', 'IQD', 12000.00, 84750.00, NULL, 'Exchange from USD', NULL, '2026-07-15 09:15:55', '2026-07-15 09:15:55', 0.00, 0.00, NULL, NULL),
(53, 3, 'exchange', 'IQD', -1000000.00, 8984750.00, NULL, 'Exchange to USD', NULL, '2026-07-15 09:17:17', '2026-07-15 09:17:17', 0.00, 0.00, NULL, NULL),
(54, 3, 'exchange', 'USD', 666.67, 668.67, NULL, 'Exchange from IQD', NULL, '2026-07-15 09:17:17', '2026-07-15 09:17:17', 0.00, 0.00, NULL, NULL),
(55, 3, 'exchange', 'USD', -666.00, 2.67, NULL, 'Exchange to IQD', NULL, '2026-07-15 09:18:07', '2026-07-15 09:18:07', 0.00, 0.00, NULL, NULL),
(56, 3, 'exchange', 'IQD', 999000.00, 9983750.00, NULL, 'Exchange from USD', NULL, '2026-07-15 09:18:07', '2026-07-15 09:18:07', 0.00, 0.00, NULL, NULL),
(57, 3, 'exchange', 'USD', -2.67, 0.00, NULL, 'Exchange to IQD', NULL, '2026-07-15 09:18:18', '2026-07-15 09:18:18', 0.00, 0.00, NULL, NULL),
(58, 3, 'exchange', 'IQD', 4005.00, 9987755.00, NULL, 'Exchange from USD', NULL, '2026-07-15 09:18:18', '2026-07-15 09:18:18', 0.00, 0.00, NULL, NULL),
(59, 3, 'debit', 'USD', -12.75, -12.75, 48, 'Order HM-20048', NULL, '2026-07-15 09:19:14', '2026-07-15 09:19:14', 0.00, 0.00, NULL, NULL),
(60, 3, 'exchange', 'IQD', -15000.00, 9972755.00, NULL, 'Exchange to USD', NULL, '2026-07-15 09:19:34', '2026-07-15 09:19:34', 0.00, 0.00, NULL, NULL),
(61, 3, 'exchange', 'USD', 10.00, -2.75, NULL, 'Exchange from IQD', NULL, '2026-07-15 09:19:34', '2026-07-15 09:19:34', 0.00, 0.00, NULL, NULL),
(62, 3, 'debit', 'USD', -27.25, -30.00, 49, 'Order HM-20049', NULL, '2026-07-15 12:09:26', '2026-07-15 12:09:26', 0.00, 0.00, NULL, NULL),
(63, 3, 'debit', 'USD', -12.75, -42.75, 50, 'Order HM-20050', NULL, '2026-07-15 12:22:16', '2026-07-15 12:22:16', 0.00, 0.00, NULL, NULL),
(64, 3, 'debit', 'USD', -32.50, -75.25, 51, 'Order HM-20051', NULL, '2026-07-15 15:54:44', '2026-07-15 15:54:44', 0.00, 0.00, NULL, NULL),
(65, 3, 'debit', 'IQD', -160500.00, 9812255.00, 52, 'Order HM-20052', NULL, '2026-07-16 13:41:07', '2026-07-16 13:41:07', 0.00, 0.00, NULL, NULL),
(66, 3, 'debit', 'USD', -12.75, -88.00, 53, 'Order HM-20053', NULL, '2026-07-23 09:41:00', '2026-07-23 09:41:00', 0.00, 0.00, NULL, NULL),
(67, 3, 'refund', 'USD', 12.75, -75.25, 48, 'Refund for cancelled HM-20048', NULL, '2026-07-23 09:43:59', '2026-07-23 09:43:59', 0.00, 0.00, NULL, NULL),
(68, 3, 'refund', 'USD', 27.25, -48.00, 49, 'Refund for cancelled HM-20049', NULL, '2026-07-23 09:44:03', '2026-07-23 09:44:03', 0.00, 0.00, NULL, NULL),
(69, 3, 'refund', 'IQD', 12250.00, 9824505.00, 47, 'Refund for cancelled HM-20047', NULL, '2026-07-23 09:44:12', '2026-07-23 09:44:12', 0.00, 0.00, NULL, NULL),
(70, 3, 'refund', 'USD', 12.75, -35.25, 50, 'Refund for cancelled HM-20050', NULL, '2026-07-23 09:44:14', '2026-07-23 09:44:14', 0.00, 0.00, NULL, NULL),
(71, 3, 'refund', 'USD', 32.50, -2.75, 51, 'Refund for cancelled HM-20051', NULL, '2026-07-23 09:44:15', '2026-07-23 09:44:15', 0.00, 0.00, NULL, NULL),
(72, 3, 'refund', 'IQD', 160500.00, 9985005.00, 52, 'Refund for cancelled HM-20052', NULL, '2026-07-23 09:44:20', '2026-07-23 09:44:20', 0.00, 0.00, NULL, NULL),
(73, 3, 'refund', 'USD', 12.75, 10.00, 53, 'Refund for cancelled HM-20053', NULL, '2026-07-23 09:44:22', '2026-07-23 09:44:22', 0.00, 0.00, NULL, NULL),
(74, 3, 'debit', 'USD', -12.75, -2.75, 54, 'Order HM-20054', NULL, '2026-07-23 10:11:07', '2026-07-23 10:11:07', 0.00, 0.00, NULL, NULL),
(75, 3, 'debit', 'USD', -159.75, -162.50, 55, 'Order HM-20055', NULL, '2026-07-23 11:52:15', '2026-07-23 11:52:15', 0.00, 0.00, NULL, NULL),
(76, 3, 'debit', 'USD', -112.25, -274.75, 56, 'Order HM-20056', NULL, '2026-07-23 12:42:29', '2026-07-23 12:42:29', 0.00, 0.00, NULL, NULL),
(77, 3, 'debit', 'USD', -184.75, -459.50, 57, 'Order HM-20057', NULL, '2026-07-23 12:58:04', '2026-07-23 12:58:04', 0.00, 0.00, NULL, NULL),
(78, 3, 'refund', 'USD', 12.75, -446.75, 57, 'Rejected shipping — item removed from HM-20057', NULL, '2026-07-23 13:17:36', '2026-07-23 13:17:36', 0.00, 0.00, NULL, NULL),
(79, 3, 'refund', 'USD', 159.25, -287.50, 57, 'Rejected shipping — item removed from HM-20057', NULL, '2026-07-23 13:18:25', '2026-07-23 13:18:25', 0.00, 0.00, NULL, NULL),
(80, 3, 'refund', 'USD', 159.25, -128.25, 55, 'Rejected shipping — item removed from HM-20055', NULL, '2026-07-23 13:24:22', '2026-07-23 13:24:22', 0.00, 0.00, NULL, NULL),
(81, 3, 'refund', 'USD', 166.25, 38.00, 55, 'Rejected shipping — item removed from HM-20055', NULL, '2026-07-23 13:30:55', '2026-07-23 13:30:55', 0.00, 0.00, NULL, NULL),
(82, 3, 'debit', 'USD', -12.75, 25.25, 58, 'Order HM-20058', NULL, '2026-07-23 16:35:25', '2026-07-23 16:35:25', 0.00, 0.00, NULL, NULL),
(83, 3, 'refund', 'USD', 12.75, 38.00, 58, 'Rejected shipping — item removed from HM-20058', NULL, '2026-07-23 16:44:40', '2026-07-23 16:44:40', 0.00, 0.00, NULL, NULL),
(84, 3, 'refund', 'USD', 12.75, 50.75, 54, 'Rejected shipping — item removed from HM-20054', NULL, '2026-07-23 16:44:42', '2026-07-23 16:44:42', 0.00, 0.00, NULL, NULL),
(85, 3, 'refund', 'USD', 100.50, 151.25, 56, 'Cancelled item from HM-20056', NULL, '2026-07-23 16:46:47', '2026-07-23 16:46:47', 0.00, 0.00, NULL, NULL),
(86, 11, 'topup', 'IQD', 125000.00, 125000.00, NULL, NULL, 3, '2026-07-25 12:50:10', '2026-07-25 12:50:10', 0.00, 0.00, NULL, NULL),
(87, 3, 'refund', 'USD', 12.75, 164.00, 53, 'Rejected shipping — item removed from HM-20053', NULL, '2026-07-26 18:33:01', '2026-07-26 18:33:01', 0.00, 0.00, NULL, NULL),
(88, 3, 'refund', 'USD', 2.50, 166.50, 55, 'Rejected shipping — item removed from HM-20055', NULL, '2026-07-26 18:33:03', '2026-07-26 18:33:03', 0.00, 0.00, NULL, NULL),
(89, 11, 'order', 'USD', 0.00, 125000.00, NULL, 'Order HM-20076', 3, '2026-07-28 13:59:20', '2026-07-28 13:59:20', -18.85, -18.85, 'HM-20076', NULL),
(90, 11, 'topup', 'USD', 0.00, 125000.00, NULL, 'Admin top-up', 3, '2026-07-28 14:00:04', '2026-07-28 14:00:04', 40.00, 21.15, NULL, NULL),
(91, 11, 'convert_out', 'IQD', -45000.00, 80000.00, NULL, 'Converted to USD', 3, '2026-07-28 14:05:45', '2026-07-28 14:05:45', 0.00, 21.15, NULL, NULL),
(92, 11, 'convert_in', 'USD', 0.00, 80000.00, NULL, 'Converted from IQD', 3, '2026-07-28 14:05:45', '2026-07-28 14:05:45', 34.35, 55.50, NULL, NULL),
(93, 11, 'order', 'USD', 0.00, 80000.00, NULL, 'Order HM-20077', 3, '2026-07-29 12:50:01', '2026-07-29 12:50:01', -18.85, 36.65, 'HM-20077', NULL),
(94, 11, 'adjust', 'USD', 0.00, 80000.00, NULL, 'Shipping change HM-20077', 3, '2026-07-29 15:15:54', '2026-07-29 15:15:54', -0.50, 36.15, 'HM-20077', NULL),
(95, 3, 'debit', 'USD', -2.50, 164.00, 81, 'Order HM-20081', NULL, '2026-07-30 11:50:58', '2026-07-30 11:50:58', 0.00, 0.00, NULL, NULL),
(96, 3, 'exchange', 'USD', -100.00, 64.00, NULL, 'Exchange to IQD', NULL, '2026-07-30 15:06:50', '2026-07-30 15:06:50', 0.00, 0.00, NULL, NULL),
(97, 3, 'exchange', 'IQD', 131000.00, 10116005.00, NULL, 'Exchange from USD', NULL, '2026-07-30 15:06:50', '2026-07-30 15:06:50', 0.00, 0.00, NULL, NULL),
(98, 10, 'topup', 'USD', 0.00, 0.00, NULL, 'Admin top-up', 3, '2026-07-30 12:28:25', '2026-07-30 12:28:25', 600.00, 600.00, NULL, NULL),
(99, 10, 'topup', 'IQD', 200000.00, 200000.00, NULL, 'Admin top-up', 3, '2026-07-30 12:28:36', '2026-07-30 12:28:36', 0.00, 600.00, NULL, NULL),
(100, 11, 'payout', 'IQD', -25000.00, 55000.00, NULL, 'Admin payout', 3, '2026-07-30 12:30:19', '2026-07-30 12:30:19', 0.00, 36.15, NULL, NULL),
(101, 12, 'order', 'IQD', -12419.00, -12419.00, NULL, 'Order HM-20082', 3, '2026-08-02 17:59:15', '2026-08-02 17:59:15', 0.00, 0.00, 'HM-20082', NULL),
(102, 12, 'adjust', 'USD', 0.00, -12419.00, NULL, 'Shipping change HM-20082', 3, '2026-08-02 18:01:56', '2026-08-02 18:01:56', -2.00, -2.00, 'HM-20082', NULL),
(103, 11, 'order', 'USD', 0.00, 55000.00, NULL, 'Order HM-20083', 3, '2026-08-04 19:01:40', '2026-08-04 19:01:40', -8.71, 27.44, 'HM-20083', NULL),
(104, 11, 'order', 'IQD', -15602.00, 39398.00, NULL, 'Order HM-20084', 3, '2026-08-06 12:53:08', '2026-08-06 12:53:08', 0.00, 27.44, 'HM-20084', NULL),
(105, 13, 'debit', 'IQD', -9500.00, -9500.00, 85, 'Order HM-20085', NULL, '2026-08-08 10:51:32', '2026-08-08 10:51:32', 0.00, 0.00, NULL, NULL),
(106, 13, 'debit', 'USD', -10.25, -10.25, 86, 'Order HM-20086', NULL, '2026-08-08 10:58:29', '2026-08-08 10:58:29', 0.00, 0.00, NULL, NULL),
(107, 13, 'refund', 'USD', 7.75, -2.50, 86, 'Cancelled item from HM-20086', NULL, '2026-08-08 11:03:59', '2026-08-08 11:03:59', 0.00, 0.00, NULL, NULL),
(108, 13, 'debit', 'USD', -31.25, -33.75, 87, 'Order HM-20087', NULL, '2026-08-08 11:25:53', '2026-08-08 11:25:53', 0.00, 0.00, NULL, NULL),
(109, 13, 'debit', 'IQD', -1750.00, -11250.00, 88, 'Order HM-20088', NULL, '2026-08-08 11:27:07', '2026-08-08 11:27:07', 0.00, 0.00, NULL, NULL),
(110, 13, 'order', 'USD', 0.00, -11250.00, NULL, 'Order HM-20089', 3, '2026-08-08 08:27:22', '2026-08-08 08:27:22', -13.57, -47.32, 'HM-20089', NULL),
(111, 13, 'refund', 'USD', 0.00, -11250.00, NULL, 'Cancelled HM-20089', 3, '2026-08-08 08:28:28', '2026-08-08 08:28:28', 13.57, -33.75, 'HM-20089', NULL),
(112, 13, 'refund', 'IQD', 1750.00, -9500.00, 88, 'Refund for cancelled HM-20088', NULL, '2026-08-08 11:32:12', '2026-08-08 11:32:12', 0.00, 0.00, NULL, NULL),
(113, 13, 'refund', 'USD', 0.00, -9500.00, NULL, 'Cancelled HM-20087', 3, '2026-08-08 08:40:45', '2026-08-08 08:40:45', 16.75, -17.00, 'HM-20087', NULL),
(114, 14, 'debit', 'USD', -13.75, -13.75, 90, 'Order HM-20090', NULL, '2026-08-08 12:02:27', '2026-08-08 12:02:27', 0.00, 0.00, NULL, NULL),
(115, 14, 'adjust', 'USD', 0.00, 0.00, NULL, 'Shipping change HM-20090', 3, '2026-08-08 09:03:41', '2026-08-08 09:03:41', -4.00, -17.75, 'HM-20090', NULL),
(116, 14, 'adjust', 'USD', 0.00, 0.00, NULL, 'Shipping change HM-20090', 3, '2026-08-08 09:05:55', '2026-08-08 09:05:55', -1.00, -14.75, 'HM-20090', NULL),
(117, 13, 'refund', 'USD', 11.57, -22.18, 89, 'Refund for cancelled HM-20089', NULL, '2026-08-08 12:28:24', '2026-08-08 12:28:24', 0.00, 0.00, NULL, NULL),
(118, 13, 'refund', 'USD', 31.25, 9.07, 87, 'Refund for cancelled HM-20087', NULL, '2026-08-08 12:32:56', '2026-08-08 12:32:56', 0.00, 0.00, NULL, NULL),
(119, 13, 'debit', 'USD', -5.50, 3.57, 91, 'Order HM-20091', NULL, '2026-08-08 12:33:52', '2026-08-08 12:33:52', 0.00, 0.00, NULL, NULL),
(120, 13, 'adjust', 'USD', 0.00, -9500.00, NULL, 'Shipping change HM-20091', 3, '2026-08-08 09:35:03', '2026-08-08 09:35:03', -3.00, 0.57, 'HM-20091', NULL),
(121, 13, 'debit', 'USD', -3.00, -2.43, 91, 'Shipping increase accepted — HM-20091', NULL, '2026-08-08 12:35:36', '2026-08-08 12:35:36', 0.00, 0.00, NULL, NULL),
(122, 11, 'order', 'USD', 0.00, 39398.00, NULL, 'Order HM-20092', 3, '2026-08-09 12:58:55', '2026-08-09 12:58:55', -12.98, 14.46, 'HM-20092', NULL),
(123, 13, 'cod', 'USD', -16.78, -16.21, 97, 'Order HM-20097', NULL, '2026-08-09 18:08:53', '2026-08-09 18:08:53', 0.00, 0.00, NULL, NULL),
(124, 11, 'order', 'USD', 0.00, 39398.00, NULL, 'Order HM-20098', 3, '2026-08-09 15:13:30', '2026-08-09 15:13:30', -12.98, 1.48, 'HM-20098', NULL),
(125, 5, 'refund', 'USD', 0.00, 0.00, NULL, 'Stocked HM-20071', 3, '2026-08-10 14:13:24', '2026-08-10 14:13:24', 34.55, 34.55, 'HM-20071', NULL),
(126, 5, 'order', 'USD', 0.00, 0.00, NULL, 'Bought from stock HM-20071', 3, '2026-08-10 14:13:47', '2026-08-10 14:13:47', -18.00, 16.55, 'HM-20071', NULL),
(127, 5, 'refund', 'USD', 0.00, 0.00, NULL, 'Stocked HM-20071', 3, '2026-08-10 14:57:35', '2026-08-10 14:57:35', 18.00, 34.55, 'HM-20071', NULL),
(128, 10, 'convert_out', 'IQD', -15000.00, 185000.00, NULL, 'Converted to USD', 3, '2026-08-10 15:08:53', '2026-08-10 15:08:53', 0.00, 600.00, NULL, NULL),
(129, 10, 'convert_in', 'USD', 0.00, 185000.00, NULL, 'Converted from IQD', 3, '2026-08-10 15:08:53', '2026-08-10 15:08:53', 10.00, 610.00, NULL, NULL),
(130, 10, 'convert_out', 'USD', 0.00, 185000.00, NULL, 'Converted to IQD', 3, '2026-08-10 15:09:17', '2026-08-10 15:09:17', -10.00, 600.00, NULL, NULL),
(131, 10, 'convert_in', 'IQD', 15000.00, 200000.00, NULL, 'Converted from USD', 3, '2026-08-10 15:09:17', '2026-08-10 15:09:17', 0.00, 600.00, NULL, NULL),
(132, 3, 'debit', 'USD', -16.78, 47.22, 99, 'Order HM-20099', NULL, '2026-08-10 22:33:45', '2026-08-10 22:33:45', 0.00, 0.00, NULL, NULL),
(133, 14, 'topup', 'IQD', 150000.00, 150000.00, NULL, 'Admin top-up', 3, '2026-08-11 12:54:29', '2026-08-11 12:54:29', 0.00, -13.75, NULL, 3),
(134, 12, 'topup', 'IQD', 10000.00, -2419.00, NULL, 'Admin top-up', 3, '2026-08-11 13:30:09', '2026-08-11 13:30:09', 0.00, -2.00, NULL, 4),
(135, 14, 'topup', 'IQD', 1000.00, 151000.00, NULL, 'Admin top-up', 3, '2026-08-11 14:34:49', '2026-08-11 14:34:49', 0.00, -13.75, NULL, 3),
(136, 11, 'order', 'USD', 0.00, 39398.00, NULL, 'Order HM-20100', 3, '2026-08-12 15:09:04', '2026-08-12 15:09:04', -14.96, -13.48, 'HM-20100', NULL),
(137, 14, 'order', 'USD', 0.00, 151000.00, NULL, 'Order HM-20101', 3, '2026-08-12 15:17:40', '2026-08-12 15:17:40', -42.00, -55.75, 'HM-20101', NULL),
(138, 12, 'order', 'USD', 0.00, -2419.00, NULL, 'Order HM-20102', 3, '2026-08-12 15:18:29', '2026-08-12 15:18:29', -42.00, -44.00, 'HM-20102', NULL),
(139, 14, 'order', 'USD', 0.00, 151000.00, NULL, 'Order HM-20103', 3, '2026-08-12 15:21:15', '2026-08-12 15:21:15', -12.65, -68.40, 'HM-20103', NULL),
(140, 14, 'order', 'USD', 0.00, 151000.00, NULL, 'Order HM-20104', 3, '2026-08-12 15:24:31', '2026-08-12 15:24:31', -12.65, -81.05, 'HM-20104', NULL),
(141, 12, 'order', 'USD', 0.00, -2419.00, NULL, 'Order HM-20105', 3, '2026-08-12 15:24:56', '2026-08-12 15:24:56', -12.65, -56.65, 'HM-20105', NULL),
(142, 11, 'order', 'IQD', -29445.00, 9953.00, NULL, 'Order HM-20106', 3, '2026-08-12 15:28:51', '2026-08-12 15:28:51', 0.00, -13.48, 'HM-20106', NULL),
(143, 13, 'order', 'IQD', -15975.00, -25475.00, NULL, 'Order HM-20107', 3, '2026-08-12 15:30:17', '2026-08-12 15:30:17', 0.00, -16.21, 'HM-20107', NULL),
(144, 14, 'order', 'IQD', -11580.00, 139420.00, NULL, 'Order HM-20108', 3, '2026-08-12 15:34:48', '2026-08-12 15:34:48', 0.00, -81.05, 'HM-20108', NULL),
(145, 14, 'order', 'IQD', -11580.00, 127840.00, NULL, 'Order HM-20109', 3, '2026-08-12 15:48:44', '2026-08-12 15:48:44', 0.00, -81.05, 'HM-20109', NULL),
(146, 14, 'order', 'IQD', -29445.00, 98395.00, NULL, 'Order HM-20110', 3, '2026-08-12 16:07:54', '2026-08-12 16:07:54', 0.00, -81.05, 'HM-20110', NULL),
(147, 11, 'order', 'IQD', -11580.00, -1627.00, NULL, 'Order HM-20111', 3, '2026-08-12 16:27:55', '2026-08-12 16:27:55', 0.00, -13.48, 'HM-20111', NULL),
(148, 12, 'order', 'IQD', -10422.00, -12841.00, NULL, 'Order HM-20112', 3, '2026-08-12 16:35:22', '2026-08-12 16:35:22', 0.00, -56.65, 'HM-20112', NULL),
(149, 14, 'order', 'IQD', -11286.00, 87109.00, NULL, 'Order HM-20113', 3, '2026-08-12 16:36:47', '2026-08-12 16:36:47', 0.00, -81.05, 'HM-20113', NULL),
(150, 14, 'order', 'IQD', -10422.00, 76687.00, NULL, 'Order HM-20114', 3, '2026-08-12 16:39:20', '2026-08-12 16:39:20', 0.00, -81.05, 'HM-20114', NULL),
(151, 14, 'order', 'IQD', -10422.00, 66265.00, NULL, 'Order HM-20115', 3, '2026-08-12 16:41:16', '2026-08-12 16:41:16', 0.00, -81.05, 'HM-20115', NULL),
(152, 14, 'refund', 'IQD', 10422.00, 76687.00, NULL, 'Stocked HM-20115', 3, '2026-08-12 16:53:07', '2026-08-12 16:53:07', 0.00, -81.05, 'HM-20115', NULL),
(153, 14, 'order', 'USD', 0.00, 76687.00, NULL, 'Order HM-20116', 3, '2026-08-12 17:28:28', '2026-08-12 17:28:28', -15.00, -96.05, 'HM-20116', NULL),
(154, 14, 'order', 'USD', 0.00, 76687.00, NULL, 'Order HM-20117', 3, '2026-08-12 17:34:23', '2026-08-12 17:34:23', -6.57, -102.62, 'HM-20117', NULL),
(155, 14, 'order', 'IQD', -30551.00, 46137.00, NULL, 'Order HM-20118', 3, '2026-08-12 21:58:19', '2026-08-12 21:58:19', 0.00, -102.62, 'HM-20118', NULL),
(156, 14, 'refund', 'IQD', 30551.00, 76688.00, NULL, 'Stocked HM-20118', 3, '2026-08-13 12:44:54', '2026-08-13 12:44:54', 0.00, -102.62, 'HM-20118', NULL),
(157, 14, 'refund', 'USD', 0.00, 76688.00, NULL, 'Stocked HM-20101', 3, '2026-08-13 12:45:12', '2026-08-13 12:45:12', 42.00, -60.62, 'HM-20101', NULL),
(158, 11, 'refund', 'USD', 0.00, -1627.00, NULL, 'Stocked HM-20100', 3, '2026-08-13 12:45:17', '2026-08-13 12:45:17', 14.96, 1.48, 'HM-20100', NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `accounts_plan_type_idx` (`plan`,`type`);

--
-- Indexes for table `account_transfers`
--
ALTER TABLE `account_transfers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_from` (`from_id`),
  ADD KEY `idx_to` (`to_id`);

--
-- Indexes for table `addresses`
--
ALTER TABLE `addresses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `addresses_user_id_foreign` (`user_id`);

--
-- Indexes for table `admin_notifications`
--
ALTER TABLE `admin_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `admin_notifications_read_at_created_at_index` (`read_at`,`created_at`);

--
-- Indexes for table `admin_tokens`
--
ALTER TABLE `admin_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `admin_tokens_hash_unique` (`token_hash`),
  ADD KEY `admin_tokens_user_idx` (`user_id`);

--
-- Indexes for table `admin_users`
--
ALTER TABLE `admin_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `admin_users_username_unique` (`username`);

--
-- Indexes for table `boxes`
--
ALTER TABLE `boxes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `boxes_plan_idx` (`plan`);

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
-- Indexes for table `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `carts_user_id_unique` (`user_id`);

--
-- Indexes for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cart_items_cart_id_foreign` (`cart_id`),
  ADD KEY `cart_items_store_id_foreign` (`store_id`);

--
-- Indexes for table `customer_status`
--
ALTER TABLE `customer_status`
  ADD PRIMARY KEY (`user_id`),
  ADD KEY `customer_status_verified_idx` (`verified_at`),
  ADD KEY `customer_status_blocked_idx` (`blocked_at`);

--
-- Indexes for table `device_tokens`
--
ALTER TABLE `device_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `device_tokens_user_id` (`user_id`);

--
-- Indexes for table `expenses`
--
ALTER TABLE `expenses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `expenses_plan_idx` (`plan`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`),
  ADD KEY `failed_jobs_connection_queue_failed_at_index` (`connection`,`queue`,`failed_at`);

--
-- Indexes for table `favorites`
--
ALTER TABLE `favorites`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `favorites_user_item_unique` (`user_id`,`item_key`);

--
-- Indexes for table `fx_rates`
--
ALTER TABLE `fx_rates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `fx_rates_currency_unique` (`currency`);

--
-- Indexes for table `fx_rate_history`
--
ALTER TABLE `fx_rate_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_currency_effective` (`currency`,`effective_at`);

--
-- Indexes for table `item_approvals`
--
ALTER TABLE `item_approvals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_ia_item` (`item_id`),
  ADD KEY `idx_ia_user` (`user_id`),
  ADD KEY `idx_ia_status` (`status`);

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
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `orders_code_unique` (`code`),
  ADD KEY `orders_user_id_foreign` (`user_id`),
  ADD KEY `orders_status_idx` (`status`),
  ADD KEY `orders_placed_idx` (`placed_at`),
  ADD KEY `idx_orders_source` (`source`);

--
-- Indexes for table `order_events`
--
ALTER TABLE `order_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_events_order_id_foreign` (`order_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_items_order_id_foreign` (`order_id`),
  ADD KEY `order_items_store_id_foreign` (`store_id`),
  ADD KEY `order_items_purchased_idx` (`purchased_at`),
  ADD KEY `idx_oi_step` (`step`),
  ADD KEY `idx_oi_box` (`box_id`),
  ADD KEY `idx_oi_approval` (`approval`);

--
-- Indexes for table `order_workflow`
--
ALTER TABLE `order_workflow`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `order_workflow_step_idx` (`step`),
  ADD KEY `order_workflow_box_idx` (`box_id`);

--
-- Indexes for table `otp_codes`
--
ALTER TABLE `otp_codes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `otp_codes_identifier_index` (`identifier`);

--
-- Indexes for table `parcels`
--
ALTER TABLE `parcels`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_plan` (`plan`),
  ADD KEY `idx_code` (`code`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `payments_plan_idx` (`plan`),
  ADD KEY `payments_user_idx` (`user_id`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `shipping_boxes`
--
ALTER TABLE `shipping_boxes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_plan` (`plan`);

--
-- Indexes for table `stores`
--
ALTER TABLE `stores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `stores_key_unique` (`key`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_phone_unique` (`phone`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Indexes for table `wallets`
--
ALTER TABLE `wallets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `wallets_user_id_unique` (`user_id`);

--
-- Indexes for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `wallet_transactions_user_id_foreign` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accounts`
--
ALTER TABLE `accounts`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `account_transfers`
--
ALTER TABLE `account_transfers`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `addresses`
--
ALTER TABLE `addresses`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `admin_notifications`
--
ALTER TABLE `admin_notifications`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `admin_tokens`
--
ALTER TABLE `admin_tokens`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=78;

--
-- AUTO_INCREMENT for table `admin_users`
--
ALTER TABLE `admin_users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `boxes`
--
ALTER TABLE `boxes`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `carts`
--
ALTER TABLE `carts`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `cart_items`
--
ALTER TABLE `cart_items`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=149;

--
-- AUTO_INCREMENT for table `device_tokens`
--
ALTER TABLE `device_tokens`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `favorites`
--
ALTER TABLE `favorites`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=83;

--
-- AUTO_INCREMENT for table `fx_rates`
--
ALTER TABLE `fx_rates`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `fx_rate_history`
--
ALTER TABLE `fx_rate_history`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `item_approvals`
--
ALTER TABLE `item_approvals`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order_events`
--
ALTER TABLE `order_events`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=135;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=137;

--
-- AUTO_INCREMENT for table `otp_codes`
--
ALTER TABLE `otp_codes`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `parcels`
--
ALTER TABLE `parcels`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `shipping_boxes`
--
ALTER TABLE `shipping_boxes`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `stores`
--
ALTER TABLE `stores`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `wallets`
--
ALTER TABLE `wallets`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=159;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `addresses`
--
ALTER TABLE `addresses`
  ADD CONSTRAINT `addresses_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `carts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD CONSTRAINT `cart_items_cart_id_foreign` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_items_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`);

--
-- Constraints for table `favorites`
--
ALTER TABLE `favorites`
  ADD CONSTRAINT `favorites_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `order_events`
--
ALTER TABLE `order_events`
  ADD CONSTRAINT `order_events_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_store_id_foreign` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`);

--
-- Constraints for table `wallets`
--
ALTER TABLE `wallets`
  ADD CONSTRAINT `wallets_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  ADD CONSTRAINT `wallet_transactions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
