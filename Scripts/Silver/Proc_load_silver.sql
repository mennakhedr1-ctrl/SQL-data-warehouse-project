/*
=====================================================================================
Stored procedure : Load silner layer (Bronze -> Silver)
=====================================================================================
Script purpose :
      This stored procedure perform the ETL (Extract, Transform, Load) processes to 
       populate the silver schema tables from bronze schema
    Actions performed :
       -Truncate silver tables 
       -Insert transformed and cleaned data from bronze schema into silver tables
=======================================================================================
*/
USE DataWarehouse;

CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN
    DECLARE @start_time DATETIME , @end_time DATETIME , @batch_strt_time DATETIME , @batch_end_time DATETIME;
	BEGIN TRY
	    SET @batch_strt_time = GETDATE();
		PRINT'================================================';
		PRINT 'Loading Silver Layer';
		PRINT'================================================';

		PRINT'------------------------------------------------';
		PRINT'Loading CRM Tables';
		PRINT'-------------------------------------------------';

		PRINT '-->>> TRUNCATING DATA FROM: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		SET @start_time = GETDATE();
		PRINT '-->>> INSERT DATA INTO: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_material_status,
		cst_gndr,
		cst_create_date

		)
		SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,

		CASE WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
			 WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
			 ELSE 'n/a'
		END cst_material_status,

		CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Fmale'
			 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			 ELSE 'n/a'
		END cst_gndr,
		cst_create_date
		FROM(
			SELECT 
			*,
			ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) AS sub_query
		WHERE flag_last =1;
		SET @end_time= GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'Seconds';
		PRINT'>>------------------------------------------'
		----================================================================
		PRINT '-->>> TRUNCATING DATA FROM: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		SET @start_time = GETDATE();
		PRINT '-->>> INSERT DATA INTO: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info(
		prd_id,
		prd_cat,
		prd_key,
		prd_name,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
		)
		SELECT 
		prd_id,
		REPLACE(SUBSTRING(prd_key,1,5),'-','_')AS prd_cat,
		SUBSTRING(prd_key,7,LEN(prd_key))AS prd_key,
		prd_name,
		ISNULL(prd_cost,0) AS prd_cost, -->>>> replace null with values
		CASE WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
			 WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
			 WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
			 WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
			 ELSE 'n/a'
		END prd_line,
		CAST(prd_start_dt AS DATE) AS prd_start_dt,
		CAST (LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) -1 AS DATE) AS prd_end_dt
		FROM bronze.crm_prd_info;
		SET @end_time=GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'Seconds';
		PRINT'>>------------------------------------------'
		--===================================================================
		PRINT '-->>> TRUNCATING DATA FROM: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		SET @start_time = GETDATE();
		PRINT '-->>> INSERT DATA INTO: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details(
		sls_ord_number,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_date,
		sls_sales,
		sls_quantity,
		sls_price
		)
		SELECT 
		sls_ord_number,
		sls_prd_key,
		sls_cust_id,
		CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt)!=8 THEN NULL
			 ELSE CAST(CAST(sls_order_dt AS varchar) AS DATE)
		END AS sls_order_dt,

		CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt)!=8 THEN NULL
			 ELSE CAST(CAST(sls_ship_dt AS varchar) AS DATE)
		END AS sls_ship_dt,

		CASE WHEN sls_due_date = 0 OR LEN(sls_due_date)!=8 THEN NULL
			 ELSE CAST(CAST(sls_due_date AS varchar) AS DATE)
		END AS sls_due_date,

		CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
			   THEN sls_quantity * ABS(sls_price)
			 ELSE sls_sales
		END AS sls_sales,
		sls_quantity,
		CASE WHEN sls_price IS NULL OR sls_price <=0 
				THEN sls_sales/NULLIF(sls_quantity,0)
			 ELSE sls_price
		END AS sls_price
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'Seconds';
		PRINT'>>------------------------------------------'
		--======================================================================
		PRINT'------------------------------------------------';
		PRINT'Loading ERP Tables';
		PRINT'-------------------------------------------------';

		PRINT '-->>> TRUNCATING DATA FROM: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		SET @start_time = GETDATE();
		PRINT '-->>> INSERT DATA INTO: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12(
		cust_id,
		B_date,
		cust_gendr
		)
		SELECT
		CASE WHEN cust_id LIKE 'NAS%' THEN SUBSTRING(cust_id,4,LEN(cust_id))
			 ELSE cust_id
		END AS cust_id,

		CASE WHEN B_date > GETDATE() THEN NULL
			 ELSE B_date
		END AS B_date,

		CASE WHEN UPPER(TRIM(cust_gendr)) IN ('F','FEMAL') THEN 'Femal'
			 WHEN UPPER(TRIM(cust_gendr)) IN ('M','MALE') THEN 'Male'
			 ELSE 'n/a'
		END AS cust_gendr
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'Seconds';
		PRINT'>>------------------------------------------'
		--====================================================================
		PRINT '-->>> TRUNCATING DATA FROM: silver.erp_cust_loc';
		TRUNCATE TABLE silver.erp_cust_loc;
		SET @start_time = GETDATE();
		PRINT '-->>> INSERT DATA INTO: silver.erp_cust_loc';
		INSERT INTO silver.erp_cust_loc(
		cust_id,
		cust_cuntry
		)
		SELECT 
		REPLACE(cust_id,'-','') as cust_id ,
		CASE WHEN TRIM(cust_cuntry) = 'DE' THEN 'Germany'
			 WHEN TRIM(cust_cuntry) IN ('US','USA') THEN 'United States'
			 WHEN TRIM(cust_cuntry) = '' OR cust_cuntry IS NULL THEN 'n/a'
			 ELSE cust_cuntry
		END AS cust_cuntry
		FROM bronze.erp_cust_loc;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'Seconds';
		PRINT'>>------------------------------------------'
		--==========================================================
		PRINT '-->>> TRUNCATING DATA FROM: silver.erp_px_cat';
		TRUNCATE TABLE silver.erp_px_cat;
		SET @start_time = GETDATE();
		PRINT '-->>> INSERT DATA INTO: silver.erp_px_cat';
		INSERT INTO silver.erp_px_cat(
		id,
		cat,
		subcat,
		maintenance
		)
		SELECT 
		id,
		cat,
		subcat,
		maintenance
		FROM bronze.erp_px_cat;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'Seconds';
		PRINT'>>------------------------------------------'

		SET @batch_end_time = GETDATE();
		PRINT'==========================================='
		PRINT'Loading Silver Layer Is Completed';
		PRINT'>>>> Total Load Duration: ' + CAST(DATEDIFF(second,@batch_strt_time,@batch_end_time)AS NVARCHAR) +'seconds';
		PRINT'============================================='
	END TRY
	BEGIN CATCH
	    PRINT'============================================'
		PRINT'ERROR OCCURED DURING LOADING Silver LAYER'
		PRINT'ERROR MESSAGE'+ ERROR_MESSAGE();
		PRINT'ERROR MESSAGE'+ CAST(ERROR_NUMBER()AS NVARCHAR);
		PRINT'ERROR MESSAGE'+ CAST(ERROR_STATE()AS NVARCHAR);
		PRINT'============================================'
	END CATCH
END
