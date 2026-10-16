/* Query Resolved 
Q1: Total Sales
q2: Average Order Value
Q3: Monthly Revenue
Q4 : Cummutative Revenue and Cummutative Orders
Q5 Find month with highest & lowest revenue
	Two methods
	Using Top
	Using max & min as window function and subquery with CTE
Q6 : Which customers have increased or decreased their spending compared with the previous month?
		Comparing one month
*/
--Total Revenue
select 
sum(sales_amount) as total_sales
from gold.fact_sales;
GO

--- Average Order Revenue
With  CTE_revenue_summary as (
	select 
	sum(sales_amount) as total_sales,
	count(distinct sales_odr_num) as total_orders
	from gold.fact_sales
)
select 
total_sales,
total_orders,
total_sales/total_orders as average_order_value
from CTE_revenue_summary
--Q3 Monthly Revenue
select
year(order_date) as years,
DATETRUNC(MONTH,order_date) as months,
datename(MONTH,order_date) as month_name,
count(distinct sales_odr_num) as total_orders,
sum(sales_amount) as total_sales
from gold.fact_sales
where  year(order_date) is not null
group  by year(order_date),DATETRUNC(MONTH,order_date),datename(month,order_date)
order by years ,DATETRUNC(MONTH,order_date) asc;
GO

--Q4
With CTE_revenue_summary as (
select
year(order_date) as years,
DATETRUNC(MONTH,order_date) as months,
datename(MONTH,order_date) as month_name,
count(distinct sales_odr_num) as total_orders,
sum(sales_amount) as total_sales
from gold.fact_sales
where  year(order_date) is not null
group  by year(order_date),DATETRUNC(MONTH,order_date),datename(month,order_date)
)
select
years as current_year,
months as current_month,
total_orders as current_year_orders,
total_sales as current_year_sale,
sum(total_orders) over(partition by years order by years,months) as cum_orders_year,-- For every year
sum(total_sales) over(partition by years order by years,months) as cum_sales_year,
sum(total_orders) over(order by years,months) as cum_orders_overall,-- For every year
sum(total_sales) over(order by years,months) as cum_sales_overall
from CTE_revenue_summary


GO
-- Maximum And Miniumum Sales Month
with CTE_revenue_summary as
(
	select 
	DATETRUNC(month,order_date) as month_name,
	sum(sales_amount) as total_sales
	from gold.fact_sales
	where DATETRUNC(month,order_date) is not null
	group by DATETRUNC(month,order_date)	
)
select
*
from(
select 
	*,
	max(total_sales) over() as maximum_sale
	from CTE_revenue_summary
 
) as ty
where maximum_sale = total_sales
union all
select
*
from(
select 
	*,
	min(total_sales) over() as minimum_sale
	from CTE_revenue_summary
 
) as ty
where minimum_sale = total_sales; 
GO
-- Q6 
With CTE_customer_revenue as
(
	select 
	datetrunc(month,s.order_date) as months,
	s.customer_key as customer_key,
	c.first_name,
	c.last_name,
	sum(s.sales_amount) as total_sales
	from gold.fact_sales s
	left join gold.dim_customers c
	on s.customer_key = c.customer_key
	where datetrunc(month,order_date) is not null
	group by datetrunc(month,s.order_date),s.customer_key,c.first_name,c.last_name
)
select
customer_key,
concat(first_name,' ',coalesce(last_name,'')) as customer_name,
months as current_month,
last_month,
total_sales as current_month_sales,
last_month_sale
from(
	select
	*,
	lag(total_sales) over(partition by customer_key order by months) as last_month_sale,
	lag(months) over(partition by customer_key order by months) as last_order_date,
	DATEADD(month,-1,months) as last_month
	from CTE_customer_revenue
) as t
where last_order_date = last_month and last_month_sale > total_sales and months = cast('2013-08-01' as date)
order by customer_key

