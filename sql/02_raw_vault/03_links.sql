-- ============================================================
-- 02_raw_vault / 03 -- Link tables
--
-- A Link records a RELATIONSHIP between Hubs -- e.g. "this contract
-- belongs to this customer". Its columns:
--   <link>_hk     -- the link's own hash = MD5 of ALL the joined
--                    business keys together (with a '||' separator)
--   one _hk per Hub it connects -- lets me join Link -> Hub
--   load_dts, record_source
--
-- Key idea: a Link is ALWAYS many-to-many. I never bake a 1:N rule
-- into the structure. If a contract gains a co-signer tomorrow,
-- that's just one more row -- no table change ever. That future-
-- proofing is why Data Vault uses Links instead of foreign keys.
--
-- LINK_CONTRACT_PAYMENT is special -- a "transactional link". It
-- records payment EVENTS, so it also carries payment_id, a
-- degenerate key (a business key that doesn't get its own Hub).
-- ============================================================
USE WAREHOUSE EDP_WH;
USE DATABASE  AUTO_FINANCE_EDP;
USE SCHEMA    RAW_VAULT;

-- LINK_APPLICATION_CUSTOMER -- which customer made which application
CREATE OR REPLACE TABLE LINK_APPLICATION_CUSTOMER (
    application_customer_hk VARCHAR(32)   NOT NULL,  -- MD5(application_id || customer_id)
    application_hk          VARCHAR(32)   NOT NULL,  -- FK -> HUB_APPLICATION
    customer_hk             VARCHAR(32)   NOT NULL,  -- FK -> HUB_CUSTOMER
    load_dts                TIMESTAMP_NTZ NOT NULL,
    record_source           STRING        NOT NULL,
    CONSTRAINT pk_link_application_customer PRIMARY KEY (application_customer_hk)
);

-- LINK_APPLICATION_DEALER -- which dealer submitted which application
CREATE OR REPLACE TABLE LINK_APPLICATION_DEALER (
    application_dealer_hk VARCHAR(32)   NOT NULL,  -- MD5(application_id || dealer_code)
    application_hk        VARCHAR(32)   NOT NULL,  -- FK -> HUB_APPLICATION
    dealer_hk             VARCHAR(32)   NOT NULL,  -- FK -> HUB_DEALER
    load_dts              TIMESTAMP_NTZ NOT NULL,
    record_source         STRING        NOT NULL,
    CONSTRAINT pk_link_application_dealer PRIMARY KEY (application_dealer_hk)
);

-- LINK_CONTRACT_CUSTOMER -- which customer holds which contract
CREATE OR REPLACE TABLE LINK_CONTRACT_CUSTOMER (
    contract_customer_hk VARCHAR(32)   NOT NULL,  -- MD5(contract_number || customer_id)
    contract_hk          VARCHAR(32)   NOT NULL,  -- FK -> HUB_CONTRACT
    customer_hk          VARCHAR(32)   NOT NULL,  -- FK -> HUB_CUSTOMER
    load_dts             TIMESTAMP_NTZ NOT NULL,
    record_source        STRING        NOT NULL,
    CONSTRAINT pk_link_contract_customer PRIMARY KEY (contract_customer_hk)
);

-- LINK_CONTRACT_VEHICLE -- which vehicle a contract finances
CREATE OR REPLACE TABLE LINK_CONTRACT_VEHICLE (
    contract_vehicle_hk VARCHAR(32)   NOT NULL,  -- MD5(contract_number || vin)
    contract_hk         VARCHAR(32)   NOT NULL,  -- FK -> HUB_CONTRACT
    vehicle_hk          VARCHAR(32)   NOT NULL,  -- FK -> HUB_VEHICLE
    load_dts            TIMESTAMP_NTZ NOT NULL,
    record_source       STRING        NOT NULL,
    CONSTRAINT pk_link_contract_vehicle PRIMARY KEY (contract_vehicle_hk)
);

-- LINK_CONTRACT_DEALER -- which dealer originated a contract
CREATE OR REPLACE TABLE LINK_CONTRACT_DEALER (
    contract_dealer_hk VARCHAR(32)   NOT NULL,  -- MD5(contract_number || dealer_code)
    contract_hk        VARCHAR(32)   NOT NULL,  -- FK -> HUB_CONTRACT
    dealer_hk          VARCHAR(32)   NOT NULL,  -- FK -> HUB_DEALER
    load_dts           TIMESTAMP_NTZ NOT NULL,
    record_source      STRING        NOT NULL,
    CONSTRAINT pk_link_contract_dealer PRIMARY KEY (contract_dealer_hk)
);

-- LINK_CONTRACT_PAYMENT -- transactional link: payment events vs contract
CREATE OR REPLACE TABLE LINK_CONTRACT_PAYMENT (
    contract_payment_hk VARCHAR(32)   NOT NULL,  -- MD5(payment_id)
    contract_hk         VARCHAR(32)   NOT NULL,  -- FK -> HUB_CONTRACT
    payment_id          STRING        NOT NULL,  -- degenerate key (no Hub of its own)
    load_dts            TIMESTAMP_NTZ NOT NULL,
    record_source       STRING        NOT NULL,
    CONSTRAINT pk_link_contract_payment PRIMARY KEY (contract_payment_hk)
);
