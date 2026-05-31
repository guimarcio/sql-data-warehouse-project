/* Checking and Cleaning erp_cust_az12 */

-- Check if cid has duplicates or nulls
-- Result: Ok
SELECT 
	cid,
	COUNT(*)
FROM bronze.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL

-- We need to change cid to connect with other table
-- Problem: NAS%
SELECT * FROM silver.crm_cust_info;


-- Check bdate consistency
-- Result: problems!
SELECT DISTINCT
	bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

-- Check gen consistency and standardize it
-- Result: problems!
SELECT DISTINCT
	gen
FROM bronze.erp_cust_az12;



/*====================== Tranformations and Loading ======================*/

TRUNCATE TABLE silver.erp_cust_az12
INSERT INTO silver.erp_cust_az12(
	cid,
	bdate,
	gen)
SELECT 
	CASE WHEN cid LIKE ('NAS%') THEN SUBSTRING(cid, 4, len(cid))
		 ELSE cid
	END AS cid,
	CASE WHEN bdate > GETDATE() THEN NULL
		 ELSE bdate
	END AS bdate,
	CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		 ELSE 'n/a'
	END AS gen
FROM bronze.erp_cust_az12;




/*====================== Validating ======================*/

-- Check if cid has duplicates or nulls
-- Result: Ok
SELECT 
	cid,
	COUNT(*)
FROM silver.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL

-- We need to change cid to connect with other table
-- Problem: Ok
SELECT * 
FROM silver.erp_cust_az12
WHERE cid LIKE 'NAS%';


-- Check bdate consistency
-- Result: ok
SELECT DISTINCT
	bdate
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();

-- Check gen consistency and standardize it
-- Result: problems!
SELECT DISTINCT
	gen
FROM silver.erp_cust_az12;

SELECT * FROM silver.erp_cust_az12;