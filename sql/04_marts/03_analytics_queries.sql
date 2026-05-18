-- ============================================================
-- 04_marts / 03 -- Analytics queries against the star schema
-- ============================================================
USE WAREHOUSE EDP_WH;
USE DATABASE  TFS_EDP;
USE SCHEMA    MARTS;

-- Q1: Payment collections by dealer region
SELECT d.region,
       COUNT(*)                        AS payments,
       ROUND(SUM(f.payment_amount), 2) AS total_collected
FROM FACT_PAYMENT f
JOIN DIM_DEALER d ON d.dealer_key = f.dealer_key
GROUP BY d.region
ORDER BY total_collected DESC;

-- Q2: Top 10 vehicle models by collections
SELECT v.make, v.model,
       COUNT(*)                        AS payments,
       ROUND(SUM(f.payment_amount), 2) AS total_collected
FROM FACT_PAYMENT f
JOIN DIM_VEHICLE v ON v.vehicle_key = f.vehicle_key
GROUP BY v.make, v.model
ORDER BY total_collected DESC
LIMIT 10;

-- Q3: Monthly payment trend
SELECT dt.year, dt.month, dt.month_name,
       COUNT(*)                        AS payments,
       ROUND(SUM(f.payment_amount), 2) AS total_collected
FROM FACT_PAYMENT f
JOIN DIM_DATE dt ON dt.date_key = f.date_key
GROUP BY dt.year, dt.month, dt.month_name
ORDER BY dt.year, dt.month;

-- Q4: Collections by customer risk band
SELECT c.risk_band,
       COUNT(*)                        AS payments,
       ROUND(SUM(f.payment_amount), 2) AS total_collected,
       ROUND(AVG(f.payment_amount), 2) AS avg_payment
FROM FACT_PAYMENT f
JOIN DIM_CUSTOMER c ON c.customer_key = f.customer_key
GROUP BY c.risk_band
ORDER BY total_collected DESC;