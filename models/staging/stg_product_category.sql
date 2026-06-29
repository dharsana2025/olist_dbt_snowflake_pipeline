{{ config(
    materialized='view',
    schema='STAGING'
) }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'product_category') }}
),

cleaned AS (
    SELECT
        product_category_name,
        product_category_name_english   AS category_name_english
    FROM source
    WHERE product_category_name IS NOT NULL
)

SELECT * FROM cleaned







