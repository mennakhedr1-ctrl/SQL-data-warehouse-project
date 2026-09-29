/*
====================================================================
Quality checks 
====================================================================
Script Purposes :
  THIS script performs various quality checks for data consistency, accuracy,
  and standarization acorss the 'silver '  schema . it includes checks for :
    - Unwanted spaces in string fielld 
    - Null or duplicate primary keys
    - Data standarization and consistency
    - Invaild data range and orders
    - Data consistency between related field 
NOTE :
run this checks after loading the silver layer
=======================================================================
*/
SELECT 
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) >1;
--=======================================
-- check for unwanted spaces

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
--=======================================
-- checking data standarization & consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

SELECT DISTINCT cst_material_status
FROM silver.crm_cust_info;
--============================================
SELECT 
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) >1; -- >>>>> No duplicates
-------------------------------------------------
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;
-->>> Check for nulls or negative values
SELECT 
prd_cost
FROM silver.crm_prd_info
WHERE prd_cost <0 OR prd_cost IS NULL;
------->>> checking for invalid dates
SELECT * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
--===============================================================

SELECT 
NULLIF(sls_order_dt,0) AS sls_order_dt -->> return null is the two are equal
FROM silver.crm_sales_details
WHERE sls_order_dt=0 OR 
LEN(sls_order_dt) != 8 OR
sls_order_dt >20500101 OR 
sls_order_dt < 19000101;

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity* sls_price OR 
sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL OR 
sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales , sls_quantity,  sls_price ;
--=================================================
-->>>> checking invalid dates 
SELECT 
B_date
FROM silver.erp_cust_az12
WHERE B_date > GETDATE() OR B_date < '1919-01-01';

-->> checking gender values 
SELECT DISTINCT cust_gendr
FROM silver.erp_cust_az12;





