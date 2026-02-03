use NorthwindAnalytics 
go



-- Q1. What is the average number of orders per customer?
--     Are there high-value repeat customers?

-- Step 1: Orders per customer
SELECT
    customerID,
    COUNT(*) AS total_orders
FROM dbo.orders
GROUP BY customerID
ORDER BY total_orders DESC;

-- Conclusion:
-- This shows how many orders each customer has placed.
-- Customers with more than one order are repeat customers.


-- Step 2: Average number of orders per customer
SELECT
    AVG(total_orders) AS avg_orders_per_customer
FROM (
    SELECT
        customerID,
        COUNT(*) AS total_orders
    FROM dbo.orders
    GROUP BY customerID
) t;

-- Conclusion:
-- This gives the overall average number of orders placed by a customer,
-- indicating the general level of repeat purchasing behavior.


-- Step 3: High-value repeat customers
SELECT
    o.customerID,
    COUNT(DISTINCT o.orderID) AS total_orders,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS total_revenue
FROM dbo.orders o
JOIN dbo.order_details od
    ON o.orderID = od.orderID
GROUP BY o.customerID
HAVING COUNT(DISTINCT o.orderID) > 1
ORDER BY total_revenue DESC;

-- Conclusion:
-- A small group of repeat customers generates significantly higher revenue,
-- highlighting the importance of customer retention.


-- Q2. How do customer order patterns vary by city or country?

-- Step 1: Orders count by country
SELECT
    c.country,
    COUNT(DISTINCT o.orderID) AS total_orders
FROM dbo.customers c
JOIN dbo.orders o
    ON c.customerID = o.customerID
GROUP BY c.country
ORDER BY total_orders DESC;

-- Conclusion:
-- Certain countries place a higher number of orders,
-- showing geographic concentration of demand.


-- Step 2: Revenue by country
SELECT
    c.country,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS total_revenue
FROM dbo.customers c
JOIN dbo.orders o
    ON c.customerID = o.customerID
JOIN dbo.order_details od
    ON o.orderID = od.orderID
GROUP BY c.country
ORDER BY total_revenue DESC;

-- Conclusion:
-- Some countries contribute more revenue than others,
-- indicating higher-value customers in those regions.


-- Step 3: Orders count by city
SELECT
    c.city,
    COUNT(DISTINCT o.orderID) AS total_orders
FROM dbo.customers c
JOIN dbo.orders o
    ON c.customerID = o.customerID
GROUP BY c.city
ORDER BY total_orders DESC;

-- Conclusion:
-- Orders are concentrated in a limited number of cities,
-- identifying major demand centers.


-- Step 4: Revenue by city
SELECT
    c.city,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS total_revenue
FROM dbo.customers c
JOIN dbo.orders o
    ON c.customerID = o.customerID
JOIN dbo.order_details od
    ON o.orderID = od.orderID
GROUP BY c.city
ORDER BY total_revenue DESC;

-- Conclusion:
-- High-revenue cities represent key markets
-- for focused sales and distribution strategies.


-- Q3. Can we cluster customers based on total spend,
--     order count, and preferred categories?

-- Step 1: Customer order and spend summary
SELECT
    o.customerID,
    COUNT(DISTINCT o.orderID) AS total_orders,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS total_spend
FROM dbo.orders o
JOIN dbo.order_details od
    ON o.orderID = od.orderID
GROUP BY o.customerID;

-- Conclusion:
-- This creates a per-customer summary showing
-- how frequently and how much each customer spends.


-- Step 2: Preferred category per customer
SELECT
    customerID,
    categoryID AS preferred_category
FROM (
    SELECT
        customerID,
        categoryID,
        ROW_NUMBER() OVER (
            PARTITION BY customerID
            ORDER BY SUM(od.unitPrice * od.quantity * (1 - od.discount)) DESC
        ) AS rn
    FROM dbo.orders o
    JOIN dbo.order_details od
        ON o.orderID = od.orderID
    JOIN dbo.products p
        ON od.productID = p.productID
    GROUP BY customerID, categoryID
) t
WHERE rn = 1;

