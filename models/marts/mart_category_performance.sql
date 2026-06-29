{{ config(
    materialized='table',
    schema='marts'
) }}


WITH products AS (
    SELECT * FROM {{ ref('int_product_enriched') }}
),

orders AS (
    SELECT
        order_id,
        order_status,
        ordered_at,
        review_score,
        review_sentiment
    FROM {{ ref('int_orders_enriched') }}
)

SELECT
    p.category_name_english,

    -- volume metrics
    COUNT(DISTINCT p.order_id)              AS total_orders,
    COUNT(p.order_item_id)                  AS total_items_sold,
    COUNT(DISTINCT p.product_id)            AS unique_products,

    -- revenue metrics
    ROUND(SUM(p.price), 2)                  AS gross_revenue,
    ROUND(AVG(p.price), 2)                  AS avg_item_price,
    ROUND(MIN(p.price), 2)                  AS min_price,
    ROUND(MAX(p.price), 2)                  AS max_price,

    -- freight metrics
    ROUND(SUM(p.freight_value), 2)          AS total_freight,
    ROUND(AVG(p.freight_pct_of_price), 2)   AS avg_freight_pct,

    -- review metrics
    ROUND(AVG(o.review_score), 2)           AS avg_review_score,
    SUM(CASE WHEN o.review_sentiment = 'Positive'
        THEN 1 ELSE 0 END)                  AS positive_reviews,
    SUM(CASE WHEN o.review_sentiment = 'Negative'
        THEN 1 ELSE 0 END)                  AS negative_reviews,

    -- product metrics
    ROUND(AVG(p.weight_g), 2)               AS avg_weight_g,
    ROUND(AVG(p.volume_cm3), 2)             AS avg_volume_cm3

FROM products p
LEFT JOIN orders o ON p.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY gross_revenue DESC