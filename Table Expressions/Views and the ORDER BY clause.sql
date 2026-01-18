-----------------------------------------------------------------
-- Views and the ORDER BY clause
-----------------------------------------------------------------
-- The query you use to define a view must meet all requirements
-- mentioned earlier with respect to the inner query in the other
-- types of table expressions.
-- The view should not guarantee any order to the rows, all view
-- columns must have names, and all column names must be unique.
-- Remember that a presentation ORDER BY clause is not allowed in
-- the query defining a table expression because a relation isn't
-- ordered.
-----------------------------------------------------------------
/**
	If you need to return rows from a view sorted for presentation
	purposes, you should specify a presentation ORDER BY clause in
	the outer query against the view.
**/
SELECT custid, companyname, region
FROM Sales.USACusts
ORDER BY region;
/**
	Trying to run code to create a view with a presentation 
	ORDER BY clause
**/
CREATE OR ALTER VIEW Sales.USACusts
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
ORDER BY region;
GO
/**
	The error message indicates that T-SQL allows the ORDER BY clause
	only in exceptional cases-when the TOP, OFFSET-FETCH, or FOR XML
	option is used. In those cases, the ORDER BY clause serves a
	purpose other than its usual presentation purpose.

	Because T-SQL allows an ORDER BY clause in a view when TOP or
	OFFSET-FETCH is also specified, some people think they can
	create "ordered views." One of the ways people try to achieve
	this is by using TOP(100) PERCENT, like the following:
**/
CREATE OR ALTER VIEW Sales.USACusts
AS

SELECT TOP (100) PERCENT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country =  N'USA'
ORDER BY region;
GO

/**
	Even though the code is technically valid and the view is
	created, you should be aware that if an outer query against
	the view doesn't have an ORDER BY clause, presentation
	order is not guaranteed.
**/
-- For example run the following query against the view
SELECT custid, companyname, region
FROM Sales.USACusts;

/**
	Inner query that uses the OFFSET clause with 0 ROWS, and without a FETCH 
	clause
**/
CREATE OR ALTER VIEW Sales.USACusts
AS

SELECT
  custid, companyname, contactname, contacttitle, address,
  city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
ORDER BY region
OFFSET 0 ROWS;
GO

/**
	If you need a guarantee that the rows will be returned
	sorted, you need an ORDER BY clause in the outer query.
**/
SELECT custid, companyname, region
FROM Sales.USACusts
ORDER BY region;
/**
	Do not confuse the behavior of a query that is used to define
	a table expression with an outer query.

	An outer query with an ORDER BY clause and a TOP or OFFSET-FETCH
	option does guarantee presentation order. The simple rule is that
	if the outer query has an ORDER BY clause, you have a presentation
	ordering guarantee, regardless of whether that ORDER BY clause also
	serves another purpose.
**/