-- Conclusion:
-- Each customer is associated with the category
-- where they spend the most, indicating preference.


-- Step 3: Customer segmentation
SELECT
    customerID,
    total_orders,
    total_spend,
    CASE
        WHEN total_spend >= 10000 AND total_orders >= 5 THEN 'high_value'
        WHEN total_spend >= 3000 THEN 'medium_value'
        ELSE 'low_value'
    END AS customer_segment
FROM (
    SELECT
        o.customerID,
        COUNT(DISTINCT o.orderID) AS total_orders,
        SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS total_spend
    FROM dbo.orders o
    JOIN dbo.order_details od
        ON o.orderID = od.orderID
    GROUP BY o.customerID
) s;

-- Conclusion:
-- Customers can be grouped into high, medium, and low value segments,
-- enabling targeted marketing and retention strategies.


-- Q4. Which product categories or products contribute most to order revenue?

-- Step 1: Revenue by product category
SELECT
    c.categoryName,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS total_revenue
FROM dbo.order_details od
JOIN dbo.products p
    ON od.productID = p.productID
JOIN dbo.categories c
    ON p.categoryID = c.categoryID
GROUP BY c.categoryName
ORDER BY total_revenue DESC;

-- Conclusion:
-- A small number of categories generate the majority of revenue,
-- indicating key focus areas for the business.


-- Step 2: Revenue by product
SELECT
    p.productName,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS total_revenue
FROM dbo.order_details od
JOIN dbo.products p
    ON od.productID = p.productID
GROUP BY p.productName
ORDER BY total_revenue DESC;

-- Conclusion:
-- Revenue is concentrated among a limited set of products,
-- identifying top-performing items.


-- Q5. Are there any correlations between orders and
--     customer location or product category?

-- Step 1: Orders by country
SELECT
    c.country,
    COUNT(DISTINCT o.orderID) AS total_orders
FROM dbo.customers c
JOIN dbo.orders o
    ON c.customerID = o.customerID
GROUP BY c.country
ORDER BY total_orders DESC;

-- Conclusion:
-- Order volumes vary significantly across countries,
-- showing strong geographic demand differences.


-- Step 2: Orders by city
SELECT
    c.city,
    COUNT(DISTINCT o.orderID) AS total_orders
FROM dbo.customers c
JOIN dbo.orders o
    ON c.customerID = o.customerID
GROUP BY c.city
ORDER BY total_orders DESC;

-- Conclusion:
-- A small number of cities dominate order volume,
-- indicating concentrated urban demand.


-- Step 3: Orders by product category
SELECT
    cat.categoryName,
    COUNT(DISTINCT o.orderID) AS total_orders
FROM dbo.orders o
JOIN dbo.order_details od
    ON o.orderID = od.orderID
JOIN dbo.products p
    ON od.productID = p.productID
JOIN dbo.categories cat
    ON p.categoryID = cat.categoryID
GROUP BY cat.categoryName
ORDER BY total_orders DESC;

-- Conclusion:
-- Certain product categories are ordered more frequently,
-- showing clear customer preference patterns.


-- Q6. How frequently do different customer segments place orders?

-- Step 1: Create customer segments
WITH customer_segments AS (
    SELECT
        o.customerID,
        COUNT(DISTINCT o.orderID) AS total_orders,
        SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS total_spend,
        CASE
            WHEN SUM(od.unitPrice * od.quantity * (1 - od.discount)) >= 10000
                 AND COUNT(DISTINCT o.orderID) >= 5
                THEN 'high_value'
            WHEN SUM(od.unitPrice * od.quantity * (1 - od.discount)) >= 3000
                THEN 'medium_value'
            ELSE 'low_value'
        END AS customer_segment
    FROM dbo.orders o
    JOIN dbo.order_details od
        ON o.orderID = od.orderID
    GROUP BY o.customerID
)

