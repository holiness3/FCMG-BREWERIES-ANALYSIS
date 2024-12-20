CREATE TABLE sales_data (
    sales_id SERIAL PRIMARY KEY,
    sales_rep VARCHAR(100),
    emails VARCHAR(255),
    brands VARCHAR(100),
    plant_cost INT,
    unit_price INT,
    quantity INT,
    cost INT,
    profit INT,
    countries VARCHAR(100),
    region VARCHAR(100),
    months VARCHAR(50),
    years INT
);


--Sales Performance
--Total Sales Calculation: What is the total sales revenue generated by each sales representative? Provide a breakdown by month.

SELECT DISTINCT sales_rep, months, SUM (cost) AS Total_sales
FROM sales_data
GROUP BY 1,2
ORDER BY 1,3 DESC;

--Profit Analysis: Which sales representative achieved the highest profit in a given year? What factors contributed to their success?
SELECT DISTINCT sales_rep, years, SUM (profit) AS Total_Profit
FROM sales_data
GROUP BY 1,2
ORDER BY 3 DESC LIMIT 1;

--Cost vs. Revenue: For each country, calculate the profit margin (profit as a percentage of total cost) and identify which country has the highest margin.

SELECT DISTINCT 
  countries, 
  SUM(profit) AS total_profit, 
  SUM(cost) AS total_sales,
ROUND((CAST(SUM(profit) AS DECIMAL(10, 2)) / SUM(cost)) * 100, 2) 
   AS profit_margin
FROM 
  sales_data
GROUP BY 
  countries
  ORDER BY 4 DESC;
  
--Sales Trends Over Time: Analyze the trend of sales over the years. Are there any noticeable patterns or seasonal effects?

SELECT DISTINCT  years, SUM (cost) AS Total_sales
FROM sales_data
GROUP BY 1
ORDER BY 1

--Brand Performance: Which brand generated the highest revenue in the last year? How does this compare to previous years?

SELECT  DISTINCT years,  brands, SUM (cost) AS Total_sales
FROM sales_data
GROUP BY 1,2
ORDER BY 1,3 DESC;

--Regional Comparison: Compare sales performance across different regions. Which region has the highest total sales, and what might explain these differences?

SELECT  DISTINCT region, SUM (cost) AS Total_sales
FROM sales_data
GROUP BY 1 
ORDER BY 2 DESC;

--Email Marketing Effectiveness: Analyze whether there is a correlation between the number of emails sent and sales generated by each sales representative.

SELECT DISTINCT sales_rep,COUNT (emails) AS TOTAL_EMAIL_SENT,
SUM (cost) AS Total_sales
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC;

--Sales by Plant Cost: How does plant cost affect unit price and profit? Create a visual representation of this relationship.
SELECT DISTINCT brands, SUM(plant_cost) AS Total_plant_cost,
SUM (unit_price) AS Total_unit_price,
SUM (profit) AS Total_profit
FROM sales_data
GROUP BY 1;

--Top Selling Products: Identify the top three products (brands) sold in each country. What trends can be observed in product popularity?
SELECT DISTINCT countries, brands,
SUM (quantity) AS total_quantity,
SUM (cost) AS total_sales
FROM sales_data
GROUP BY 1,2
ORDER BY 1,4 DESC;

--Quantity Sold Analysis: What is the average quantity sold per transaction for each brand? Which brand has the highest average quantity sold?
SELECT DISTINCT brands, AVG(quantity) AS avg_quantity_sold
FROM sales_data
GROUP BY 1
ORDER BY 2;

--YearoverYear Growth: Calculate the yearoveryear growth rate of sales for each brand. Which brands are experiencing significant growth or decline?

WITH sales_data_by_brand AS (
  SELECT 
    brands,
    years,
    SUM(cost) AS total_sales
  FROM 
    sales_data
  GROUP BY 
    brands,years
),
yoy_growth_rate AS (
  SELECT 
    brands,
    years,
    total_sales,
    LAG(total_sales) OVER (PARTITION BY brands ORDER BY years) AS prev_year_sales
  FROM 
    sales_data_by_brand
)
SELECT 
  brands,
  years,
  total_sales,
  prev_year_sales,
  CASE 
    WHEN prev_year_sales IS NULL THEN NULL 
    ELSE ROUND((((CAST(total_sales AS DECIMAL(10,2)) - (prev_year_sales))) / prev_year_sales) * 100, 2) 
  END AS yoy_growth_rate
FROM 
  yoy_growth_rate
ORDER BY 
  brands,
  years;

	

--Cost Control Analysis: Identify which countries have the highest average costs and investigate potential reasons for these high costs.

SELECT DISTINCT countries,
  AVG(total_cost) AS avg_total_cost
FROM 
  (
    SELECT 
      countries, 
      SUM(plant_cost * quantity) AS total_cost
    FROM 
      sales_data
    GROUP BY 
      countries
  ) AS subquery
  GROUP BY 1
  ORDER BY 2 DESC;

--Sales Rep Performance: Rank sales representatives based on their profitability over the last three years. What characteristics do top performers share?

WITH sales_rep_performance AS (
  SELECT 
    sales_rep,
    SUM(profit) AS total_profit
  FROM 
    sales_data
  WHERE 
    YEARS BETWEEN 2017 AND 2019
  GROUP BY 
    sales_rep
)
SELECT 
  sales_rep,
  total_profit,
  RANK() OVER (ORDER BY total_profit DESC) AS profit_rank
FROM 
  sales_rep_performance
ORDER BY 
  profit_rank;

--Impact of Regions on Profitability: How does profitability vary across different regions? Are there regions where certain brands perform better?

SELECT region, brands, SUM(profit) AS total_profit
FROM sales_data
GROUP BY 1,2
ORDER BY 1,3 DESC;


--Sales Forecasting: Based on historical data, forecast sales for the next quarter for each brand using a suitable forecasting method.
-- Customer Insights
--Customer Retention Analysis: Identify trends in repeat purchases by country or region. Which areas show strong customer loyalty?
SELECT countries, COUNT(sales_id)
FROM sales_data
GROUP BY 1
ORDER BY 2 DESC;

