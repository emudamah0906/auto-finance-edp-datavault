-- ============================================================
-- 02_raw_vault / 02 -- Hub loaders
--
-- This is where I fill the empty Hubs. Every Hub loader follows
-- the same 3 rules:
--   1. HASH    -- compute MD5(business key) for the hash key
--   2. INSERT-ONLY -- I only ever add new keys, never update/delete
--   3. IDEMPOTENT  -- the WHERE ... NOT IN (...) skips keys already
--                     loaded, so I can re-run this file safely any
--                     number of times and it adds nothing twice.
-- ============================================================
USE WAREHOUSE EDP_WH;
USE DATABASE  AUTO_FINANCE_EDP;
USE SCHEMA    RAW_VAULT;

-- HUB_CUSTOMER -- the interesting one: it's MULTI-SOURCE.
-- The same customer_id can arrive from BOTH origination and servicing.
-- I UNION the two sources, but I still want ONE hub row per customer --
-- so QUALIFY ROW_NUMBER() keeps just one row per customer_id, and the
-- WHERE NOT IN skips anyone already in the hub. Two sources, one key.
INSERT INTO HUB_CUSTOMER (customer_hk, customer_id, load_dts, record_source)
SELECT MD5(customer_id), customer_id, CURRENT_TIMESTAMP(), record_source
FROM (
    SELECT customer_id, 'ORIGINATION' AS record_source FROM STAGING.STG_ORIGINATION_CUSTOMERS
    UNION ALL
    SELECT customer_id, 'SERVICING'   AS record_source FROM STAGING.STG_SERVICING_CUSTOMERS
)
WHERE customer_id NOT IN (SELECT customer_id FROM HUB_CUSTOMER)
QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY record_source) = 1;

-- HUB_DEALER -- single source. DISTINCT first, then skip what's loaded.
INSERT INTO HUB_DEALER (dealer_hk, dealer_code, load_dts, record_source)
SELECT MD5(dealer_code), dealer_code, CURRENT_TIMESTAMP(), 'DEALER'
FROM (SELECT DISTINCT dealer_code FROM STAGING.STG_DEALER_DEALERS)
WHERE dealer_code NOT IN (SELECT dealer_code FROM HUB_DEALER);

-- HUB_VEHICLE -- single source.
INSERT INTO HUB_VEHICLE (vehicle_hk, vin, load_dts, record_source)
SELECT MD5(vin), vin, CURRENT_TIMESTAMP(), 'DEALER'
FROM (SELECT DISTINCT vin FROM STAGING.STG_DEALER_VEHICLES)
WHERE vin NOT IN (SELECT vin FROM HUB_VEHICLE);

-- HUB_APPLICATION -- single source.
INSERT INTO HUB_APPLICATION (application_hk, application_id, load_dts, record_source)
SELECT MD5(application_id), application_id, CURRENT_TIMESTAMP(), 'ORIGINATION'
FROM (SELECT DISTINCT application_id FROM STAGING.STG_ORIGINATION_APPLICATIONS)
WHERE application_id NOT IN (SELECT application_id FROM HUB_APPLICATION);

-- HUB_CONTRACT -- single source.
INSERT INTO HUB_CONTRACT (contract_hk, contract_number, load_dts, record_source)
SELECT MD5(contract_number), contract_number, CURRENT_TIMESTAMP(), 'SERVICING'
FROM (SELECT DISTINCT contract_number FROM STAGING.STG_SERVICING_CONTRACTS)
WHERE contract_number NOT IN (SELECT contract_number FROM HUB_CONTRACT);

-- Check the row counts after loading.
SELECT 'HUB_CUSTOMER' AS hub, COUNT(*) AS n FROM HUB_CUSTOMER
UNION ALL SELECT 'HUB_DEALER',      COUNT(*) FROM HUB_DEALER
UNION ALL SELECT 'HUB_VEHICLE',     COUNT(*) FROM HUB_VEHICLE
UNION ALL SELECT 'HUB_APPLICATION', COUNT(*) FROM HUB_APPLICATION
UNION ALL SELECT 'HUB_CONTRACT',    COUNT(*) FROM HUB_CONTRACT
ORDER BY hub;
