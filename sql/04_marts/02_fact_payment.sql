-- ============================================================
-- 04_marts / 02 -- FACT_PAYMENT  (grain: one payment)
-- ============================================================
USE WAREHOUSE EDP_WH;
USE DATABASE  TFS_EDP;
USE SCHEMA    MARTS;

CREATE OR REPLACE TABLE FACT_PAYMENT (
    payment_key    NUMBER IDENTITY(1,1) NOT NULL,
    payment_id     STRING,                 -- degenerate dimension
    customer_key   NUMBER,                 -- FK -> DIM_CUSTOMER
    vehicle_key    NUMBER,                 -- FK -> DIM_VEHICLE
    dealer_key     NUMBER,                 -- FK -> DIM_DEALER
    date_key       NUMBER,                 -- FK -> DIM_DATE
    payment_amount NUMBER(12,2),           -- measure
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
FROM      RAW_VAULT.LINK_CONTRACT_PAYMENT  lp
JOIN      RAW_VAULT.SAT_PAYMENT            sp  ON sp.contract_payment_hk = lp.contract_payment_hk
LEFT JOIN RAW_VAULT.LINK_CONTRACT_CUSTOMER lcc ON lcc.contract_hk = lp.contract_hk
LEFT JOIN RAW_VAULT.LINK_CONTRACT_VEHICLE  lcv ON lcv.contract_hk = lp.contract_hk
LEFT JOIN RAW_VAULT.LINK_CONTRACT_DEALER   lcd ON lcd.contract_hk = lp.contract_hk
LEFT JOIN MARTS.DIM_CUSTOMER dc ON dc.customer_hk = lcc.customer_hk
LEFT JOIN MARTS.DIM_VEHICLE  dv ON dv.vehicle_hk  = lcv.vehicle_hk
LEFT JOIN MARTS.DIM_DEALER   dd ON dd.dealer_hk   = lcd.dealer_hk;

-- Verify: row count + a quick business query
SELECT COUNT(*) AS fact_rows FROM FACT_PAYMENT;