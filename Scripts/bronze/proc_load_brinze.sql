/*
=====================================================================
Stored Procedure : load bronze layer (source -> bronze)
=====================================================================
script purpose:
    This procedure loads data into bronze schema from external csv files
    It perform the following actions:
       Truncate the bronze layer tables before loading data
       use 'BULK INSERT' command to load data from external csv files into bronze layer tables
Parameters:
   None
   This stored procedure does not accept any parameters or return any values.
Usage Example:
EXEC bronze.load_bronze;
===========================================================================
*/

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
