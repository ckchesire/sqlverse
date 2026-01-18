-----------------------------------------------------------
-- Views
-----------------------------------------------------------
-- Derived tables and CTEs have a single-statement scope,
-- which means they are not reusable. Views and inline
-- table-valued functions (inline TVFs) are two types of
-- table expressions whose definitions are stored as 
-- permanent objects in the database, making them reusable.
-- In most other respects, views and inline TVFs are
-- treated like derived tables and CTEs. For example, when
-- querying a view or an inline TVF, SQL Server expands the
-- definition of the table expression and queries the 
-- underlying objects directly, as with derived tables and
-- CTEs.
-----------------------------------------------------------
/**
	The following code creates a view calles USACusts in the
	Sales schema in the TSQLV6 database, representing all
	customers from the United States.

	Note: The GO command is used here to terminate what's
	called a batch in T-SQL.
**/
-- DROP VIEW IF EXISTS Sales.USACusts;
CREATE OR ALTER VIEW Sales.USACusts
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

-- You can query the view much like other tables in the database
SELECT custid, companyname
FROM Sales.USACusts;

SELECT *
FROM Sales.USACusts;

/**
	Because a view is an object in the database, you can manage
	access permission similar to the way you do for tables.(These
	permissions include SELECT, INSERT, UPDATE, and DELETE). You
	can even deny direct access to the underlying objects while
	granting access to the view.

	Note: That the general recommendation to avoid using SELECT * 
	has specific relevance in the context of views. The columns are
	enumerated in the compiled form of the view, and the new table
	columns will not be automatically added to the view.

	The best practice is to explicitly list the column names you 
	need in the definition of the view. If columns are added to
	the underlying tables and you need them in the view, use the
	CREATE OR ALTER VIEW statement or the ALTER VIEW statement
	to revise the view definition accordingly.
**/
