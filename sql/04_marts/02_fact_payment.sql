-- ============================================================
-- 04_marts / 02 -- FACT_PAYMENT
--
-- The fact table is the centre of the star schema. Its grain is
-- ONE PAYMENT -- one row per payment event. It holds:
--   * measures        -- the numbers I aggregate (payment_amount)
--   * dimension FKs    -- customer_key, vehicle_key, dealer_key, date_key
--   * a degenerate key -- payment_id, a natural key with no dimension
--
-- The loader walks the vault: each payment -> its contract -> the
-- contract's customer / vehicle / dealer, then swaps each hash key
-- for the dimension's integer surrogate key.
--
-- WHY LEFT JOIN to the dimensions (not INNER JOIN)? An inner join
-- would silently DROP a payment if a related dimension row were
-- missing. A fact table must never lose a measurement -- LEFT JOIN
-- keeps every payment; a missing key just comes through as NULL.
-- ============================================================
USE WAREHOUSE EDP_WH;
USE DATABASE  AUTO_FINANCE_EDP;
USE SCHEMA    MARTS;

CREATE OR REPLACE TABLE FACT_PAYMENT (
    payment_key    NUMBER IDENTITY(1,1) NOT NULL,
    payment_id     STRING,                 -- degenerate dimension (natural key)
    customer_key   NUMBER,                 -- FK -> DIM_CUSTOMER
    vehicle_key    NUMBER,                 -- FK -> DIM_VEHICLE
    dealer_key     NUMBER,                 -- FK -> DIM_DEALER
    date_key       NUMBER,                 -- FK -> DIM_DATE
    payment_amount NUMBER(12,2),           -- the measure
    payment_method STRING,
    CONSTRAINT pk_fact_payment PRIMARY KEY (payment_key)
);

INSERT INTO FACT_PAYMENT
       (payment_id, customer_key, vehicle_key, dealer_key, date_key,
        payment_amount, payment_method)
SELECT lp.payment_id,
       dc.customer_key,
       dv.vehicle_key,
       dd.dealer_key,
       TO_NUMBER(TO_CHAR(sp.payment_date,'YYYYMMDD'))  AS date_key,
       sp.payment_amount,
       sp.payment_method
FROM      RAW_VAULT.LINK_CONTRACT_PAYMENT  lp                              -- start at the payment
JOIN      RAW_VAULT.SAT_PAYMENT            sp  ON sp.contract_payment_hk = lp.contract_payment_hk  -- its amounts
LEFT JOIN RAW_VAULT.LINK_CONTRACT_CUSTOMER lcc ON lcc.contract_hk = lp.contract_hk   -- payment -> contract -> customer
LEFT JOIN RAW_VAULT.LINK_CONTRACT_VEHICLE  lcv ON lcv.contract_hk = lp.contract_hk   -- -> vehicle
LEFT JOIN RAW_VAULT.LINK_CONTRACT_DEALER   lcd ON lcd.contract_hk = lp.contract_hk   -- -> dealer
LEFT JOIN MARTS.DIM_CUSTOMER dc ON dc.customer_hk = lcc.customer_hk    -- swap hash key -> surrogate key
LEFT JOIN MARTS.DIM_VEHICLE  dv ON dv.vehicle_hk  = lcv.vehicle_hk
LEFT JOIN MARTS.DIM_DEALER   dd ON dd.dealer_hk   = lcd.dealer_hk;

-- Check the row count.
SELECT COUNT(*) AS fact_rows FROM FACT_PAYMENT;
