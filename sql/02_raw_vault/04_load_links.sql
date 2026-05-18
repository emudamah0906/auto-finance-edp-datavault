-- ============================================================
-- 02_raw_vault / 04 -- Link loaders (insert-only, idempotent)
-- ============================================================
USE WAREHOUSE EDP_WH;
USE DATABASE  TFS_EDP;
USE SCHEMA    RAW_VAULT;

-- LINK_APPLICATION_CUSTOMER -- source: STG_ORIGINATION_APPLICATIONS
INSERT INTO LINK_APPLICATION_CUSTOMER
       (application_customer_hk, application_hk, customer_hk, load_dts, record_source)
SELECT MD5(application_id || '||' || customer_id),
       MD5(application_id),
       MD5(customer_id),
       CURRENT_TIMESTAMP(), 'ORIGINATION'
FROM (SELECT DISTINCT application_id, customer_id FROM STAGING.STG_ORIGINATION_APPLICATIONS)
WHERE MD5(application_id || '||' || customer_id)
      NOT IN (SELECT application_customer_hk FROM LINK_APPLICATION_CUSTOMER);

-- LINK_APPLICATION_DEALER -- source: STG_ORIGINATION_APPLICATIONS
INSERT INTO LINK_APPLICATION_DEALER
       (application_dealer_hk, application_hk, dealer_hk, load_dts, record_source)
SELECT MD5(application_id || '||' || dealer_code),
       MD5(application_id),
       MD5(dealer_code),
       CURRENT_TIMESTAMP(), 'ORIGINATION'
FROM (SELECT DISTINCT application_id, dealer_code FROM STAGING.STG_ORIGINATION_APPLICATIONS)
WHERE MD5(application_id || '||' || dealer_code)
      NOT IN (SELECT application_dealer_hk FROM LINK_APPLICATION_DEALER);

-- LINK_CONTRACT_CUSTOMER -- source: STG_SERVICING_CONTRACTS
INSERT INTO LINK_CONTRACT_CUSTOMER
       (contract_customer_hk, contract_hk, customer_hk, load_dts, record_source)
SELECT MD5(contract_number || '||' || customer_id),
       MD5(contract_number),
       MD5(customer_id),
       CURRENT_TIMESTAMP(), 'SERVICING'
FROM (SELECT DISTINCT contract_number, customer_id FROM STAGING.STG_SERVICING_CONTRACTS)
WHERE MD5(contract_number || '||' || customer_id)
      NOT IN (SELECT contract_customer_hk FROM LINK_CONTRACT_CUSTOMER);

-- LINK_CONTRACT_VEHICLE -- source: STG_SERVICING_CONTRACTS
INSERT INTO LINK_CONTRACT_VEHICLE
       (contract_vehicle_hk, contract_hk, vehicle_hk, load_dts, record_source)
SELECT MD5(contract_number || '||' || vin),
       MD5(contract_number),
       MD5(vin),
       CURRENT_TIMESTAMP(), 'SERVICING'
FROM (SELECT DISTINCT contract_number, vin FROM STAGING.STG_SERVICING_CONTRACTS)
WHERE MD5(contract_number || '||' || vin)
      NOT IN (SELECT contract_vehicle_hk FROM LINK_CONTRACT_VEHICLE);

-- LINK_CONTRACT_DEALER -- source: STG_SERVICING_CONTRACTS
INSERT INTO LINK_CONTRACT_DEALER
       (contract_dealer_hk, contract_hk, dealer_hk, load_dts, record_source)
SELECT MD5(contract_number || '||' || dealer_code),
       MD5(contract_number),
       MD5(dealer_code),
       CURRENT_TIMESTAMP(), 'SERVICING'
FROM (SELECT DISTINCT contract_number, dealer_code FROM STAGING.STG_SERVICING_CONTRACTS)
WHERE MD5(contract_number || '||' || dealer_code)
      NOT IN (SELECT contract_dealer_hk FROM LINK_CONTRACT_DEALER);

-- LINK_CONTRACT_PAYMENT -- transactional link, source: STG_SERVICING_PAYMENTS
INSERT INTO LINK_CONTRACT_PAYMENT
       (contract_payment_hk, contract_hk, payment_id, load_dts, record_source)
SELECT MD5(payment_id),
       MD5(contract_number),
       payment_id,
       CURRENT_TIMESTAMP(), 'SERVICING'
FROM (SELECT DISTINCT payment_id, contract_number FROM STAGING.STG_SERVICING_PAYMENTS)
WHERE MD5(payment_id)
      NOT IN (SELECT contract_payment_hk FROM LINK_CONTRACT_PAYMENT);

-- Verify row counts
SELECT 'LINK_APPLICATION_CUSTOMER' AS lnk, COUNT(*) AS n FROM LINK_APPLICATION_CUSTOMER
UNION ALL SELECT 'LINK_APPLICATION_DEALER',  COUNT(*) FROM LINK_APPLICATION_DEALER
UNION ALL SELECT 'LINK_CONTRACT_CUSTOMER',   COUNT(*) FROM LINK_CONTRACT_CUSTOMER
UNION ALL SELECT 'LINK_CONTRACT_VEHICLE',    COUNT(*) FROM LINK_CONTRACT_VEHICLE
UNION ALL SELECT 'LINK_CONTRACT_DEALER',     COUNT(*) FROM LINK_CONTRACT_DEALER
UNION ALL SELECT 'LINK_CONTRACT_PAYMENT',    COUNT(*) FROM LINK_CONTRACT_PAYMENT
ORDER BY lnk;