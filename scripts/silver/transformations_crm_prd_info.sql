/* Checking and Cleaning crm_prd_info */

-- Check for Nulls or duplicates in primary key
-- Expectation: No Result
-- Result: OK

SELECT
	prd_id,
	COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted spaces
-- Expectation: No Result
-- Results: OK

SELECT *
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- Check for nulls or negative numbers
-- Expectation: No results
-- Results: 2 nulls (replaced by 0)

SELECT *
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;

-- Check consistency and standardize the column prd_line

SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;

-- Checking invalid date orders
-- Results: problems
-- Solution: create a logic line between start and end date 

SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- Logic

SELECT 
	prd_id,
	prd_key,
	prd_nm,
	prd_start_dt,
	prd_end_dt,
	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt ASC)-1 AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R','AC-HE-HL-U509')



/*====================== Tranformations ======================*/

TRUNCATE TABLE silver.crm_prd_info
INSERT INTO silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt)
SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Extrating the category and replacing '-' by '_' so we can join tables later
	SUBSTRING(prd_key,7, LEN(prd_key)) AS prd_key, -- extrating the key
	prd_nm,
	COALESCE(prd_cost,0) AS prd_cost, -- handling nulls
	CASE UPPER(TRIM(prd_line))
		 WHEN 'M' THEN 'Mountain'
		 WHEN 'R' THEN 'Road'
		 WHEN 'S' THEN 'Other Sales'
		 WHEN 'T' THEN 'Touring'
		 ELSE 'n/a'
	END AS prd_line,
	CAST (prd_start_dt AS DATE) AS prd_start_dt, -- datetime to date
	CAST (LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt ASC)-1 AS DATE) AS prd_end_dt -- aligning the start dates and datetime to date
FROM bronze.crm_prd_info



/*====================== Validating ======================*/

SELECT * FROM silver.crm_prd_info

-- Check for Nulls or duplicates in primary key
-- Expectation: No Result
-- Result: OK

SELECT
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;


-- Check for unwanted spaces
-- Expectation: No Result
-- Results: OK

SELECT *
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- Check for nulls or negative numbers
-- Expectation: No results
-- Results: OK

SELECT *
FROM silver.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;


-- Check consistency and standardize the column prd_line

SELECT DISTINCT prd_line
FROM silver.crm_prd_info;


-- Checking invalid date orders
-- Results: problems
-- Solution: OK

SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;