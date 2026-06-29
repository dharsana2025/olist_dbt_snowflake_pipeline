{{ config(
    materialized='view',
    schema='STAGING'
) }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'order_items') }}
),

cleaned AS (
    SELECT
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date,
        ROUND(price, 2)             AS price,
        ROUND(freight_value, 2)     AS freight_value,
        ROUND(price + freight_value, 2) AS total_item_value  -- useful derived column
    FROM source
    WHERE order_id    IS NOT NULL
      AND product_id  IS NOT NULL
      AND price       > 0
)

SELECT * FROM cleaned