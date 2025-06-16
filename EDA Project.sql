USE DataWarehouse;


-- View all tables available in the DataWarehouse database
SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- View all column names and details for the 'dim_customers' table
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'dim_customers';

-- List all unique countries from the customer dimension
SELECT DISTINCT country FROM gold.dim_customers;

-- List distinct combinations of category, subcategory, and product names
SELECT DISTINCT category, subcategory, product_name 
FROM gold.dim_products
ORDER BY 1, 2, 3;

-- Find the first and last order date and calculate the month difference
SELECT MIN(order_date) as first_order, MAX(order_date) as last_order,
DATEDIFF(month, MIN(order_date), MAX(order_date)) as date_diff_month
FROM gold.fact_sales;

-- Find the oldest and youngest customer's birthdate and age
SELECT 
MIN(birthdate) as oldest_birthdate,
DATEDIFF(year, MIN(birthdate), GETDATE()) as oldest_age,
MAX(birthdate) as youngest_birthdate,
DATEDIFF(year, MAX(birthdate), GETDATE()) as youngest_age
FROM gold.dim_customers;

-- Get the total sale amount
SELECT SUM(sale_amount) as total_sale_amount FROM gold.fact_sales;

-- Get the total quantity sold
SELECT SUM(sales_quantity) as total_sale_quantity FROM gold.fact_sales;

-- Get the average sales price rounded to the nearest integer
SELECT CAST(ROUND(AVG(sales_price), 0) AS INT) AS avg_sale_price 
FROM gold.fact_sales;

-- Count all order records
SELECT COUNT(order_number) as total_orders FROM gold.fact_sales;

-- Count distinct orders (unique order numbers)
SELECT COUNT(DISTINCT order_number) as total_orders FROM gold.fact_sales;

-- Count all product keys in product dimension
SELECT COUNT(product_key) as total_products FROM gold.dim_products;

-- Count all product names in product dimension
SELECT COUNT(product_name) as total_product_name FROM gold.dim_products;

-- Count total customers from customer dimension
SELECT COUNT(customer_key) as total_customer FROM gold.dim_customers;

-- Count distinct customers who placed orders (from fact table)
SELECT COUNT(DISTINCT customer_key) as total_customer FROM gold.fact_sales;

-- Summary of key metrics: sales, quantity, average price, total orders, customers, and products
SELECT 'Total_Sales' AS measure_name, CAST(SUM(sale_amount) AS INT) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total_Quantity', CAST(SUM(sales_quantity) AS INT) FROM gold.fact_sales
UNION ALL
SELECT 'Avg_Price', CAST(AVG(sales_price) AS float) FROM gold.fact_sales
UNION ALL
SELECT 'Total NR. Orders', CAST(COUNT(DISTINCT order_number) AS INT) FROM gold.fact_sales
UNION ALL
SELECT 'Total NR. Customer', CAST(COUNT(DISTINCT customer_key) AS INT) FROM gold.fact_sales
UNION ALL
SELECT 'Total NR. Products', CAST(COUNT(DISTINCT product_key) AS INT) FROM gold.fact_sales;

-- Count of customers by country
SELECT country, count(customer_key) AS total_customers 
FROM gold.dim_customers 
GROUP BY country
ORDER BY 2 DESC;

-- Count of customers by gender
SELECT gender, count(customer_key) AS total_customers 
FROM gold.dim_customers 
GROUP BY gender
ORDER BY 2 DESC;

-- Count of products by category
SELECT category, count(product_key) AS total_products 
FROM gold.dim_products
GROUP BY category
ORDER BY 2 DESC;

-- Average cost of products grouped by category
SELECT category, AVG(product_cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- Total sales grouped by product category
SELECT dp.category, SUM(fc.sale_amount) AS total_sales
FROM gold.fact_sales fc
LEFT JOIN gold.dim_products dp ON fc.product_key = dp.product_key
GROUP BY dp.category
ORDER BY total_sales DESC;

-- Total amount spent by each customer (with names)
SELECT 
fc.customer_key, dc.first_name, dc.last_name,
CAST(SUM(fc.sale_amount) AS INT) as total_amount 
FROM gold.fact_sales fc
LEFT JOIN gold.dim_customers dc ON fc.customer_key = dc.customer_key
GROUP BY fc.customer_key, dc.first_name, dc.last_name
ORDER BY total_amount DESC;

-- Get age of customer named 'Nichole Nara'
SELECT DATEDIFF(year, birthdate, GETDATE()) as age 
FROM gold.dim_customers 
WHERE first_name = 'Nichole' AND last_name = 'Nara';

-- Total quantity sold grouped by customer country
SELECT dc.country, CAST(SUM(fc.sales_quantity) AS INT) as total_quantity
FROM gold.fact_sales fc
LEFT JOIN gold.dim_customers dc ON fc.customer_key = dc.customer_key
GROUP BY dc.country
ORDER BY total_quantity DESC;

-- Top 5 best-selling products by total sale amount
SELECT TOP 5 dp.product_name, SUM(fc.sale_amount) as total_sales
FROM gold.fact_sales fc 
LEFT JOIN gold.dim_products dp ON fc.product_key = dp.product_key
GROUP BY product_name
ORDER BY total_sales DESC;

-- Top 5 least-selling products by total sale amount
SELECT TOP 5 dp.product_name, SUM(fc.sale_amount) as total_sales
FROM gold.fact_sales fc 
LEFT JOIN gold.dim_products dp ON fc.product_key = dp.product_key
GROUP BY product_name
ORDER BY total_sales ASC;

-- Bottom 5 products by sales using DENSE_RANK
SELECT * FROM (
  SELECT 
  dp.product_name, 
  SUM(fc.sale_amount) as total_sales,
  DENSE_RANK() OVER(ORDER BY SUM(fc.sale_amount)) as Rank_products
  FROM gold.fact_sales fc 
  LEFT JOIN gold.dim_products dp ON fc.product_key = dp.product_key
  GROUP BY product_name
) t 
WHERE Rank_products < 6;

-- Top 10 customers by total sales amount
SELECT TOP 10 
dc.customer_id, dc.first_name, dc.last_name,
SUM(fc.sale_amount) as total_sales
FROM gold.fact_sales fc 
LEFT JOIN gold.dim_customers dc ON fc.customer_key = dc.customer_key
GROUP BY customer_id, dc.first_name, dc.last_name
ORDER BY total_sales DESC;

-- Bottom 3 customers by number of orders placed
SELECT TOP 3 
dc.customer_id, dc.first_name, dc.last_name,
COUNT(fc.order_number) as total_order
FROM gold.fact_sales fc 
LEFT JOIN gold.dim_customers dc ON fc.customer_key = dc.customer_key
GROUP BY customer_id, dc.first_name, dc.last_name
ORDER BY total_order ASC;
