-- =============================================================================
-- 00_setup / 01 -- Warehouse, database, and layer schemas
-- Run:  snow sql -c edp -f sql/00_setup/01_warehouse_db_schemas.sql
-- =============================================================================

-- 1. Dedicated warehouse for EDP workloads -----------------------------------
--    A separate warehouse (not the shared COMPUTE_WH) isolates this project's
--    compute so its cost and performance are attributable on their own.
CREATE WAREHOUSE IF NOT EXISTS EDP_WH
    WAREHOUSE_SIZE      = 'XSMALL'   -- smallest = cheapest; plenty for this data volume
    AUTO_SUSPEND       = 60          -- park the warehouse after 60s idle (credit control)
    AUTO_RESUME        = TRUE        -- wake automatically on the next query
    INITIALLY_SUSPENDED = TRUE       -- don't burn credits the moment it's created
    COMMENT = 'Compute for the TFS auto-finance Enterprise Data Platform';

-- 2. The EDP database ---------------------------------------------------------
CREATE DATABASE IF NOT EXISTS TFS_EDP
    COMMENT = 'Auto-finance Enterprise Data Platform (Data Vault 2.0)';

USE DATABASE TFS_EDP;

-- 3. One schema per pipeline layer -------------------------------------------
--    Schemas, not databases, per layer: same DB keeps cross-layer joins cheap
--    and permissions simple, while schemas still give a clean security boundary.
CREATE SCHEMA IF NOT EXISTS STAGING
    COMMENT = 'ODS -- source-aligned landing tables, 1:1 with source extracts';

CREATE SCHEMA IF NOT EXISTS RAW_VAULT
    COMMENT = 'Raw Vault -- Hubs, Links, Satellites loaded as-is, no business rules';

CREATE SCHEMA IF NOT EXISTS BUSINESS_VAULT
    COMMENT = 'Business Vault -- computed satellites, PIT and Bridge tables';

CREATE SCHEMA IF NOT EXISTS MARTS
    COMMENT = 'Star Schema marts -- dimensions and facts for BI consumption';

-- 4. Show what we built -------------------------------------------------------
SHOW SCHEMAS IN DATABASE TFS_EDP;
