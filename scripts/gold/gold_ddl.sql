
drop view if exists gold.dim_product ;
GO
create view gold.dim_product as
select 
ROW_NUMBER () over(order by pi.prod_id) as product_key,
pi.prod_id as product_id,
pi.prod_key as product_number,
pi.prod_name as product_name,
pi.prod_cat as category_id,
pc.prod_cat as category,
pc.prod_subcat as subcategory,
pc.prod_maintaince as maintaince,
pi.prod_line as product_line,
pi.prod_cost as product_cost,
pi.prod_start_date as product_start_date
from sliver.crm_prod_info pi
left join sliver.erp_px_cat_G1V2 pc
on pc.prod_id = pi.prod_cat
where pi.prod_end_date is NULL ;
GO
drop view if exists gold.dim_customers;
GO
create view gold.dim_customers 
as 
select  
ROW_NUMBER() over(order by ci.cst_id)  as customer_key,
ci.cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as first_name,
ci.cst_lastname as last_name,
la.cst_country,
ci.cst_material_status as martial_status,
case when ci.cst_gender != 'N/A' then ci.cst_gender
else coalesce(ca.cst_gender,'N/A')
end gender ,
ca.cst_birthdate as birth_date,
ci.cst_date as create_date
from sliver.crm_cust_info ci
left join sliver.erp_cust_AZ12 ca
on ca.cst_id = ci.cst_key
left join sliver.erp_loc_A101 la
on la.cust_id = ci.cst_key
GO
drop view if exists gold.fact_sales;
GO
create view gold.fact_sales as
select 
sales_odr_num,
dc.customer_key as customer_key,
dp.product_key as product_key,
sales_order_date as order_date,
sales_ship_date as shipping_date,
sales_due_date as due_date,
sales_amt as sales_amount,
sales_qty as quantity,
sales_price as price
from sliver.crm_sales_info si
left join gold.dim_product dp
on si.sales_prod_key = dp.product_number
left join gold.dim_customers dc
on dc.customer_id = si.sales_cst_id


