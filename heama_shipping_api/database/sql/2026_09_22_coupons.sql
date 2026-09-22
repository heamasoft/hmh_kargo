-- Coupons (run once in phpMyAdmin → SQL). Same as the migration
-- 2026_09_22_000001_create_coupons.php; the last INSERT records it as run so a
-- later `php artisan migrate` won't try to create these again.

CREATE TABLE `coupons` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `percent` decimal(5,2) NOT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `coupons_code_unique` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `coupon_redemptions` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `coupon_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `order_id` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `coupon_redemptions_coupon_id_user_id_unique` (`coupon_id`,`user_id`),
  CONSTRAINT `coupon_redemptions_coupon_id_foreign` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `orders`
  ADD `discount_iqd` decimal(14,2) NOT NULL DEFAULT '0.00' AFTER `service_fee_iqd`,
  ADD `discount_percent` decimal(5,2) NOT NULL DEFAULT '0.00' AFTER `discount_iqd`,
  ADD `coupon_code` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `discount_percent`;

INSERT INTO `migrations` (`migration`, `batch`)
SELECT '2026_09_22_000001_create_coupons', COALESCE(MAX(`batch`), 0) + 1 FROM `migrations`;
