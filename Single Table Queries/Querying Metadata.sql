--------------------------------------------------------------
-- Querying Metadata
--------------------------------------------------------------
-- SQL Server provides tools for getting information about
-- the metadata of objects, such as information about tables
-- in a database and columns in a table.
-- Those tools include catalog views, information schema views
-- ,and system stored procedure functions.
--------------------------------------------------------------
-- Catalog Views
--------------------------------------------------------------
-- Provide detail information about objects in the database,
-- including information that is specific to SQL Server.
--------------------------------------------------------------
/**
	List the tables in a database along with their schema names
	,you can query the sys.tables view as follows:
**/
USE TSQLV6;

SELECT SCHEMA_NAME(schema_id) AS table_schema_name, name AS table_name
FROM sys.tables;

--SELECT * FROM sys.tables;

/**
	To get information about columns in a table, you can query the
	sys.columns table.

	The following code returns information about columns in the
	Sales.Orders table.
**/
SELECT
	name AS column_name,
	TYPE_NAME(system_type_id) AS column_type,
	max_length,
	collation_name,
	is_nullable
FROM sys.columns
WHERE object_id = OBJECT_ID(N'Sales.Orders');

---------------------------------------------------------------
-- Information Schema Views
-- SQL Server supports a set of views that reside in a schema 
-- called INFORMATION_SCHEMA and provide metadata information
-- in a standard manner. That is, the views are defined in the
-- SQL standard, so naturally they don't cover metadata aspects
-- or objects specific to SQL Server(such as indexing).
---------------------------------------------------------------
/**
	The following query againsts the INFORMATION_SCHEMA.TABLES view
	lists the base tables in the current database along with their
	schema names:
**/
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = N'BASE TABLE';

/**
	The following query against the INFORMATION_SCHEMA.COLUMNS views
	provides most of the available information about columns in the
	Sales.Orders table
**/
SELECT
	COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH,
	COLLATION_NAME, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = N'Sales'
	AND TABLE_NAME = N'Orders';

-----------------------------------------------------------------
-- System Stored Procedures and Functions
-- Internally query the system catalog and return more "digested"
-- metadata information
-----------------------------------------------------------------
/**
	The sp_tables stored procedure returns a list of objects
	(such as tables and views) that can be queried in the current
	database.
**/
EXEC sys.sp_tables;

/**
	The sp_help procedure accepts an object name as input and 
	returns multiple result sets with general information about
	the object, and also information about columns, indexes,
	constraints, and more.

	For example, the following code returns a detailed information
	about the Orders table:
**/
EXEC sys.sp_help
	@objname = N'Sales.Orders';

/**
	The sp_columns procedure returns information about columns in an
	object.

	For example the following code returns information about columns
	in the Orders table
**/
EXEC sys.sp_columns
	@table_name = N'Orders',
	@table_owner = N'Sales';

/**
	The sp_helpconstrain procedure returns information about constraints in an
	object.

	For example the following code returns information about constraints in the
	Orders table.
**/
EXEC sys.sp_helpconstraint
	@objname = N'Sales.Orders';

/**
	One set of functions returns information about properties of entities such as
	the SQL Server instance, database, object, column and so on.

	The SERVERPROPERTY function returns the requested property of the current.
	For example, the following code returns the collation of the current instance:
**/
SELECT
	SERVERPROPERTY('Collation');

/**
	THE DATABASEPROPERTYEX function returns the requested property of the specified
	database name.

	For example, the following code returns the collation of the TSQLV6 database:
**/
SELECT
	DATABASEPROPERTYEX(N'TSQLV6', 'Collation');

/**
	The OBJECTPROPERTY function returns the requested property of the specified
	object name.

	For example, the output of the following code indicates whether the Orders
	table has a primary key:
**/
SELECT
	OBJECTPROPERTY(OBJECT_ID(N'Sales.Orders'), 'TableHasPrimaryKey');

/**
	The COLUMNPROPERTY function returns the requested property of a specified
	column.

	For example, the output of the following code indicates whether the shipcountry
	column in the Orders table is nullable:
**/
SELECT
	COLUMNPROPERTY(OBJECT_ID(N'Sales.Orders'), N'shipcountry', 'AllowsNull');
