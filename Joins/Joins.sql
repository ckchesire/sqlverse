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

UPDATE Sales.OrderDetails 
SET qty = qty + 1
WHERE orderid = 10248
  AND productid = 72;

SELECT * FROM Sales.OrderDetailsAudit;

SELECT OD.orderid, OD.productid, OD.qty,
  ODA.dt, ODA.loginname, ODA.oldval, ODA.newval
FROM Sales.OrderDetails AS OD
  INNER JOIN Sales.OrderDetailsAudit AS ODA
    ON OD.orderid = ODA.orderid
	AND OD.productid = ODA.productid
WHERE ODA.columnname = N'qty';


---------------------------------------------------------------------------
-- Non-equi joins
-- When a join condition involves only an equality operator, the join is 
-- said to be an equi join. When a join condition involves any operator
-- besides equality, the join is said to be a non-equi join.
---------------------------------------------------------------------------
/**
	As an example of a non-equi join, the following query joins two instances
	of the Employees table to produce unique pairs of employees.

	Notice the predicate specified in the ON clause. The purpose of the query
	is to produce unique pairs of employees.
**/
SELECT
	E1.empid, E1.firstname, E1.lastname,
	E2.empid, E2.firstname, E2.lastname
FROM HR.Employees AS E1
	INNER JOIN HR.Employees AS E2
	  ON E1.empid < E2.empid;

---------------------------------------------------------------------------
-- Multi-join queries
-- A join table operator operates only on two tables, but a single query
-- can have multiple joins.
-- In general, when more than one table operator appears in the FROM clause
-- ,the table operators are logically processed in written order.
-- If there are multiple joins in the FROM clause, the first join operates
-- on the two base tables, but all other joins get the result of the
-- preceding join as their left input.
---------------------------------------------------------------------------
SELECT
	C.custid, C.companyname, O.orderid,
	OD.productid, OD.qty
FROM Sales.Customers AS C
	INNER JOIN Sales.Orders AS O
	  ON C.custid = O.custid
	INNER JOIN Sales.OrderDetails AS OD
	  ON O.orderid = OD.orderid;

---------------------------------------------------------------------------
-- Outer Joins
---------------------------------------------------------------------------
-- The outer joins apply the two logical procesing phases that inner joins
-- apply (Cartesian Product and the ON filter), plus a third phase called
-- Adding Outer Rows that is unique to this type of join.
-- In an outer join, you mark a table as a preserved table by using the 
-- keywords LEFT OUTER JOIN, RIGHT OUTER JOIN, or FULL OUTER JOIN between
-- the table names.The OUTER keyword is optional.
---------------------------------------------------------------------------
/**
	The following query joins the Customers and Orders tables, based on a
	match between the customer's customer ID and the order's customer ID,
	to return customers and their orders.

	The join type is a left outer join; therefore, the query also returns
	customers who did not place any orders.
**/

SELECT C.custid, C.companyname, O.orderid
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
	ON C.custid = O.custid;

/**
	When you need to express a predicate that is not final - meaning a
	predicate that determines which rows to match from the nonpreserved
	side - specify the predicate in the ON clause.

	When you need a filter to be applied after outer rows are produced,
	and you want the filter to be final, specify the predicate in the
	WHERE clause.Conceptually, the WHERE clause is processed after the
	FROM clause - specifically, after all table operators have been processed
	and(in the case of outer joins) after all outer rows have been produced

	To recap, in the ON clause you specify nonfinal, or matching, predicates.
	In the WHERE clause you specify final, or filtering, predicates.

	The following is an example to return only customers who did not place
	any orders or, more technically, you need to return only outer rows.
**/
SELECT C.custid, C.companyname, O.orderid
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
WHERE O.orderid IS NULL;

---------------------------------------------------------------------------
-- Including Missing Values
-- You can use outer joins to identify and include missing values when
-- querying data.
---------------------------------------------------------------------------
/**
	Suppose you need to query all orders from the Orders table. You need to
	ensure that you get atleast one row in the output for each date in the
	range January 1,2020 through December 31,2022. You don't want to do 
	anything special with dates within the range that have orders, but you
	do want the output to include the dates with no orders, with NULLs as
	placeholders in the attributes of the order.

	To solve the problem, you can first write a query that returns a sequence
	of all dates in the requested period. You can then perform a left outer join
	between that set and the Orders table. This way, the result also includes
	missing dates.
**/

-- Query to return a sequence of all dates in the range January 1,2020 through
-- December 31,2022
SELECT DATEADD(day, n-1, CAST('20200101' AS DATE)) AS orderdate
FROM dbo.Nums
WHERE n <= DATEDIFF(day, '20200101', '20221231') + 1
ORDER BY orderdate;

-- Next step is to extend the previous query, adding a left outer join between
-- Nums and the Orders tables.
SELECT DATEADD(day, Nums.n - 1, CAST('20200101' AS DATE)) AS orderdate,
  O.orderid, O.custid, O.empid
FROM dbo.Nums
  LEFT OUTER JOIN Sales.Orders AS O
    ON DATEADD(day, Nums.n - 1, CAST('20200101' AS DATE)) = O.orderdate
WHERE Nums.n <= DATEDIFF(day, '20200101', '20221231') + 1
ORDER BY orderdate;

-- Generate dates using generate series
SELECT CAST (DATEADD(day, value, '20200101') AS DATE) AS orderdate
FROM GENERATE_SERIES(
		0,
		DATEDIFF(day, '20200101', '20221231')
	)
ORDER BY orderdate;

