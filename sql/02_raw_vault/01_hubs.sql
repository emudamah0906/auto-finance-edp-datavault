-- ============================================================
-- 02_raw_vault / 01 -- Hubs
--
-- A Hub is the simplest Data Vault table. It's just a unique list
-- of the business keys for one concept -- one row per customer,
-- per dealer, etc. Nothing descriptive lives here.
--
-- Every Hub has the same 4 columns:
--   <entity>_hk   -- the hash key = MD5(business key). My primary key.
--   <business key>-- the natural key from the source system
--   load_dts      -- when this key first showed up in the vault
--   record_source -- which source system first sent it
--
-- WHY a hash key instead of an auto-number? It's deterministic --
-- the same customer_id always hashes to the same value. So I can
-- build hubs, links and satellites in parallel without waiting on
-- a central key-lookup. That's the whole point of Data Vault 2.0.
--
-- Note: the MD5() isn't here -- this file only defines the empty
-- shape. The hashing happens in the loader (02_load_hubs.sql).
-- ============================================================
USE WAREHOUSE EDP_WH;
USE DATABASE  AUTO_FINANCE_EDP;
USE SCHEMA    RAW_VAULT;

-- HUB_CUSTOMER -- business key: customer_id
CREATE OR REPLACE TABLE HUB_CUSTOMER (
    customer_hk   VARCHAR(32)   NOT NULL,   -- MD5(customer_id)
    customer_id   STRING        NOT NULL,   -- business key
    load_dts      TIMESTAMP_NTZ NOT NULL,
    record_source STRING        NOT NULL,
    CONSTRAINT pk_hub_customer PRIMARY KEY (customer_hk)
);

-- HUB_DEALER -- business key: dealer_code
CREATE OR REPLACE TABLE HUB_DEALER (
    dealer_hk     VARCHAR(32)   NOT NULL,   -- MD5(dealer_code)
    dealer_code   STRING        NOT NULL,   -- business key
    load_dts      TIMESTAMP_NTZ NOT NULL,
    record_source STRING        NOT NULL,
    CONSTRAINT pk_hub_dealer PRIMARY KEY (dealer_hk)
);

-- HUB_VEHICLE -- business key: vin
CREATE OR REPLACE TABLE HUB_VEHICLE (
    vehicle_hk    VARCHAR(32)   NOT NULL,   -- MD5(vin)
    vin           STRING        NOT NULL,   -- business key
    load_dts      TIMESTAMP_NTZ NOT NULL,
    record_source STRING        NOT NULL,
    CONSTRAINT pk_hub_vehicle PRIMARY KEY (vehicle_hk)
);

-- HUB_APPLICATION -- business key: application_id
CREATE OR REPLACE TABLE HUB_APPLICATION (
    application_hk VARCHAR(32)   NOT NULL,   -- MD5(application_id)
    application_id STRING        NOT NULL,   -- business key
    load_dts       TIMESTAMP_NTZ NOT NULL,
    record_source  STRING        NOT NULL,
    CONSTRAINT pk_hub_application PRIMARY KEY (application_hk)
);

-- HUB_CONTRACT -- business key: contract_number
CREATE OR REPLACE TABLE HUB_CONTRACT (
    contract_hk     VARCHAR(32)   NOT NULL,   -- MD5(contract_number)
    contract_number STRING        NOT NULL,   -- business key
    load_dts        TIMESTAMP_NTZ NOT NULL,
    record_source   STRING        NOT NULL,
    CONSTRAINT pk_hub_contract PRIMARY KEY (contract_hk)
);
