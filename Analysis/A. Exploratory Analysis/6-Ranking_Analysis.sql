/*
===============================================================================
                               Ranking Analysis
===============================================================================
Purpose:
    - To identify top-performing and underperforming business entities.
    - To rank customers and products based on sales volume and order frequency.
    - To apply advanced statistical ranking (CUME_DIST) for tier-based analysis.

SQL Functions Used:
    - TOP
    - SUM(), COUNT()
    - CUME_DIST() OVER()
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


-- Top Profitable Customers 

SELECT TOP 10
    c.customer_id,
    c.customer_name,
    SUM( s.sales_amount ) Total_Sales
FROM Gold.fact_sales s
LEFT JOIN Gold.dim_customer c
ON        s.customer_sk = c.customer_sk
GROUP BY c.customer_id, c.customer_name
ORDER BY SUM( s.sales_amount ) DESC;


-- Best Selling Subcategories

SELECT TOP 5
    p.subcategory,
    COUNT( DISTINCT s.order_number ) Total_Orders
FROM Gold.fact_sales s
LEFT JOIN Gold.dim_product p
ON        s.product_sk = p.product_sk
GROUP BY subcategory
ORDER BY COUNT( DISTINCT order_number ) DESC;


-- Worst Selling Subcategories

SELECT TOP 5
    p.subcategory,
    COUNT( DISTINCT s.order_number ) Total_Orders
FROM Gold.fact_sales s
LEFT JOIN Gold.dim_product p
ON        s.product_sk = p.product_sk
GROUP BY subcategory
ORDER BY COUNT( DISTINCT order_number ) ASC;


-- Top Profitable Products

SELECT
    product_name,
    Total_Sales
FROM (
    SELECT
        p.product_name,
        SUM( sales_amount ) Total_Sales,
        CUME_DIST() OVER( ORDER BY SUM( sales_amount ) DESC ) Cume_Rank
    FROM Gold.fact_sales s
    LEFT JOIN Gold.dim_product p
    ON        s.product_sk = p.product_sk
    GROUP BY p.product_name )t
WHERE Cume_Rank <= 0.1;

