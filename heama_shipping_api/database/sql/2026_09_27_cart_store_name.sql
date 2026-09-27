-- Cart lines remember which shop they came from
-- (run once in phpMyAdmin → SQL). Same as the migration
-- 2026_09_27_000001_add_store_name_to_cart_items.php; the INSERT records it
-- as run so `php artisan migrate` won't repeat it.
--
-- A line from a shop we don't carry had only store_id, which is null for
-- exactly those items, so the order it became carried no store name and the
-- admin buying it had the link and nothing else. Order lines already had a
-- store_name column; cart lines now have one too, and it is carried across
-- when the order is placed.

ALTER TABLE `cart_items`
  ADD `store_name` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `store_id`;

INSERT INTO `migrations` (`migration`, `batch`)
SELECT '2026_09_27_000001_add_store_name_to_cart_items', COALESCE(MAX(`batch`), 0) + 1 FROM `migrations`;
