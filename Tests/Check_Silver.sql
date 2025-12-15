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
===========================================================================
              Identifying Data Quality Issues (Bronze Layer)
===========================================================================

Script Purpose:
This script performs initial data quality checks on the Bronze layer to identify
raw data issues originating from source systems. These checks help detect data
problems early before transformation into the Silver layer.

The checks include:
    - Detection of NULL or duplicate primary keys
    - Identification of unwanted leading or trailing spaces in string columns
    - Validation of data standardization and value consistency
    - Verification of valid date ranges and chronological order
    - Consistency checks between related attributes and tables

Usage Notes:
    - Execute this script after loading data into the Bronze layer.
    - Use the results to identify source system data issues.
    - Address critical issues before proceeding with Silver-layer transformations.

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


-- Check for invalid Keys
-- Expectation: No Results

SELECT
    cst_key
FROM Silver.crm_cust_info
WHERE cst_key NOT IN (SELECT cid FROM Silver.erp_cust_az12);

-----

SELECT
    cst_key
FROM Silver.crm_cust_info
WHERE cst_key NOT IN (SELECT cid FROM Silver.erp_loc_a101);


-- Check for unwanted spaces in string columns
-- Expectation: No Results

SELECT
    cst_first_name
FROM Silver.crm_cust_info
WHERE LEN( cst_first_name ) != LEN( TRIM( cst_first_name ) );

-----

SELECT
    cst_last_name
FROM Silver.crm_cust_info
WHERE LEN( cst_last_name ) != LEN( TRIM( cst_last_name ) );


-- Check for data inconsistency in low-cardinality columns
-- Expectation: Unique and Standard Labels

SELECT 
    DISTINCT cst_marital_status
FROM Silver.crm_cust_info;

-----

SELECT 
    DISTINCT cst_gender
FROM Silver.crm_cust_info;


-- Check for invalid dates in date column
-- Expectation: No Results

SELECT
    cst_create_date
FROM Silver.crm_cust_info
WHERE ( ISDATE( CAST( cst_create_date AS NVARCHAR) ) = 0
    OR cst_create_date < '1990-01-01' -- business's creation date
    OR cst_create_date > GETDATE() )
    AND cst_create_date IS NOT NULL;




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
FROM Silver.crm_prd_info
GROUP BY prd_id 
HAVING prd_id IS NULL OR COUNT(*) > 1;
/* cat_id & prd_id are not PK because of the Historization) */


-- Check for invalid Keys
-- Expectation: No Results

SELECT
    cat_id
FROM Silver.crm_prd_info
WHERE cat_id NOT IN (SELECT id FROM Silver.erp_px_cat_g1v2);


-- Check for unwanted spaces in string columns
-- Expectation: No Results

SELECT
    prd_nm
FROM Silver.crm_prd_info
WHERE LEN( prd_nm ) != LEN( TRIM( prd_nm ) );


-- Check for data inconsistency in low-cardinality columns
-- Expectation: Unique and Standard Labels

SELECT 
    DISTINCT prd_line
FROM Silver.crm_prd_info;


-- Check for invalid costs
-- Expectation: No Results

SELECT
    prd_cost
FROM Silver.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost<0;


-- Check for invalid dates in date column
-- Expectation: No Results

SELECT
    prd_start_dt,
    prd_end_dt
FROM Silver.crm_prd_info
WHERE ( ISDATE( CAST( prd_start_dt AS NVARCHAR) ) = 0
    OR ISDATE( CAST( prd_end_dt AS NVARCHAR) ) = 0
    OR prd_start_dt > prd_end_dt
    OR prd_start_dt < '1990-01-01' -- business's creation date
    OR prd_start_dt > GETDATE() )
    AND prd_end_dt IS NOT NULL;




/*
==========================================================
         Checking for 'Silver.crm_sales_details'
==========================================================
*/

-- Check for invalid Keys
-- Expectation: No Results

