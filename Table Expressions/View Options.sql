-------------------------------------------------------------------
-- View Options
-------------------------------------------------------------------
-- When you create or alter a view, you can specify view attributes
-- and options as part of the view definition. In the header of the
-- view, under the WITH clause, you can specify attributes such as
-- ENCRYPTION and SCHEMABINDING, and at the end of the query you
-- can specify WITH CHECK OPTION.
-------------------------------------------------------------------

--------------------------------------------------------------------
-- The ENCRYPTION option
--------------------------------------------------------------------
-- The ENCRYPTION option is available when you create or alter views
-- , stored procedures, triggers, and user-defined functions (UDF).
-- The ENCRYPTION option indicates that SQL Server will internally
-- store the text with the definition of the object in an obfuscated
-- format.
-- The obfuscated text is not directly visible to users through any
-- of the catalog objects-only to privileged users through special
-- means.
--------------------------------------------------------------------
CREATE OR ALTER VIEW Sales.USACusts
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

/**
	To get the definition of the view, invoke the OBJECT_DEFINITION
	function, like shown below.

	The text with the definition of the view is available because
	the view was created without the ENCRYPTION option.
**/
SELECT OBJECT_DEFINITION(OBJECT_ID('Sales.USACusts'));

/**
	Next, we alter the definition-only this time, we include the 
	ENCRYPTION option.
**/
CREATE OR ALTER VIEW Sales.USACusts WITH ENCRYPTION
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

/**
	We try again to get the text with the definition of the view.
	This time we get NULL back.
**/
SELECT OBJECT_DEFINITION(OBJECT_ID('Sales.USACusts'));

/**
	As an alternative to the OBJECT_DEFINITION function, you can use
	the sp_helptext stored procedure to get object definitions

	For example the following code requests the object definition of
	the USACusts view.

	We get the following message:
	"The text for object 'Sales.USACusts' is encrypted."
**/
EXEC sp_helptext 'Sales.USACusts';


---------------------------------------------------------------------
-- The SCHEMABINDING option
---------------------------------------------------------------------
-- The SCHEMABINDING option is available to views, UDFs, and natively
-- compiled modules; it binds the schema of referenced objects and
-- columns to the schema of the referencing object. It indicates that
-- referenced objects cannot be dropped and that the referenced 
-- columns cannot be dropped or altered.
---------------------------------------------------------------------
/**
	For example, alter the USACusts view with the SCHEMABINDING option
**/
CREATE OR ALTER VIEW Sales.USACusts WITH SCHEMABINDING
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

/**
	Now let's try to drop the address column from the Customers
	table.
**/
ALTER TABLE Sales.Customers DROP COLUMN address;

/**
	Without the SCHEMABINDING option, you would have been allowed to make
	such a schema change, as well as drop the Customers table altogether.
	This can lead to errors at run time when you try to query the view
	and referenced objects or columns do not exist. If you create the view
	with the SCHEMABINDING option, you can avoid these errors.

	To support the SCHEMABINDING option, the object definition must meet a
	couple of requirements:
	 1.) The query is not allowed to use * in the SELECT clause; instead, you
		 have to explicitly list column names.
	 2.) Also, you must use schema-qualified two-part names when referring to
	     objects.

	Creating your objects with the SCHEMABINDING option is generally considered
	a good practice. However, it could complicate application upgrades that
	involve structural object changes and make them longer due to the dependencies
	that are created.
**/

---------------------------------------------------------------------
-- The CHECK OPTION option
---------------------------------------------------------------------
-- The purpose of CHECK OPTION is to prevent modifications through
-- the view that conflict with the views inner query filter.
---------------------------------------------------------------------
/**
	The query defining the view USACusts filters customers from the 
	United States. The view is currently defined without CHECK OPTION.
	This means you can currently insert through the view customers
	from other countries, and you can update the country of existing
	customers through the view to one other than the United States.

	For example, the following code successfully inserts a customer
	from the United Kingdom through the view
**/
INSERT INTO Sales.USACusts(
	companyname, contactname, contacttitle, address,
	city, region, postalcode, country, phone, fax)
  VALUES(
    N'Customer ABCDE', N'Contact ABCDE', N'Title ABCDE', N'Address ABCDE',
	N'London', NULL, N'12345', N'UK', N'012-3456789', N'012-3456789');

/**
	The row was inserted through the view into the Customers table. However,
	because the view filters only customers from the United States, if you
	query the view looking for the new customer, you get an empty set back.
**/
SELECT custid, companyname, country
FROM Sales.USACusts
WHERE companyname = N'Customer ABCDE';

/**
	Query the Customers table directly to look for the new customer
**/
SELECT custid, companyname, country
FROM Sales.Customers
WHERE companyname = N'Customer ABCDE';

SELECT COUNT(*)
FROM Sales.Customers

/**
	Similarly, if you update a customer row through the view, changing
	the country attribute to a country other than the United States, the
	update succeeds. But that customer information doesn't show up anymore
	in the view because it doesn't satisfy the view's query filter.

	If you want  to prevent modifications that conflict with the view's
	filter, add WITH CHECK OPTION at the end of the query defining the
	view.
**/
CREATE OR ALTER VIEW Sales.USACusts WITH SCHEMABINDING
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
WITH CHECK OPTION;
GO

/**
	Now lets try to insert a row that conflicts  with the view's
	filter.

	We get an error:
	Msg 550, Level 16, State 1, Line 190
	The attempted insert or update failed because the target view either specifies
	WITH CHECK OPTION or spans a view that specifies WITH CHECK OPTION and one or 
	more rows resulting from the operation did not qualify under the CHECK OPTION 
	constraint.
	The statement has been terminated.
**/
INSERT INTO Sales.USACusts(
  companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax)
VALUES(
  N'Customer FGHIJ', N'Contact FGHIJ', N'Title FGHIJ', N'Address FGHIJ',
  N'London', NULL, N'12345', N'UK', N'012-3456789', N'012-3456789');

/**
	Code cleanup.
**/
DELETE FROM Sales.Customers
WHERE custid > 91;

DROP VIEW IF EXISTS Sales.USACusts;