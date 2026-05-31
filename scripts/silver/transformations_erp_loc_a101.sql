/* Checking and Cleaning erp_loc_a101 */

-- Checking cid and cst_id
-- Result: problem with '-'.
SELECT 
	cid,
	cntry
FROM bronze.erp_loc_a101;
SELECT * FROM silver.crm_cust_info;


-- Checking cntry consistency and standardize it
-- Result: problems!

SELECT DISTINCT
	cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;


/*====================== Tranformations and Loading ======================*/
TRUNCATE TABLE silver.erp_loc_a101
INSERT INTO silver.erp_loc_a101 (cid, cntry)
SELECT 
	REPLACE(cid, '-', '') AS cid,
	CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
		 WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'n/a'
		 ELSE TRIM(cntry)
	END AS cntry
FROM bronze.erp_loc_a101;

/*====================== Validating ======================*/

-- Checking cid and cst_id
-- Result: Ok
SELECT *
FROM silver.erp_loc_a101
WHERE cid LIKE '%-%';

-- Checking cntry consistency and standardize it
-- Result: Ok

SELECT DISTINCT
	cntry
FROM silver.erp_loc_a101
ORDER BY cntry;