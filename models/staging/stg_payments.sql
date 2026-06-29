{{ config(
    materialized='view',
    schema='STAGING'
) }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'payments') }}
),

cleaned AS (
    SELECT
        order_id,
        payment as payment_sequential,
        payment_type,
        payment_installments,
        ROUND(payment_value, 2)     AS payment_amount
    FROM source
    WHERE order_id      IS NOT NULL
      AND payment_value  > 0
)

SELECT * FROM cleaned

