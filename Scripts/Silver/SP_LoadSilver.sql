/*
===========================================================================
                	Load Data into Silver Layer (CTAS)
===========================================================================

Script Purpose:
This script creates a stored procedure 'Silver.load_silver' that loads and
transforms data from the Bronze layer into the Silver-layer tables within the
'DataWarehouse' database. The Silver layer stores cleansed, standardized, and
validated data prepared for analytical consumption. The procedure truncates
each table before inserting data to ensure that only the latest dats is loaded.

Data Flow:
    Source Systems (CRM / ERP)
        → Bronze Layer (Raw Data)
            → Silver Layer (Cleaned & Standardized Data)

Tables Truncated & Inserted Data:

CRM Source System:
    - crm_cust_info       : Customer information
    - crm_prd_info        : Product information
    - crm_sales_details   : Sales data

ERP Source System:
    - erp_cust_az12       : Customer demographics
    - erp_loc_a101        : Customer locations
    - erp_px_cat_g1v2     : Product category information

Key Features:
- Loads data from Bronze-layer tables after data transformations.
- Applies data cleansing, standardization, and validation rules.
- Truncates Silver tables before loading to maintain a consistent dataset.
- Uses TRY…CATCH for robust error handling and logging.
- Tracks execution time for individual tables and the full load process.

Parameters:
This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;

---------------------------------------------------------------------------
⚠️ CRITICAL WARNING
---------------------------------------------------------------------------

Running this procedure will permanently delete all existing data in the
Silver-layer tables before loading new data. Ensure that you have verified
backups of any important data and fully understand the consequences before
executing this procedure.
*/

-- Create stored procedure to load data when updated.

