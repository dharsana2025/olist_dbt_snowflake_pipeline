# 🛒 Olist Retail Analytics Pipeline
### dbt + Snowflake | Medallion Architecture | End-to-End Data Pipeline

---

## 📌 Project Overview

An end-to-end retail analytics pipeline built on the 
**Brazilian E-Commerce (Olist)** public dataset using 
**dbt + Snowflake**, implementing a 4-layer Medallion architecture 
to transform raw transactional data into business-ready KPI tables.

**Business Questions Answered:**
- Which product categories generate the highest revenue?
- What is the customer lifetime value and repeat purchase rate?
- How does delivery performance impact review scores?
- What are monthly GMV trends across Brazilian states?

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
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
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

## ✅ Data Quality Tests

23 automated dbt tests across all source and staging models:
- `unique` and `not_null` on all primary keys
- `accepted_values` on `order_status`, `payment_type`, `review_score`

```bash
dbt test
# PASS=23 WARN=0 ERROR=0
```

---

## 🚀 How to Run

### Prerequisites
- Snowflake account (free trial at snowflake.com)
- Python 3.8+
- dbt-snowflake

### Setup

```bash
# Install dbt
pip install dbt-snowflake

# Clone repo
git clone https://github.com/dharsana2025/olist_dbt_snowflake_pipeline.git
cd olist_dbt_snowflake_pipeline

# Configure Snowflake connection
# Create ~/.dbt/profiles.yml with your credentials

# Run pipeline
dbt run
dbt test
dbt docs generate && dbt docs serve
```

---

## 💡 Key Business Insights

1. **Top Category:** Health & Beauty generates the highest GMV 
   among all 74 product categories
2. **Delivery Performance:** Average delivery is 12 days vs 
   24 days promised — most orders arrive early
3. **Customer Segments:** 97% of customers are one-time buyers — 
   significant retention opportunity
4. **Review Correlation:** Categories with avg delivery delay 
   > 5 days score below 3.5 stars on average

---

## 📊 Lineage DAG

<img width="1920" height="1080" alt="dbt_serve" src="https://github.com/user-attachments/assets/9f5a2ea3-62dd-4734-a6f4-1dcf24af778b" />


---

## 🔗 Links

- **Dataset:** [Kaggle — Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **dbt Docs:** Generated locally via `dbt docs serve`
