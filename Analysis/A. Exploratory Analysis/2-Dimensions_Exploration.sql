/*
===============================================================================
                             Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure and unique values within dimension tables.
    - To retrieve distinct lists of countries, product categories, and hierarchies.

SQL Functions Used:
    - DISTINCT

Tables Used:
    - Gold.dim_customer
    - Gold.dim_product
===============================================================================
*/

-- Make sure using the correct database

USE DataWarehouse;
GO


-- Explore different countries customers are from

SELECT DISTINCT country FROM Gold.dim_customer;


-- Explore existing product categories

SELECT DISTINCT category FROM Gold.dim_product;


-- Explore subcategories within the categories

SELECT DISTINCT category, subcategory FROM Gold.dim_product;


-- Explore each product with category informations

SELECT DISTINCT category, subcategory, product_name FROM Gold.dim_product;


-- Explore the product lines

SELECT DISTINCT product_line FROM Gold.dim_product;

