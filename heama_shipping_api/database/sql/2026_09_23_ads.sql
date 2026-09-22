-- Home-page ads (run once in phpMyAdmin → SQL). Same as the migration
-- 2026_09_23_000001_create_ads.php; the INSERT records it as run.
-- Uploaded images are saved in public/uploads/ads — that folder must be
-- writable by the web server (the API creates it on the first upload).

CREATE TABLE `ads` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `image_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `link_url` varchar(1024) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort` int UNSIGNED NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `migrations` (`migration`, `batch`)
SELECT '2026_09_23_000001_create_ads', COALESCE(MAX(`batch`), 0) + 1 FROM `migrations`;
