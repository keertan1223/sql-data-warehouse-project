/*
Creating the data warehouse after 
checking it aleady exists named  dataWarehouse and 
then the schema of bronze , sliver , gold

Warning
while running the query the previous dataWarehouse will be removed
*/
use master

if exists (select 1 from sys.databases where name = 'DataWarehouse')
begin
	alter Database DataWarehouse set single_user with rollback immediate
	drop database DataWarehouse;
end;

create database DataWarehouse;
use DataWarehouse;
go
create schema bronze;
go

create schema sliver;
go

create schema gold;
go
