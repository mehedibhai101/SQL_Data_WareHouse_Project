/*
===========================================================================
                     Data Quality Checks (Gold Layer)
===========================================================================

Script Purpose:
This script performs comprehensive data quality checks on the Gold layer to
ensure data accuracy, consistency, and analytical reliability.

The checks include:
    - Validation of surrogate key integrity between fact and dimension views
    - Detection of NULL or duplicate business and surrogate keys
    - Identification of invalid or inconsistent low-cardinality values
    - Verification of derived attributes (e.g., age calculations)
    - Consistency checks between fact and dimension relationships

Usage Notes:
    - Execute this script after successfully creating and validating Gold views.
    - Investigate and resolve any records returned by these checks before
      exposing the data for reporting or analytics.

===========================================================================
*/

-- Make sure using the correct Database
USE DataWarehouse;
GO

/*
==========================================================
             Checking for 'Gold.dim_customer'
==========================================================
*/

-- Check Foreign Key (Surrogate Key) integrity
-- Expectation: No Results

SELECT
    s.customer_sk
FROM Gold.fact_sales s
LEFT JOIN Gold.dim_customer c
ON        s.customer_sk = c.customer_sk
WHERE c.customer_sk IS NULL;


-- Check uniqueness of Primary Key after joining
-- Expectation: No Results

SELECT 
    customer_id,
    COUNT(*) TimesRepeated
FROM Gold.dim_customer
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- Check for null values after concatenation
-- Expectation: No Results

SELECT
    customer_name
FROM Gold.dim_customer
WHERE customer_name IS NULL;


-- Check invalidness of age calculation
-- Expectation: No Results

SELECT
    age
FROM Gold.dim_customer
WHERE age < 0;


-- Check for data inconsistency in low-cardinality columns
-- Expectation: Unique and Standard Labels

SELECT 
    DISTINCT marital_status
FROM Gold.dim_customer;

-----

SELECT 
    DISTINCT gender
FROM Gold.dim_customer;



/*
==========================================================
              Checking for 'Gold.dim_product'
==========================================================
*/

-- Check Foreign Key (Surrogate Key) integrity
-- Expectation: No Results

SELECT
    s.product_sk
FROM Gold.fact_sales s
LEFT JOIN Gold.dim_product p
ON        s.product_sk = p.product_sk
WHERE p.product_sk IS NULL;


-- Check uniqueness of Primary Key after joining
-- Expectation: No Results

SELECT 
    product_id,
    COUNT(*) TimesRepeated
FROM Gold.dim_product
GROUP BY product_id
HAVING COUNT(*) > 1;


-- Check for data inconsistency in low-cardinality columns
-- Expectation: Unique and Standard Labels

SELECT 
    DISTINCT category
FROM Gold.dim_product;

-----

SELECT 
    DISTINCT subcategory
FROM Gold.dim_product;

-----

SELECT 
    DISTINCT maintainance
FROM Gold.dim_product;

-----

SELECT 
    DISTINCT product_line
FROM Gold.dim_product;



/*
==========================================================
              Checking for 'Gold.fact_sales'
==========================================================
*/

-- Check connectivity between fact and dimensions
-- Expectation: No Results

SELECT * 
FROM Gold.fact_sales s
LEFT JOIN Gold.dim_customer c
ON        c.customer_sk = s.customer_sk
LEFT JOIN Gold.dim_product p
ON        p.product_sk = s.product_sk
WHERE p.product_sk IS NULL 
    OR c.customer_sk IS NULL;

