-- An admin's own shipping figure on a cart line
-- (run once in phpMyAdmin → SQL). Same as the migration
-- 2026_10_20_000001_add_shipping_override_to_cart_items.php; the INSERT records
-- it as run so `php artisan migrate` won't repeat it.
--
-- Shipping was never stored on a cart line — it was computed from the flat
-- per-unit rate each time the cart was read, so a scarf and a winter coat both
-- came out at $2. NULL still means "use the rate", so existing lines are
-- unaffected; a number here is PER UNIT, because each unit becomes its own
-- order and carries this amount.

ALTER TABLE `cart_items`
  ADD `shipping_override` decimal(14,2) DEFAULT NULL AFTER `iqd_price`;

INSERT INTO `migrations` (`migration`, `batch`)
SELECT '2026_10_20_000001_add_shipping_override_to_cart_items', COALESCE(MAX(`batch`), 0) + 1 FROM `migrations`;
