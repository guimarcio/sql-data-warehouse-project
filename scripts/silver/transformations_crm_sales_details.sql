/* Checking and Cleaning crm_sales_details */

-- Check for unwanted spaces
-- Expectation: No Result
-- Results: OK

SELECT *
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);


-- Check if prd_key and cst_id are ok
-- Results: OK

SELECT * 
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

SELECT * 
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

-- Check for invalid dates sls_order_dt
-- Result: problems
SELECT
	NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8 
OR sls_order_dt > 20500101 
OR sls_order_dt < 19000101;

-- Check for invalid dates sls_ship_dt
-- Result: Ok but we're going to do the same previously processing 
SELECT
	NULLIF(sls_ship_dt, 0) AS sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 
OR LEN(sls_ship_dt) != 8 
OR sls_ship_dt > 20500101 
OR sls_ship_dt < 19000101;

-- Check for invalid dates sls_due_dt
-- Result: Ok but we're going to do the same previously processing 
SELECT
	NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
OR LEN(sls_due_dt) != 8 
OR sls_due_dt > 20500101 
OR sls_due_dt < 19000101;

-- Check if order_dt is > ship_dt or order_dt is > due_dt
-- Result: OK
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Check data consistency: between sales, quantity and price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative
-- Results: Lots of problems -> use the information given to get a better result.

SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


/*====================== Tranformations and Loading ======================*/

TRUNCATE TABLE silver.crm_sales_details 
INSERT INTO silver.crm_sales_details (
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price)
SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	
	CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL -- date cleaning
		 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,
	
	CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL -- date cleaning
		 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,
	
	CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL -- date cleaning
		 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,

	CASE WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price) -- sales consistency
		 THEN sls_quantity * ABS(sls_price) 
		 ELSE sls_sales
	END AS sls_sales,

	sls_quantity,

	CASE WHEN sls_price IS NULL OR sls_price <= 0 -- price consistency
		 THEN sls_sales / NULLIF(sls_quantity, 0)
		 ELSE sls_price
	END AS sls_price

FROM bronze.crm_sales_details


/*====================== Validating ======================*/


-- Check for unwanted spaces
-- Expectation: No Result
-- Results: OK
SELECT *
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);


-- Check if prd_key and cst_id are ok
-- Results: OK
SELECT * 
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

SELECT * 
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

-- Check if order_dt is > ship_dt or order_dt is > due_dt
-- Result: OK
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Check data consistency: between sales, quantity and price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative
-- Results: Lots of problems -> use the information given to get a better result.

SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

SELECT * FROM silver.crm_sales_details;


