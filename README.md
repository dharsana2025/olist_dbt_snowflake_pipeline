# 🛒 Olist Retail Analytics Pipeline
### dbt + Snowflake + Snowpark | Medallion Architecture | End-to-End Data Pipeline

---

## 📌 Project Overview

An end-to-end retail analytics pipeline built on the 
**Brazilian E-Commerce (Olist)** public dataset using 
**dbt + Snowflake + Snowpark**, implementing a 4-layer Medallion architecture 
to transform raw transactional data into business-ready insights.

**Business Questions Answered:**
- Which product categories generate the highest revenue?
- What is the customer lifetime value and repeat purchase rate?
- How does delivery performance impact review scores?
- What are monthly GMV trends across Brazilian states?
- What is the average rating per customer?

---

## 🏗️ Architecture

```
Raw CSVs
    ↓
Snowflake RAW Schema (7 tables)
    ↓
dbt Staging Layer (7 views) — clean, rename, cast
    ↓
dbt Intermediate Layer (2 views) — join, enrich
    ↓
dbt Marts Layer (3 tables) — business KPIs
    ↓
Snowpark Transformations — join, aggregate, analyze
```

---

## 🗂️ Dataset

**Source:** [Brazilian E-Commerce by Olist — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

| Table | Rows | Description |
|---|---|---|
| orders | 99,441 | Main transaction table |
| customers | 99,441 | Customer city and state |
| order_items | 112,650 | Line items per order |
| payments | 103,886 | Payment type and value |
| reviews | 99,224 | Customer review scores |
| product | 32,951 | Product catalog |
| product_category | 71 | Portuguese → English translation |

---

## 🔧 Tech Stack

![dbt](https://img.shields.io/badge/dbt-FF694B?style=flat&logo=dbt&logoColor=white)
![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=flat&logo=snowflake&logoColor=white)
![Snowpark](https://img.shields.io/badge/Snowpark-Python-3776AB?style=flat&logo=python&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-4479A1?style=flat&logo=postgresql&logoColor=white)

---

## 📁 Project Structure

```
olist_dbt_snowflake_pipeline/
├── models/
│   ├── staging/
│   │   ├── sources.yml
│   │   ├── schema.yml
│   │   ├── stg_orders.sql
│   │   ├── stg_customers.sql
│   │   ├── stg_order_items.sql
│   │   ├── stg_payments.sql
│   │   ├── stg_reviews.sql
│   │   ├── stg_products.sql
│   │   └── stg_product_category.sql
│   ├── intermediate/
│   │   ├── int_orders_enriched.sql
│   │   └── int_product_enriched.sql
│   └── marts/
│       ├── mart_customer_orders.sql
│       ├── mart_category_performance.sql
│       └── mart_revenue_trends.sql
├── dbt_project.yml
└── README.md
```

---

## 🔄 dbt Models

### Staging Layer — 7 Views
| Model | Source | Key Additions |
|---|---|---|
| `stg_orders` | raw.orders | `actual_delivery_days`, `promised_delivery_days` |
| `stg_customers` | raw.customers | Formatted city/state |
| `stg_order_items` | raw.order_items | `total_item_value` |
| `stg_payments` | raw.payments | Filtered zero-value rows |
| `stg_reviews` | raw.reviews | `review_sentiment` classification |
| `stg_products` | raw.product | `volume_cm3` derived column |
| `stg_product_category` | raw.product_category | Clean translation mapping |

### Intermediate Layer — 2 Views
| Model | Joins | Key Columns |
|---|---|---|
| `int_orders_enriched` | orders + customers + payments + reviews | `delivery_delay_days`, `delivery_status`, `total_payment` |
| `int_product_enriched` | order_items + products + category | `category_name_english`, `freight_pct_of_price` |

### Marts Layer — 3 Tables
| Model | Rows | Description |
|---|---|---|
| `mart_customer_orders` | 93,471 | Customer LTV, segmentation, RFM |
| `mart_category_performance` | 74 | Revenue and reviews by category |
| `mart_revenue_trends` | 556 | Monthly GMV by state |

---

## 🐍 Snowpark Transformations

### Customer Summary Analysis

Snowpark Python code running **inside Snowflake** to join and aggregate customer data.

**Code:**
```python
from snowflake.snowpark import Session
from snowflake.snowpark.functions import *

session = Session.builder.getOrCreate()

orders = session.table("olist_db.raw.orders")
reviews = session.table("olist_db.raw.reviews")

customer_summary = orders.join(
    reviews,
    orders.order_id == reviews.order_id,
    "left"
).groupBy(
    orders.customer_id
).agg(
    count(orders.order_id).alias("total_orders"),
    avg(reviews.review_score).alias("avg_rating")
)

customer_summary.show()
```

**Output:**
```
| CUSTOMER_ID | TOTAL_ORDERS | AVG_RATING |
|---|---|---|
| cab782713f3d | 1 | 5.0 |
| a00f913be49c | 1 | 1.0 |
| 28e5dd68bcf6 | 1 | 5.0 |
```

**Why Snowpark?**
- Join orders + reviews **inside Snowflake** (no data export)
- Python syntax familiar to data engineers
- Executes efficiently on warehouse compute
- Results ready for downstream analysis

---

## ✅ Data Quality Tests

23 automated dbt tests across all source and staging models:
- `unique` and `not_null` on all primary keys
- `accepted_values` on `order_status`, `payment_type`, `review_score`

```bash
dbt test
# PASS=23 WARN=0 ERROR=0
```

---

## 💡 Key Business Insights

1. **Top Revenue Category:** Health & Beauty leads all 74 product 
   categories with **$ 1,237,439 in gross revenue**

2. **Delivery Performance:** Average actual delivery is **12.5 days** 
   against a promised window of 24 days — majority of orders 
   arrive ahead of schedule

3. **Customer Retention Gap:** **97.1% of 93,471 customers are 
   one-time buyers** (90,772 one-time vs 2,654 occasional vs 45 loyal) 
   — significant opportunity for repeat purchase campaigns

4. **Loyalty is Rare:** Only **45 customers (0.05%)** qualify as 
   loyal buyers — indicating strong acquisition but weak retention

5. **Customer Ratings:** Snowpark analysis shows average customer 
   rating distribution — insights for satisfaction tracking

---

## 📊 Lineage DAG

<img width="1775" height="826" alt="dbt_serve" src="https://github.com/user-attachments/assets/4778b15e-1712-4942-9855-c05f3e2877fa" />

---

## 🔗 Links

- **Dataset:** [Kaggle — Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **dbt Docs:** Generated locally via `dbt docs serve`
- **Snowpark Docs:** [Snowflake Snowpark Python Guide](https://docs.snowflake.com/en/developer-guide/snowpark/python/)