-- Conclusion:
-- Customers are classified into high, medium, and low value segments
-- based on their spending and order frequency.


-- Step 2: Order frequency by customer segment
SELECT
    customer_segment,
    COUNT(customerID) AS customer_count,
    AVG(total_orders) AS avg_orders_per_customer
FROM customer_segments
GROUP BY customer_segment
ORDER BY avg_orders_per_customer DESC;

-- Conclusion:
-- High-value customers place orders more frequently on average,
-- while low-value customers show lower repeat purchase behavior.

-- Q7. What is the geographic and title-wise distribution of employees?

-- Step 1: Employee distribution by country
SELECT
    country,
    COUNT(employeeID) AS employee_count
FROM dbo.employees
GROUP BY country
ORDER BY employee_count DESC;

-- Conclusion:
-- Employees are unevenly distributed across countries,
-- with certain countries having a higher workforce concentration.


-- Step 2: Employee distribution by city
SELECT
    city,
    COUNT(employeeID) AS employee_count
FROM dbo.employees
GROUP BY city
ORDER BY employee_count DESC;

-- Conclusion:
-- Employee presence is concentrated in a limited number of cities,
-- indicating major operational hubs.


-- Step 3: Employee distribution by job title
SELECT
    title,
    COUNT(employeeID) AS employee_count
FROM dbo.employees
GROUP BY title
ORDER BY employee_count DESC;

-- Conclusion:
-- Certain job titles dominate the organization,
-- reflecting the overall role structure.


-- Step 4: Title-wise distribution by country
SELECT
    country,
    title,
    COUNT(employeeID) AS employee_count
FROM dbo.employees
GROUP BY country, title
ORDER BY country, employee_count DESC;

-- Conclusion:
-- Job roles vary by country, showing differences
-- in organizational structure across regions.





-- Q8. What patterns exist in employee title distributions?


SELECT
    title,
    COUNT(employeeID) AS employee_count
FROM dbo.employees
GROUP BY title
ORDER BY employee_count DESC;

-- Conclusion:
-- Some job titles are more common,
-- indicating key functional roles in the organization.





-- Q9. Are there correlations between product pricing
--      and sales performance?

-- Step 1: Product-level sales performance
SELECT
    p.productID,
    p.productName,
    p.unitPrice,
  
    SUM(od.quantity) AS total_quantity_sold,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS total_revenue
FROM dbo.products p
JOIN dbo.order_details od
    ON p.productID = od.productID
GROUP BY
    p.productID,
    p.productName,
    p.unitPrice,
   

-- Conclusion:
-- Products with different price points 
-- show varying sales volumes and revenue performance.


-- Step 2: Sales performance by price range
SELECT
    CASE
        WHEN p.unitPrice < 20 THEN 'low_price'
        WHEN p.unitPrice BETWEEN 20 AND 50 THEN 'mid_price'
        ELSE 'high_price'
    END AS price_range,
    SUM(od.quantity) AS total_quantity_sold,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS total_revenue
FROM dbo.products p
JOIN dbo.order_details od
    ON p.productID = od.productID
GROUP BY
    CASE
        WHEN p.unitPrice < 20 THEN 'low_price'
        WHEN p.unitPrice BETWEEN 20 AND 50 THEN 'mid_price'
        ELSE 'high_price'
    END;

-- Conclusion:
-- Mid and high-priced products often contribute
-- significantly to total revenue compared to low-priced items.





-- Q10. How does product demand change over months or seasons?

-- Step 1: Monthly product demand (overall)
SELECT
    YEAR(o.orderDate) AS order_year,
    MONTH(o.orderDate) AS order_month,
    SUM(od.quantity) AS total_quantity_sold
FROM dbo.orders o
JOIN dbo.order_details od
    ON o.orderID = od.orderID
GROUP BY
    YEAR(o.orderDate),
    MONTH(o.orderDate)
ORDER BY
    order_year,
    order_month;

