-- Optional store logos for the app's store tiles (run once in phpMyAdmin).
-- Leave logo_url empty and the app uses the store website's own icon
-- automatically (sharp for Shein, Trendyol, Mango, Karaca; small for some),
-- then the letter glyph. Set it to any square PNG/JPG link — at least 128 px —
-- for a crisp logo. Example afterwards:
--   UPDATE stores SET logo_url = 'https://…/hm-logo.png' WHERE `key` = 'hm';

ALTER TABLE `stores`
  ADD `logo_url` varchar(1024) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `glyph_color`;

INSERT INTO `migrations` (`migration`, `batch`)
SELECT '2026_09_23_000002_add_logo_url_to_stores', COALESCE(MAX(`batch`), 0) + 1 FROM `migrations`;
