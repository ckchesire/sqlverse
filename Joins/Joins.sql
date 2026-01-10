-----------------------------------------------------------------------
-- Joins
-----------------------------------------------------------------------
-- The FROM clause of a query is the first clause to be logically
-- processed, and within the FROM clause, table operators operate
-- on input. T-SQL supports four table operators: JOIN, APPLY, PIVOT, 
-- and UNPIVOT. The JOIN table operator are standard, whereas APPLY,
-- PIVOT, and UNPIVOT are T-SQL extensions to the standard.
--
-- A JOIN table operator operates on two input tables. The three
-- fundamental types of joins are cross joins, inner joins, and outer
-- joins. These three types of joins differ in how they apply their 
-- logical query processing phases; each type applies a different
-- set of phases. A cross join applies only one phase-Cartesian 
-- Product. An inner join applies two phases-Cartesian Product and 
-- Filter. An outer join applies three phases-Cartesian Product,Filter,
-- and Add Outer Rows.
-----------------------------------------------------------------------
USE TSQLV6;

-----------------------------------------------------------------------
-- Cross Joins
-----------------------------------------------------------------------
-- The cross join is the simplest type of join. It implements only one
-- logical query processing phase-a Cartesian Product. This phase 
-- operates on the two tables provided as inputs and produces a 
-- Cartesian product of the two. That is, each row from one input is
-- matched with all rows from the other. So if you have m rows in one
-- table and n rows in the other, you get m*n rows in the result.
-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- SQL-92 syntax
-- The following query applies a cross join between the Customers and
-- Employees tables (using the SQL-92 syntax) in the TSQLV6 database,
-- and returns the custid and empid attributes
-----------------------------------------------------------------------
SELECT C.custid, E.empid
FROM Sales.Customers AS C
	CROSS JOIN HR.Employees AS E;

------------------------------------------------------------------------
-- SQL-89 syntax
-- T-SQL supports an older syntax for cross joins that was introduced in
-- SQL-89. In this syntax, you simply specify a comma between the table
-- names.
------------------------------------------------------------------------
SELECT C.custid, E.empid
FROM Sales.Customers AS C, HR.Employees AS E;


------------------------------------------------------------------------
-- Self Cross Joins
-- You can join multiple instances of the same table. This capability is
-- known as a self join and is supported with all fundamental join types
-- (cross joins, inner joins, and outer joins)
------------------------------------------------------------------------
/**
	The following query performs a self cross join between two instances
	of the Employees table.
**/
SELECT
   E1.empid, E1.firstname, E1.lastname,
   E2.empid, E1.firstname, E2.lastname
FROM HR.Employees as E1
   CROSS JOIN HR.Employees as E2;

------------------------------------------------------------------------
-- Producing tables of numbers
-- One situation in which cross joins can be handy is when they are used
-- to produce a result set with a sequence of integers(1, 2, 3, and so
-- on).
-- By using cross joins, you can produce the sequence of integers in a
-- very efficient manner.
------------------------------------------------------------------------

/**
	Create a table Digits with a column called digit, and populate the
	table with 10 rows with the digits 0 through 9.
**/
USE TSQLV6;

DROP TABLE IF EXISTS dbo.Digits;

CREATE TABLE dbo.Digits(digit INT NOT NULL PRIMARY KEY);

INSERT INTO dbo.Digits(digit)
  VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

SELECT digit FROM dbo.Digits;

/**
	Suppose you need to write a query that produces a sequence of integers
	in the range 1 through 1,000. You apply cross joins between three instances
	of the Digits table, each representing a different power of 10(1,10,100).
	By multiplying three instances of the same table,each instance with 10 rows,
	you get a result set with 1,000 rows.
	
	To produce the actual number, multiply the digit from each instance by the
	power of 10 it represents, sum the results, and add 1.
**/

SELECT D3.digit * 100 + D2.digit * 10 + D1.digit + 1 AS n
FROM		dbo.Digits AS D1
 CROSS JOIN dbo.Digits AS D2
 CROSS JOIN dbo.Digits AS D3
ORDER BY n;

-- Using GENERATE_SERIES function as an alternative.
SELECT value
FROM GENERATE_SERIES( 1, 1000 ) AS N;

-------------------------------------------------------------------------
-- Inner Joins
-- An inner join applies two logical query processing phases-it applies
-- a Cartesian product between the two input tables like in a cross join
-- ,and then filters rows based on a predicate you specify.
-------------------------------------------------------------------------
/**
	SQL-92 syntax.

	The following query performs an inner join between Employees and Orders
	tables in the TSQLV6 database, matching employees and orders based on
	the predicate E.empid = O.empid
**/
USE TSQLV6;

SELECT E.empid, E.firstname, E.lastname, O.orderid
FROM HR.Employees AS E
  INNER JOIN Sales.Orders AS O
  ON E.empid = O.empid;

/**
	SQL-89 syntax
	
	You specify a comma between the table names just as in
	cross join, and you specify the join condition in the query's
	WHERE clause.
**/
SELECT E.empid, E.firstname, E.lastname, O.orderid
FROM HR.Employees AS E, Sales.Orders AS O
WHERE E.empid = O.empid;


-------------------------------------------------------------------------
-- More Join Examples
-- We cover composite joins, non-equi joins, and multi-join queries
-------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Composite Joins
-- A composite join is simply a join for which you need to match multiple
-- attributes from each side.
-- You usually need such a join when a primary key-foreign key relationship
-- is based on more than one attribute.
---------------------------------------------------------------------------
/**
	Suppose you have a foreign key defined on dbo.Table2, columns col1,col2,
	referencing dbo.Table1, columns col1,col2, and you need to write a query
	that joins the two based on this relationship.
	
	The FROM clause of the query would look like this:
**/
FROM dbo.Table1 AS T1
  INNER JOIN dbo.Table2 AS T2
    ON T1.col1 = T2.col1
	AND T1.col2 = T2.col2

/**
	Create audit updates to column values against the OrderDetails
	table.

	Create a custom auditing table called OrderDetailsAudit.
**/

USE TSQLV6;

DROP TABLE IF EXISTS Sales.OrderDetailsAudit;

CREATE TABLE Sales.OrderDetailsAudit
(
	lsn			INT NOT NULL IDENTITY,
	orderid		INT NOT NULL,
	productid	INT NOT NULL,
	dt			DATETIME NOT NULL,
	loginname	sysname NOT NULL,
	columnname	sysname NOT NULL,
	oldval		SQL_VARIANT,
	newval		SQL_VARIANT,
	CONSTRAINT PK_OrderDetailsAudit PRIMARY KEY(lsn),
	CONSTRAINT FK_OrderDetailsAudit_OrderDetails
		FOREIGN KEY(orderid, productid)
		REFERENCES Sales.OrderDetails(orderid, productid)
);

SELECT TOP 5 * 
FROM Sales.OrderDetails;

/*
	Check for the trigger on OrderDetails table,
	used to update the OrderDetailsAudit table.
*/
SELECT * FROM sys.triggers 
WHERE parent_id = OBJECT_ID('Sales.OrderDetails');


SELECT * FROM Sales.OrderDetailsAudit;

UPDATE Sales.OrderDetails 
SET qty = qty + 1
WHERE orderid = 10248
  AND productid = 72;

SELECT OD.orderid, OD.productid, OD.qty,
  ODA.dt, ODA.loginname, ODA.oldval, ODA.newval
FROM Sales.OrderDetails AS OD
  INNER JOIN Sales.OrderDetailsAudit AS ODA
    ON OD.orderid = ODA.orderid
	AND OD.productid = ODA.productid
WHERE ODA.columnname = N'qty';


