/*
===========================================================================
                Load Data into Silver Layer (Bulk Insert)
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
		BULK INSERT Silver.crm_cust_info
		FROM 'C:\Users\perennial\SQL\SQL_Data_Warehouse_Project\Datasets\CRM\cust_info.csv'
		WITH (
			FIRSTROW = 2, -- First rows from source files contains header
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		-- CRM : Product Info Table

		SET @start_time = GETDATE();

		PRINT '';
		PRINT '>> Truncating Table: Silver.crm_prd_info';
		TRUNCATE TABLE Silver.crm_prd_info;

		PRINT '>> Inserting Data Into: Silver.crm_prd_info';
		BULK INSERT Silver.crm_prd_info
		FROM 'C:\Users\perennial\SQL\SQL_Data_Warehouse_Project\Datasets\CRM\prd_info.csv'
		WITH (
			FIRSTROW = 2, -- First rows from source files contains header
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		-- CRM : Sales Details Table

		SET @start_time = GETDATE();

		PRINT '';
		PRINT '>> Truncating Table: Silver.crm_sales_details';
		TRUNCATE TABLE Silver.crm_sales_details;

		PRINT '>> Inserting Data Into: Silver.crm_sales_details';
		BULK INSERT Silver.crm_sales_details
		FROM 'C:\Users\perennial\SQL\SQL_Data_Warehouse_Project\Datasets\CRM\sales_details.csv'
		WITH (
			FIRSTROW = 2, -- First rows from source files contains header
			FIELDTERMINATOR = ',',
			TABLOCK
		);

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
		BULK INSERT Silver.erp_cust_az12
		FROM 'C:\Users\perennial\SQL\SQL_Data_Warehouse_Project\Datasets\ERP\cust_az12.csv'
		WITH (
			FIRSTROW = 2, -- First rows from source files contains header
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		-- ERP : Customer Location Table

		SET @start_time = GETDATE();

		PRINT '';
		PRINT '>> Truncating Table: Silver.erp_loc_a101';
		TRUNCATE TABLE Silver.erp_loc_a101;
	
		PRINT '>> Inserting Data Into: Silver.erp_loc_a101';
		BULK INSERT Silver.erp_loc_a101
		FROM 'C:\Users\perennial\SQL\SQL_Data_Warehouse_Project\Datasets\ERP\loc_a101.csv'
		WITH (
			FIRSTROW = 2, -- First rows from source files contains header
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		-- ERP : Product Category Table

		SET @start_time = GETDATE();

		PRINT '';
		PRINT '>> Truncating Table: Silver.erp_px_cat_g1v2';
		TRUNCATE TABLE Silver.erp_px_cat_g1v2;

		PRINT '>> Inserting Data Into: Silver.erp_px_cat_g1v2';
		BULK INSERT Silver.erp_px_cat_g1v2
		FROM 'C:\Users\perennial\SQL\SQL_Data_Warehouse_Project\Datasets\ERP\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2, -- First rows from source files contains header
			FIELDTERMINATOR = ',',
			TABLOCK
		);

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
