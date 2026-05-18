-- ============================================================
-- 02_raw_vault / 05 -- Satellites (descriptive context + history)
-- ============================================================
USE WAREHOUSE EDP_WH;
USE DATABASE  TFS_EDP;
USE SCHEMA    RAW_VAULT;

-- SAT_CUSTOMER_ORIGINATION -- off HUB_CUSTOMER, source: origination
CREATE OR REPLACE TABLE SAT_CUSTOMER_ORIGINATION (
    customer_hk    VARCHAR(32)   NOT NULL,
    load_dts       TIMESTAMP_NTZ NOT NULL,
    hash_diff      VARCHAR(32)   NOT NULL,
    record_source  STRING        NOT NULL,
    first_name     STRING,
    last_name      STRING,
    date_of_birth  DATE,
    email          STRING,
    phone          STRING,
    street_address STRING,
    city           STRING,
    province       STRING,
    postal_code    STRING,
    credit_score   NUMBER(4,0),
    risk_band      STRING,
    CONSTRAINT pk_sat_customer_origination PRIMARY KEY (customer_hk, load_dts)
);

-- SAT_CUSTOMER_SERVICING -- off HUB_CUSTOMER, source: servicing
CREATE OR REPLACE TABLE SAT_CUSTOMER_SERVICING (
    customer_hk         VARCHAR(32)   NOT NULL,
    load_dts            TIMESTAMP_NTZ NOT NULL,
    hash_diff           VARCHAR(32)   NOT NULL,
    record_source       STRING        NOT NULL,
    first_name          STRING,
    last_name           STRING,
    email               STRING,
    phone               STRING,
    mailing_street      STRING,
    mailing_city        STRING,
    mailing_province    STRING,
    mailing_postal_code STRING,
    CONSTRAINT pk_sat_customer_servicing PRIMARY KEY (customer_hk, load_dts)
);

-- SAT_DEALER_DETAILS -- off HUB_DEALER
CREATE OR REPLACE TABLE SAT_DEALER_DETAILS (
    dealer_hk     VARCHAR(32)   NOT NULL,
    load_dts      TIMESTAMP_NTZ NOT NULL,
    hash_diff     VARCHAR(32)   NOT NULL,
    record_source STRING        NOT NULL,
    dealer_name   STRING,
    region        STRING,
    city          STRING,
    province      STRING,
    dealer_status STRING,
    CONSTRAINT pk_sat_dealer_details PRIMARY KEY (dealer_hk, load_dts)
);

-- SAT_VEHICLE_DETAILS -- off HUB_VEHICLE
CREATE OR REPLACE TABLE SAT_VEHICLE_DETAILS (
    vehicle_hk    VARCHAR(32)   NOT NULL,
    load_dts      TIMESTAMP_NTZ NOT NULL,
    hash_diff     VARCHAR(32)   NOT NULL,
    record_source STRING        NOT NULL,
    make          STRING,
    model         STRING,
    model_year    NUMBER(4,0),
    trim          STRING,
    msrp          NUMBER(10,2),
    CONSTRAINT pk_sat_vehicle_details PRIMARY KEY (vehicle_hk, load_dts)
);

-- SAT_APPLICATION_DETAILS -- off HUB_APPLICATION (the request side)
CREATE OR REPLACE TABLE SAT_APPLICATION_DETAILS (
    application_hk   VARCHAR(32)   NOT NULL,
    load_dts         TIMESTAMP_NTZ NOT NULL,
    hash_diff        VARCHAR(32)   NOT NULL,
    record_source    STRING        NOT NULL,
    product_type     STRING,
    requested_amount NUMBER(12,2),
    application_date DATE,
    channel          STRING,
    CONSTRAINT pk_sat_application_details PRIMARY KEY (application_hk, load_dts)
);

-- SAT_APPLICATION_DECISION -- off HUB_APPLICATION (the decision side)
CREATE OR REPLACE TABLE SAT_APPLICATION_DECISION (
    application_hk  VARCHAR(32)   NOT NULL,
    load_dts        TIMESTAMP_NTZ NOT NULL,
    hash_diff       VARCHAR(32)   NOT NULL,
    record_source   STRING        NOT NULL,
    credit_decision STRING,
    approved_amount NUMBER(12,2),
    decision_date   DATE,
    CONSTRAINT pk_sat_application_decision PRIMARY KEY (application_hk, load_dts)
);

-- SAT_CONTRACT_TERMS -- off HUB_CONTRACT (static, set at booking)
CREATE OR REPLACE TABLE SAT_CONTRACT_TERMS (
    contract_hk     VARCHAR(32)   NOT NULL,
    load_dts        TIMESTAMP_NTZ NOT NULL,
    hash_diff       VARCHAR(32)   NOT NULL,
    record_source   STRING        NOT NULL,
    contract_type   STRING,
    apr             NUMBER(5,2),
    term_months     NUMBER(3,0),
    amount_financed NUMBER(12,2),
    residual_value  NUMBER(12,2),
    start_date      DATE,
    maturity_date   DATE,
    CONSTRAINT pk_sat_contract_terms PRIMARY KEY (contract_hk, load_dts)
);

-- SAT_CONTRACT_STATUS -- SNAPSHOT satellite: status_date is part of the PK
CREATE OR REPLACE TABLE SAT_CONTRACT_STATUS (
    contract_hk         VARCHAR(32)   NOT NULL,
    status_date         DATE          NOT NULL,
    load_dts            TIMESTAMP_NTZ NOT NULL,
    hash_diff           VARCHAR(32)   NOT NULL,
    record_source       STRING        NOT NULL,
    contract_status     STRING,
    delinquency_bucket  STRING,
    outstanding_balance NUMBER(12,2),
    CONSTRAINT pk_sat_contract_status PRIMARY KEY (contract_hk, status_date)
);

-- SAT_PAYMENT -- NON-HISTORIZED satellite off the transactional link
CREATE OR REPLACE TABLE SAT_PAYMENT (
    contract_payment_hk VARCHAR(32)   NOT NULL,
    load_dts            TIMESTAMP_NTZ NOT NULL,
    hash_diff           VARCHAR(32)   NOT NULL,
    record_source       STRING        NOT NULL,
    payment_date        DATE,
    payment_amount      NUMBER(12,2),
    payment_method      STRING,
    CONSTRAINT pk_sat_payment PRIMARY KEY (contract_payment_hk)
);