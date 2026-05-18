-- ============================================================
-- 01_staging / 03 -- Load the stage files into the staging tables
--
-- This is the actual ingestion step. I use the "transform" form of
-- COPY -- COPY INTO <table> FROM (SELECT ... FROM @stage/file) -- so I
-- can add two columns the CSV doesn't have:
--   METADATA$FILENAME   -> _SOURCE_FILE  (which file the row came from)
--   CURRENT_TIMESTAMP() -> _LOAD_TS      (when I loaded it)
-- That's my data lineage, captured right at the front door.
--
-- $1,$2,... are the CSV's columns BY POSITION. ON_ERROR = ABORT_STATEMENT
-- means a single bad row fails the whole load -- I never want a
-- half-loaded table in a regulated finance dataset.
-- ============================================================
USE WAREHOUSE EDP_WH;
USE DATABASE  AUTO_FINANCE_EDP;
USE SCHEMA    STAGING;

-- DEALER source --------------------------------------------------------
COPY INTO STG_DEALER_DEALERS
FROM (SELECT $1,$2,$3,$4,$5,$6, METADATA$FILENAME, CURRENT_TIMESTAMP()
      FROM @EDP_STAGE/dealer_dealers.csv)
FILE_FORMAT = (FORMAT_NAME = CSV_FF) ON_ERROR = ABORT_STATEMENT;

COPY INTO STG_DEALER_VEHICLES
FROM (SELECT $1,$2,$3,$4,$5,$6, METADATA$FILENAME, CURRENT_TIMESTAMP()
      FROM @EDP_STAGE/dealer_vehicles.csv)
FILE_FORMAT = (FORMAT_NAME = CSV_FF) ON_ERROR = ABORT_STATEMENT;

-- ORIGINATION source ---------------------------------------------------
COPY INTO STG_ORIGINATION_CUSTOMERS
FROM (SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13, METADATA$FILENAME, CURRENT_TIMESTAMP()
      FROM @EDP_STAGE/origination_customers.csv)
FILE_FORMAT = (FORMAT_NAME = CSV_FF) ON_ERROR = ABORT_STATEMENT;

COPY INTO STG_ORIGINATION_APPLICATIONS
FROM (SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11, METADATA$FILENAME, CURRENT_TIMESTAMP()
      FROM @EDP_STAGE/origination_applications.csv)
FILE_FORMAT = (FORMAT_NAME = CSV_FF) ON_ERROR = ABORT_STATEMENT;

-- SERVICING source -----------------------------------------------------
COPY INTO STG_SERVICING_CONTRACTS
FROM (SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12, METADATA$FILENAME, CURRENT_TIMESTAMP()
      FROM @EDP_STAGE/servicing_contracts.csv)
FILE_FORMAT = (FORMAT_NAME = CSV_FF) ON_ERROR = ABORT_STATEMENT;

COPY INTO STG_SERVICING_CUSTOMERS
FROM (SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10, METADATA$FILENAME, CURRENT_TIMESTAMP()
      FROM @EDP_STAGE/servicing_customers.csv)
FILE_FORMAT = (FORMAT_NAME = CSV_FF) ON_ERROR = ABORT_STATEMENT;

COPY INTO STG_SERVICING_CONTRACT_STATUS
FROM (SELECT $1,$2,$3,$4,$5, METADATA$FILENAME, CURRENT_TIMESTAMP()
      FROM @EDP_STAGE/servicing_contract_status.csv)
FILE_FORMAT = (FORMAT_NAME = CSV_FF) ON_ERROR = ABORT_STATEMENT;

COPY INTO STG_SERVICING_PAYMENTS
FROM (SELECT $1,$2,$3,$4,$5, METADATA$FILENAME, CURRENT_TIMESTAMP()
      FROM @EDP_STAGE/servicing_payments.csv)
FILE_FORMAT = (FORMAT_NAME = CSV_FF) ON_ERROR = ABORT_STATEMENT;
