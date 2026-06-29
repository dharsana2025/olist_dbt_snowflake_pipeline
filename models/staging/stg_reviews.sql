
{{ config(
    materialized='view',
    schema='STAGING'
) }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'reviews') }}
),
cleaned AS (
    SELECT
        review_id,
        order_id,
        review_score,
        CASE
            WHEN review_score >= 4 THEN 'Positive'
            WHEN review_score =  3 THEN 'Neutral'
            ELSE 'Negative'
        END AS review_sentiment
    FROM source
    WHERE review_id IS NOT NULL
      AND order_id  IS NOT NULL
)

SELECT * FROM cleaned