/*

===================================
Create Database and Schemas
===================================

Script Purpose:
	This script creates a new database named 'DataWarehouse' after checking if it already exists.
	If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
	within the database: 'bronze', 'silver' and 'gold'.

WARNING:
	Runnning this script will drop the entire 'DataWarehouse' database if it exists. Proceed with caution!
*/

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

-- Create 'DataWarehouse' DB
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
