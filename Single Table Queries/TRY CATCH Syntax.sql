----------------------------------------------------------------
-- Syntax:
-- The basic syntax for a TRY...CATCH block is as follows
----------------------------------------------------------------
BEGIN TRY
	-- SQL Statements that might cause an error
END TRY
BEGIN CATCH
	-- Code to handle the error (e.g., logging, rollback)
END CATCH;
-- Statements here execute whether an error occured or not 
-- (similar to FINALLY in other Languages)



------------------------------------------------------------------
-- Usage with Error functions
-- Within the CATCH block, built-in functions can provide details
-- about an error. These include ERROR_NUMBER(), ERROR_SEVERITY(),
-- ERROR_STATE(), ERROR_PROCEDURE(), ERROR_LINE(), and 
-- ERROR_MESSAGE().
------------------------------------------------------------------
BEGIN TRY
	-- Generate a divide-by-zero error
	SELECT 1 / 0 AS ERROR;
END TRY
BEGIN CATCH
	SELECT
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() AS ErrorState,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage;
END CATCH

----------------------------------------------------------------
-- Using with Transactions
-- TRY...CATCH is commonly used with transactions to maintain
-- data integrity. If an error makes a transaction uncommitable,
-- the CATCH block can use XACT_STATE() to check the status and
-- ROLLBACK.
----------------------------------------------------------------
BEGIN TRANSACTION;
BEGIN TRY
	-- DML statements (INSERT, UPDATE, DELETE)
	DELETE FROM Production.Product WHERE ProductID = 980; -- Example might violate a constraint
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	-- Check if a transaction is active and roll it back
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

	-- Log the error details or raise a custom error
	SELECT ERROR_MESSAGE() AS ErrorMessage;
	-- Optionally re-throw the error for the client using THROW or RAISERROR
	THROW;
END CATCH;

-- SELECT @@TRANCOUNT;
-- ROLLBACK TRANSACTION;


