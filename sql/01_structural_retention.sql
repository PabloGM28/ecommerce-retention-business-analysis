01_structural_retention.sql
-- ============================================================
-- FILE: 01_structural_retention.sql
-- OBJECTIVE:
-- Diagnose structural retention by calculating the percentage
-- of one-time customers.
--
-- BUSINESS QUESTION:
-- Is there a structural retention problem?
--
-- HYPOTHESIS (H1):
-- If more than 60% of customers purchase only once,
-- retention is considered structurally weak.
--
-- DATASET:
-- bigquery-public-data.thelook_ecommerce
-- ============================================================

WITH purchases_per_user AS (
  SELECT
    user_id,
    COUNT(order_id) AS purchase_count
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  GROUP BY user_id
),
agg AS (
  SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN purchase_count = 1 THEN 1 ELSE 0 END) AS one_time_customers
  FROM purchases_per_user
)
SELECT
  total_customers,
  one_time_customers,
  SAFE_DIVIDE(one_time_customers, total_customers) AS one_time_customer_rate
FROM agg;

-- RESULT (as of analysis):
-- total_customers = 79,937
-- one_time_customers = 50,173
-- one_time_customer_rate = 0.6277 (62.8%)
--
-- INTERPRETATION:
-- 62.8% of customers purchase only once.
-- This exceeds the internal 60% alert threshold defined for this analysis.
-- However, industry benchmarks for non-luxury fashion e-commerce
-- typically range between 50% and 70%.
--
-- Therefore, while the retention level sits in the upper range
-- of industry standards and suggests limited retention strength,
-- it does not represent a clear structural anomaly.
-- Further dynamic (time-based) analysis is required.
