create or alter procedure sliver.sliver_load as
begin
	begin try 
		print('===============================');
		print('Loading Data In Bronze Layer ');
		print('==============================');
		Print('================================');
		Print('CRM Files Data Transferring');
		Print('=================================');
		declare @startDate datetime ,@endDate datetime,@batch_start_time datetime,@batch_end_time datetime

		set @startDate = getDAte();
		set @batch_start_time = getDAte();

		print('Inserting data in sliver.crm_cust_info ');

		Truncate table sliver.crm_cust_info
		insert into sliver.crm_cust_info(	
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_material_status,
			cst_gender,
			cst_date
		)
		select 
		cst_id,
		cst_key,
		trim(cst_firstname) as cst_firstname,
		trim(cst_lastname) as cst_lastname,
		case when upper(trim(cst_material_status)) ='M' then 'Married'
			when upper(trim(cst_material_status)) ='S' then 'Single'
			else 'n/a'
		end cst_material_status,
		case when upper(trim(cst_gender)) = 'M' then 'Male'
			when upper(trim(cst_gender)) ='F' then 'Female'
			else 'n/a'
		end cst_gender,
		cst_date

		from
		(
		select
		*,
		ROW_NUMBER() over(partition by cst_id order by cst_date desc ) as totalCount
		from bronze.crm_cust_info
		)t
		where totalCount= 1 and cst_id is not null
		set @endDate = getDate();
		print('DATA transfarred in sliver.crm_cust_info ');
		print('Load Duration : '+cast(datediff(second,@startDate,@endDate)as nvarchar)+' seconds');
		print('');

		 set @startDate = GETDATE()
		 print('Inserting data in sliver.crm_prod_info ');
		truncate table  sliver.crm_prod_info
		insert into sliver.crm_prod_info
		(
		  prod_id,
		  prod_cat,
		  prod_key,
		  prod_name,
		  prod_cost,
		  prod_line,
		  prod_start_date,
		  prod_end_date
		)
		select
		prod_id,
		replace(SUBSTRING(prod_key,1,5),'-','_') as prod_cat,
		substring(prod_key,7,len(prod_key)) as prod_key,
		prod_name,
		coalesce(prod_cost,0)as prod_cost,
		case upper(trim(prod_line))
			when 'M' then 'Mountains'
			when 'R' then 'Roads'
			when 'S' then 'Other Sales'
			when 'T' then 'Touring'
			else 'N/A'
		end prod_line,
		cast(prod_start_date as date),
		cast(lead(prod_start_date) over(partition by prod_key order by prod_start_date ) -1 as date) prod_end_date
		from bronze.crm_prod_info
		set @endDate = getDate();
		print('DATA transfarred in sliver.crm_prod_info . ');
		print('Load Duration : '+cast(datediff(second,@startDate,@endDate)as nvarchar)+' seconds');
		print('');

	--
		set @startDate = GETDATE()
		print('Inserting data in sluver.crm_sales_info ');
		truncate table sliver.crm_sales_info
		insert into sliver.crm_sales_info
		(
		  sales_odr_num,
		  sales_prod_key,
		  sales_cst_id,
		  sales_order_date,
		  sales_ship_date,
		  sales_due_date,
		  sales_amt,
		  sales_qty,
		  sales_price
		)
		select
		sales_odr_num,
		sales_prod_key,
		sales_cst_id,
		case when sales_order_date is Null or len(sales_order_date) ! =8 then NULL
			else cast (cast(sales_order_date as nvarchar) as date )
		end sales_order_date,
		case when sales_ship_date is Null or len(sales_order_date) ! =8 then NULL
			else cast (cast(sales_ship_date as nvarchar) as date )
		end sales_ship_date,
		case when sales_due_date is Null or len(sales_order_date) ! =8 then NULL
			else cast (cast(sales_order_date as nvarchar) as date )
		end sales_due_date,
		case when sales_amt is NULL or 
				 sales_amt <= 0 or 
				 sales_amt != sales_qty* abs(sales_price) 
				 then sales_qty * abs(sales_price)
			else sales_amt
		end sales_amt,
		sales_qty,
		case when sales_price is NULL or 
				 sales_price <= 0  
				 then (sales_amt) / sales_qty
			else sales_price
		end sales_price
		from bronze.crm_sales_info
		set @endDate = GETDATE()
		print('DATA transfarred in sliver.crm_sales_info . ');
		print('Load Duration : '+cast(datediff(second,@startDate,@endDate)as nvarchar)+' seconds');
		print('');
	----
		Print('================================');
		Print('CRM Files Completely Transferred');
		Print('=================================');
		Print('================================');
		Print('       ERP Files Transferring    ');
		Print('=================================');
		set @startDate = GETDATE()
		print('Inserting data in sliver.erp_cust_AZ12 ');
		truncate table sliver.erp_cust_AZ12
		insert into sliver.erp_cust_AZ12(cst_id,cst_birthdate,cst_gender)
		select
		case when cst_id like 'NAS%' then SUBSTRING(cst_id,4,len(cst_id))
			else cst_id
			end cst_id,
		case when cst_birthdate> GETDATE() then null
			else cst_birthdate
			end cst_birthdate,
		case when upper(trim(cst_gender)) in ('M','Male') then 'Male'
				when upper(trim(cst_gender)) in ('F','Female') then 'Female'
				else 'N/A'
				end cst_gender
		from bronze.erp_cust_AZ12
		set @endDate = getDate();
		print('DATA transfarred in sliver.erp_cust_AZ12 . ');
		print('Load Duration : '+cast(datediff(second,@startDate,@endDate)as nvarchar)+' seconds');
		print('');

		set @startDate = GETDATE()
		print('Inserting data in  sliver.erp_loc_A101 ');
		truncate table sliver.erp_loc_A101
	 
		insert into sliver.erp_loc_A101(cust_id,cst_country)
		select  
		replace(cust_id,'-','') as cust_id,
		case when upper(trim(cst_country)) in ('DE','Germany')then 'Germany'
			when upper(trim(cst_country))  in('US','USA','United States') then 'United States'
			when upper(trim(cst_country)) is NULL or upper(trim(cst_country)) ='' then 'N/A'
			else trim(cst_country)
			end cst_country
		from bronze.erp_loc_A101
		set @endDate = getDate();
		print('DATA transfarred in  sliver.erp_loc_A101 . ');
		print('Load Duration : '+cast(datediff(second,@startDate,@endDate)as nvarchar)+' seconds');
		print('');
		
		set @startDate = GETDATE()
		print('Inserting data in  bronze.erp_loc_A101 ');
		Truncate table sliver.erp_px_cat_G1V2
		insert into sliver.erp_px_cat_G1V2(prod_id,prod_cat,prod_subcat,prod_maintaince)
		select 
		prod_id,
		prod_cat,
		prod_subcat,
		prod_maintaince
		from bronze.erp_px_cat_G1V2
		set @endDate = getDate();
		print('DATA transfarred in  sliver.erp_loc_A101 . ');
		print('Load Duration : '+cast(datediff(second,@startDate,@endDate)as nvarchar)+' seconds');
		print('');
		set @batch_end_time =getDate();
		Print('================================');
		Print('       ERP Files Transferring    ');
		Print('=================================');
		Print('================================');
		Print(' Sliver Data Transfer Completed  ');
		Print('Total Task Completed in '+ Cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar)+' seconds')
		Print('=================================');

	end try
	begin catch
		print('      Error Found ');
		print('Error Message : ' + error_message());
		print('Error Line : '+ cast(error_line() as nvarchar));
		print('Error Message : '+ cast (error_state()as nvarchar));
		print('Error Number : ' + cast(error_number() as nvarchar));
	end catch;
end;


exec sliver.sliver_load
