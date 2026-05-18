-- ============================================================
-- 04_marts / 01 -- Star Schema dimensions
-- Built by collapsing Hub + latest Satellite from the Raw Vault.
-- ============================================================
USE WAREHOUSE EDP_WH;
USE DATABASE  TFS_EDP;
USE SCHEMA    MARTS;

-- ---- DIM_DATE -- generated calendar dimension ----
CREATE OR REPLACE TABLE DIM_DATE (
    date_key     NUMBER       NOT NULL,   -- YYYYMMDD
    full_date    DATE         NOT NULL,
    year         NUMBER,
    quarter      NUMBER,
    month        NUMBER,
    month_name   STRING,
    day_of_month NUMBER,
    day_name     STRING,
    CONSTRAINT pk_dim_date PRIMARY KEY (date_key)
);

INSERT INTO DIM_DATE
SELECT TO_NUMBER(TO_CHAR(d,'YYYYMMDD')), d,
       YEAR(d), QUARTER(d), MONTH(d), MONTHNAME(d), DAY(d), DAYNAME(d)
FROM (
    SELECT DATEADD(day, SEQ4(), '2022-01-01'::DATE) AS d
    FROM TABLE(GENERATOR(ROWCOUNT => 3653))     -- ~10 years
)
WHERE d <= '2031-12-31';

-- ---- DIM_CUSTOMER -- HUB_CUSTOMER + latest SAT_CUSTOMER_ORIGINATION ----
CREATE OR REPLACE TABLE DIM_CUSTOMER (
    customer_key  NUMBER IDENTITY(1,1) NOT NULL,   -- surrogate key
    customer_hk   VARCHAR(32),                     -- lineage back to the vault
    customer_id   STRING,                          -- natural key
    first_name    STRING,
    last_name     STRING,
    date_of_birth DATE,
    email         STRING,
    phone         STRING,
    city          STRING,
    province      STRING,
    credit_score  NUMBER(4,0),
    risk_band     STRING,
    CONSTRAINT pk_dim_customer PRIMARY KEY (customer_key)
);

INSERT INTO DIM_CUSTOMER
       (customer_hk, customer_id, first_name, last_name, date_of_birth,
        email, phone, city, province, credit_score, risk_band)
SELECT h.customer_hk, h.customer_id, s.first_name, s.last_name, s.date_of_birth,
       s.email, s.phone, s.city, s.province, s.credit_score, s.risk_band
FROM RAW_VAULT.HUB_CUSTOMER h
JOIN RAW_VAULT.SAT_CUSTOMER_ORIGINATION s ON s.customer_hk = h.customer_hk
QUALIFY ROW_NUMBER() OVER (PARTITION BY h.customer_hk ORDER BY s.load_dts DESC) = 1;

-- ---- DIM_DEALER -- HUB_DEALER + latest SAT_DEALER_DETAILS ----
CREATE OR REPLACE TABLE DIM_DEALER (
    dealer_key    NUMBER IDENTITY(1,1) NOT NULL,
    dealer_hk     VARCHAR(32),
    dealer_code   STRING,
    dealer_name   STRING,
    region        STRING,
    city          STRING,
    province      STRING,
    dealer_status STRING,
    CONSTRAINT pk_dim_dealer PRIMARY KEY (dealer_key)
);

INSERT INTO DIM_DEALER
       (dealer_hk, dealer_code, dealer_name, region, city, province, dealer_status)
SELECT h.dealer_hk, h.dealer_code, s.dealer_name, s.region, s.city, s.province, s.dealer_status
FROM RAW_VAULT.HUB_DEALER h
JOIN RAW_VAULT.SAT_DEALER_DETAILS s ON s.dealer_hk = h.dealer_hk
QUALIFY ROW_NUMBER() OVER (PARTITION BY h.dealer_hk ORDER BY s.load_dts DESC) = 1;

-- ---- DIM_VEHICLE -- HUB_VEHICLE + latest SAT_VEHICLE_DETAILS ----
CREATE OR REPLACE TABLE DIM_VEHICLE (
    vehicle_key NUMBER IDENTITY(1,1) NOT NULL,
    vehicle_hk  VARCHAR(32),
    vin         STRING,
    make        STRING,
    model       STRING,
    model_year  NUMBER(4,0),
    trim        STRING,
    msrp        NUMBER(10,2),
    CONSTRAINT pk_dim_vehicle PRIMARY KEY (vehicle_key)
);

INSERT INTO DIM_VEHICLE
       (vehicle_hk, vin, make, model, model_year, trim, msrp)
SELECT h.vehicle_hk, h.vin, s.make, s.model, s.model_year, s.trim, s.msrp
FROM RAW_VAULT.HUB_VEHICLE h
JOIN RAW_VAULT.SAT_VEHICLE_DETAILS s ON s.vehicle_hk = h.vehicle_hk
QUALIFY ROW_NUMBER() OVER (PARTITION BY h.vehicle_hk ORDER BY s.load_dts DESC) = 1;

-- Verify
SELECT 'DIM_DATE' AS dim, COUNT(*) AS n FROM DIM_DATE
UNION ALL SELECT 'DIM_CUSTOMER', COUNT(*) FROM DIM_CUSTOMER
UNION ALL SELECT 'DIM_DEALER',   COUNT(*) FROM DIM_DEALER
UNION ALL SELECT 'DIM_VEHICLE',  COUNT(*) FROM DIM_VEHICLE
ORDER BY dim;