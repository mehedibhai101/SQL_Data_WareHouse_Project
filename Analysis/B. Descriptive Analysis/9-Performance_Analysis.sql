/*
===============================================================================
                             Performance Analysis
===============================================================================
Purpose:
    - To evaluate product subcategory performance relative to historical averages.
    - To calculate Year-Over-Year (YoY) sales growth and identifying trends.
    - To segment performance into qualitative categories (Over/Under Avg, Increase/Decrease).

SQL Functions Used:
    - AVG() OVER(), LAG() OVER()
    - YEAR()
    - CASE
    - Common Table Expressions (CTEs)
    - LEFT JOIN
    - GROUP BY, ORDER BY

Tables Used:
    - Gold.fact_sales
    - Gold.dim_product
===============================================================================
*/

-- Make sure using the correct database

USE DataWarehouse;
GO


-- Product Performance Compared to Average Sales and YoY Growth

WITH Product_Sales AS
(
    SELECT
        p.subcategory,
        YEAR( s.order_date ) AS order_year,
        SUM( s.sales_amount ) AS Total_Sales
    FROM Gold.fact_sales AS s
    LEFT JOIN Gold.dim_product AS p
        ON s.product_sk = p.product_sk
    WHERE s.order_date IS NOT NULL
    GROUP BY
        p.subcategory,
        YEAR( s.order_date )
),
Product_Analytics AS
(
    SELECT
        subcategory,
        order_year,
        Total_Sales,
        AVG( Total_Sales ) OVER ( PARTITION BY subcategory ) AS avg_sales,
        LAG( Total_Sales ) OVER ( PARTITION BY subcategory ORDER BY order_year ) AS prev_year_sales
    FROM Product_Sales
)
SELECT
    subcategory,
    order_year,
    Total_Sales,

    -- Compare to Average
    avg_sales,
    Total_Sales - avg_sales AS Diff_Avg,
    CASE
        WHEN Total_Sales > avg_sales THEN 'Over Avg'
        WHEN Total_Sales < avg_sales THEN 'Under Avg'
        ELSE 'Avg'
    END AS Compare_Avg,

    -- YoY Growth Analysis
    Total_Sales - prev_year_sales AS Vs_PY_Sales,
    CASE
        WHEN Total_Sales > prev_year_sales THEN 'Increase'
        WHEN Total_Sales < prev_year_sales THEN 'Decrease'
        ELSE NULL
    END AS Compare_PY
FROM Product_Analytics;

