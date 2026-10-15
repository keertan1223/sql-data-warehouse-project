/*

Query Resolved:
Q1: revenue By each category
Q2 Average Selling per unit
Q3 : Top 5 Product Contributing the most revenue and percentage to overall sales
Q4 : Top 3 product categories with most revenue
Q5 : Product with decling sales compare to previous year
Q6 : Product Performance for last 30 days or 1 month
*/
select 
p.category,
coalesce (sum(s.sales_amount),0) as total_sales,
count(distinct sales_odr_num)  as total_orders
from gold.dim_product p
left join gold.fact_sales s
on p.product_key = s.product_key
where p.category is not null 
group by p.category

select 
p.product_id,
p.product_name,
avg(s.sales_amount) as averageSellingCostUnit
from gold.fact_sales s
left join gold.dim_product p
on s.product_key = p.product_key
group by p.product_id,p.product_name
order by avg(s.sales_amount) desc;
GO

With CTE_total_product_sale as
	(
	
	select 
	p.product_id,
	p.product_name,
	sum(s.sales_amount) as total_sales
	from gold.fact_sales s
	left join gold.dim_product p
	on s.product_key = p.product_key
	group by p.product_id,p.product_name
	)

	select top 5
	*,
	concat(cast(round(cast(total_sales*100 as float )/ (select sum(sales_amount)from gold.fact_sales),2)as nvarchar),'%')as revenue_perc
	from CTE_total_product_sale
	order by total_sales desc;
GO
With CTE_total_product_sale as
	(
	select 
	p.category,
	sum(s.sales_amount) as total_sales
	from gold.fact_sales s
	left join gold.dim_product p
	on s.product_key = p.product_key
	group by p.category
	)

	select top 3
	*,
	concat(cast(round(cast(total_sales*100 as float )/ (select sum(sales_amount)from gold.fact_sales),2)as nvarchar),'%')as revenue_perc
	from CTE_total_product_sale
	order by total_sales desc;

	-- Q5 Finding Product declining from current year to their previous year
With CTE_total_product_sale as
	(
	
	select 
	p.product_id,
	p.product_name as product_name ,
	year(s.order_date) as saleYear,
	sum(s.sales_amount) as total_sales
	from gold.fact_sales s
	left join gold.dim_product p
	on s.product_key = p.product_key
	group by p.product_id,p.product_name,year(s.order_date)
	)
select 
*
from 
(
 select 
 *,
 lag(saleYear,1,saleYear-1) over(partition by product_id order by product_name,saleYear asc) as last_year,
 lag(total_sales,1,0) over( partition by product_id order by product_name,saleYear asc) as last_year_sales

 from CTE_total_product_sale
 where saleYear is not NULL

)t
where saleYear = 2014
and last_year_sales > total_sales;
--- Q6
GO
With CTE_total_product_sale as
	(
	
	select 
	p.product_id as product_id ,
	p.product_name as product_name ,
	datetrunc(month,s.order_date) as salemonth,
	sum(s.sales_amount) as total_sales
	from gold.fact_sales s
	left join gold.dim_product p
	on s.product_key = p.product_key
	group by p.product_id,p.product_name,datetrunc(month,s.order_date)
	)
	select 
	* 
	from
	CTE_total_product_sale
	where product_id = 214 and cast('2012-12-01' as date) = salemonth
	

	