# EDA using SQL – Sales, Customers, and Products Analysis

This project demonstrates **Exploratory Data Analysis (EDA)** using SQL on a retail dataset consisting of `fact_sales`, `dim_customers`, and `dim_products` tables. The analysis helps uncover insights related to **sales performance**, **customer demographics**, and **product trends** using clean and readable SQL queries.

## 📊 Project Summary

- **Tools Used:** SQL (SQL Server / T-SQL)
- **Focus Areas:**
  - Sales trends
  - Customer demographics
  - Product performance
  - Aggregate insights and KPIs

## 📁 Dataset Structure

The analysis uses the following tables:

- `gold.fact_sales` – Contains transactional data (orders, sales amounts, quantities, etc.)
- `gold.dim_customers` – Contains customer demographic details (name, country, gender, birthdate)
- `gold.dim_products` – Contains product-related information (category, subcategory, cost, etc.)

## 🔍 Key Analysis Queries

| Query Description | Output |
|-------------------|--------|
| List of tables and columns | Shows all table names and their column structures |
| Country-wise & gender-wise customer counts | Understands customer demographics |
| First and last order dates, and time range | Sales time range |
| Average sale price, total sales, and quantity | Key metrics |
| Top/Bottom 5 selling products | Product performance |
| Top customers by total sales and order count | Customer contribution |
| Sales by category | Revenue contribution by product category |
| Age calculation for specific customers | Age-based insights |
| Dense ranking of products by sales | Ranking products with equal performance |

## 📌 Sample Query

```sql
SELECT 
    dp.category, 
    SUM(fc.sale_amount) AS total_sales
FROM gold.fact_sales fc
LEFT JOIN gold.dim_products dp
    ON fc.product_key = dp.product_key
GROUP BY dp.category
ORDER BY total_sales DESC;
