-- ============================================================
-- FILE: 06_customer_ltv_by_type.sql
-- OBJECTIVE:
-- Estimate customer lifetime value (LTV) by customer type.
--
-- BUSINESS QUESTION:
-- Do repeat customers generate significantly more value
-- than one-time customers?
--
-- DATASET:
-- bigquery-public-data.thelook_ecommerce
-- ============================================================

WITH customer_revenue AS (
  SELECT
    user_id,
    COUNT(DISTINCT order_id) AS orders_per_user,
    SUM(sale_price) AS revenue_per_user
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  GROUP BY user_id
),
customer_base AS (
  SELECT
    user_id,
    revenue_per_user,
    CASE
      WHEN orders_per_user = 1 THEN 'ONE_TIME'
      ELSE 'REPEAT'
    END AS customer_type
  FROM customer_revenue
)
SELECT
  customer_type,
  COUNT(*) AS num_users,
  ROUND(AVG(revenue_per_user), 2) AS ltv
FROM customer_base
GROUP BY customer_type
ORDER BY customer_type;

-- RESULT (as of analysis):
-- ONE_TIME:
--   num_users = 50,003
--   ltv       = 86.99
--
-- REPEAT:
--   num_users = 30,016
--   ltv       = 217.12
--
-- INTERPRETATION:
-- Repeat customers generate approximately 2.5x more value
-- than one-time customers, confirming that retention is
-- economically valuable for the business.
