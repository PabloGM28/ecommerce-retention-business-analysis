-- ============================================================
-- FILE: 04_return_rate_analysis.sql
-- OBJECTIVE:
-- Measure revenue quality through the monthly return rate.
--
-- BUSINESS QUESTION:
-- Is revenue quality deteriorating over time due to increasing returns?
--
-- DATASET:
-- bigquery-public-data.thelook_ecommerce
-- ============================================================

WITH added_revenues AS (
  SELECT
    DATE_TRUNC(DATE(created_at), MONTH) AS month,
    SUM(sale_price) AS monthly_revenue,
    SUM(CASE WHEN returned_at IS NOT NULL THEN sale_price ELSE 0 END) AS returned_revenue
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  GROUP BY month
)
SELECT
  month,
  monthly_revenue,
  returned_revenue,
  SAFE_DIVIDE(returned_revenue, monthly_revenue) AS return_rate
FROM added_revenues
ORDER BY month;

-- INTERPRETATION:
-- The monthly return rate remains broadly stable over time,
-- fluctuating around typical levels for e-commerce.
-- No clear deterioration in revenue quality is observed.
