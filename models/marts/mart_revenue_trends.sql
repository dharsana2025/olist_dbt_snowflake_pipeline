{{ config(
    materialized='table',
    schema='marts'
) }}

WITH orders AS (
    SELECT * FROM {{ ref('int_orders_enriched') }}
)

SELECT
    DATE_TRUNC('month', ordered_at)         AS order_month,
    customer_state,

    -- volume
    COUNT(DISTINCT order_id)                AS total_orders,
    COUNT(DISTINCT customer_unique_id)      AS unique_customers,

    -- revenue
    ROUND(SUM(total_payment), 2)            AS monthly_gmv,
    ROUND(AVG(total_payment), 2)            AS avg_order_value,

    -- delivery
    ROUND(AVG(actual_delivery_days), 1)     AS avg_delivery_days,
    SUM(CASE WHEN delivery_status = 'Late'
        THEN 1 ELSE 0 END)                  AS late_orders,
    ROUND(
        SUM(CASE WHEN delivery_status = 'Late'
            THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(DISTINCT order_id), 0)
    , 2)                                    AS late_order_pct,

    -- reviews
    ROUND(AVG(review_score), 2)             AS avg_review_score,
    SUM(CASE WHEN review_sentiment = 'Positive'
        THEN 1 ELSE 0 END)                  AS positive_reviews,
    SUM(CASE WHEN review_sentiment = 'Negative'
        THEN 1 ELSE 0 END)                  AS negative_reviews

FROM orders
WHERE order_status  = 'delivered'
  AND ordered_at    IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2