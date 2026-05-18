# Auto-Finance EDP — Data Vault 2.0 on Snowflake

A reference **Enterprise Data Platform** for an auto-finance lender, built on
Snowflake. Synthetic source data from three operational systems flows through a
layered warehouse — Data Vault 2.0 for integration, Star Schema for consumption.

## Architecture

```
data/ (Data Lake)  ->  Staging / ODS  ->  Raw Vault  ->  Business Vault  ->  Star Schema Marts
  raw CSV files        source-aligned     Hubs/Links/    PIT tables          dims + fact
                       1:1 with source    Satellites                         <- BI queries here
```

- **Staging (ODS)** — each source file mirrored 1:1 into Snowflake, no business logic.
- **Raw Vault** — source data loaded exactly as received. Insert-only and fully
  auditable: every row carries `LOAD_DTS` + `RECORD_SOURCE`. Hash keys (`MD5`) let
  Hubs, Links and Satellites load in parallel and make every loader idempotent.
- **Business Vault** — `PIT` (Point-In-Time) tables that pre-resolve "current satellite
  version" so the marts skip that work. Pure performance, fully rebuildable.
- **Star Schema Marts** — denormalized dimensions + fact table for BI. Data Vault
  *feeds* the star schema; it does not replace it.

## Domain

An auto-finance lender: customers apply for financing, dealers originate deals,
vehicles are the collateral, contracts are the booked loan/lease accounts, and
payments flow against contracts over the term. Three simulated source systems —
**origination**, **servicing**, and **dealer** — are integrated in the vault.

## Data model

| Type | Tables |
|---|---|
| Hubs (5) | `HUB_CUSTOMER`, `HUB_DEALER`, `HUB_VEHICLE`, `HUB_APPLICATION`, `HUB_CONTRACT` |
| Links (6) | `LINK_APPLICATION_CUSTOMER`, `LINK_APPLICATION_DEALER`, `LINK_CONTRACT_CUSTOMER`, `LINK_CONTRACT_VEHICLE`, `LINK_CONTRACT_DEALER`, `LINK_CONTRACT_PAYMENT` |
| Satellites (9) | `SAT_CUSTOMER_ORIGINATION`, `SAT_CUSTOMER_SERVICING`, `SAT_DEALER_DETAILS`, `SAT_VEHICLE_DETAILS`, `SAT_APPLICATION_DETAILS`, `SAT_APPLICATION_DECISION`, `SAT_CONTRACT_TERMS`, `SAT_CONTRACT_STATUS`, `SAT_PAYMENT` |
| Marts | `DIM_DATE`, `DIM_CUSTOMER`, `DIM_DEALER`, `DIM_VEHICLE`, `FACT_PAYMENT` |

`SAT_CUSTOMER_ORIGINATION` / `SAT_CUSTOMER_SERVICING` show satellites split by
**source system**; `SAT_CONTRACT_TERMS` / `SAT_CONTRACT_STATUS` show satellites
split by **rate of change**.

## How to run

Built with the Snowflake CLI (`snow`). Run the SQL files in numbered order:

```bash
python3 data/generate_source_data.py                       # generate source CSVs
snow sql -c <conn> -f sql/00_setup/01_warehouse_db_schemas.sql
snow sql -c <conn> -f sql/01_staging/01_file_format_and_stage.sql
snow stage copy "data/*.csv" "@AUTO_FINANCE_EDP.STAGING.EDP_STAGE" -c <conn>
snow sql -c <conn> -f sql/01_staging/02_staging_tables.sql
# ... continue through 01_staging, 02_raw_vault, 03_business_vault, 04_marts
```

## Layout

| Path | Layer |
|---|---|
| `data/` | Source CSV generator + files (Data Lake landing) |
| `sql/00_setup/` | Warehouse, database, layer schemas |
| `sql/01_staging/` | Staging / ODS — file format, stage, COPY INTO |
| `sql/02_raw_vault/` | Raw Vault — Hubs, Links, Satellites + loaders |
| `sql/03_business_vault/` | Business Vault — PIT table |
| `sql/04_marts/` | Star Schema marts — dimensions, fact, analytics |

## Tech

Snowflake · SQL · Data Vault 2.0 · Star Schema · Python (synthetic data)
