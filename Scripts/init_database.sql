/*
====================================================
create database and schemas 
====================================================
script purpose:
this scripts create a new database named DataWarehouse after checking if it already exists.
if the database exists, it's droped and recreated. Additionaly, the scripts setsup three schemas 
within the database: 'bronze' , 'silver', and 'gold'

WARNING :
running this script will drop the entire 'DataWarehouse' database if it's exists 
All data in database will be permanently deleted .
proceed with caution and ensure you have proper backups before running the scripts
*/
USE master;

-- drop and recreate the 'data warehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse' )
BEGIN 
  ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE ;
  DROP DATABASE DataWarehouse ;
END ;
GO 
--- create database 'Data Warehouse'  
CREATE DATABASE DataWarehouse;

USE DataWarehouse;

--- create schema

CREATE SCHEMA bronze;
GO 
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
