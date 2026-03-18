-- ============================================================
-- FILE: 05_monthly_revenue_mix_first_vs_repeat.sql
-- OBJECTIVE:
-- Analyze the monthly revenue mix between first purchases
-- and repeat purchases.
--
-- BUSINESS QUESTION:
-- Is the business becoming more or less dependent on new customers?
--
-- DATASET:
-- bigquery-public-data.thelook_ecommerce
-- ============================================================

WITH order_level AS (
  SELECT
    order_id,
    user_id,
    MIN(created_at) AS order_created_at,
    SUM(sale_price) AS order_revenue
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  GROUP BY order_id, user_id
),
orders_numbered AS (
  SELECT
    order_id,
    user_id,
    order_created_at,
    order_revenue,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_created_at) AS order_number
  FROM order_level
),
orders_labeled AS (
  SELECT
    DATE_TRUNC(DATE(order_created_at), MONTH) AS month,
    CASE
      WHEN order_number = 1 THEN 'FIRST_PURCHASE'
      ELSE 'REPEAT_PURCHASE'
    END AS customer_type,
    order_revenue
  FROM orders_numbered
),
monthly_mix AS (
  SELECT
    month,
    customer_type,
    SUM(order_revenue) AS revenue
  FROM orders_labeled
  GROUP BY month, customer_type
)
SELECT
  month,
  customer_type,
  revenue,
  SUM(revenue) OVER (PARTITION BY month) AS monthly_total_revenue,
  SAFE_DIVIDE(revenue, SUM(revenue) OVER (PARTITION BY month)) AS revenue_share
FROM monthly_mix
ORDER BY month, customer_type;

-- INTERPRETATION:
-- Over time, repeat purchases represent an increasing share of monthly revenue.
-- This suggests that the business is becoming less dependent on first-time purchases
-- and more supported by existing customers.
