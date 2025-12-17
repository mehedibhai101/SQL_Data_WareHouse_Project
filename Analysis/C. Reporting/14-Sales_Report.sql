/*
===============================================================================
                           Sales Seasonality Report
===============================================================================
Purpose:
    - To provide a consolidated view of business performance over time.
    - To analyze monthly and yearly trends for revenue, orders, and customers.
    - To facilitate time-series forecasting and seasonal performance reviews.

SQL Functions Used:
    - SUM(), COUNT(DISTINCT)
    - DATETRUNC(), YEAR(), MONTH()
    - Window Functions

Tables Used:
    - Gold.fact_sales
===============================================================================
*/

-- Make sure using the correct database

USE DataWarehouse;
GO

-----

IF OBJECT_ID( 'Gold.report_trends', 'V' ) IS NOT NULL
    DROP VIEW Gold.report_trends;
GO

CREATE VIEW Gold.report_trends AS


/*--------------------------------------------------------
                       Base Table
        Retrieves core fields from relevant table
--------------------------------------------------------*/

WITH CTE_Sales_Details AS (

SELECT
    order_number,
    order_date,
    sales_amount,
    quantity,
    customer_sk
FROM Gold.fact_sales
),



/*--------------------------------------------------------
                     Aggregated Table
       Summarizes Key Metrics at the Monthly level
--------------------------------------------------------*/

CTE_Sales_Trends AS (
    SELECT
        DATETRUNC( month, order_date ) AS order_month,
        SUM( sales_amount ) AS Monthly_Revenue,
        COUNT( DISTINCT order_number ) AS Monthly_Orders,
        COUNT( quantity ) AS Monthly_Quantity_Sold,
        COUNT( DISTINCT customer_sk ) AS Monthly_Active_Customers
    FROM CTE_Sales_Details
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC( month, order_date )
)



/*--------------------------------------------------------
                      Final Report
    Adds cumulative metrics and time-based descriptors
--------------------------------------------------------*/

SELECT
    order_month,
    YEAR( order_month ) AS order_year,
    MONTH( order_month ) AS order_month_num,
    DATENAME( month, order_month ) AS order_month_name,
    Monthly_Revenue,
    -- Cumulative Revenue (Year-to-Date style)
    SUM( Monthly_Revenue ) OVER (  PARTITION BY YEAR(order_month) ORDER BY order_month ) AS YTD_Revenue,
    -- Running Total Revenue (Lifetime)
    SUM( Monthly_Revenue ) OVER ( ORDER BY order_month ) AS Running_Total_Revenue,
    Monthly_Orders,
    Monthly_Quantity_Sold,
    Monthly_Active_Customers,
    -- Avg Order Value and Moving Avg over Time
    CASE
        WHEN Monthly_Orders = 0 THEN 0
        ELSE Monthly_Revenue / Monthly_Orders
    END Avg_Order_Value,
    AVG( CASE WHEN Monthly_Orders = 0 THEN 0 ELSE Monthly_Revenue / Monthly_Orders END ) 
        OVER ( ORDER BY order_month ) AS Moving_Avg_Order_Value
FROM CTE_Sales_Trends;
GO


-- Query the View to see the Report

SELECT * FROM Gold.report_trends
ORDER BY order_month;
GO

