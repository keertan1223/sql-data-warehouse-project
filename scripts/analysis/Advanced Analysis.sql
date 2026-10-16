/*
Query Resolved
Q1 : Change in Revenue by year
Q2 : -- Change in revenue month by month
Q3: -- Analyze the  yearly performance of prodcuts by comparing their sales to 
      both the average sales performance and previous year sale
 Q4:Group customer into three segments on their spend behaviour 
	 VIP : Customer with alteast 12 month of history and spending more than 5000
	 Regular : Customer with atleast 12 month of history and spending 5000 or less
	 New : customer with a lifespan less than 12 month
*/
--Change in Revenue by year

with CTE_sales_year_summary as(
select 
year(order_date)as year_name,
sum(sales_amount) as total_sales
from gold.fact_sales
where year(order_date) is not null
group by year(order_date)
)

select
year_name as current_year,
total_sales as current_year_sales,
lag(total_sales,1,0) over(order by year_name) as last_year_sales,
concat(cast(round((cast(total_sales-lag(total_sales,1,0) over(order by year_name) as float)/
lag(total_sales,1,1) over(order by year_name))*100,2)as nvarchar) ,'%')as change_perc
from CTE_sales_year_summary;

GO
-- Change in revenue month by month
with CTE_sales_year_summary as(
select 
DATETRUNC(month,order_date) as year_name,
sum(sales_amount) as total_sales
from gold.fact_sales
where DATETRUNC(month,order_date) is not null
group by DATETRUNC(month,order_date)
)

select
format(year_name,'yyyy-MMMM') as current_month,
total_sales as current_year_sales,
lag(total_sales,1,0) over(order by year_name) as last_year_sales,
concat(cast(round((cast(total_sales-lag(total_sales,1,0) over(order by year_name) as float)/
lag(total_sales,1,1) over(order by year_name))*100,2)as nvarchar) ,'%')as change_perc
from CTE_sales_year_summary;


GO

-- Analyze the  yearly performance of prodcuts by comparing their sales to 
--both the average sales performance and previous year sale
with CTE_product_sales_summary as (
	select
	product_key,
	year(order_date) as order_date,
	sum(sales_amount) as total_sales,
	count(distinct sales_odr_num) as total_orders,
	count(quantity) as total_quantity
	from gold.fact_sales
	where year(order_date) is not null
	group by year(order_date), product_key
	
)
select 
order_date,
t.product_key,
p.product_name,
total_sales as current_year_sale,
last_year_sale ,
average_sales as productwise_avg_sale,
avg_rating
from(
select
*,
avg(total_sales) over(partition by product_key) as average_sales,
lag(total_sales) over(partition by product_key order by order_date) as last_year_sale,
case when lag(total_sales) over(partition by product_key order by order_date) - total_sales >0
	then 'Decreased'
	when  lag(total_sales) over(partition by product_key order by order_date) - total_sales <0
	then 'Increased'
	else 'No change'
	end last_year_report,
case when avg(total_sales) over(partition by product_key) - total_sales >0
	then 'Below Avg'
	when  avg(total_sales) over(partition by product_key) - total_sales <0
	then 'Above Avg'
	else 'Avg'
	end avg_rating

from CTE_product_sales_summary
)t
left join gold.dim_product p
on p.product_key = t.product_key
where last_year_sale is not NULL and avg_rating = 'Above Avg' and last_year_report = 'Increased'

-- Group customer into three segments on their spend behaviour 
-- VIP : Customer with alteast 12 month of history and spending more than 5000
-- Regular : Customer with atleast 12 month of history and spending 5000 or less
-- New : customer with a lifespan less than 12 month
GO
With CTE_cust_total_spent as (
	select
	customer_key,
	max(order_date) as last_order,
	min(order_date) as first_order,
	sum(sales_amount) as total_sales
	from  gold.fact_sales
	group by customer_key
)
select 
customer_segment,
count(customer_key) as total_count
from(
select 
c.customer_key,
c.first_name,c.last_name,
s.total_sales as total_spending,
s.first_order,
s.last_order,
case when s.total_sales > 5000 and datediff(month,first_order,last_order)> 12
	then 'VIP'
	when s.total_sales <= 5000 and datediff(month,first_order,last_order)> 12
	then 'Regular'
	else 'New'
	end customer_segment
from CTE_cust_total_spent s
right join gold.dim_customers c
on c.customer_key = s.customer_key
)t
group by customer_segment
order by total_count desc


