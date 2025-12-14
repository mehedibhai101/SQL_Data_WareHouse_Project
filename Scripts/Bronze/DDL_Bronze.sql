/*
===========================================================================
                            Create Bronze Tables
===========================================================================

Script Purpose:
This script creates all the Bronze-layer tables in the 'DataWarehouse' database
according to the source systems (CRM and ERP). It follows the naming conventions
for tables and columns as per the source system structure.

Tables Created:

CRM Source System:
    - crm_cust_info       : Customer information
    - crm_prd_info        : Product information
    - crm_sales_details   : Sales data

ERP Source System:
    - erp_cust_az12       : Customer demographics
    - erp_loc_a101        : Customer locations
    - erp_px_cat_g1v2     : Product category information

Important Notes:
- If a table already exists, it will be dropped and recreated. This will result
  in permanent loss of all data in the existing table.
- Data types and column lengths are defined based on the source system.
- Some numeric fields use INT as the source system does not contain decimals.

---------------------------------------------------------------------------
⚠️ CRITICAL WARNING
---------------------------------------------------------------------------

Dropping existing tables will permanently delete all their data. Ensure that 
you have valid, up-to-date backups and fully understand the consequences before
running this script.
*/

-- Make sure using the correct database 'DataWarehouse'

USE DataWarehouse;
GO

/* Creating tables according to the source system
		(following the naming convention)		*/

-- CRM : Customer Info Table

IF OBJECT_ID('Bronze.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE Bronze.crm_cust_info;

CREATE TABLE Bronze.crm_cust_info (
	cst_id				INT,
	cst_key				NVARCHAR(50),
	cst_first_name		NVARCHAR(50),
	cst_last_name		NVARCHAR(50),
	cst_marital_status	NVARCHAR(50),
	cst_gender			NVARCHAR(50),
	cst_create_date		DATE
);
GO

-- CRM : Product Info Table

IF OBJECT_ID('Bronze.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE Bronze.crm_prd_info;

CREATE TABLE Bronze.crm_prd_info (
	prd_id			INT,
	prd_key			NVARCHAR(50),
	prd_nm			NVARCHAR(50),
	prd_cost		INT, --there's no decimal cost in the system
	prd_line		NVARCHAR(50),
	prd_start_dt	DATETIME,
	prd_end_dt		DATETIME
);
GO

-- CRM : Sales Details Table

IF OBJECT_ID('Bronze.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE Bronze.crm_sales_details;

CREATE TABLE Bronze.crm_sales_details (
	sls_ord_num		NVARCHAR(50),
	sls_prd_key		NVARCHAR(50),
	sls_cust_id		INT,
	sls_order_dt	INT,
	sls_ship_dt		INT,
	sls_due_dt		INT,
	sls_sales		INT, --as no product has a decimal cost
	sls_quantity	INT,
	sls_price		INT
);
GO

-- ERP : Customer Table

IF OBJECT_ID('Bronze.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE Bronze.erp_cust_az12;

CREATE TABLE Bronze.erp_cust_az12 (
	cid		NVARCHAR(50),
	bdate	DATE,
	gen		NVARCHAR(50)
);
GO

-- ERP : Customer Location Table

IF OBJECT_ID('Bronze.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE Bronze.erp_loc_a101;

CREATE TABLE Bronze.erp_loc_a101 (
	cid		NVARCHAR(50),
	cntry	NVARCHAR(50)
);
GO

-- ERP : Product Category Table

IF OBJECT_ID('Bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE Bronze.erp_px_cat_g1v2;

CREATE TABLE Bronze.erp_px_cat_g1v2 (
	id				NVARCHAR(50),
	cat				NVARCHAR(50),
	subcat			NVARCHAR(50),
	maintainance	NVARCHAR(50)
);
GO
