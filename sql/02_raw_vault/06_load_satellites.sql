-- ============================================================
-- 02_raw_vault / 06 -- Satellite loaders (HASH_DIFF change detection)
-- ============================================================
USE WAREHOUSE EDP_WH;
USE DATABASE  TFS_EDP;
USE SCHEMA    RAW_VAULT;

-- ---- SAT_CUSTOMER_ORIGINATION (standard) ----
INSERT INTO SAT_CUSTOMER_ORIGINATION
       (customer_hk, load_dts, hash_diff, record_source,
        first_name, last_name, date_of_birth, email, phone,
        street_address, city, province, postal_code, credit_score, risk_band)
WITH src AS (
    SELECT MD5(customer_id) AS customer_hk,
           MD5(COALESCE(TO_VARCHAR(first_name),'')||'|'||COALESCE(TO_VARCHAR(last_name),'')||'|'||
               COALESCE(TO_VARCHAR(date_of_birth),'')||'|'||COALESCE(TO_VARCHAR(email),'')||'|'||
               COALESCE(TO_VARCHAR(phone),'')||'|'||COALESCE(TO_VARCHAR(street_address),'')||'|'||
               COALESCE(TO_VARCHAR(city),'')||'|'||COALESCE(TO_VARCHAR(province),'')||'|'||
               COALESCE(TO_VARCHAR(postal_code),'')||'|'||COALESCE(TO_VARCHAR(credit_score),'')||'|'||
               COALESCE(TO_VARCHAR(risk_band),'')) AS hash_diff,
           first_name, last_name, date_of_birth, email, phone,
           street_address, city, province, postal_code, credit_score, risk_band
    FROM STAGING.STG_ORIGINATION_CUSTOMERS
),
cur AS (
    SELECT customer_hk, hash_diff FROM SAT_CUSTOMER_ORIGINATION
    QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_hk ORDER BY load_dts DESC) = 1
)
SELECT src.customer_hk, CURRENT_TIMESTAMP(), src.hash_diff, 'ORIGINATION',
       src.first_name, src.last_name, src.date_of_birth, src.email, src.phone,
       src.street_address, src.city, src.province, src.postal_code, src.credit_score, src.risk_band
FROM src LEFT JOIN cur ON src.customer_hk = cur.customer_hk
WHERE cur.customer_hk IS NULL OR cur.hash_diff <> src.hash_diff;

-- ---- SAT_CUSTOMER_SERVICING (standard) ----
INSERT INTO SAT_CUSTOMER_SERVICING
       (customer_hk, load_dts, hash_diff, record_source,
        first_name, last_name, email, phone,
        mailing_street, mailing_city, mailing_province, mailing_postal_code)
WITH src AS (
    SELECT MD5(customer_id) AS customer_hk,
           MD5(COALESCE(TO_VARCHAR(first_name),'')||'|'||COALESCE(TO_VARCHAR(last_name),'')||'|'||
               COALESCE(TO_VARCHAR(email),'')||'|'||COALESCE(TO_VARCHAR(phone),'')||'|'||
               COALESCE(TO_VARCHAR(mailing_street),'')||'|'||COALESCE(TO_VARCHAR(mailing_city),'')||'|'||
               COALESCE(TO_VARCHAR(mailing_province),'')||'|'||COALESCE(TO_VARCHAR(mailing_postal_code),'')) AS hash_diff,
           first_name, last_name, email, phone,
           mailing_street, mailing_city, mailing_province, mailing_postal_code
    FROM STAGING.STG_SERVICING_CUSTOMERS
),
cur AS (
    SELECT customer_hk, hash_diff FROM SAT_CUSTOMER_SERVICING
    QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_hk ORDER BY load_dts DESC) = 1
)
SELECT src.customer_hk, CURRENT_TIMESTAMP(), src.hash_diff, 'SERVICING',
       src.first_name, src.last_name, src.email, src.phone,
       src.mailing_street, src.mailing_city, src.mailing_province, src.mailing_postal_code
FROM src LEFT JOIN cur ON src.customer_hk = cur.customer_hk
WHERE cur.customer_hk IS NULL OR cur.hash_diff <> src.hash_diff;

-- ---- SAT_DEALER_DETAILS (standard) ----
INSERT INTO SAT_DEALER_DETAILS
       (dealer_hk, load_dts, hash_diff, record_source,
        dealer_name, region, city, province, dealer_status)
