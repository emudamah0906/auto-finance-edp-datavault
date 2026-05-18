-- ============================================================
-- 03_business_vault / 01 -- PIT_CONTRACT (Point-In-Time table)
--
-- THE PROBLEM this solves: HUB_CONTRACT has two satellites. To get
-- "the current picture of a contract" every query has to re-derive
-- which satellite version is current (a MAX/ROW_NUMBER each time).
--
-- A PIT table does that derivation ONCE and stores the answer: for
-- each contract on a snapshot date, exactly which satellite rows
-- are current. Then a mart query just joins on those keys -- no
-- "find the latest" logic at all.
--
-- Important: a PIT table holds NO new business data. It's pure
-- performance and 100% rebuildable from the Raw Vault -- that's
-- why it lives in the Business Vault, not the Raw Vault.
-- ============================================================
USE WAREHOUSE EDP_WH;
USE DATABASE  AUTO_FINANCE_EDP;
USE SCHEMA    BUSINESS_VAULT;

-- The PIT table -- per contract + snapshot date, the pointers to the
-- current row in each of the contract's satellites.
CREATE OR REPLACE TABLE PIT_CONTRACT (
    contract_hk    VARCHAR(32)   NOT NULL,
    snapshot_date  DATE          NOT NULL,
    terms_load_dts TIMESTAMP_NTZ,           -- points at current SAT_CONTRACT_TERMS version
    status_date    DATE,                    -- points at current SAT_CONTRACT_STATUS row
    CONSTRAINT pk_pit_contract PRIMARY KEY (contract_hk, snapshot_date)
);

-- Loader -- one row per contract for today's snapshot. The two
-- sub-queries find the current version in each satellite.
INSERT INTO PIT_CONTRACT (contract_hk, snapshot_date, terms_load_dts, status_date)
SELECT h.contract_hk,
       CURRENT_DATE() AS snapshot_date,
       (SELECT MAX(t.load_dts)               -- latest version of the terms sat
          FROM RAW_VAULT.SAT_CONTRACT_TERMS t
         WHERE t.contract_hk = h.contract_hk)   AS terms_load_dts,
       (SELECT MAX(s.status_date)            -- latest monthly status row
          FROM RAW_VAULT.SAT_CONTRACT_STATUS s
         WHERE s.contract_hk = h.contract_hk)   AS status_date
FROM RAW_VAULT.HUB_CONTRACT h
WHERE NOT EXISTS (                           -- idempotent: skip if today already built
    SELECT 1 FROM PIT_CONTRACT p
    WHERE p.contract_hk = h.contract_hk
      AND p.snapshot_date = CURRENT_DATE()
);

-- Check the row count.
SELECT COUNT(*) AS pit_rows FROM PIT_CONTRACT;
