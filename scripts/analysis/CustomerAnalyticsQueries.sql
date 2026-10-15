--
/*
Queries Resolved
Q1: Find the total orders by the customer,average per unit per customer
Q2 : Find the top  10 customer with most sales
	solved by two methods:
	a) Using Top 
	b) Window Function Dense_Rank()
Q3 :Find the customer with no orders
Q4: Find the Gender ratio of customers
Q5: Customers having higher Average order value than average order value
Q6: Checking Order ratio with  martial status


*/
With CTE_customer_order_summary as 
(
	select 
	s.customer_key as customer_key,
	c.first_name as first_name,
	c.last_name as last_name,
	sum(s.sales_amount) as total_sales,-- total Sales
	count(distinct s.sales_odr_num) as total_orders,-- Total Order
	sum(s.quantity) as total_quantity,-- total Quantity
	avg(s.sales_amount) as average_per_unit
	from gold.fact_sales s
	left join gold.dim_customers c
	on c.customer_key = s.customer_key
	group by s.customer_key,c.first_name,c.last_name
)
select top 10
customer_key,
first_name,
last_name,
total_sales,
total_orders,
total_quantity,
average_per_unit,
total_sales/total_orders as AOV
from CTE_customer_order_summary
order by total_sales desc, total_orders;

GO
With CTE_customer_order_summary as 
(
	select 
	s.customer_key as customer_key,
	c.first_name as first_name,
	c.last_name as last_name,
	sum(s.sales_amount) as total_sales,-- total Sales
	count(distinct s.sales_odr_num) as total_orders,-- Total Order
	sum(s.quantity) as total_quantity-- total Quantity
	from gold.fact_sales s
	left join gold.dim_customers c
	on c.customer_key = s.customer_key
	group by s.customer_key,c.first_name,c.last_name
)
-- This query is alternate of finding  top 10 customer with customer having 
-- same number of sales
select
customer_key,
first_name,
last_name,
total_sales,
total_orders,
total_quantity
from(
select 
DENSE_RANK() over(order by total_sales desc) as customerRank,
*
from CTE_customer_order_summary
)t
where customerRank<=10;
GO

-- Customer having greater average order value than conclusive average order value 


-- Customer with zero order
select
c.customer_key,
count(distinct sales_odr_num) as total_order
from gold.fact_sales s
right join gold.dim_customers c
on c.customer_key = s.customer_key
group by 
c.customer_key
having  count(distinct sales_odr_num) =0;

GO
-- customer gender ratio
select
gender,
total_orders,
concat (cast(round(cast (total_orders *100 as float)/(select count(distinct sales_odr_num) from gold.fact_sales),2) as nvarchar),'%') as gender_ratio
from(
select
c.gender as gender,
count(distinct s.sales_odr_num) as total_orders
from gold.fact_sales s
left join gold.dim_customers c
on s.customer_key =  c.customer_key
group by c.gender
) t
order by total_orders desc;

-- Select Customer with more AOV then the average order value
GO
With CTE_customer_order_summary as 
(
	select 
	s.customer_key as customer_key,
	c.first_name as first_name,
	c.last_name as last_name,
	sum(s.sales_amount) as total_sales,-- total Sales
	count(distinct s.sales_odr_num) as total_orders,-- Total Order
	sum(s.quantity) as total_quantity,-- total Quantity
	avg(s.sales_amount) as average_per_unit
	from gold.fact_sales s
	left join gold.dim_customers c
	on c.customer_key = s.customer_key
	group by s.customer_key,c.first_name,c.last_name
),
CTE_salesInfo as
(
select 
	 count(distinct sales_odr_num) as total_orders,
	 sum(sales_amount) as total_sales 
from gold.fact_sales
)

select 
customer_key,
first_name,
last_name,
total_sales/total_orders as customer_AOV
from CTE_customer_order_summary
where  total_sales/total_orders > (select cast(total_sales as float)/total_orders from CTE_salesInfo)
order by total_sales/total_orders desc

GO
-- Customer Martial Status Ratio
select
martial_status,
total_orders,
concat (cast(round(cast (total_orders *100 as float)/(select count(distinct sales_odr_num) from gold.fact_sales),2) as nvarchar),'%') as gender_ratio
from
(
select
c.martial_status as martial_status,
count(distinct s.sales_odr_num) as total_orders
from gold.fact_sales s
left join gold.dim_customers c
on s.customer_key =  c.customer_key
group by c.martial_status
) t
order by total_orders desc
