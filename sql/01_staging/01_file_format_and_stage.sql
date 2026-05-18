-- ============================================================
-- 01_staging / 01 -- File format + internal stage
--
-- Before I can load a single CSV, I need two reusable objects:
--   1. a FILE FORMAT -- tells Snowflake HOW to read a CSV
--   2. a STAGE       -- a spot inside Snowflake to drop the files
-- ============================================================
USE WAREHOUSE EDP_WH;
USE DATABASE  AUTO_FINANCE_EDP;
USE SCHEMA    STAGING;

-- The file format. I write the CSV parsing rules ONCE here, as a named
-- object, instead of repeating them on every COPY command later.
CREATE OR REPLACE FILE FORMAT CSV_FF
    TYPE = 'CSV'
    FIELD_DELIMITER = ','                  -- columns are separated by commas
    SKIP_HEADER = 1                        -- row 1 is column names -- skip it, it's not data
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'     -- a value containing a comma is wrapped in quotes
    NULL_IF = ('NULL', 'null', '')         -- treat these literal strings as NULL
    EMPTY_FIELD_AS_NULL = TRUE             -- an empty cell becomes NULL, not an empty string
    TRIM_SPACE = TRUE                      -- strip stray spaces around values
    COMMENT = 'CSV parsing rules for source data files';

-- The stage. This is the landing zone INSIDE Snowflake -- I upload my
-- local CSVs here first, then COPY from here into tables. In a real
-- platform this would be an EXTERNAL stage pointing at an S3 bucket;
-- the rest of the pipeline wouldn't change.
CREATE STAGE IF NOT EXISTS EDP_STAGE
    FILE_FORMAT = CSV_FF
    COMMENT = 'Internal stage -- landing zone for source CSV files';
