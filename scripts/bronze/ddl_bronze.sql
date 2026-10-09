use DataWarehouse;
if OBJECT_ID('bronze.crm_cust_info','U') is not null
drop table bronze.crm_cust_info;
GO
create table bronze.crm_cust_info(
	cst_id int,
	cst_key nvarchar (50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_material_status nvarchar(50),
	cst_gender nvarchar(50),
	cst_date date
);
go
if OBJECT_ID('bronze.crm_prod_info','U') is not null
drop table bronze.crm_prod_info;
go
create table bronze.crm_prod_info
(
	prod_id int ,
	prod_key nvarchar(50),
	prod_name nvarchar (100),
	prod_cost int,
	prod_line nvarchar(50),
	prod_start_date date,
	prod_end_date date

);
go
if OBJECT_ID('bronze.crm_sales_info','U') is not null
drop table bronze.crm_sales_info;

go

create table bronze.crm_sales_info
(
	sales_odr_num nvarchar(50),
	sales_prod_key nvarchar(50),
	sales_cst_id int,
	sales_order_date int,
	sales_ship_date int,
	sales_due_date int,
	sales_amt int,
	sales_qty int,
	sales_price int
);
go
if OBJECT_ID('bronze.erp_cust_AZ12','U') is not null
drop table bronze.erp_cust_AZ12;
go
create table bronze.erp_cust_AZ12
(
	cst_id nvarchar (50),
	cst_birthdate date,
	cst_gender nvarchar(50)
);
go
if OBJECT_ID('bronze.erp_cust_AZ12','U') is not null
drop table bronze.erp_loc_A101;
go

create table bronze.erp_loc_A101
(
    cust_id nvarchar(50),
	cst_country nvarchar(100)
);

if OBJECT_ID('bronze.erp_px_cat_G1V2','U') is not null
drop table bronze.erp_px_cat_G1V2;

go

create table bronze.erp_px_cat_G1V2(
   prod_id nvarchar(50),
   prod_cat nvarchar(50),
   prod_subcat nvarchar(50),
   prod_maintaince nvarchar (10)
);
go
