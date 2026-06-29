WITH source AS (
    SELECT * FROM {{ source('raw', 'customers') }}
),

cleaned AS (
    SELECT
        customer_id,
        customer_unique_id,
        customer_zip_prefix    AS zip_code,
        INITCAP(customer_city)      AS customer_city,   -- capitalizes city name
        UPPER(customer_state)       AS customer_state
    FROM source
    WHERE customer_id IS NOT NULL
)

SELECT * FROM cleaned