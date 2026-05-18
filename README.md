# TFS EDP — Auto-Finance Data Vault 2.0 on Snowflake

A reference Enterprise Data Platform slice for an auto-finance lender: synthetic
source data flows through a layered warehouse and lands in star-schema marts that
BI can query.

## Architecture

```
data/ (S3 Data Lake)  ->  ODS staging  ->  Raw Vault  ->  Business Vault  ->  Star Schema Marts
   raw source files       source-aligned    Hubs/Links/    PIT + Bridge        dims + facts
                          1:1 with source   Satellites     computed sats       <- BI queries here
```

- **Raw Vault** loads source data exactly as received — no business rules. Insert-only,
  fully auditable (`LOAD_DTS` + `RECORD_SOURCE` on every row).
- **Business Vault** holds derived satellites and PIT/Bridge tables that pre-join Hubs
  to their satellites so the marts don't pay the join cost on every query.
- **Star Schema Marts** are the consumption layer. Data Vault feeds the star schema;
  it does not replace it.

## Domain

Auto-finance lender (modeled on Toyota Financial Services): customers apply for
financing, dealers originate deals, vehicles are collateral, contracts are the booked
loan/lease accounts, payments flow against contracts over the term.

## Data model

| Type | Tables |
|---|---|
| Hubs | `HUB_CUSTOMER`, `HUB_DEALER`, `HUB_VEHICLE`, `HUB_APPLICATION`, `HUB_CONTRACT` |
| Links | `LINK_APPLICATION_CUSTOMER`, `LINK_APPLICATION_DEALER`, `LINK_CONTRACT_CUSTOMER`, `LINK_CONTRACT_VEHICLE`, `LINK_CONTRACT_DEALER`, `LINK_CONTRACT_PAYMENT` |
| Satellites | customer details/credit, dealer details, vehicle details, application details/decision, contract terms/status, payment |

See `docs/data-model.md` for the full design and rationale.

## Layout

| Path | Layer |
|---|---|
| `data/` | Source files (Data Lake landing) |
| `sql/00_setup/` | Database, schemas, warehouse, file formats |
| `sql/01_staging/` | ODS — source-aligned staging |
| `sql/02_raw_vault/` | Raw Vault — Hubs, Links, Satellites |
| `sql/03_business_vault/` | Business Vault — PIT, Bridge, computed sats |
| `sql/04_marts/` | Star Schema marts |
| `docs/adr/` | Architecture decision records |
