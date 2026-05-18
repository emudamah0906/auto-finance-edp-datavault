-- ============================================================
-- 02_raw_vault / 01 -- Hubs (unique business keys)
-- ============================================================
USE WAREHOUSE EDP_WH;
USE DATABASE  TFS_EDP;
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