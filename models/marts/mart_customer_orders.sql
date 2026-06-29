{{ config(
    materialized='table',
    schema='marts'
) }}
WITH orders AS (
    SELECT * FROM {{ ref('int_orders_enriched') }}
)

SELECT
    customer_unique_id,
    customer_city,
    customer_state,

    -- order metrics
    COUNT(DISTINCT order_id)                        AS total_orders,
    MIN(ordered_at)                                 AS first_order_date,
    MAX(ordered_at)                                 AS last_order_date,
    DATEDIFF('day',
        MIN(ordered_at),
        MAX(ordered_at))                            AS customer_tenure_days,

    -- revenue metrics
    ROUND(SUM(total_payment), 2)                    AS lifetime_value,
    ROUND(AVG(total_payment), 2)                    AS avg_order_value,
    ROUND(MAX(total_payment), 2)                    AS max_order_value,

    -- delivery metrics
    ROUND(AVG(actual_delivery_days), 1)             AS avg_delivery_days,
    ROUND(AVG(delivery_delay_days), 1)              AS avg_delay_days,
    SUM(CASE WHEN delivery_status = 'Late'
        THEN 1 ELSE 0 END)                          AS late_deliveries,

    -- review metrics
    ROUND(AVG(review_score), 2)                     AS avg_review_score,
    SUM(CASE WHEN review_sentiment = 'Positive'
        THEN 1 ELSE 0 END)                          AS positive_reviews,
    SUM(CASE WHEN review_sentiment = 'Negative'
        THEN 1 ELSE 0 END)                          AS negative_reviews,

    -- customer segmentation
    CASE
        WHEN COUNT(DISTINCT order_id) = 1  THEN 'One-time'
        WHEN COUNT(DISTINCT order_id) <= 3 THEN 'Occasional'
        ELSE 'Loyal'
    END                                             AS customer_segment,

    -- RFM recency flag
    CASE
        WHEN MAX(ordered_at) >= DATEADD('month', -3,
            (SELECT MAX(ordered_at) FROM orders))   THEN 'Active'
        WHEN MAX(ordered_at) >= DATEADD('month', -6,
            (SELECT MAX(ordered_at) FROM orders))   THEN 'At Risk'
        ELSE 'Churned'
    END                                             AS recency_segment

FROM orders
WHERE order_status = 'delivered'
GROUP BY 1, 2, 3