-- Wallet: make every row say which currency its amount is in
-- (run once in phpMyAdmin → SQL, after uploading the new app files).
--
-- Two systems write `wallet_transactions`. The admin CMS keeps dollars in
-- `amount_usd` and leaves `amount_iqd` at 0. The app used to write every
-- amount into `amount_iqd`, whatever `currency` said, and rebuilt both
-- balances from `amount_iqd` alone — so every dollar row the CMS had written
-- counted as zero, and the app wrote that zero over the real balance. Dinar
-- orders (Shein) were unaffected, because there both systems use the same
-- column; dollar orders (Trendyol and the other foreign stores) lost their
-- cancels and refunds.
--
-- The app now reads whichever column holds the amount, and writes dollars the
-- way the CMS does. This moves the older app-written dollar rows across, so
-- the whole table means one thing, and rebuilds the balances from the ledger.

-- 1. Older app rows: the dollars are in amount_iqd — move them across.
UPDATE `wallet_transactions`
SET `amount_usd` = `amount_iqd`,
    `balance_usd_after` = `balance_after`,
    `amount_iqd` = 0,
    `balance_after` = 0
WHERE UPPER(COALESCE(NULLIF(`currency`, ''), 'IQD')) = 'USD'
  AND COALESCE(`amount_usd`, 0) = 0
  AND `amount_iqd` <> 0;

-- 2. Rebuild every balance from the ledger, which is the source of truth.
--    The CASE covers any row either system may still have written its own way.
UPDATE `wallets` `w`
SET `w`.`balance_iqd` = COALESCE((
      SELECT SUM(`t`.`amount_iqd`)
      FROM `wallet_transactions` `t`
      WHERE `t`.`user_id` = `w`.`user_id`
        AND UPPER(COALESCE(NULLIF(`t`.`currency`, ''), 'IQD')) = 'IQD'
    ), 0),
    `w`.`balance_usd` = COALESCE((
      SELECT SUM(CASE WHEN COALESCE(`t`.`amount_usd`, 0) <> 0
                      THEN `t`.`amount_usd` ELSE `t`.`amount_iqd` END)
      FROM `wallet_transactions` `t`
      WHERE `t`.`user_id` = `w`.`user_id`
        AND UPPER(COALESCE(NULLIF(`t`.`currency`, ''), 'IQD')) = 'USD'
    ), 0);

-- 3. Check: every wallet should now match its ledger, so this returns nothing.
SELECT `w`.`user_id`, `w`.`balance_usd` AS `stored_usd`, COALESCE(`l`.`total`, 0) AS `ledger_usd`
FROM `wallets` `w`
LEFT JOIN (
  SELECT `user_id`,
         SUM(CASE WHEN COALESCE(`amount_usd`, 0) <> 0
                  THEN `amount_usd` ELSE `amount_iqd` END) AS `total`
  FROM `wallet_transactions`
  WHERE UPPER(COALESCE(NULLIF(`currency`, ''), 'IQD')) = 'USD'
  GROUP BY `user_id`
) `l` ON `l`.`user_id` = `w`.`user_id`
WHERE ABS(`w`.`balance_usd` - COALESCE(`l`.`total`, 0)) > 0.001;
