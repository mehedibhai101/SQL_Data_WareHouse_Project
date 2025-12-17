/*
===============================================================================
                                Trend Analysis
===============================================================================
Purpose:
    - To analyze business performance over various time granularities.
    - To identify seasonal patterns, growth trends, and peak activity periods.
    - To observe the relationship between customer volume and revenue over time.

SQL Functions Used:
    - DATETRUNC(), YEAR(), MONTH(), DATEPART(), DATENAME()
    - SUM(), COUNT(DISTINCT)
    - GROUP BY, ORDER BY

Tables Used:
    - Gold.fact_sales
===============================================================================
*/

-- Make sure using the correct database

USE DataWarehouse;
GO


-- Total Sales & Total Customers trend over Time

SELECT
    DATETRUNC( month, order_date ) Year_Month,
    SUM( sales_amount ) Total_Sales,
    COUNT( DISTINCT customer_sk ) Total_Customers
FROM Gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC( month, order_date )
ORDER BY DATETRUNC( month, order_date );


-- Yearly Revenue and Total Customers

SELECT
    YEAR( order_date ) 'Year',
    SUM( sales_amount ) Revenue,
    COUNT( DISTINCT customer_sk ) Total_Customers
FROM Gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR( order_date )
ORDER BY YEAR( order_date );


-- Annual Sales Trend

SELECT
    MONTH( order_date ) 'Month',
    DATENAME( month, order_date ) 'Month Name',
    SUM( sales_amount ) Revenue
FROM Gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH( order_date ), DATENAME( month, order_date )
ORDER BY MONTH( order_date );


-- Weekly Crowd

SELECT
    DATEPART( weekday, order_date) 'Weekday',
    DATENAME( weekday, order_date ) 'Weekday Name',
    COUNT( DISTINCT order_number ) Total_Orders
FROM Gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATEPART( weekday, order_date), DATENAME( weekday, order_date )
ORDER BY DATEPART( weekday, order_date);