SELECT
    sls_cust_id
FROM Silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM Silver.crm_cust_info)
    AND sls_cust_id NOT IN (SELECT RIGHT(cid, 5) FROM Silver.erp_cust_az12)
    AND sls_cust_id NOT IN (SELECT RIGHT(cid, 5) FROM Silver.erp_loc_a101);

-----

SELECT
    sls_prd_key
FROM Silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM Silver.crm_prd_info);


-- Check for invalid date keys
-- Expectation: No Results

SELECT
    sls_order_dt
FROM Silver.crm_sales_details
WHERE ( ISDATE( CAST( sls_order_dt AS NVARCHAR) ) = 0
    OR sls_order_dt < '1990-01-01' -- business's creation date
    OR sls_order_dt > GETDATE()
    OR sls_order_dt > sls_ship_dt
    OR sls_order_dt > sls_due_dt )
    AND sls_order_dt IS NOT NULL;

----- 

SELECT
    sls_ship_dt
FROM Silver.crm_sales_details
WHERE ( ISDATE( CAST( sls_ship_dt AS NVARCHAR) ) = 0
    OR sls_ship_dt < '1990-01-01' -- business's creation date
    OR sls_ship_dt > GETDATE() )
    AND sls_ship_dt IS NOT NULL;

-----

SELECT
    sls_due_dt
FROM Silver.crm_sales_details
WHERE ( ISDATE( CAST( sls_due_dt AS NVARCHAR) ) = 0
    OR sls_due_dt < '1990-01-01' -- business's creation date
    OR sls_due_dt > GETDATE() )
    AND sls_due_dt IS NOT NULL;


-- Check for invalid integers: quantity, price, sales
-- Expectation: No Results

SELECT
    sls_sales,
    sls_quantity,
    sls_price 
FROM Silver.crm_sales_details
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
FROM Silver.erp_cust_az12
GROUP BY cid 
HAVING cid IS NULL OR COUNT(*) > 1;


-- Check for invalid Keys
-- Expectation: No Results

SELECT
    cid
FROM Silver.erp_cust_az12
WHERE cid NOT IN (SELECT cst_key FROM Silver.crm_cust_info);


-- Check for data inconsistency in low-cardinality columns
-- Expectation: Unique and Standard Labels

SELECT 
    DISTINCT gen
FROM Silver.erp_cust_az12;


-- Check for data integrity (same info from diff sources)
-- Expectation: Matching and non-null results for bpth

SELECT DISTINCT
    c.cst_gender,
    cd.gen
FROM Silver.crm_cust_info c
LEFT JOIN Silver.erp_cust_az12 cd
ON c.cst_key = cd.cid;


-- Check for invalid dates in date column
-- Expectation: No Results

SELECT
    bdate
FROM Silver.erp_cust_az12
WHERE ( ISDATE( CAST( bdate AS NVARCHAR) ) = 0
    OR bdate > GETDATE() )
    AND bdate IS NOT NULL;




/*
==========================================================
            Checking for 'Silver.erp_loc_a101'
==========================================================
*/

-- Check for invalid Keys
-- Expectation: No Results

SELECT
    cid
FROM Silver.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM Silver.crm_cust_info);


-- Check for data inconsistency in low-cardinality columns
-- Expectation: Unique and Standard Labels

SELECT 
    DISTINCT cntry
FROM Silver.erp_loc_a101
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
FROM Silver.erp_px_cat_g1v2
WHERE id NOT IN (SELECT cat_id FROM Silver.crm_prd_info);


-- Check for data inconsistency in low-cardinality columns
-- Expectation: Unique and Standard Labels

SELECT 
    DISTINCT cat
FROM Silver.erp_px_cat_g1v2;

-----

SELECT 
    DISTINCT subcat
FROM Silver.erp_px_cat_g1v2;

-----

SELECT 
    DISTINCT maintainance
FROM Silver.erp_px_cat_g1v2;

