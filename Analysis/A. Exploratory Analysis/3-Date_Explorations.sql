/*
===============================================================================
                              Date Explorations
===============================================================================
Purpose:
    - To analyze the chronological lifespan of business operations.
    - To calculate performance metrics related to shipping lead times.
    - To determine the demographic age distribution of the customer base.

SQL Functions Used:
    - MIN(), MAX(), AVG()
    - DATEDIFF(), CAST(), ROUND()
    - PRINT
    - UNION ALL

Tables Used:
    - Gold.fact_sales
    - Gold.dim_customer
===============================================================================
*/

-- Make sure using the correct database

USE DataWarehouse;
GO


-- Explore Business Lifespan

DECLARE @start_date DATE, @end_date DATE, @years INT
SELECT 
    @start_date = MIN(order_date),
    @end_date = MAX(order_date),
    @years = DATEDIFF( year, MIN(order_date), MAX(order_date) )
FROM Gold.fact_sales
PRINT '======================================='
PRINT '            Business Lifespan'
PRINT '======================================='
PRINT 'Business Start Date: ' + CAST( @start_date AS NVARCHAR )
PRINT 'Last Active Date: ' + CAST( @end_date AS NVARCHAR )
PRINT 'Total Business Years: ' + CAST( @years AS NVARCHAR )


-- Explore Avg Shipping Duration

SELECT
    ROUND( AVG( CAST( DATEDIFF( day, order_date, shipping_date ) AS FLOAT ) ), 5 )
        AS 'Avg_Shipping_Duration(days)'
FROM Gold.fact_sales


-- Explore customer's age range

SELECT
    'Youngest Customer: ' AS Dimension,
    MIN(age) AS Age
FROM Gold.dim_customer

UNION ALL 

SELECT
    'Oldest Customer: ',
    MAX(age)
FROM Gold.dim_customer

