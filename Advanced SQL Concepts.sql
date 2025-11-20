/*
Author: Richard Ndlovu
Date: October 2025
Description: Create 2 tables and demo 12 advanced SQL concepts
*/

CREATE TABLE sales (
    dt DATE,
    num_sales INT
);

-- insert sales data into the table
INSERT INTO sales (dt, num_sales)
VALUES
    ('2025-01-01', 61),
    ('2025-01-02', 72),
    ('2025-01-04', 84),
    ('2025-01-05', 95),
    ('2025-01-07', 77);
    
-- create a final sales table
CREATE TABLE final_sales (
    dt DATE,
    num_sales INT
);

-- insert final sales data into the table
INSERT INTO final_sales (dt, num_sales)
VALUES
    ('2025-01-01', 61),
    ('2025-01-02', 72),
    ('2025-01-03', 78),
    ('2025-01-04', 84),
    ('2025-01-05', 95),
    ('2025-01-06', 86),
    ('2025-01-07', 77);

-- 1. view the table (note the missing dates)
SELECT * FROM sales;

-- 2. preview the final results
SELECT * FROM final_sales;
    
-- 3. generate a series of dates [UNION, UNION ALL]
SELECT '2025-01-01' AS dt
UNION ALL
SELECT '2025-01-01'
UNION ALL
SELECT '2025-01-03';

-- 4. join with our original table [Subquery, Left Join, Inner Join]
SELECT sq.dt, sales.num_sales
FROM

(SELECT '2025-01-01' AS dt
UNION ALL
SELECT '2025-01-02'
UNION ALL
SELECT '2025-01-03'
UNION ALL
SELECT '2025-01-04'
UNION ALL
SELECT '2025-01-05'
UNION ALL
SELECT '2025-01-06'
UNION ALL
SELECT '2025-01-07') AS sq

LEFT JOIN sales ON sq.dt = sales.dt;

-- 5. rewrite subquery as a CTE [CTE]
WITH cte AS (SELECT '2025-01-01' AS dt
			UNION ALL
			SELECT '2025-01-02'
			UNION ALL
			SELECT '2025-01-03'
			UNION ALL
			SELECT '2025-01-04'
			UNION ALL
			SELECT '2025-01-05'
			UNION ALL
			SELECT '2025-01-06'
			UNION ALL
			SELECT '2025-01-07')

SELECT	cte.dt, sales.num_sales
FROM	cte LEFT JOIN sales ON cte.dt = sales.dt;

-- 6. rewrite CTE as a recursive CTE [Recursive CTE, Date Expression, CAST Function]
WITH RECURSIVE cte AS ( SELECT CAST('2025-01-01' AS DATE) AS dt
						UNION ALL
						SELECT dt + INTERVAL 1 DAY
                        FROM cte
                        WHERE dt < CAST('2025-01-07' AS DATE)
)

SELECT	cte.dt, sales.num_sales
FROM	cte LEFT JOIN sales ON cte.dt = sales.dt;

-- 7. fill in null values [NULL Function, Numeric Function]
WITH RECURSIVE cte AS ( SELECT CAST('2025-01-01' AS DATE) AS dt
						UNION ALL
						SELECT dt + INTERVAL 1 DAY
                        FROM cte
                        WHERE dt < CAST('2025-01-07' AS DATE)
)

SELECT	cte.dt, sales.num_sales,
		COALESCE(sales.num_sales, 0) AS sales_estimate,            -- detecting and filling in null values
        COALESCE(sales.num_sales, ROUND((SELECT AVG(sales.num_sales) FROM sales), 1)) AS sales_estimate_2 
FROM	cte LEFT JOIN sales ON cte.dt = sales.dt;

-- 8. introduce window functions [Window Functions]
SELECT	dt, num_sales,
		ROW_NUMBER() OVER() AS row_num,
        LAG(num_sales) OVER() AS prior_row,
        LEAD(num_sales) OVER() AS next_row
FROM	sales;

-- 9. add on two window functions [Final Query]
WITH RECURSIVE cte AS ( SELECT CAST('2025-01-01' AS DATE) AS dt
						UNION ALL
						SELECT dt + INTERVAL 1 DAY
                        FROM cte
                        WHERE dt < CAST('2025-01-07' AS DATE)
)

SELECT	cte.dt,
        COALESCE(sales.num_sales, ROUND((LAG(sales.num_sales) OVER() + LEAD(sales.num_sales) OVER())/2)) AS sales_estimate
FROM	cte LEFT JOIN sales ON cte.dt = sales.dt;




select 
orderid, creationtime, '2025-09-07' as hardcoded, NOW() AS TODAY
from  orders;

select 
orderid, year(creationtime), monthname(creationtime), day(creationtime)
from  orders;

select
orderid, creationtime, dayname(creationtime), cast(creationtime as date)
from orders;

select current_timestamp();   -- gives current date & time

select current_time();   -- gives current time 

select 3.516,
round(3.516, 2) as round_2,     -- rounds to 2 decimal places
round(3.516, 1) as round_1,    -- rounds to 1 decimal places
round(3.516, 0) as round_0;   -- rounds to 0 decimal places

select -10, 
ABS(-10);      -- converts negative to positive numbers

SELECT 
now(),
date_add('2025-05-29', interval 5 day) date_add,    -- adding 5 days on current date 
date_sub(now(), interval 5 month) date_sub;    -- subtracting 5 months on current date 

select 
timestampdiff('2025-08-07','2010-05-05');     -- difference in days between two days 

select 
employeeid,birthdate,
timestampdiff(year, birthdate, curdate()) as age   -- shwoing current age 
from employees;
 
 
select customerid, 
score, avg(score) over() AVG_SCORE,              -- showing averages using window functions 
avg(coalesce(Score,0)) over () AvgScore2 
from customers;
        					
select 
orderdate, date_format(orderdate),
case when isdate(orderdate) = 1 THEN CAST(orderdate as date)
end newOrderDate
from orders;

select distinct productid, sum(sales) over (partition by productid)        --  sum of sales group by products 
from orders;


select orderID, 
orderdate, sales, rank () over (order by sales desc) as rank_sales    -- ranking sales from hoghest to lowest 
from orders;


Select 
category,
sum(sales) as total_Sales
FROM ( 
	Select sales,
	CASE when sales > 50 then 'high'
	when sales > 20 then 'medium'        -- report showing total sales categorized and sorted descedenly 
    else 'low' 
end category
from orders
)t
group by category;


select         
customerid,                 -- average score of customer and treat null as 0 
lastname, 
score, 
Case 
	when score is null then 0 
	else score 
end score_clean,
AVG (Case 
		when score is null then 0 
		else score 
        end) over () AvgCustomerClean,
avg(score) over() AvgCustomer
from customers;


select 
customerid, 
Sum(case                           -- count how many times each customer has an order with sales > 30
	when sales > 30 then 1 
    else 0 
end) total_order
from orders
group by customerid;