-- Conclusion:
-- Product demand fluctuates across months,
-- indicating seasonal variations in overall sales volume.


-- Step 2: Monthly product demand by category
SELECT
    YEAR(o.orderDate) AS order_year,
    MONTH(o.orderDate) AS order_month,
    c.categoryName,
    SUM(od.quantity) AS total_quantity_sold
FROM dbo.orders o
JOIN dbo.order_details od
    ON o.orderID = od.orderID
JOIN dbo.products p
    ON od.productID = p.productID
JOIN dbo.categories c
    ON p.categoryID = c.categoryID
GROUP BY
    YEAR(o.orderDate),
    MONTH(o.orderDate),
    c.categoryName
ORDER BY
    order_year,
    order_month,
    c.categoryName;

-- Conclusion:
-- Different product categories show different demand patterns
-- across months, indicating category-specific seasonality.


-- Step 3: Seasonal aggregation (quarterly demand)
SELECT
    YEAR(o.orderDate) AS order_year,
    DATEPART(QUARTER, o.orderDate) AS order_quarter,
    SUM(od.quantity) AS total_quantity_sold
FROM dbo.orders o
JOIN dbo.order_details od
    ON o.orderID = od.orderID
GROUP BY
    YEAR(o.orderDate),
    DATEPART(QUARTER, o.orderDate)
ORDER BY
    order_year,
    order_quarter;

-- Conclusion:
-- Quarterly aggregation highlights seasonal peaks and dips,
-- helping identify high-demand and low-demand seasons.


-- Q11. Can we identify anomalies in product sales or revenue performance?

-- Step 1: Product-level sales and revenue summary
SELECT
    p.productID,
    p.productName,
    SUM(od.quantity) AS total_quantity_sold,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS total_revenue
FROM dbo.products p
JOIN dbo.order_details od
    ON p.productID = od.productID
GROUP BY
    p.productID,
    p.productName;

-- Conclusion:
-- This provides a baseline view of sales volume and revenue
-- for each product.


-- Step 2: Identify high-revenue anomalies
SELECT
    productName,
    total_revenue
FROM (
    SELECT
        p.productName,
        SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS total_revenue
    FROM dbo.products p
    JOIN dbo.order_details od
        ON p.productID = od.productID
    GROUP BY p.productName
) t
WHERE total_revenue >
      (
          SELECT AVG(total_revenue) * 2
          FROM (
              SELECT
                  SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS total_revenue
              FROM dbo.products p
              JOIN dbo.order_details od
                  ON p.productID = od.productID
              GROUP BY p.productID
          ) x
      )
ORDER BY total_revenue DESC;

-- Conclusion:
-- Products with revenue significantly higher than the average
-- are identified as high-performing or anomalous products.


-- Step 3: Identify low-demand anomalies
SELECT
    p.productName,
    SUM(od.quantity) AS total_quantity_sold
FROM dbo.products p
JOIN dbo.order_details od
    ON p.productID = od.productID
GROUP BY p.productName
HAVING SUM(od.quantity) < 10
ORDER BY total_quantity_sold;

-- Conclusion:
-- Products with very low sales volume are identified as
-- underperforming or low-demand items.


-- Step 4: Monthly revenue spikes by product
SELECT
    p.productName,
    YEAR(o.orderDate) AS order_year,
    MONTH(o.orderDate) AS order_month,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS monthly_revenue
FROM dbo.orders o
JOIN dbo.order_details od
    ON o.orderID = od.orderID
JOIN dbo.products p
    ON od.productID = p.productID
GROUP BY
    p.productName,
    YEAR(o.orderDate),
    MONTH(o.orderDate)
HAVING
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) >
    2 * (
        SELECT AVG(od2.unitPrice * od2.quantity * (1 - od2.discount))
        FROM dbo.order_details od2
    )
ORDER BY monthly_revenue DESC;

-- Conclusion:
-- Sudden spikes in monthly revenue highlight unusual sales behavior,
-- which may be driven by promotions, bulk orders, or special events.