WITH src AS (
    SELECT MD5(dealer_code) AS dealer_hk,
           MD5(COALESCE(TO_VARCHAR(dealer_name),'')||'|'||COALESCE(TO_VARCHAR(region),'')||'|'||
               COALESCE(TO_VARCHAR(city),'')||'|'||COALESCE(TO_VARCHAR(province),'')||'|'||
               COALESCE(TO_VARCHAR(dealer_status),'')) AS hash_diff,
           dealer_name, region, city, province, dealer_status
    FROM STAGING.STG_DEALER_DEALERS
),
cur AS (
    SELECT dealer_hk, hash_diff FROM SAT_DEALER_DETAILS
    QUALIFY ROW_NUMBER() OVER (PARTITION BY dealer_hk ORDER BY load_dts DESC) = 1
)
SELECT src.dealer_hk, CURRENT_TIMESTAMP(), src.hash_diff, 'DEALER',
       src.dealer_name, src.region, src.city, src.province, src.dealer_status
FROM src LEFT JOIN cur ON src.dealer_hk = cur.dealer_hk
WHERE cur.dealer_hk IS NULL OR cur.hash_diff <> src.hash_diff;

-- ---- SAT_VEHICLE_DETAILS (standard) ----
INSERT INTO SAT_VEHICLE_DETAILS
       (vehicle_hk, load_dts, hash_diff, record_source,
        make, model, model_year, trim, msrp)
WITH src AS (
    SELECT MD5(vin) AS vehicle_hk,
           MD5(COALESCE(TO_VARCHAR(make),'')||'|'||COALESCE(TO_VARCHAR(model),'')||'|'||
               COALESCE(TO_VARCHAR(model_year),'')||'|'||COALESCE(TO_VARCHAR(trim),'')||'|'||
               COALESCE(TO_VARCHAR(msrp),'')) AS hash_diff,
           make, model, model_year, trim, msrp
    FROM STAGING.STG_DEALER_VEHICLES
),
cur AS (
    SELECT vehicle_hk, hash_diff FROM SAT_VEHICLE_DETAILS
    QUALIFY ROW_NUMBER() OVER (PARTITION BY vehicle_hk ORDER BY load_dts DESC) = 1
)
SELECT src.vehicle_hk, CURRENT_TIMESTAMP(), src.hash_diff, 'DEALER',
       src.make, src.model, src.model_year, src.trim, src.msrp
FROM src LEFT JOIN cur ON src.vehicle_hk = cur.vehicle_hk
WHERE cur.vehicle_hk IS NULL OR cur.hash_diff <> src.hash_diff;

-- ---- SAT_APPLICATION_DETAILS (standard) ----
INSERT INTO SAT_APPLICATION_DETAILS
       (application_hk, load_dts, hash_diff, record_source,
        product_type, requested_amount, application_date, channel)
WITH src AS (
    SELECT MD5(application_id) AS application_hk,
           MD5(COALESCE(TO_VARCHAR(product_type),'')||'|'||COALESCE(TO_VARCHAR(requested_amount),'')||'|'||
               COALESCE(TO_VARCHAR(application_date),'')||'|'||COALESCE(TO_VARCHAR(channel),'')) AS hash_diff,
           product_type, requested_amount, application_date, channel
    FROM STAGING.STG_ORIGINATION_APPLICATIONS
),
cur AS (
    SELECT application_hk, hash_diff FROM SAT_APPLICATION_DETAILS
    QUALIFY ROW_NUMBER() OVER (PARTITION BY application_hk ORDER BY load_dts DESC) = 1
)
SELECT src.application_hk, CURRENT_TIMESTAMP(), src.hash_diff, 'ORIGINATION',
       src.product_type, src.requested_amount, src.application_date, src.channel
FROM src LEFT JOIN cur ON src.application_hk = cur.application_hk
WHERE cur.application_hk IS NULL OR cur.hash_diff <> src.hash_diff;

-- ---- SAT_APPLICATION_DECISION (standard) ----
INSERT INTO SAT_APPLICATION_DECISION
       (application_hk, load_dts, hash_diff, record_source,
        credit_decision, approved_amount, decision_date)
WITH src AS (
    SELECT MD5(application_id) AS application_hk,
           MD5(COALESCE(TO_VARCHAR(credit_decision),'')||'|'||COALESCE(TO_VARCHAR(approved_amount),'')||'|'||
               COALESCE(TO_VARCHAR(decision_date),'')) AS hash_diff,
           credit_decision, approved_amount, decision_date
    FROM STAGING.STG_ORIGINATION_APPLICATIONS
),
cur AS (
    SELECT application_hk, hash_diff FROM SAT_APPLICATION_DECISION
    QUALIFY ROW_NUMBER() OVER (PARTITION BY application_hk ORDER BY load_dts DESC) = 1
)
SELECT src.application_hk, CURRENT_TIMESTAMP(), src.hash_diff, 'ORIGINATION',
       src.credit_decision, src.approved_amount, src.decision_date
FROM src LEFT JOIN cur ON src.application_hk = cur.application_hk
WHERE cur.application_hk IS NULL OR cur.hash_diff <> src.hash_diff;

