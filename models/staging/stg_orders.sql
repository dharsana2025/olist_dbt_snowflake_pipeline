{{ config(
    materialized='view',
    schema='STAGING'
) }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'orders') }}
),

cleaned AS (
    SELECT
        order_id,
        customer_id,
        order_status,

        -- rename timestamps to readable names
        order_purchase_timestamp            AS ordered_at,
        order_approved_at                   AS approved_at,
        order_delivered_carrier_date        AS shipped_at,
        order_delivered_customer_date       AS delivered_at,
        order_estimated_delivery_date       AS estimated_delivery_at,

        -- delivery metrics
        DATEDIFF('day',
            order_purchase_timestamp,
            order_delivered_customer_date)  AS actual_delivery_days,

        DATEDIFF('day',
            order_purchase_timestamp,
            order_estimated_delivery_date)  AS promised_delivery_days

    FROM source
    WHERE order_id IS NOT NULL
)

SELECT * FROM cleaned