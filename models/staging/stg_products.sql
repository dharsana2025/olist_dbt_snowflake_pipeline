{{ config(
    materialized='view',
    schema='STAGING'
) }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'product') }}
),

cleaned AS (
    SELECT
        product_id,
        product_category_name,                      -- Portuguese name (will join translation later)
        product_name_lenght as product_name_lenght  ,
        product_description_lenght as product_description_length,
        product_photos_qty,
        ROUND(product_weight_g, 2)      AS weight_g,
        ROUND(product_length_cm, 2)     AS length_cm,
        ROUND(product_height_cm, 2)     AS height_cm,
        ROUND(product_width_cm, 2)      AS width_cm,

        -- volume calculation (useful for logistics analysis)
        ROUND(
            product_length_cm * product_height_cm * product_width_cm,
        2)                              AS volume_cm3

    FROM source
    WHERE product_id IS NOT NULL
)

SELECT * FROM cleaned