CREATE OR ALTER PROCEDURE Silver.load_Silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME,
		@batch_start_time DATETIME, @batch_end_time DATETIME;

	BEGIN TRY 
		SET @batch_start_time = GETDATE();

		PRINT '=======================================================';
		PRINT '				  Loading Silver Layer';
		PRINT '=======================================================';

		PRINT '-------------------------------------------------------';
		PRINT '				   Loading CRM Tables';
		PRINT '-------------------------------------------------------';


		-- CRM : Customer Info Table

		SET @start_time = GETDATE();

		PRINT '';
		PRINT '>> Truncating Table: Silver.crm_cust_info';
		TRUNCATE TABLE Silver.crm_cust_info;

		PRINT '>> Inserting Data Into: Silver.crm_cust_info';
		SELECT
		    cst_id,
		    cst_key,
		    TRIM( cst_first_name ) cst_first_name,
		    TRIM( cst_last_name ) cst_last_name,
		    CASE UPPER( TRIM( cst_marital_status ) )
		        WHEN 'M' THEN 'Married'
		        WHEN 'S' THEN 'Single'
		        ELSE 'n/a'
		    END cst_marital_status,
		    CASE UPPER( TRIM( cst_gender ) )
		        WHEN 'M' THEN 'Male'
		        WHEN 'F' THEN 'Female'
		        ELSE 'n/a'
		    END cst_gender,
		    CASE WHEN cst_create_date < '1990-01-01' -- business's creation date
		            OR cst_create_date > GETDATE()
		        THEN NULL
		        ELSE cst_create_date
		    END cst_create_date
		INTO Silver.crm_cust_info 
		FROM 
		    (SELECT
		        *,
		        ROW_NUMBER() OVER( PARTITION BY cst_id ORDER BY cst_create_date DESC ) flag_duplicate
		    FROM Bronze.crm_cust_info
		    WHERE cst_id IS NOT NULL
		)t
		WHERE flag_duplicate = 1;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		-- CRM : Product Info Table

		SET @start_time = GETDATE();

		PRINT '';
		PRINT '>> Truncating Table: Silver.crm_prd_info';
		TRUNCATE TABLE Silver.crm_prd_info;

		PRINT '>> Inserting Data Into: Silver.crm_prd_info';
		SELECT
		    prd_id,
		    REPLACE( LEFT( TRIM( prd_key ), 5), '-', '_' ) cat_id,
		    SUBSTRING( TRIM( prd_key ), 7) prd_key,
		    prd_nm,
		    COALESCE(prd_cost, 0) prd_cost,
		    CASE UPPER( TRIM( prd_line ) )
		        WHEN 'M' THEN 'Mountain'
		        WHEN 'R' THEN 'Road'
		        WHEN 'T' THEN 'Touring'
		        WHEN 'S' THEN 'Others'
		        ELSE 'n/a'
		    END prd_line,
		    CAST( prd_start_dt AS DATE ) prd_start_dt,
		    CAST(
		        LEAD(prd_start_dt) OVER( PARTITION BY prd_key ORDER BY prd_start_dt ASC) -1
		        AS DATE ) prd_end_dt
		INTO Silver.crm_prd_info
		FROM Bronze.crm_prd_info;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		-- CRM : Sales Details Table

		SET @start_time = GETDATE();

		PRINT '';
		PRINT '>> Truncating Table: Silver.crm_sales_details';
		TRUNCATE TABLE Silver.crm_sales_details;

		PRINT '>> Inserting Data Into: Silver.crm_sales_details';
		SELECT
		    sls_ord_num,
		    sls_prd_key,
		    sls_cust_id,
		
		    CASE WHEN sls_order_dt <= 0 OR LEN( sls_order_dt ) != 8
		        THEN NULL
		        ELSE CAST( CAST( sls_order_dt AS NVARCHAR ) AS DATE )
		    END sls_order_dt,
		
		    CASE WHEN sls_ship_dt <= 0 OR LEN( sls_ship_dt ) != 8
		        THEN NULL
		        ELSE CAST( CAST( sls_ship_dt AS NVARCHAR ) AS DATE )
		    END sls_ship_dt,
		
		    CASE WHEN sls_due_dt <= 0 OR LEN( sls_due_dt ) != 8
		        THEN NULL
		        ELSE CAST( CAST( sls_due_dt AS NVARCHAR ) AS DATE )
		    END sls_due_dt,
		
		    CASE WHEN sls_sales <=0 OR sls_sales IS NULL OR sls_sales != ( sls_quantity * ABS(sls_price) )
		        THEN ( sls_quantity * ABS(sls_price) )
		        ELSE sls_sales
		    END sls_sales,
		
		    sls_quantity,
		
		    CASE WHEN sls_price <=0 OR sls_price IS NULL
		        THEN ABS( sls_sales ) / NULLIF( sls_quantity, 0 )
		        ELSE sls_price
		    END sls_price
		
		INTO Silver.crm_sales_details
		FROM Bronze.crm_sales_details;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';


		PRINT '';
		PRINT '-------------------------------------------------------';
		PRINT '				  Loading ERP Tables';
		PRINT '-------------------------------------------------------';


		-- ERP : Customer Demographics Table

		SET @start_time = GETDATE();

		PRINT '';
		PRINT '>> Truncating Table: Silver.erp_cust_az12';
		TRUNCATE TABLE Silver.erp_cust_az12;

		PRINT '>> Inserting Data Into: Silver.erp_cust_az12';
		SELECT
		    CASE
		        WHEN TRIM( cid ) LIKE 'NAS%'
		        THEN SUBSTRING( cid, 4)
		        ELSE cid
		    END cid,
		    CASE
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END bdate,
		    CASE 
		        WHEN UPPER( TRIM( gen ) ) IN ('M', 'MALE') THEN 'Male'
		        WHEN UPPER( TRIM( gen ) ) IN ('F', 'FEMALE') THEN 'Female'
		        ELSE 'n/a'
		    END gen
		INTO Silver.erp_cust_az12
		FROM Bronze.erp_cust_az12;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		-- ERP : Customer Location Table

		SET @start_time = GETDATE();

		PRINT '';
		PRINT '>> Truncating Table: Silver.erp_loc_a101';
		TRUNCATE TABLE Silver.erp_loc_a101;
	
		PRINT '>> Inserting Data Into: Silver.erp_loc_a101';
		SELECT
		    REPLACE( TRIM(cid), '-', '' ) cid,
		    CASE
		        WHEN TRIM( cntry ) = 'DE' THEN 'Germany'
				WHEN TRIM( cntry ) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM( cntry ) = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM( cntry )
			END AS cntry
		INTO Silver.erp_loc_a101
		FROM Bronze.erp_loc_a101;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		-- ERP : Product Category Table

		SET @start_time = GETDATE();

		PRINT '';
		PRINT '>> Truncating Table: Silver.erp_px_cat_g1v2';
		TRUNCATE TABLE Silver.erp_px_cat_g1v2;

		PRINT '>> Inserting Data Into: Silver.erp_px_cat_g1v2';
		SELECT
		    CASE WHEN id='CO_PD' THEN 'CO_PE' ELSE id
		    END id,
		    cat,
		    subcat,
		    maintainance
		INTO Silver.erp_px_cat_g1v2
		FROM Bronze.erp_px_cat_g1v2;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';


		SET @batch_end_time = GETDATE();
		PRINT '';
		PRINT '=======================================================';
		PRINT '		   Completed Loading The Silver Layer';
		PRINT '=======================================================';
		PRINT 'Total Loading Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';


	END TRY

	BEGIN CATCH
		PRINT '';
		PRINT '=======================================================';
		PRINT '	   AN ERROR OCCURED LOADING THE Silver LAYER!';
		PRINT '=======================================================';
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
		PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
		PRINT 'Error Procedure: ' + ERROR_PROCEDURE();
	END CATCH

END;
GO

-- Execute the stored procedure to complete loading the data.

EXEC Silver.load_silver;
GO
