# **Naming Conventions**

This document defines the standardized naming conventions used for schemas,
tables, views, columns, and stored procedures in the data warehouse. Adhering
to these conventions ensures consistency, readability, and maintainability
across all layers.

---

## **Table of Contents**

1. [General Principles](#general-principles)
2. [Database Naming Conventions](#database-naming-conventions)
3. [Schema Naming Conventions](#schema-naming-conventions)
4. [Table Naming Conventions](#table-naming-conventions)
   - [Bronze Rules](#bronze-rules)
   - [Silver Rules](#silver-rules)
   - [Gold Rules](#gold-rules)
5. [Column Naming Conventions](#column-naming-conventions)
   - [Surrogate Keys](#surrogate-keys)
   - [Technical Columns](#technical-columns)
6. [Stored Procedure Naming Conventions](#stored-procedure-naming-conventions)

---

## **General Principles**

- **Case Style**: Use `snake_case` with lowercase letters and underscores (`_`).
- **Language**: Use English for all object and column names.
- **Clarity**: Names should be descriptive and self-explanatory.
- **Reserved Words**: Avoid SQL reserved keywords for object names.

---

## **Database Naming Conventions**

- The data warehouse database must use a **clear, descriptive, and singular name**.
- Naming standard:

  **`DataWarehouse`**

---

## **Schema Naming Conventions**

- Each layer must have its own dedicated schema.
- Schema names must be **short, clear, and consistent**.

| Schema Name | Purpose                                      |
|------------|----------------------------------------------|
| `Bronze`   | Raw, unprocessed data from source systems     |
| `Silver`   | Cleansed, standardized, validated data        |
| `Gold`     | Business-ready data for analytics and BI      |

---

## **Table Naming Conventions**

### **Bronze Rules**
- Table names must reflect the **original source system structure**.
- No renaming or business interpretation is applied at this layer.
- Naming pattern:

  **`<source_system>_<entity>`**

  - `<source_system>`: Source system identifier (e.g., `crm`, `erp`)
  - `<entity>`: Original table/entity name from the source system

  **Example:**
  - `crm_customer_info` → Raw customer data from the CRM system

---

### **Silver Rules**
- Table names remain aligned with the **source system entities**.
- Data is cleansed and standardized, but naming remains unchanged for traceability.
- Naming pattern:

  **`<source_system>_<entity>`**

  **Example:**
  - `crm_customer_info` → Cleaned and standardized customer data

---

### **Gold Rules**
- Table and view names must be **business-oriented** and independent of source systems.
- Naming reflects analytical intent and star schema design.
- Naming pattern:

  **`<category>_<entity>`**

  - `<category>`: Table role (`dim`, `fact`, `report`)
  - `<entity>`: Business-aligned entity name

  **Examples:**
  - `dim_customers` → Customer dimension
  - `fact_sales` → Sales fact table

#### **Glossary of Category Prefixes**

| Prefix     | Description                     | Example(s)                             |
|------------|----------------------------------|----------------------------------------|
| `dim_`     | Dimension table                  | `dim_customers`, `dim_products`        |
| `fact_`    | Fact table                       | `fact_sales`                           |
| `report_`  | Reporting or aggregated view     | `report_sales_monthly`                 |

---

## **Column Naming Conventions**

### **Surrogate Keys**
- All surrogate primary keys in dimension tables must end with `_key`.
- Naming pattern:

  **`<entity>_key`**

  **Example:**
  - `customer_key` → Surrogate key in `dim_customers`

---

### **Technical Columns**
- System-generated metadata columns must start with the prefix `dwh_`.
- Naming pattern:

  **`dwh_<column_name>`**

  **Examples:**
  - `dwh_load_date` → Record load timestamp
  - `dwh_source_system` → Originating source system

---

## **Stored Procedure Naming Conventions**

- Stored procedures used for data loading must follow this pattern:

  **`load_<layer>`**

  - `<layer>`: Target data layer (`bronze`, `silver`, `gold`)

  **Examples:**
  - `load_bronze` → Loads data into the Bronze layer
  - `load_silver` → Transforms data into the Silver layer