-- ---- SAT_CONTRACT_TERMS (standard) ----
INSERT INTO SAT_CONTRACT_TERMS
       (contract_hk, load_dts, hash_diff, record_source,
        contract_type, apr, term_months, amount_financed, residual_value, start_date, maturity_date)
WITH src AS (
    SELECT MD5(contract_number) AS contract_hk,
           MD5(COALESCE(TO_VARCHAR(contract_type),'')||'|'||COALESCE(TO_VARCHAR(apr),'')||'|'||
               COALESCE(TO_VARCHAR(term_months),'')||'|'||COALESCE(TO_VARCHAR(amount_financed),'')||'|'||
               COALESCE(TO_VARCHAR(residual_value),'')||'|'||COALESCE(TO_VARCHAR(start_date),'')||'|'||
               COALESCE(TO_VARCHAR(maturity_date),'')) AS hash_diff,
           contract_type, apr, term_months, amount_financed, residual_value, start_date, maturity_date
    FROM STAGING.STG_SERVICING_CONTRACTS
),
cur AS (
    SELECT contract_hk, hash_diff FROM SAT_CONTRACT_TERMS
    QUALIFY ROW_NUMBER() OVER (PARTITION BY contract_hk ORDER BY load_dts DESC) = 1
)
SELECT src.contract_hk, CURRENT_TIMESTAMP(), src.hash_diff, 'SERVICING',
       src.contract_type, src.apr, src.term_months, src.amount_financed,
       src.residual_value, src.start_date, src.maturity_date
FROM src LEFT JOIN cur ON src.contract_hk = cur.contract_hk
WHERE cur.contract_hk IS NULL OR cur.hash_diff <> src.hash_diff;

-- ---- SAT_CONTRACT_STATUS (snapshot: insert any new contract_hk + status_date) ----
INSERT INTO SAT_CONTRACT_STATUS
       (contract_hk, status_date, load_dts, hash_diff, record_source,
        contract_status, delinquency_bucket, outstanding_balance)
SELECT MD5(s.contract_number), s.status_date, CURRENT_TIMESTAMP(),
       MD5(COALESCE(TO_VARCHAR(s.contract_status),'')||'|'||COALESCE(TO_VARCHAR(s.delinquency_bucket),'')||'|'||
           COALESCE(TO_VARCHAR(s.outstanding_balance),'')),
       'SERVICING', s.contract_status, s.delinquency_bucket, s.outstanding_balance
FROM STAGING.STG_SERVICING_CONTRACT_STATUS s
WHERE NOT EXISTS (
    SELECT 1 FROM SAT_CONTRACT_STATUS t
    WHERE t.contract_hk = MD5(s.contract_number) AND t.status_date = s.status_date
);

-- ---- SAT_PAYMENT (non-historized: insert any new payment key) ----
INSERT INTO SAT_PAYMENT
       (contract_payment_hk, load_dts, hash_diff, record_source,
        payment_date, payment_amount, payment_method)
SELECT MD5(s.payment_id), CURRENT_TIMESTAMP(),
       MD5(COALESCE(TO_VARCHAR(s.payment_date),'')||'|'||COALESCE(TO_VARCHAR(s.payment_amount),'')||'|'||
           COALESCE(TO_VARCHAR(s.payment_method),'')),
       'SERVICING', s.payment_date, s.payment_amount, s.payment_method
FROM STAGING.STG_SERVICING_PAYMENTS s
WHERE MD5(s.payment_id) NOT IN (SELECT contract_payment_hk FROM SAT_PAYMENT);

-- Verify row counts
SELECT 'SAT_CUSTOMER_ORIGINATION' AS sat, COUNT(*) AS n FROM SAT_CUSTOMER_ORIGINATION
UNION ALL SELECT 'SAT_CUSTOMER_SERVICING',  COUNT(*) FROM SAT_CUSTOMER_SERVICING
UNION ALL SELECT 'SAT_DEALER_DETAILS',      COUNT(*) FROM SAT_DEALER_DETAILS
UNION ALL SELECT 'SAT_VEHICLE_DETAILS',     COUNT(*) FROM SAT_VEHICLE_DETAILS
UNION ALL SELECT 'SAT_APPLICATION_DETAILS', COUNT(*) FROM SAT_APPLICATION_DETAILS
UNION ALL SELECT 'SAT_APPLICATION_DECISION',COUNT(*) FROM SAT_APPLICATION_DECISION
UNION ALL SELECT 'SAT_CONTRACT_TERMS',      COUNT(*) FROM SAT_CONTRACT_TERMS
UNION ALL SELECT 'SAT_CONTRACT_STATUS',     COUNT(*) FROM SAT_CONTRACT_STATUS
UNION ALL SELECT 'SAT_PAYMENT',             COUNT(*) FROM SAT_PAYMENT
ORDER BY sat;