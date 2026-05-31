/* Checking and Cleaning erp_px_cat_g1v2 */

-- Checking the id and prd_key
-- Result: CO_PD is not in the crm_prd_info table
SELECT id
FROM bronze.erp_px_cat_g1v2
WHERE id NOT IN (SELECT cat_id FROM silver.crm_prd_info);

-- Check for unwanted spaces
-- Result:Ok
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);


-- Check data consistency and standardization
-- Results: Ok
SELECT DISTINCT 
	cat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT 
	subcat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT 
	maintenance
FROM bronze.erp_px_cat_g1v2;

/*====================== Tranformations and Loading ======================*/
TRUNCATE TABLE silver.erp_px_cat_g1v2
INSERT INTO silver.erp_px_cat_g1v2(
	id,
	cat,
	subcat,
	maintenance)
SELECT 
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2;


/*====================== Validating ======================*/

SELECT * FROM silver.erp_px_cat_g1v2;

-- Everything were fine, don't need validation.