# 🛒 Olist Retail Analytics Pipeline
### dbt + Snowflake + Snowpark | Medallion Architecture | End-to-End Data Pipeline

---

## 📌 Project Overview

An end-to-end retail analytics pipeline built on the 
**Brazilian E-Commerce (Olist)** public dataset using 
**dbt + Snowflake + Snowpark**, implementing a 4-layer Medallion architecture 
to transform raw transactional data into business-ready KPI tables.

**Business Questions Answered:**
- Which product categories generate the highest revenue?
- What is the customer lifetime value and repeat purchase rate?
- How does delivery performance impact review scores?
- What are monthly GMV trends across Brazilian states?
- Which customers have high engagement (5-star reviews)?

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
Snowpark UDF (Python) — customer_summary analysis
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
├── snowpark/
│   └── customer_summary.py
├── macros/
│   └── generate_schema_name.sql
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

## 🐍 Snowpark UDF Layer

### Customer Summary Analysis

**File:** `snowpark/customer_summary.py`

Snowpark module that runs **inside Snowflake warehouse** (no data export) to calculate customer engagement metrics.

**What it does:**
- Joins orders + reviews tables
- Groups by customer_id
- Calculates: total_orders, avg_rating, five_star_count
- Filters customers with >2 orders
- Writes results to `RAW.CUSTOMER_SUMMARY` table

**Why Snowpark?**
- Complex Python logic executes in-warehouse (secure)
- No data movement = faster, cheaper
- Results persist as table for dbt/analytics

**Run:**
```bash
python snowpark/customer_summary.py
```

**Output Table:** `RAW.CUSTOMER_SUMMARY`
```sql
select * from RAW.CUSTOMER_SUMMARY
order by avg_rating desc
limit 10;
```

| CUSTOMER_ID | TOTAL_ORDERS | AVG_RATING | FIVE_STAR_COUNT |
|---|---|---|---|
| c123 | 5 | 4.2 | 3 |
| c456 | 3 | 3.8 | 1 |
| c789 | 7 | 4.5 | 6 |

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

5. **High-Engagement Customers:** Snowpark customer_summary identifies 
   customers with 5+ star reviews — opportunity for VIP loyalty programs

---

## 📊 Lineage DAG

<img width="1775" height="826" alt="dbt_serve" src="https://github.com/user-attachments/assets/4778b15e-1712-4942-9855-c05f3e2877fa" />

---

## 🚀 Quick Start

```bash
# 1. Clone and setup
git clone <repo>
cd olist_dbt_snowflake_pipeline
pip install dbt-snowflake snowflake-snowpark-python

# 2. Load raw data (from Kaggle)
dbt seed

# 3. Run dbt transformations
dbt run
dbt test

# 4. Run Snowpark analysis
python snowpark/customer_summary.py

# 5. View results in Snowflake
select * from RAW.CUSTOMER_SUMMARY;
```

---

## 🔗 Links

- **Dataset:** [Kaggle — Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **dbt Docs:** Generated locally via `dbt docs serve`
- **Snowpark Docs:** [Snowflake Snowpark Python Guide](https://docs.snowflake.com/en/developer-guide/snowpark/python/)
