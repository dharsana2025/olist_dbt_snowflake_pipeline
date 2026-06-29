{{ config(
    materialized='view',
    schema='INTERMEDIATE'
) }}
WITH order_items AS (
    SELECT * FROM {{ ref('stg_order_items') }}
),

products AS (
    SELECT * FROM {{ ref('stg_products') }}
),

category AS (
    SELECT * FROM {{ ref('stg_product_category') }}
)

SELECT
    -- order item info
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.price,
    oi.freight_value,
    oi.total_item_value,

    -- product info
    p.product_category_name,
    p.weight_g,
    p.volume_cm3,
    p.product_photos_qty,

    -- english category name (from translation table)
    COALESCE(
        c.category_name_english,
        p.product_category_name,    -- fallback to Portuguese if no translation
        'Unknown'
    ) AS category_name_english,

    -- derived
    ROUND(oi.freight_value / NULLIF(oi.price, 0) * 100, 2) AS freight_pct_of_price

FROM order_items oi
LEFT JOIN products p    ON oi.product_id            = p.product_id
LEFT JOIN category c    ON p.product_category_name  = c.product_category_name