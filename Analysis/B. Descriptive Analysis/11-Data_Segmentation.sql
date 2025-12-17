/*
===============================================================================
                               Data Segmentation
===============================================================================
Purpose:
    - To group data into meaningful tiers for better business insights.
    - To segment products by cost ranges and customers by demographic age groups.
    - To classify customers into functional tiers (VIP, Regular, New) based on 
      spending behavior and tenure.

SQL Functions Used:
    - CASE
    - SUM(), COUNT(), MIN(), MAX()
    - DATEDIFF()
    - Common Table Expressions (CTEs)
    - GROUP BY, ORDER BY

Tables Used:
    - Gold.dim_product
    - Gold.dim_customer
    - Gold.fact_sales
===============================================================================
*/

-- Make sure using the correct database

USE DataWarehouse;
GO

  
-- Total Products in different Cost Ranges

SELECT
    cost_range,
    COUNT(*) Total_Products
FROM (
    SELECT
        CASE
            WHEN cost < 100 THEN 'below 100'
            WHEN cost <= 500 THEN '100-500'
            WHEN cost <= 1000 THEN '500-1000'
            WHEN cost <= 1500 THEN '1000-1500'
            WHEN cost <= 2000 THEN '1500-2000'
            WHEN cost > 2000 THEN 'above 2000'
            ELSE 'n/a'
        END cost_range
    FROM Gold.dim_product
)t
GROUP BY cost_range
ORDER BY Total_Products DESC;


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


-- Customer Segmentation
    -- VIP: at least 12 months of history and spending more than €5,000
    -- Regular: at least 12 months of history but spending €5,000 or less
    -- New: lifespan less than 12 months



WITH CTE_Customer_Report AS (
    SELECT
        customer_sk,
        SUM( sales_amount ) Total_Spend,
        DATEDIFF( month, MIN( order_date ), MAX( order_date ) ) Lifespan
    FROM Gold.fact_sales
    GROUP BY customer_sk
),

CTE_Customer_Segment AS (
    SELECT
        CASE
            WHEN Total_Spend > 5000 AND Lifespan >=12 THEN 'VIP'
            WHEN Total_Spend <=5000 AND Lifespan >=12 THEN 'Regular'
            WHEN Lifespan < 12 THEN 'New'
            ELSE 'Others'
        END Segment
    FROM CTE_Customer_Report
)

SELECT
    Segment,
    COUNT(*) Total_Customer
FROM CTE_Customer_Segment
GROUP BY Segment
ORDER BY COUNT(*);

