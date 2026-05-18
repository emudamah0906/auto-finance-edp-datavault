-- ============================================================
-- 03_business_vault / 01 -- PIT_CONTRACT (point-in-time table)
-- ============================================================
USE WAREHOUSE EDP_WH;
USE DATABASE  TFS_EDP;
USE SCHEMA    BUSINESS_VAULT;

-- The PIT table: for each contract + snapshot date, which satellite
-- versions are current.
CREATE OR REPLACE TABLE PIT_CONTRACT (
    contract_hk    VARCHAR(32)   NOT NULL,
    snapshot_date  DATE          NOT NULL,
    terms_load_dts TIMESTAMP_NTZ,           -- current SAT_CONTRACT_TERMS version
    status_date    DATE,                    -- current SAT_CONTRACT_STATUS row
    CONSTRAINT pk_pit_contract PRIMARY KEY (contract_hk, snapshot_date)
);

-- Loader: one row per contract for today's snapshot.
INSERT INTO PIT_CONTRACT (contract_hk, snapshot_date, terms_load_dts, status_date)
SELECT h.contract_hk,
       CURRENT_DATE() AS snapshot_date,
       (SELECT MAX(t.load_dts)
          FROM RAW_VAULT.SAT_CONTRACT_TERMS t
         WHERE t.contract_hk = h.contract_hk)   AS terms_load_dts,
       (SELECT MAX(s.status_date)
          FROM RAW_VAULT.SAT_CONTRACT_STATUS s
         WHERE s.contract_hk = h.contract_hk)   AS status_date
FROM RAW_VAULT.HUB_CONTRACT h
WHERE NOT EXISTS (
    SELECT 1 FROM PIT_CONTRACT p
    WHERE p.contract_hk = h.contract_hk
      AND p.snapshot_date = CURRENT_DATE()
);

-- Verify
SELECT COUNT(*) AS pit_rows FROM PIT_CONTRACT;