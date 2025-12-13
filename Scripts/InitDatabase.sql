/*
===========================================================================
                        Create Database and Schemas
===========================================================================

Script Purpose:

This script creates a database named 'DataWarehouse'. If the database already
exists,it will be dropped and recreated. After creation, the script initializes
three schemas within the database: 'Bronze', 'Silver', and 'Gold'.

---

⚠️ CRITICAL WARNING

If DataWarehouse already exists, running this script will permanently delete
the entire database and all its data before recreating it.
This action is irreversible.

Proceed only after confirming that you have verified, up-to-date backups and
fully understand the impact of data loss.
*/

-- Create the 'DataWarehouse' database (drop if it already exists)

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse';
BEGIN 
  DROP DATABASE DataWarehouse
END;
GO
  
CREATE DATABASE DataWarehouse;
GO

-- Switch to the 'DataWarehouse' database

USE DataWarehouse;
GO

-- Create schemas for 'Bronze', 'Silver', and 'Gold' layers

CREATE SCHEMA Bronze;
GO
  
CREATE SCHEMA Silver;
GO
  
CREATE SCHEMA Gold;
GO
