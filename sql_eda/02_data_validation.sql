USE NorthwindAnalytics;
GO

-- =========================
-- DATA VALIDATION
-- =========================

-- 1. Check duplicate customers
SELECT customerID, COUNT(*) AS cnt
FROM dbo.customers
GROUP BY customerID
HAVING COUNT(*) > 1;

-- 2. Check duplicate products
SELECT productID, COUNT(*) AS cnt
FROM dbo.products
GROUP BY productID
HAVING COUNT(*) > 1;

-- 3. Check duplicate orders
SELECT orderID, COUNT(*) AS cnt
FROM dbo.orders
GROUP BY orderID
HAVING COUNT(*) > 1;

-- 4. Check duplicate employees
SELECT employeeID, COUNT(*) AS cnt
FROM dbo.employees
GROUP BY employeeID
HAVING COUNT(*) > 1;



-- =========================
-- NULL CHECKS IN KEY COLUMNS
-- =========================

-- 1. customers
SELECT *
FROM dbo.customers
WHERE customerID IS NULL;

-- 2. products
SELECT *
FROM dbo.products
WHERE productID IS NULL;

-- 3. orders
SELECT *
FROM dbo.orders
WHERE orderID IS NULL
   OR customerID IS NULL
   OR orderDate IS NULL;

-- 4. order_details
SELECT *
FROM dbo.order_details
WHERE orderID IS NULL
   OR productID IS NULL;

-- 5. employees
SELECT *
FROM dbo.employees
WHERE employeeID IS NULL;

-- 6. categories
SELECT *
FROM dbo.categories
WHERE categoryID IS NULL;

-- 7. shippers
SELECT *
FROM dbo.shippers
WHERE shipperID IS NULL;
