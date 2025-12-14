/*
===========================================================================
                     Data Quality Checks (Silver Layer)
===========================================================================

Script Purpose:
This script performs comprehensive data quality checks on the Silver layer to
ensure data consistency, accuracy, and standardization. The checks include:

    - Detection of NULL or duplicate primary keys
    - Identification of unwanted leading or trailing spaces in string columns
    - Validation of data standardization and value consistency
    - Verification of valid date ranges and chronological order
    - Consistency checks between related attributes and tables

Usage Notes:
    - Execute this script after successfully loading data into the Silver layer.
    - Review and investigate any issues identified by these checks.

===========================================================================
*/

-- Make sure using the correct Database
USE DataWarehouse;
GO

/*
==========================================================
            Checking for 'Silver.crm_cust_info'
==========================================================
*/

-- Check for nulls or duplicates in Primary Key
-- Expectation: No Results

SELECT
    cst_id,
    COUNT(*) TimesRepeated
FROM Silver.crm_cust_info
GROUP BY cst_id 
HAVING cst_id IS NULL OR COUNT(*) > 1;

-----

SELECT
    cst_key,
    COUNT(*) TimesRepeated
FROM Silver.crm_cust_info
GROUP BY cst_key 
HAVING cst_key IS NULL OR COUNT(*) > 1;


-- Check for unwanted spaces in string columns
-- Expectation: No Results

SELECT
    cst_first_name
FROM Bronze.crm_cust_info
WHERE LEN( cst_first_name ) != LEN( TRIM( cst_first_name ) );

-----

SELECT
    cst_last_name
FROM Bronze.crm_cust_info
WHERE LEN( cst_last_name ) != LEN( TRIM( cst_last_name ) );


-- Check for data inconsistency in low-cardinality columns
-- Expectation: Unique and Standard Labels

SELECT 
    DISTINCT cst_marital_status
FROM Bronze.crm_cust_info;

-----

SELECT 
    DISTINCT cst_gender
FROM Bronze.crm_cust_info;


-- Check for invalid dates in date column
-- Expectation: No Results

SELECT
    cst_create_date
FROM Bronze.crm_cust_info
WHERE cst_create_date < '1990-01-01' -- business's creation date
    OR cst_create_date > GETDATE();




/*
==========================================================
            Checking for 'Silver.crm_prd_info'
==========================================================
*/

-- Check for nulls or duplicates in Primary Key
-- Expectation: No Results

SELECT
    prd_id,
    COUNT(*) TimesRepeated
FROM Bronze.crm_prd_info
GROUP BY prd_id 
HAVING prd_id IS NULL OR COUNT(*) > 1;
/* cat_id & prd_id are not PK because of the Historization) */


-- Check for unwanted spaces in string columns
-- Expectation: No Results

SELECT
    prd_nm
FROM Bronze.crm_prd_info
WHERE LEN( prd_nm ) != LEN( TRIM( prd_nm ) );


-- Check for data inconsistency in low-cardinality columns
-- Expectation: Unique and Standard Labels

SELECT 
    DISTINCT prd_line
FROM Bronze.crm_prd_info;


-- Check for invalid costs
-- Expectation: No Results

SELECT
    prd_cost
FROM Bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost<0;


-- Check for invalid dates in date column
-- Expectation: No Results

SELECT
    prd_start_dt,
    prd_end_dt
FROM Bronze.crm_prd_info
WHERE prd_start_dt > prd_end_dt
    OR prd_start_dt < '1990-01-01' -- business's creation date
    OR prd_start_dt > GETDATE();




/*
==========================================================
         Checking for 'Silver.crm_sales_details'
==========================================================
*/

-- Check for invalid date keys
-- Expectation: No Results

SELECT
    sls_order_dt
FROM Bronze.crm_sales_details
WHERE sls_order_dt <=0
    OR LEN( sls_order_dt ) != 8
    OR sls_order_dt < 19900101 -- business's creation date
    OR sls_order_dt > REPLACE( CAST( GETDATE() AS DATE ), '-', '' )
    OR sls_order_dt > sls_ship_dt
    OR sls_order_dt > sls_due_dt;

-----

SELECT
    sls_ship_dt
FROM Bronze.crm_sales_details
WHERE sls_ship_dt <=0
    OR LEN( sls_ship_dt ) != 8
    OR sls_ship_dt < 19900101 -- business's creation date
    OR sls_ship_dt > REPLACE( CAST( GETDATE() AS DATE ), '-', '' );

-----

SELECT
    sls_due_dt
FROM Bronze.crm_sales_details
WHERE sls_due_dt <=0
    OR LEN( sls_due_dt ) != 8
    OR sls_due_dt < 19900101 -- business's creation date
    OR sls_due_dt > REPLACE( CAST( GETDATE()+100 AS DATE ), '-', '' );


-- Check for invalid integers: quantity, price, sales
-- Expectation: No Results

SELECT
    sls_sales,
    sls_quantity,
    sls_price 
FROM Bronze.crm_sales_details
WHERE sls_sales != ( sls_quantity * sls_price )
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL;




/*
==========================================================
             Checking for 'Silver.erp_cust_az12'
==========================================================
*/

-- Check for nulls or duplicates in Primary Key
-- Expectation: No Results

SELECT
    cid,
    COUNT(*) TimesRepeated
FROM Bronze.erp_cust_az12
GROUP BY cid 
HAVING cid IS NULL OR COUNT(*) > 1;


-- Check for invalid Keys
-- Expectation: No Results

SELECT
    cid
FROM Bronze.erp_cust_az12
WHERE cid NOT IN (SELECT cst_key FROM Bronze.crm_cust_info);


-- Check for data inconsistency in low-cardinality columns
-- Expectation: Unique and Standard Labels

SELECT 
    DISTINCT gen
FROM Bronze.erp_cust_az12;


-- Check for invalid dates in date column
-- Expectation: No Results

SELECT
    bdate
FROM Bronze.erp_cust_az12
WHERE bdate > GETDATE();




/*
==========================================================
            Checking for 'Silver.erp_loc_a101'
==========================================================
*/

-- Check for invalid Keys
-- Expectation: No Results

SELECT
    cid
FROM Bronze.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM Bronze.crm_cust_info);


-- Check for data inconsistency in low-cardinality columns
-- Expectation: Unique and Standard Labels

SELECT 
    DISTINCT cntry
FROM Bronze.erp_loc_a101
ORDER BY cntry;




/*
==========================================================
           Checking for 'Silver.erp_px_cat_g1v2'
==========================================================
*/

-- Check for invalid Keys
-- Expectation: No Results

SELECT
    id
FROM Bronze.erp_px_cat_g1v2
WHERE id NOT IN (SELECT REPLACE( LEFT( TRIM( prd_key ), 5), '-', '_' ) FROM Bronze.crm_prd_info);


-- Check for data inconsistency in low-cardinality columns
-- Expectation: Unique and Standard Labels

SELECT 
    DISTINCT cat
FROM Bronze.erp_px_cat_g1v2;

-----

SELECT 
    DISTINCT subcat
FROM Bronze.erp_px_cat_g1v2;

-----

SELECT 
    DISTINCT maintainance
FROM Bronze.erp_px_cat_g1v2;

