/*
===============================================================================
                             Database Exploration
===============================================================================
Purpose:
    - To list all tables and views in the database.
    - To examine the schema details (columns, data types) for database objects.
    - To preview the first 1000 rows of key Gold layer tables.

SQL Functions Used:
    - TOP

Tables Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

-- Make sure using the correct database

USE DataWarehouse;
GO


-- Explore tables and objects in the database

SELECT * FROM INFORMATION_SCHEMA.TABLES;


-- Explore fields of each table in the database

SELECT * FROM INFORMATION_SCHEMA.COLUMNS;


-- Explore each table's data

SELECT TOP 1000 * FROM Gold.dim_customer;
SELECT TOP 1000 * FROM Gold.dim_product;
SELECT TOP 1000 * FROM Gold.fact_sales;
