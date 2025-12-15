# Data Catalog – Gold Layer

## Overview

The Gold layer represents the business-ready data model designed for analytics and reporting. It follows a **star schema** pattern and consists of **dimension** and **fact** views built on top of the Silver layer.

---

## 1. **gold.dim_customer**

**Purpose:**
Stores consolidated customer information enriched with demographic and geographic attributes for analytical use.

**Columns:**

| Column Name    | Data Type    | Description                                                               |
| -------------- | ------------ | ------------------------------------------------------------------------- |
| customer_sk    | INT          | Surrogate key uniquely identifying each customer record.                  |
| customer_id    | INT          | Numeric customer identifier from the source system (e.g., 11000).         |
| customer_key   | NVARCHAR(50) | Business key representing the customer (e.g., AW00011000).                |
| customer_name  | NVARCHAR(50) | Full customer name derived from first and last name (e.g., Mehedi Hasan). |
| country        | NVARCHAR(50) | Customer country of residence (e.g., Australia).                          |
| gender         | NVARCHAR(50) | Standardized gender value (e.g., Male, Female, n/a).                      |
| age            | INT          | Customer age calculated from birth date and creation date (e.g., 42).     |
| marital_status | NVARCHAR(50) | Customer marital status (e.g., Married, Single).                          |

---

## 2. **gold.dim_product**

**Purpose:**
Provides a unified view of product attributes, categories, and classifications for reporting and analysis.

**Columns:**

| Column Name  | Data Type    | Description                                                         |
| ------------ | ------------ | ------------------------------------------------------------------- |
| product_sk   | INT          | Surrogate key uniquely identifying each product record.             |
| product_id   | INT          | Numeric product identifier from the source system (e.g., 200).      |
| product_key  | NVARCHAR(50) | Business product key (e.g., BK-M82B-42).                            |
| product_name | NVARCHAR(50) | Descriptive product name (e.g., HL Road Frame - Black - 58).        |
| category_id  | NVARCHAR(50) | Category identifier from the source system (e.g., CO_RF).           |
| category     | NVARCHAR(50) | High-level product category (e.g., Bikes, Components).              |
| subcategory  | NVARCHAR(50) | Detailed product subcategory (e.g., Road Frames, Mountain Bikes).   |
| maintainance | NVARCHAR(50) | Indicates whether maintenance is required (e.g., Yes, No).          |
| product_line | NVARCHAR(50) | Product line or series (e.g., Road, Mountain, Touring, Others).     |
| cost         | INT          | Product cost in whole currency units (e.g., 25).                    |
| launch_date  | DATE         | Date the product became available (e.g., 2019-01-01).               |

---

## 3. **gold.fact_sales**

**Purpose:**
Stores transactional sales data used for measuring business performance and trends.

**Columns:**

| Column Name   | Data Type    | Description                                                 |
| ------------- | ------------ | ----------------------------------------------------------- |
| order_number  | NVARCHAR(50) | Unique sales order identifier (e.g., SO54496).              |
| customer_sk   | INT          | Surrogate key referencing **gold.dim_customer**.            |
| product_sk    | INT          | Surrogate key referencing **gold.dim_product**.             |
| order_date    | DATE         | Date the order was placed (e.g., 2023-06-15).               |
| shipping_date | DATE         | Date the order was shipped (e.g., 2023-06-17).              |
| due_date      | DATE         | Payment due date for the order (e.g., 2023-06-30).          |
| sales_amount  | INT          | Total sales amount for the line item (e.g., 250).           |
| quantity      | INT          | Number of units sold (e.g., 2).                             |
| price         | INT          | Unit price of the product (e.g., 125).                      | 

---

**Notes:**

* All Gold objects are implemented as **views**.
* Surrogate keys are generated using deterministic logic for analytical consistency.
* The Gold layer should be treated as read-only and used exclusively for reporting and analytics.
