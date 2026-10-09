create or alter  procedure bronze.load_bronze as
begin

	begin try
		print('===============================');
		print('Loading Data In Bronze Layer ');
		print('==============================');
		Print('================================');
		Print('CRM Files Completely Transferred');
		Print('=================================');

		declare @startDate datetime ,@endDate datetime,@batch_start_time datetime,@batch_end_time datetime

		set @startDate = getDAte();
		set @batch_start_time = getDAte();

		print('Inserting data in bronze.crm_cust_info ');

		truncate table  bronze.crm_cust_info;
		-- Adding data
		bulk insert bronze.crm_cust_info
		from 'D:\Sql project file\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
		with (
		-- first row is column names so the actual table start from 2nd row
			firstRow = 2 ,
			-- the each columnn break using ,
			fieldterminator = ',',
			tablock
		);
		set @endDate = getDate();
		print('DATA transfarred in bronze.crm_cust_info ');
		print('Load Duration : '+cast(datediff(second,@startDate,@endDate)as nvarchar)+' seconds');
		print('');
		 -- Date transferred into bronze.crm_cust_info
		 --Heading to next file
		 
		 set @startDate = GETDATE()
		 print('Inserting data in bronze.crm_prod_info ');
		 
		  truncate table  bronze.crm_prod_info;
		-- Adding data into bronze.crm_prod_info
		 bulk insert bronze.crm_prod_info
		 from 'D:\Sql project file\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
		 with (
			-- first row is column names so the actual table start from 2nd row
				firstRow = 2 ,
				-- the each columnn break using ,
				fieldterminator = ',',
				tablock
		       );
		set @endDate = getDate();
		print('DATA transfarred in bronze.crm_prod_info . ');
		print('Load Duration : '+cast(datediff(second,@startDate,@endDate)as nvarchar)+' seconds');
		print('');

		-----------------------------------File Changed--------------------------------
		set @startDate = GETDATE()
		print('Inserting data in bronze.crm_sales_info ');
		truncate table  bronze.crm_sales_info;
		-- Adding data
		bulk insert bronze.crm_sales_info
		from 'D:\Sql project file\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
		with (
		-- first row is column names so the actual table start from 2nd row
			firstRow = 2 ,
			-- the each columnn break using ,
			fieldterminator = ',',
			tablock
		     );
		set @endDate = GETDATE()
		print('DATA transfarred in bronze.crm_sales_info . ');
		print('Load Duration : '+cast(datediff(second,@startDate,@endDate)as nvarchar)+' seconds');
		print('');

		--------------------File Changed--------------------
		Print('================================');
		Print('CRM Files Completely Transferred');
		Print('=================================');
		Print('================================');
		Print('       ERP Files Transferring    ');
		Print('=================================');
		set @startDate = GETDATE()
		print('Inserting data in bronze.erp_cust_AZ12 ');

		truncate table  bronze.erp_cust_AZ12;
		-- Adding data
		bulk insert bronze.erp_cust_AZ12
		from 'D:\Sql project file\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
		with (
		-- first row is column names so the actual table start from 2nd row
			firstRow = 2 ,
			-- the each columnn break using ,
			fieldterminator = ',',
			tablock
		);
		set @endDate = getDate();
		print('DATA transfarred in bronze.erp_cust_AZ12 . ');
		print('Load Duration : '+cast(datediff(second,@startDate,@endDate)as nvarchar)+' seconds');
		print('');

		set @startDate = GETDATE()
		print('Inserting data in  bronze.erp_loc_A101 ');

		truncate table  bronze.erp_loc_A101;
		-- Adding data
		bulk insert bronze.erp_loc_A101
		from 'D:\Sql project file\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
		with (
		-- first row is column names so the actual table start from 2nd row
			firstRow = 2 ,
			-- the each columnn break using ,
			fieldterminator = ',',
			tablock
		);
		set @endDate = getDate();
		print('DATA transfarred in  bronze.erp_loc_A101 . ');
		print('Load Duration : '+cast(datediff(second,@startDate,@endDate)as nvarchar)+' seconds');
		print('');
		
		set @startDate = GETDATE()
		print('Inserting data in  bronze.erp_loc_A101 ');

		truncate table  bronze.erp_px_cat_G1V2;
		-- Adding data
		bulk insert bronze.erp_px_cat_G1V2
		from 'D:\Sql project file\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
		with (
		-- first row is column names so the actual table start from 2nd row
			firstRow = 2 ,
			-- the each columnn break using ,
			fieldterminator = ',',
			tablock
		);
		set @endDate = getDate();
		print('DATA transfarred in  bronze.erp_loc_A101 . ');
		print('Load Duration : '+cast(datediff(second,@startDate,@endDate)as nvarchar)+' seconds');
		print('');
		set @batch_end_time =getDate();
		Print('================================');
		Print('       ERP Files Transferring    ');
		Print('=================================');
		Print('================================');
		Print(' Bronze Data Transfer Completed  ');
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









