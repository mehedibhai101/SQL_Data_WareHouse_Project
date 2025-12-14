/*
===========================================================================
                Load Data into Bronze Layer (Bulk Insert)
===========================================================================

Script Purpose:
This script creates a stored procedure 'Bronze.load_bronze' that loads raw
data from source CSV files (CRM and ERP) into the Bronze-layer tables of the
'DataWarehouse' database. The procedure truncates each table before inserting
fresh data to ensure that only the latest dataset is present.

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
- Measures and prints load durations for each table and the entire batch.
- Uses TRY…CATCH for error handling and prints detailed error messages if
  the loading process fails.
- Bulk Insert is performed from CSV files located in source directories.
- Tables are truncated before loading to maintain a clean dataset.

Parameters:
This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Bronze.load_bronze;

---------------------------------------------------------------------------
⚠️ CRITICAL WARNING
---------------------------------------------------------------------------

Running this procedure will permanently delete all existing data in the
Bronze-layer tables before loading new data. Ensure that you have verified
backups of any important data and fully understand the consequences before
executing this procedure.
*/

-- Create stored procedure to load data when updated.

CREATE OR ALTER PROCEDURE Bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME,
		@batch_start_time DATETIME, @batch_end_time DATETIME;

	BEGIN TRY 
		SET @batch_start_time = GETDATE();

		PRINT '=======================================================';
		PRINT '				  Loading Bronze Layer';
		PRINT '=======================================================';

		PRINT '-------------------------------------------------------';
		PRINT '				   Loading CRM Tables';
		PRINT '-------------------------------------------------------';


		-- CRM : Customer Info Table

		SET @start_time = GETDATE();

		PRINT '';
		PRINT '>> Truncating Table: Bronze.crm_cust_info';
		TRUNCATE TABLE Bronze.crm_cust_info;

		PRINT '>> Inserting Data Into: Bronze.crm_cust_info';
		BULK INSERT Bronze.crm_cust_info
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
		PRINT '>> Truncating Table: Bronze.crm_prd_info';
		TRUNCATE TABLE Bronze.crm_prd_info;

		PRINT '>> Inserting Data Into: Bronze.crm_prd_info';
		BULK INSERT Bronze.crm_prd_info
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
		PRINT '>> Truncating Table: Bronze.crm_sales_details';
		TRUNCATE TABLE Bronze.crm_sales_details;

		PRINT '>> Inserting Data Into: Bronze.crm_sales_details';
		BULK INSERT Bronze.crm_sales_details
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
		PRINT '>> Truncating Table: Bronze.erp_cust_az12';
		TRUNCATE TABLE Bronze.erp_cust_az12;

		PRINT '>> Inserting Data Into: Bronze.erp_cust_az12';
		BULK INSERT Bronze.erp_cust_az12
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
		PRINT '>> Truncating Table: Bronze.erp_loc_a101';
		TRUNCATE TABLE Bronze.erp_loc_a101;
	
		PRINT '>> Inserting Data Into: Bronze.erp_loc_a101';
		BULK INSERT Bronze.erp_loc_a101
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
		PRINT '>> Truncating Table: Bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE Bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting Data Into: Bronze.erp_px_cat_g1v2';
		BULK INSERT Bronze.erp_px_cat_g1v2
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
		PRINT '		   Completed Loading The Bronze Layer';
		PRINT '=======================================================';
		PRINT 'Total Loading Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';


	END TRY

	BEGIN CATCH
		PRINT '';
		PRINT '=======================================================';
		PRINT '	   AN ERROR OCCURED LOADING THE BRONZE LAYER!';
		PRINT '=======================================================';
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
		PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
		PRINT 'Error Procedure: ' + ERROR_PROCEDURE();
	END CATCH

END;
GO

-- Execute the stored procedure to complete loading the data.

EXEC Bronze.load_bronze;
GO
