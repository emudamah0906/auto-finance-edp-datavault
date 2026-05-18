-- ============================================================
-- 00_setup / 01 -- Warehouse, database and the layer schemas
--
-- This is the first script I run. Before touching any data I need
-- somewhere to store it (a database + schemas) and something to
-- process it (a warehouse).
--   Run me:  snow sql -c edp -f sql/00_setup/01_warehouse_db_schemas.sql
-- ============================================================

-- STEP 1 -- a warehouse just for this project.
-- In Snowflake a "warehouse" is the compute engine: it runs the queries
-- and it's billed per second it's awake. I create a dedicated one instead
-- of reusing the shared COMPUTE_WH so this project's cost stands on its
-- own, and a heavy query here can't slow down anyone else.
CREATE WAREHOUSE IF NOT EXISTS EDP_WH
    WAREHOUSE_SIZE      = 'XSMALL'    -- smallest size -- my data is small, no reason to pay more
    AUTO_SUSPEND        = 60          -- idle for 60s? switch it off so I stop being billed
    AUTO_RESUME         = TRUE        -- switch back on automatically on the next query
    INITIALLY_SUSPENDED = TRUE        -- don't start it (and bill me) the second it's created
    COMMENT = 'Compute for the auto-finance Enterprise Data Platform';

-- STEP 2 -- the database. This is just the container that will hold
-- every table in the project.
CREATE DATABASE IF NOT EXISTS AUTO_FINANCE_EDP
    COMMENT = 'Auto-finance Enterprise Data Platform (Data Vault 2.0)';

USE DATABASE AUTO_FINANCE_EDP;

-- STEP 3 -- one schema per layer of the pipeline.
-- My data flows through 4 stages, so each stage gets its own schema. I use
-- schemas (not separate databases) because they keep cross-layer joins
-- simple while still drawing a clean line between raw and finished data.
CREATE SCHEMA IF NOT EXISTS STAGING          -- raw files land here, copied 1:1 from source
    COMMENT = 'ODS -- source-aligned landing tables, 1:1 with source extracts';

CREATE SCHEMA IF NOT EXISTS RAW_VAULT        -- the Data Vault itself: hubs, links, satellites
    COMMENT = 'Raw Vault -- Hubs, Links, Satellites loaded as-is, no business rules';

CREATE SCHEMA IF NOT EXISTS BUSINESS_VAULT   -- helper tables that make the vault fast to query
    COMMENT = 'Business Vault -- computed satellites, PIT and Bridge tables';

CREATE SCHEMA IF NOT EXISTS MARTS            -- the star schema the BI tools actually read
    COMMENT = 'Star Schema marts -- dimensions and facts for BI consumption';

-- Quick check -- list what I just created.
SHOW SCHEMAS IN DATABASE AUTO_FINANCE_EDP;
