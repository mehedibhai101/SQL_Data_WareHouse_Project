/*
===============================================================================
                           Customer Analysis Report
===============================================================================
Purpose:
    - To create a comprehensive 360-degree view of customer behavior.
    - To consolidate demographic details, purchase history, and calculated KPIs.
    - To facilitate customer segmentation and recency analysis for marketing.

SQL Functions Used:
    - SUM(), COUNT(), MIN(), MAX(), DATEDIFF()
    - CASE, LEFT JOIN
    - Window Functions

Tables Used:
    - Gold.fact_sales
    - Gold.dim_customer
===============================================================================
*/

-- Make sure using the correct database

USE DataWarehouse;
GO

-----

IF OBJECT_ID( 'Gold.report_customer', 'V' ) IS NOT NULL
    DROP VIEW Gold.report_customer;
GO

CREATE VIEW Gold.report_customer AS

/*--------------------------------------------------------
                     Base Table
 Retrieves core fields from fact and relevant dimensions
--------------------------------------------------------*/

WITH CTE_Customer_Details AS (

SELECT
    c.customer_id,
    c.customer_name,
    c.age,
    s.order_number,
    s.order_date,
    s.sales_amount
FROM Gold.fact_sales s
LEFT JOIN Gold.dim_customer c
ON s.customer_sk = c.customer_sk
),


/*--------------------------------------------------------
                     Aggregated Table
       Summarizes Key Metrics at the Customer level
--------------------------------------------------------*/

CTE_Customer_Summary AS (

SELECT
    customer_id,
    customer_name,
    age,
    COUNT( DISTINCT order_number ) Total_Orders,
    SUM( sales_amount ) Total_Spend,
    MIN( order_date ) First_Order,
    MAX( order_date ) Last_Order,
    DATEDIFF( month, MIN( order_date ), MAX( order_date ) ) Lifespan
FROM CTE_Customer_Details
GROUP BY
    customer_id,
    customer_name,
    age
)


/*--------------------------------------------------------
                      Final Report
    Combines all Product details into one sinple output
--------------------------------------------------------*/

SELECT
    Customer_ID,
    Customer_Name,
    Age,
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
    END Age_Group,
        CASE
        WHEN Total_Spend > 5000 AND Lifespan >=12 THEN 'VIP'
        WHEN Total_Spend <=5000 AND Lifespan >=12 THEN 'Regular'
        WHEN Lifespan < 12 THEN 'New'
        ELSE 'Others'
    END Segment,
    Total_Spend,
    CASE
        WHEN Lifespan = 0 THEN Total_Spend
        ELSE Total_Spend / Lifespan
    END Monthly_Spend,
    Total_Orders,
    CASE
        WHEN Total_Orders = 0 THEN 0
        ELSE Total_Spend / Total_Orders
    END Avg_Order_Value,
    Last_Order,
    Lifespan,
    DATEDIFF( day, Last_Order, MAX(Last_Order) OVER() ) Recency_days
FROM CTE_Customer_Summary;
GO


-- Query the View to see the Report

SELECT * FROM Gold.report_customer;
GO

