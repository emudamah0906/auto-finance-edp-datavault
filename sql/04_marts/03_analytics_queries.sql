-- ============================================================
-- 04_marts / 03 -- Analytics queries against the star schema
--
-- This is the payoff. Each query is a simple star-schema join:
-- the fact table in the middle, a dimension joined on its key.
-- No vault hash keys, no "latest version" logic -- the marts made
-- the data easy to read. This is what a BI tool or analyst runs.
-- ============================================================
USE WAREHOUSE EDP_WH;
USE DATABASE  AUTO_FINANCE_EDP;
USE SCHEMA    MARTS;

-- Q1: How much are we collecting, by dealer region?
SELECT d.region,
       COUNT(*)                        AS payments,
       ROUND(SUM(f.payment_amount), 2) AS total_collected
FROM FACT_PAYMENT f
JOIN DIM_DEALER d ON d.dealer_key = f.dealer_key
GROUP BY d.region
ORDER BY total_collected DESC;

-- Q2: Which vehicle models drive the most collections? (top 10)
SELECT v.make, v.model,
       COUNT(*)                        AS payments,
       ROUND(SUM(f.payment_amount), 2) AS total_collected
FROM FACT_PAYMENT f
JOIN DIM_VEHICLE v ON v.vehicle_key = f.vehicle_key
GROUP BY v.make, v.model
ORDER BY total_collected DESC
LIMIT 10;

-- Q3: Payment trend month by month.
SELECT dt.year, dt.month, dt.month_name,
       COUNT(*)                        AS payments,
       ROUND(SUM(f.payment_amount), 2) AS total_collected
FROM FACT_PAYMENT f
JOIN DIM_DATE dt ON dt.date_key = f.date_key
GROUP BY dt.year, dt.month, dt.month_name
ORDER BY dt.year, dt.month;

-- Q4: Collections split by customer credit risk band.
SELECT c.risk_band,
       COUNT(*)                        AS payments,
       ROUND(SUM(f.payment_amount), 2) AS total_collected,
       ROUND(AVG(f.payment_amount), 2) AS avg_payment
FROM FACT_PAYMENT f
JOIN DIM_CUSTOMER c ON c.customer_key = f.customer_key
GROUP BY c.risk_band
ORDER BY total_collected DESC;
