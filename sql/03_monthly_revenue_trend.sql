-- ============================================================
-- FILE: 03_monthly_revenue_trend.sql
-- OBJECTIVE:
-- Analyze monthly revenue evolution and revenue growth over time.
--
-- BUSINESS QUESTION:
-- Is revenue growth slowing down over time?
--
-- DATASET:
-- bigquery-public-data.thelook_ecommerce
-- ============================================================

WITH monthly_sales AS (
  SELECT
    DATE_TRUNC(DATE(created_at), MONTH) AS month,
    SUM(sale_price) AS revenue
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  GROUP BY month
),
monthly_comparison AS (
  SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,
    LAG(revenue, 12) OVER (ORDER BY month) AS revenue_prev_year_same_month
  FROM monthly_sales
)
SELECT
  month,
  revenue,
  previous_month_revenue,
  SAFE_DIVIDE(revenue - previous_month_revenue, previous_month_revenue) * 100 AS mom_revenue_growth_pct,
  revenue_prev_year_same_month,
  SAFE_DIVIDE(revenue - revenue_prev_year_same_month, revenue_prev_year_same_month) * 100 AS yoy_revenue_growth_pct
FROM monthly_comparison
ORDER BY month ASC;

-- INTERPRETATION:
-- Revenue shows sustained long-term growth.
-- No clear, persistent slowdown is observed in the available data.
-- YoY growth remains strong after the launch period, with normal volatility.
