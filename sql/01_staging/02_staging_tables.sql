-- ============================================================
-- 01_staging / 02 -- Staging (ODS) tables, one per source CSV
-- 1:1 mirror of source. No business logic. + 2 metadata columns.
-- ============================================================
USE WAREHOUSE EDP_WH;
USE DATABASE TFS_EDP;
USE SCHEMA STAGING; 

----- DEALER source table------
CREATE OR REPLACE TABLE STG_DEALER_DEALERS (
    dealer_code   STRING,
    dealer_name   STRING,
    region        STRING,
    city          STRING,
    province      STRING,
    dealer_status STRING,
    _SOURCE_FILE  STRING,
    _LOAD_TS      TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE STG_DEALER_VEHICLES (
    vin          STRING,
    make         STRING,
    model        STRING,
    model_year   NUMBER(4,0),
    trim         STRING,
    msrp         NUMBER(10,2),
    _SOURCE_FILE STRING,
    _LOAD_TS     TIMESTAMP_NTZ
);

-- ---- ORIGINATION source ----
CREATE OR REPLACE TABLE STG_ORIGINATION_CUSTOMERS (
    customer_id         STRING,
    first_name          STRING,
    last_name           STRING,
    date_of_birth       DATE,
    email               STRING,
    phone               STRING,
    street_address      STRING,
    city                STRING,
    province            STRING,
    postal_code         STRING,
    credit_score        NUMBER(4,0),
    risk_band           STRING,
    source_extract_date DATE,
    _SOURCE_FILE        STRING,
    _LOAD_TS            TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE STG_ORIGINATION_APPLICATIONS (
    application_id   STRING,
    customer_id      STRING,
    dealer_code      STRING,
    vin              STRING,
    product_type     STRING,
    requested_amount NUMBER(12,2),
    application_date DATE,
    channel          STRING,
    credit_decision  STRING,
    approved_amount  NUMBER(12,2),
    decision_date    DATE,
    _SOURCE_FILE     STRING,
    _LOAD_TS         TIMESTAMP_NTZ
);

-- ---- SERVICING source ----
CREATE OR REPLACE TABLE STG_SERVICING_CONTRACTS (
    contract_number STRING,
    application_id  STRING,
    customer_id     STRING,
    vin             STRING,
    dealer_code     STRING,
    contract_type   STRING,
    apr             NUMBER(5,2),
    term_months     NUMBER(3,0),
    amount_financed NUMBER(12,2),
    residual_value  NUMBER(12,2),
    start_date      DATE,
    maturity_date   DATE,
    _SOURCE_FILE    STRING,
    _LOAD_TS        TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE STG_SERVICING_CUSTOMERS (
    customer_id         STRING,
    first_name          STRING,
    last_name           STRING,
    email               STRING,
    phone               STRING,
    mailing_street      STRING,
    mailing_city        STRING,
    mailing_province    STRING,
    mailing_postal_code STRING,
    source_extract_date DATE,
    _SOURCE_FILE        STRING,
    _LOAD_TS            TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE STG_SERVICING_CONTRACT_STATUS (
    contract_number     STRING,
    status_date         DATE,
    contract_status     STRING,
    delinquency_bucket  STRING,
    outstanding_balance NUMBER(12,2),
    _SOURCE_FILE        STRING,
    _LOAD_TS            TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE STG_SERVICING_PAYMENTS (
    payment_id      STRING,
    contract_number STRING,
    payment_date    DATE,
    payment_amount  NUMBER(12,2),
    payment_method  STRING,
    _SOURCE_FILE    STRING,
    _LOAD_TS        TIMESTAMP_NTZ
);
