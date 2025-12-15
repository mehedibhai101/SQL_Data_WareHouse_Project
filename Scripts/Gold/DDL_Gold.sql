/*
===========================================================================
                            Create Gold Views
===========================================================================

Script Purpose:
This script creates analytical views for the Gold layer of the data warehouse.
The Gold layer represents the final business-ready dimension and fact tables
implemented using a star schema design.

Each view performs the necessary transformations, aggregations, and joins on
Silver-layer data to deliver clean, enriched, and analytics-optimized datasets.

Views Created:

Dimensions:
    - dim_customer   : Customer dimension
    - dim_product    : Product dimension

Fact:
    - fact_sales     : Sales fact view

Important Notes:
- If a view already exists, it will be dropped and recreated. This will result
  in permanent loss of all queries in the existing views.
- Views depend on Silver-layer tables and must be created after Silver loads.
- No data is physically stored in this layer; views are generated at query time.
- Ensure that Silver-layer data quality checks have passed before using
  these views for reporting.

Usage:
    - These views can be queried directly for analytics and reporting.

---------------------------------------------------------------------------
⚠️ WARNING
---------------------------------------------------------------------------

Running this script will drop existing views that share the same names before
recreating them. Ensure that all dependent workloads are identified and that you fully
understand the impact before executing this script.
*/

-- Make sure using the correct database 'DataWarehouse'

USE DataWarehouse;
GO

/* Creating views based on Business Objects
		  (following the naming convention)  */

-- Dimension : Customer

IF OBJECT_ID('Gold.dim_customer', 'V') IS NOT NULL
	DROP VIEW Gold.dim_customer;
GO
  
CREATE VIEW Gold.dim_customer AS
SELECT
    ROW_NUMBER() OVER( ORDER BY c.cst_id ) AS customer_sk, --create surrogate key
    c.cst_id                AS customer_id,
    c.cst_key               AS customer_key,
    CONCAT( cst_first_name, ' ', COALESCE( cst_last_name,'' ) ) AS customer_name,
    cl.cntry                AS country,
    CASE
        WHEN c.cst_gender IN (NULL, 'n/a') --CRM is the primary source for gender
        THEN COALESCE( cd.gen, 'n/a')
        ELSE c.cst_gender
    END gender,
    DATEDIFF( year, cd.bdate, COALESCE( c.cst_create_date, GETDATE() ) ) AS age,
    c.cst_marital_status    AS marital_status
FROM Silver.crm_cust_info c
LEFT JOIN   Silver.erp_loc_a101 cl
ON          c.cst_key = cl.cid
LEFT JOIN   Silver.erp_cust_az12 cd
ON          c.cst_key = cd.cid;
GO

-- Dimension : Product

IF OBJECT_ID('Gold.dim_product', 'V') IS NOT NULL
	DROP VIEW Gold.dim_product;
GO
  
CREATE VIEW Gold.dim_product AS
SELECT
    ROW_NUMBER() OVER( ORDER BY p.prd_start_dt, p.prd_key ) AS product_sk, --create surrogate key
    p.prd_id        AS product_id,
    p.prd_key       AS product_key,
    p.prd_nm        AS product_name,
    p.cat_id        AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintainance AS maintainance,
    p.prd_line      AS product_line,
    p.prd_cost      AS cost,
    p.prd_start_dt  AS launch_date
FROM Silver.crm_prd_info p
LEFT JOIN   Silver.erp_px_cat_g1v2 pc
ON          p.cat_id = pc.id
WHERE prd_end_dt IS NULL; --filter out all historical data
GO

-- Fact : Sales
  
IF OBJECT_ID('Gold.fact_sales', 'V') IS NOT NULL
	DROP VIEW Gold.fact_sales;
GO
  
CREATE VIEW Gold.fact_sales AS
SELECT
    s.sls_ord_num AS order_number,
    gc.customer_sk AS customer_sk, --using sk from dimensions
    gp.product_sk AS product_sk,
    s.sls_order_dt AS order_date,
    s.sls_ship_dt AS shipping_date,
    s.sls_due_dt AS due_date,
    s.sls_sales AS sales_amount,
    s.sls_quantity AS quantity,
    s.sls_price AS price
FROM Silver.crm_sales_details s
LEFT JOIN Gold.dim_customer gc
ON s.sls_cust_id = gc.customer_id
LEFT JOIN Gold.dim_product gp
ON s.sls_prd_key = gp.product_key;
GO
