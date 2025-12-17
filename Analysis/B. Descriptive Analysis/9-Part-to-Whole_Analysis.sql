/*
===============================================================================
                            Part-to-Whole Analysis
===============================================================================
Purpose:
    - To analyze the relative contribution of different dimensions to the total.
    - To calculate percentage shares for product categories, countries, and demographics.
    - To identify key drivers of revenue and customer volume across the business.

SQL Functions Used:
    - SUM() OVER(), COUNT()
    - CAST(), ROUND(), CONCAT()
    - Common Table Expressions (CTEs)
    - LEFT JOIN
    - GROUP BY
===============================================================================
*/

-- Make sure using the correct database

USE DataWarehouse;
GO


-- %Comtribution of different Categories to the Total Sales

WITH CTE_Cat_Sales AS (
    SELECT
        p.category,
        SUM( s.sales_amount ) AS Cat_Sales
    FROM Gold.fact_sales s
    LEFT JOIN Gold.dim_product p
           ON s.product_sk = p.product_sk
    GROUP BY p.category
)
SELECT 
    category,
    Cat_Sales,
    CONCAT( ROUND( CAST( Cat_Sales AS FLOAT ) / SUM( Cat_Sales ) OVER() * 100, 2 ), '%' ) '%Sales'
FROM CTE_Cat_Sales


-- %Comtribution of different Countries to the Total Sales

WITH CTE_Country_Sales AS (
    SELECT
        c.country,
        SUM( s.sales_amount ) AS Country_Sales
    FROM Gold.fact_sales s
    LEFT JOIN Gold.dim_customer c
           ON s.customer_sk = c.customer_sk
    GROUP BY c.country
)
SELECT 
    country,
    Country_Sales,
    CONCAT( ROUND( CAST( Country_Sales AS FLOAT ) / SUM( Country_Sales ) OVER() * 100, 2 ), '%' ) '%Sales'
FROM CTE_Country_Sales


-- Total Customers % by Gender

WITH CTE_Gender_Customer AS (
    SELECT
        gender,
        COUNT( customer_id ) Gender_Customers
    FROM Gold.dim_customer
    GROUP BY gender
)
SELECT 
    gender,
    Gender_Customers,
    CONCAT( ROUND( CAST( Gender_Customers AS FLOAT ) / SUM( Gender_Customers ) OVER() * 100, 2 ), '%' ) '%Sales'
FROM CTE_Gender_Customer