---------------------------------------------------------------------------
-- Filtering attributes from the nonpreserved side of an outer join
------------------------------------------------------------------------------
-- When you need to review code involving outer joins to look for logical
-- bugs, one thing you should examine is the WHERE clause. If the predicate
-- in the WHERE clause refers to an attribute from the nonpreserved side of
-- the join using an expression in the form <attribute> <operator> <value>,
-- it's usually an indication of a bug.
--
-- This is because attributes from the non preserved side of the join are
-- NULLs in outer rows, and an expression in the from NULL <operator> <value>
-- yields UNKNOWN (unless it's the IS NULL operator explicitly looking for
-- NULLs, or the distinct predicat IS [NOT] DISTINCT FROM). Recall that a 
-- WHERE clause filters UNKNOWN out. Such a predicate in the WHERE clause
-- causes all outer rows to be filtered out. Effectively, the join becomes an
-- inner join.
------------------------------------------------------------------------------

/**
	Consider the following query.

	The predicate O.orderddate >= '20220101' in the WHERE clause evaluates
	to UNKNOWN for all outer rows, because those have a NULL in the O.orderdate
	attribute. All outer rows are eliminated by the WHERE filter.
**/
SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
WHERE O.orderdate >= '20220101';

/**
	Inorder to return the outer rows we use the filter in the ON predicate
**/
SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid AND O.orderdate >='20220101';

-------------------------------------------------------------------------------
-- Using Outer Joins in a Multi-Join Query
-------------------------------------------------------------------------------
-- Recall the discussion about all-at-once operations in "Single-table queries"
-- The concept describes the fact that all expressions that appear in the same
-- logical query processing phase are evaluated as a set, at the same point in
-- time. However, this concept is not applicable to the processing of table 
-- operators in the FROM phase. Table operators are logically evaluated in 
-- written order. Rearranging the order in which outer joins are processed might
-- result in different output, so you cannot rearrange the at will.
-------------------------------------------------------------------------------
/**
	Some interesting bugs have to do with the logical order in which outer joins
	are processed.

	Suppose you write a multi-join query with an outer join between two tables,
	followed by an inner join with a third table. If the predicate in the inner
	join's ON clause compares an attribute from the nonpreserved side  of the 
	outer join and an attribute from the third table, all outer rows are discarded.

	Remember that outer rows have NULLs in the attributes from the nonpreserved 
	side of the join, and comparing a NULL with anything yields UNKNOWN. UNKNOWN
	is filtered out by the ON filter. In other words, such a predicate nullifies
	the outer join, effectively turning it into an inner join.

	Consider the following query.
**/
SELECT C.custid, O.orderid, OD.productid, OD.qty
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
  INNER JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid;

/**
	Generally, outer rows are dropped whenever any kind of outer join(left, right, or
	full) is followed by a subsequent inner join or right outer join. That's assuming
	, of course, that the join condition compares the NULLS from the left side with
	something from the right side.

	There are several ways to get around the problem if you want to return customers
	with no orders in the output.

	One option is to use a left outer join in the second join as well.
**/
SELECT C.custid, O.orderid, OD.productid, OD.qty
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
  LEFT OUTER JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid;

/**
	The above solution is usually not a good one, because it preserves
	all  rows from Orders. What if there were rows in Orders that didn't
	have matches in OrderDetails, and you wanted those rows to be discarded.

	What you want is an inner join between Orders and OrderDetails

	A second option is to use an inner join between Orders and OrderDetails,
	and then join the result with the Customers table using a right outer join.

	This way, the outer rows are produced by the last join and are not filtered out
**/
SELECT C.custid, O.orderid, OD.productid, OD.qty
FROM Sales.Orders AS O
  INNER JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid
  RIGHT OUTER JOIN Sales.Customers AS C
    ON O.custid = C.custid;

/**
	A third option is to consider the inner join between Orders and
	OrderDetails as its own unit. Then, apply a left outer join between
	the Customers table and that unit.

	Below we are essentially nesting on join within another. A technique
	referred to as nested joins.
**/
SELECT C.custid, O.orderid, OD.productid, OD.qty
FROM Sales.Customers AS C
  LEFT OUTER JOIN
	  (Sales.Orders AS O
	     INNER JOIN Sales.OrderDetails AS OD
		   ON O.orderid = OD.orderid)
	ON C.custid = O.custid;

-------------------------------------------------------------------------------
-- Using the COUNT aggregate with outer joins
-------------------------------------------------------------------------------
-- Another common bug involves using COUNT with outer joins. When you group the
-- result of an outer join and use the COUNT(*) aggregate, the aggregate takes
-- into consideration both inner rows and outer rows, because it counts rows
-- regardless of their contents. Usually, you're not supposed to take outer 
-- rows into consideration for the purpose of counting.
-------------------------------------------------------------------------------
/**
	For example, the following query is supposed to return the count of orders
	for each customer.

	The problem is the below query returns customer such as 22 and 57, who did
	not place orders, each have an outer row in the result of the join; therefore
	,they show up in the output with a count of 1
**/
SELECT C.custid, COUNT(*) AS numorders
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
GROUP BY C.custid;

/**
	The COUNT(*) aggregate function cannot detect whether a row 
	really represents an order. To fix the problem, you should use
	COUNT(<column>) instead of COUNT(*) and provide a column from 
	the non preserved side of the join. This way, the COUNT() aggregate
	ignores outer rows because they have a NULL in that column.

	Remember to use a column that can only be NULL in case the row is
	an outer row - for example, the primary key column orderid:
**/
SELECT C.custid, COUNT(O.orderid) AS numorders
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON C.custid = O.custid
GROUP BY C.custid;