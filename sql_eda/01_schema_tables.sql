-- =========================================
-- SCHEMA OVERVIEW : NORTHWIND DATABASE
-- FILE: 01_schema_tables.sql
-- PURPOSE:
--   1. List all main tables used in analysis
--   2. Inspect columns and primary keys
--   3. Understand table relationships
-- =========================================

USE NorthwindAnalytics;
GO

-- =========================
-- 1. CUSTOMERS TABLE
-- =========================
SELECT TOP 5 *
FROM customers;


-- =========================
-- 2. ORDERS TABLE
-- =========================
SELECT TOP 5 *
FROM orders;


-- =========================
-- 3. ORDER_DETAILS TABLE
-- =========================
SELECT TOP 5 *
FROM order_details;


-- =========================
-- 4. PRODUCTS TABLE
-- =========================
SELECT TOP 5 *
FROM products;


-- =========================
-- 5. CATEGORIES TABLE
-- =========================
SELECT TOP 5 *
FROM categories;


-- =========================
-- 6. EMPLOYEES TABLE
-- =========================
SELECT TOP 5 *
FROM employees;


-- =========================
-- 7. SHIPPERS TABLE
-- =========================
SELECT TOP 5 *
FROM shippers;


