/*
================================================================
DDL & Load Script: Bronze Layer
================================================================
Script Purpose:
    This script drops and recreates tables in the 'bronze' schema, 
    then truncates and bulk-loads raw CSV data into staging tables.
==================================================================
*/
USE DataWarehouse;
GO
  
IF OBJECT_ID ('bronze.crm_cust_info','U') IS NOT NULL
   DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info(
cst_id INT, 
cst_key NVARCHAR (50),
cst_firstname NVARCHAR (50),
cst_lastname NVARCHAR (50),
cst_material_status NVARCHAR (50),
cst_gndr NVARCHAR(50),
cst_create_date DATE 
);

IF OBJECT_ID ('bronze.crm_prd_info','U') IS NOT NULL
   DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info (
prd_id INT,
prd_key NVARCHAR (50),
prd_name NVARCHAR (50),
prd_cost INT,
prd_line NVARCHAR(50),
prd_start_dt DATETIME,
prd_end_dt DATETIME
);

IF OBJECT_ID ('bronze.crm_sales_details','U') IS NOT NULL
   DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
sls_ord_number NVARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_due_date INT,
sls_sales INT,
sls_quantity INT ,
sls_price INT
);

IF OBJECT_ID ('bronze.erp_cust_az12','U') IS NOT NULL
   DROP TABLE bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
cust_id NVARCHAR (50),
B_date DATE ,
cust_gendr NVARCHAR(50) 
);

IF OBJECT_ID ('bronze.erp_cust_loc','U') IS NOT NULL
   DROP TABLE bronze.erp_cust_loc;
CREATE TABLE bronze.erp_cust_loc(
cust_id NVARCHAR(50),
cust_cuntry NVARCHAR(50)
);

IF OBJECT_ID ('bronze.erp_px_cat','U') IS NOT NULL
   DROP TABLE bronze.erp_px_cat;
CREATE TABLE bronze.erp_px_cat(
id	NVARCHAR(50),
cat NVARCHAR(50),
subcat NVARCHAR(50),
maintenance NVARCHAR (50)
);
--------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT'================================================';
		PRINT 'Loading Bronze Layer';
		PRINT'================================================';

		PRINT'------------------------------------------------';
		PRINT'Loading CRM Tables';
		PRINT'-------------------------------------------------';

		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		SET @start_time = GETDATE();
		PRINT'INSERT DATA INTO:crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'D:\AI\Data Engineering\data engineering\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
		WITH (
		   FIRSTROW =2,
		   FIELDTERMINATOR =',',
		   TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'Seconds';
		PRINT'>>------------------------------------------'
		-- ==============================================
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT'INSERT DATA INTO:crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'D:\AI\Data Engineering\data engineering\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
		WITH (
		   FIRSTROW =2,
		   FIELDTERMINATOR =',',
		   TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'Seconds';
		PRINT'>>------------------------------------------'
		--=================================================
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT'INSERT DATA INTO:crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'D:\AI\Data Engineering\data engineering\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
		WITH (
		   FIRSTROW =2,
		   FIELDTERMINATOR =',',
		   TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'Seconds';
		PRINT'>>------------------------------------------'
		--===================================================
		PRINT'------------------------------------------------';
		PRINT'Loading ERP Tables';
		PRINT'-------------------------------------------------';
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT'INSERT DATA INTO:erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'D:\AI\Data Engineering\data engineering\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
		WITH(
		   FIRSTROW =2,
		   FIELDTERMINATOR =',',
		   TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'Seconds';
		PRINT'>>------------------------------------------'
		--====================================================
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_loc';
		TRUNCATE TABLE bronze.erp_cust_loc;

		PRINT'INSERT DATA INTO:erp_cust_loc';
		BULK INSERT bronze.erp_cust_loc
		FROM 'D:\AI\Data Engineering\data engineering\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
		WITH(
		   FIRSTROW =2,
		   FIELDTERMINATOR =',',
		   TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'Seconds';
		PRINT'>>------------------------------------------'
		--====================================================
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat';
		TRUNCATE TABLE bronze.erp_px_cat;

		PRINT'INSERT DATA INTO:erp_px_cat';
		BULK INSERT bronze.erp_px_cat
		FROM 'D:\AI\Data Engineering\data engineering\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH(
		   FIRSTROW =2,
		   FIELDTERMINATOR =',',
		   TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'Seconds';
		PRINT'>>---------------------------';

		SET @batch_end_time = GETDATE();
		PRINT'==========================================='
		PRINT'Loading Bronze Layer Is Completed';
		PRINT'>>>> Total Load Duration: ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time)AS NVARCHAR) +'seconds';
		PRINT'============================================='
	END TRY 
	BEGIN CATCH
	    PRINT'============================================'
		PRINT'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT'ERROR MESSAGE'+ ERROR_MESSAGE();
		PRINT'ERROR MESSAGE'+ CAST(ERROR_NUMBER()AS NVARCHAR);
		PRINT'ERROR MESSAGE'+ CAST(ERROR_STATE()AS NVARCHAR);
		PRINT'============================================'
	END CATCH

END
