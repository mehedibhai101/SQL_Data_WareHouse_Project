/*
===============================================================================
                             Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals and moving averages for sales performance.
    - To observe longitudinal growth patterns across months and years.
    - To analyze periodic performance using rolling totals and partitions.

SQL Functions Used:
    - SUM() OVER(), AVG()
    - DATETRUNC(), YEAR()
    - Common Table Expressions (CTEs)
    - GROUP BY, ORDER BY
    - PARTITION BY

Tables Used:
    - Gold.fact_sales
===============================================================================
*/

-- Make sure using the correct database

USE DataWarehouse;
GO


-- Running Total Sales over Time

WITH CTE_Sales_Time AS (
    SELECT
        DATETRUNC( month, order_date ) Year_Month,
        SUM( sales_amount ) Total_Sales
    FROM Gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC( month, order_date )
) 
SELECT
    Year_Month,
    SUM( Total_Sales ) OVER( ORDER BY Year_Month ) Running_Total_Sales
FROM CTE_Sales_Time;


-- Moving Average Sales over Time
WITH CTE_Sales_Time_Order AS (
    SELECT
        DATETRUNC( month, order_date ) Year_Month,
        COUNT( DISTINCT order_number ) Total_Orders,
        SUM( sales_amount ) Total_Sales_Order
    FROM Gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC( month, order_date )
) 
SELECT
    Year_Month,
    AVG( CASE WHEN Total_Orders = 0 THEN 0 ELSE Total_Sales_Order / Total_Orders END ) 
        OVER( ORDER BY Year_Month ) Moving_Avg_Sales
FROM CTE_Sales_Time_Order;


-- Rolling Total Sales (Year) over Time

WITH CTE_Sales_Time AS (
    SELECT
        DATETRUNC( month, order_date ) Year_Month,
        SUM( sales_amount ) Total_Sales
    FROM Gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC( month, order_date )
) 
SELECT
    Year_Month,
    SUM( Total_Sales ) OVER( PARTITION BY YEAR(Year_Month) ORDER BY Year_Month ) Running_Total_Sales
FROM CTE_Sales_Time;


-- Running Total Sales over Years

WITH CTE_Sales_Year AS (
    SELECT
        YEAR( order_date ) AS [Year],
        SUM( sales_amount ) Total_Sales
    FROM Gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR( order_date )
) 
SELECT
    [Year],
    SUM( Total_Sales ) OVER( ORDER BY [Year] ) Running_Total_Sales
FROM CTE_Sales_Year;

