-- ============================================================
-- 02_raw_vault / 03 -- Link tables (relationships between Hubs)
-- ============================================================
USE WAREHOUSE EDP_WH;
USE DATABASE  TFS_EDP;
USE SCHEMA    RAW_VAULT;

-- LINK_APPLICATION_CUSTOMER -- application <-> customer
CREATE OR REPLACE TABLE LINK_APPLICATION_CUSTOMER (
    application_customer_hk VARCHAR(32)   NOT NULL,  -- MD5(application_id || customer_id)
    application_hk          VARCHAR(32)   NOT NULL,  -- FK -> HUB_APPLICATION
    customer_hk             VARCHAR(32)   NOT NULL,  -- FK -> HUB_CUSTOMER
    load_dts                TIMESTAMP_NTZ NOT NULL,
    record_source           STRING        NOT NULL,
    CONSTRAINT pk_link_application_customer PRIMARY KEY (application_customer_hk)
);

-- LINK_APPLICATION_DEALER -- application <-> dealer
CREATE OR REPLACE TABLE LINK_APPLICATION_DEALER (
    application_dealer_hk VARCHAR(32)   NOT NULL,  -- MD5(application_id || dealer_code)
    application_hk        VARCHAR(32)   NOT NULL,  -- FK -> HUB_APPLICATION
    dealer_hk             VARCHAR(32)   NOT NULL,  -- FK -> HUB_DEALER
    load_dts              TIMESTAMP_NTZ NOT NULL,
    record_source         STRING        NOT NULL,
    CONSTRAINT pk_link_application_dealer PRIMARY KEY (application_dealer_hk)
);

-- LINK_CONTRACT_CUSTOMER -- contract <-> customer
CREATE OR REPLACE TABLE LINK_CONTRACT_CUSTOMER (
    contract_customer_hk VARCHAR(32)   NOT NULL,  -- MD5(contract_number || customer_id)
    contract_hk          VARCHAR(32)   NOT NULL,  -- FK -> HUB_CONTRACT
    customer_hk          VARCHAR(32)   NOT NULL,  -- FK -> HUB_CUSTOMER
    load_dts             TIMESTAMP_NTZ NOT NULL,
    record_source        STRING        NOT NULL,
    CONSTRAINT pk_link_contract_customer PRIMARY KEY (contract_customer_hk)
);

-- LINK_CONTRACT_VEHICLE -- contract <-> vehicle
CREATE OR REPLACE TABLE LINK_CONTRACT_VEHICLE (
    contract_vehicle_hk VARCHAR(32)   NOT NULL,  -- MD5(contract_number || vin)
    contract_hk         VARCHAR(32)   NOT NULL,  -- FK -> HUB_CONTRACT
    vehicle_hk          VARCHAR(32)   NOT NULL,  -- FK -> HUB_VEHICLE
    load_dts            TIMESTAMP_NTZ NOT NULL,
    record_source       STRING        NOT NULL,
    CONSTRAINT pk_link_contract_vehicle PRIMARY KEY (contract_vehicle_hk)
);

-- LINK_CONTRACT_DEALER -- contract <-> dealer
CREATE OR REPLACE TABLE LINK_CONTRACT_DEALER (
    contract_dealer_hk VARCHAR(32)   NOT NULL,  -- MD5(contract_number || dealer_code)
    contract_hk        VARCHAR(32)   NOT NULL,  -- FK -> HUB_CONTRACT
    dealer_hk          VARCHAR(32)   NOT NULL,  -- FK -> HUB_DEALER
    load_dts           TIMESTAMP_NTZ NOT NULL,
    record_source      STRING        NOT NULL,
    CONSTRAINT pk_link_contract_dealer PRIMARY KEY (contract_dealer_hk)
);

-- LINK_CONTRACT_PAYMENT -- TRANSACTIONAL link: payment events against a contract
CREATE OR REPLACE TABLE LINK_CONTRACT_PAYMENT (
    contract_payment_hk VARCHAR(32)   NOT NULL,  -- MD5(payment_id)
    contract_hk         VARCHAR(32)   NOT NULL,  -- FK -> HUB_CONTRACT
    payment_id          STRING        NOT NULL,  -- degenerate key (no Hub of its own)
    load_dts            TIMESTAMP_NTZ NOT NULL,
    record_source       STRING        NOT NULL,
    CONSTRAINT pk_link_contract_payment PRIMARY KEY (contract_payment_hk)
);