/*
===============================================================================
                           Product Performance Report
===============================================================================
Purpose:
    - To create a comprehensive 360-degree view of product performance.
    - To consolidate product details, sales metrics, and categorization logic.
    - To facilitate inventory analysis, pricing strategies, and performance tiering.

SQL Functions Used:
    - IF OBJECT_ID(), DROP, CREATE VIEW
    - SUM(), COUNT(), MIN(), MAX(), AVG()
    - DATEDIFF(), CAST()
    - CASE, LEFT JOIN
    - Window Functions (MAX OVER)

Tables Used:
    - Gold.fact_sales
    - Gold.dim_product
===============================================================================
*/

-- Make sure using the correct database

USE DataWarehouse;
GO

-----

IF OBJECT_ID( 'Gold.report_product', 'V' ) IS NOT NULL
    DROP VIEW Gold.report_product;
GO

CREATE VIEW Gold.report_product AS

/*--------------------------------------------------------
                     Base Table
 Retrieves core fields from fact and relevant dimensions
--------------------------------------------------------*/

WITH CTE_Product_Details AS (

SELECT
    p.product_id,
    p.product_name,
    p.subcategory,
    p.category,
    p.cost,
    s.order_number,
    s.customer_sk,
    s.order_date,
    s.sales_amount,
    s.quantity,
    s.price
FROM Gold.fact_sales s
LEFT JOIN Gold.dim_product p
ON s.product_sk = p.product_sk
),


/*--------------------------------------------------------
                     Aggregated Table
       Summarizes Key Metrics at the Product level
--------------------------------------------------------*/

CTE_Product_Summary AS (

SELECT
    product_id,
    product_name,
    subcategory,
    category,
    cost,
    COUNT( DISTINCT order_number ) Total_Orders,
    SUM( sales_amount ) Total_Revenue,
    AVG( CAST( price AS FLOAT ) ) Avg_Selling_Price,
    SUM( quantity ) Total_Qty_Sold,
    MIN( order_date ) First_Order,
    MAX( order_date ) Last_Sale,
    DATEDIFF( month, MIN( order_date ), MAX( order_date ) ) Lifespan
FROM CTE_Product_Details
GROUP BY
    product_id,
    product_name,
    subcategory,
    category,
    cost
)


/*--------------------------------------------------------
                      Final Report
    Combines all Product details into one sinple output
--------------------------------------------------------*/

SELECT
    product_id,
    product_name,
    subcategory,
    category,
    cost,
    CASE
        WHEN cost < 500 THEN 'Cheap'
        WHEN cost BETWEEN 500 AND 1500 THEN 'Moderate'
        WHEN cost > 1500 THEN 'Expensive'
        ELSE 'unknown'
    END cost_group,
    CASE
        WHEN Total_Revenue >= 1000000 THEN 'Top Performer'
        WHEN Total_Revenue >= 200000 THEN 'High Performer'
        WHEN Total_Revenue >= 100000 THEN 'Mid Performer'
        WHEN Total_Revenue >= 40000 THEN 'Low Performer'
        WHEN Total_Revenue < 40000 THEN 'Underperformer'
        ELSE 'Others'
    END Segment,
    Total_Revenue,
    Total_Orders,
    Total_Qty_Sold,
    Avg_Selling_Price,
    Last_Sale,
    Lifespan,
    DATEDIFF( day, Last_Sale, MAX(Last_Sale) OVER() ) Recency_days
FROM CTE_Product_Summary;
GO


-- Query the View to see the Report

SELECT * FROM Gold.report_product;
GO

