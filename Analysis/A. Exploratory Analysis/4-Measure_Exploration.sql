/*
===============================================================================
Measure Exploration
===============================================================================
Purpose:
    - To calculate high-level Business KPIs (Key Performance Indicators).
    - To analyze sales performance, order metrics, and customer activity.
    - To provide a consolidated view of business health across various dimensions.

SQL Functions Used:
    - SUM(), COUNT(), AVG(), MIN(), MAX()
    - CAST(), ROUND()
    - GROUP BY
    - UNION ALL

Tables Used:
    - Gold.fact_sales
    - Gold.dim_customer
    - Gold.dim_product
===============================================================================
*/

-- Make sure using the correct database

USE DataWarehouse;
GO


-->> Business KPI Report <<--

    -- Total Sales Amount

    SELECT
        'Total Sales Amount:' AS KPI,
        SUM(sales_amount) AS Value
    FROM Gold.fact_sales


    -- Total Orders

UNION ALL
    SELECT
        'Total Orders:',
        COUNT(*)
    FROM (SELECT DISTINCT order_number FROM Gold.fact_sales)t


    -- Maximum Orders by a Customer

UNION ALL
    SELECT
        'Max Customer Orders:',
        MAX( total_orders )
    FROM ( SELECT 
        COUNT( DISTINCT order_number ) total_orders
        FROM Gold.fact_sales
        GROUP BY customer_sk )t


    -- Avg Order Value

UNION ALL
    SELECT
        'Avg Order Value:',
        ROUND( AVG( CAST( order_value AS FLOAT ) ), 2 )
    FROM ( SELECT 
        SUM( sales_amount ) order_value
        FROM Gold.fact_sales
        GROUP BY order_number )t


    -- Maximum Order Value

UNION ALL
    SELECT
        'Max Order Value:',
        MAX( order_value )
    FROM ( SELECT 
        SUM( sales_amount ) order_value
        FROM Gold.fact_sales
        GROUP BY order_number )t


    -- Total Qty Sold

UNION ALL
    SELECT
        'Total Qty Sold:',
        SUM( quantity )
    FROM Gold.fact_sales


    -- Avg Quantity Sold

UNION ALL
    SELECT
        'Avg Qtuantity Sold:',
        ROUND( AVG( CAST( order_quantity AS FLOAT ) ), 2 )
    FROM ( SELECT 
        SUM( quantity ) order_quantity
        FROM Gold.fact_sales
        GROUP BY order_number )t


    -- Avg Price per Order

UNION ALL
    SELECT
        'Avg Product Price per Order:',
        ROUND( AVG( CAST( avg_price AS FLOAT ) ), 2 )
    FROM ( SELECT 
        AVG( CAST( price AS FLOAT ) ) avg_price
        FROM Gold.fact_sales
        GROUP BY order_number )t


    -- Avg Product Cost

UNION ALL
    SELECT
        'Avg Product Cost:',
        ROUND( AVG( CAST( cost AS FLOAT ) ), 2 )
    FROM Gold.dim_product


    -- Total Customers

UNION ALL
    SELECT
        'Total Customers:',
        COUNT( customer_key )
    FROM Gold.dim_customer


    -- Active Customers

UNION ALL
    SELECT
        'Active Customers:',
        COUNT( DISTINCT customer_sk )
    FROM Gold.fact_sales


    -- Avg Purchase per Customer

UNION ALL
    SELECT
        'Avg Purchase per Customer:',
        ROUND( AVG( CAST( purchase_amount AS FLOAT ) ), 2 )
    FROM ( SELECT 
        SUM( CAST( sales_amount AS FLOAT ) ) purchase_amount
        FROM Gold.fact_sales
        GROUP BY customer_sk )t;

