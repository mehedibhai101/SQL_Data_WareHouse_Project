/*
===============================================================================
                             Magnitude Exploration
===============================================================================
Purpose:
    - To analyze the distribution of volume and value across different dimensions.
    - To compare performance across geographical regions, demographics, and product categories.
    - To identify high-value segments and inventory concentrations.

SQL Functions Used:
    - SUM(), COUNT(), AVG()
    - CASE
    - LEFT JOIN
    - GROUP BY, ORDER BY

Tables Used:
    - Gold.fact_sales
    - Gold.dim_customer
    - Gold.dim_product
===============================================================================
*/

-- Make sure using the correct database

USE DataWarehouse;
GO


-- Country wise Revenue

SELECT
    c.country,
    SUM( s.sales_amount ) Total_Revenue
FROM Gold.fact_sales s
LEFT JOIN   Gold.dim_customer c
ON          s.customer_sk = c.customer_sk
GROUP BY c.country
ORDER BY SUM( s.sales_amount ) DESC;


-- Total Customers from different Countries

SELECT
    country,
    COUNT( customer_key ) Total_Customers
FROM Gold.dim_customer
GROUP BY country
ORDER BY COUNT( customer_key ) DESC;


-- Gender wise Total Customers

SELECT
    gender,
    COUNT( customer_key ) Total_Customers
FROM Gold.dim_customer
GROUP BY gender
ORDER BY COUNT( customer_key );


-- Total Customers by Age Group

SELECT
    age_group,
    COUNT(*) Total_Customers
FROM (SELECT
        CASE
            WHEN age < 40 THEN 'below 40'
            WHEN age < 50 THEN '40-49'
            WHEN age < 60 THEN '50-59'
            WHEN age < 70 THEN '60-69'
            WHEN age < 80 THEN '70-79'
            WHEN age < 90 THEN '80-89'
            WHEN age < 100 THEN '90-99'
            WHEN age < 110 THEN '100-109'
            WHEN age >= 110 THEN '109+'
            ELSE 'unknown'
        END age_group
    FROM Gold.dim_customer
)t
GROUP BY age_group
ORDER BY COUNT(*) DESC;


-- Category wise Revenue & Total Orders

SELECT
    p.category,
    SUM( s.sales_amount ) Total_Revenue,
    COUNT( DISTINCT order_number ) Total_Orders
FROM Gold.fact_sales s
LEFT JOIN   Gold.dim_product p
ON          s.product_sk = p.product_sk
GROUP BY p.category
ORDER BY SUM( s.sales_amount ) DESC;


-- Total Products of different Categories

SELECT
    category,
    COUNT( product_name ) Total_Products
FROM Gold.dim_product
GROUP BY category
ORDER BY COUNT( product_name ) DESC;


-- Avg Cost of different Categories

SELECT
    category,
    AVG( cost ) Total_Products
FROM Gold.dim_product
GROUP BY category
ORDER BY AVG( cost ) DESC;

