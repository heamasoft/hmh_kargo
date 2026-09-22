-- App Store review account (run once in phpMyAdmin → SQL).
--
-- Apple rejected 1.0.1 because the reviewer, who has no account, got an error
-- when tapping "Log in". This creates a working account for them, with an
-- address and some wallet balance so they can try the whole flow, checkout
-- included. Give Apple these details in App Store Connect →
-- App Review Information → Sign-in required:
--
--     User name:  7000000001        (the app already shows +964)
--     Password:   HmhReview2026
--
-- Orders placed with it are Apple's tests — ignore them in the dashboard.
-- 070… is not an Iraqi mobile prefix, so it can't clash with a real customer.

INSERT INTO `users` (`name`, `phone`, `city`, `phone_verified_at`, `password`, `is_admin`, `created_at`, `updated_at`)
VALUES ('App Review', '07000000001', 'Erbil', NOW(),
        '$2y$10$KSxCOgdL.h0VuEZTjN6v4.FfWVaoPuNvU.Q1JH6RmrQBu4Lvb8Udu', 0, NOW(), NOW());

SET @review_id = LAST_INSERT_ID();

INSERT INTO `wallets` (`user_id`, `balance_iqd`, `balance_usd`, `created_at`, `updated_at`)
VALUES (@review_id, 500000, 300, NOW(), NOW());

INSERT INTO `carts` (`user_id`, `created_at`, `updated_at`)
VALUES (@review_id, NOW(), NOW());

INSERT INTO `addresses` (`user_id`, `recipient_name`, `governorate`, `city`, `street`, `phone`, `note`, `is_default`, `created_at`, `updated_at`)
VALUES (@review_id, 'App Review', 'Erbil', 'Erbil', '100m Street', '07000000001', 'Apple App Review test address', 1, NOW(), NOW());
