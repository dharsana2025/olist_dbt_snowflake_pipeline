{{ config(materialized='view') }}

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

payments AS (
    SELECT
        order_id,
        SUM(payment_amount)             AS total_payment,
        COUNT(DISTINCT payment_type)    AS payment_methods_used,
        MAX(payment_installments)       AS max_installments
    FROM {{ ref('stg_payments') }}
    GROUP BY order_id
),

reviews AS (
    SELECT
        order_id,
        review_score,
        review_sentiment
    FROM {{ ref('stg_reviews') }}
)

SELECT
    -- order info
    o.order_id,
    o.order_status,
    o.ordered_at,
    o.approved_at,
    o.delivered_at,
    o.estimated_delivery_at,
    o.actual_delivery_days,
    o.promised_delivery_days,
    (o.actual_delivery_days - o.promised_delivery_days) AS delivery_delay_days,

    CASE
        WHEN o.actual_delivery_days <= o.promised_delivery_days THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,

    -- customer info
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,

    -- payment info
    p.total_payment,
    p.payment_methods_used,
    p.max_installments,

    -- review info
    r.review_score,
    r.review_sentiment

FROM orders o
LEFT JOIN customers c   ON o.customer_id    = c.customer_id
LEFT JOIN payments  p   ON o.order_id       = p.order_id
LEFT JOIN reviews   r   ON o.order_id       = r.order_id