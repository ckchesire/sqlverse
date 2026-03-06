USE TSQLV6;
------------------------------------------------------------
-- Grouping Sets
------------------------------------------------------------
-- A grouping set is a set of expressions you group the data
-- by in a grouped query(a query with a GROUP BY clause).
------------------------------------------------------------
/**
	Each of the following four queries defines a different
	single grouping set.
**/
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid;

SELECT empid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid;

SELECT custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY custid;

-- Empty Grouping Set
SELECT SUM(qty) AS sumqty
FROM dbo.Orders;


/**
	Suppose for reporting purposes, that instead of wanting four
	separate result sets returned, you want a single unified result
	set. You can achieve this using the UNION ALL operator between
	queries.
**/
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid

UNION ALL

SELECT empid, NULL, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid

UNION ALL

SELECT NULL, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY custid

UNION ALL

SELECT NULL, NULL, SUM(qty) AS sumqty
FROM dbo.Orders;

/**
	Even though you managed to get what you were after, this solution
	has two main problems - the length of the code and performance. It's
	long because you have a separate scanning of the data for each query.
**/

/**
	T-SQL supports standard features you can use to define multiple
	grouping sets in the same query. Those are the GROUPING SETS, 
	CUBE, and ROLLUP subclasses of the GROUP BY clause, and the 
	GROUPING and GROUPING_ID functions. The main use cases are 
	reporting and data analysis.
**/

------------------------------------------------------------
-- The GROUPING SETS subclause
------------------------------------------------------------
-- The GROUPING SETS subclause is a powerful enhancement to
-- the GROUP BY clause. You can use it to define multiple
-- grouping sets in the same query.
------------------------------------------------------------
/**
	For example the following query defines four grouping
	sets: (empid, custid), (empid), (custid), and ()
**/
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY
  GROUPING SETS
  (
	(empid, custid),
	(empid),
	(custid),
	()
  );
/**
	The last grouping set is the empty grouping set representing
	the grand total. This query is a logical equivalent of the 
	previous solution that unified the result sets of four aggregate
	queries.

	Only this one is much shorter, plus it gets optimized better.
	SQL Server typically needs fewer scans of the data than the
	number of grouping sets because it can roll up aggregates
	internally.
**/

------------------------------------------------------------
-- The CUBE subclause
------------------------------------------------------------
-- The CUBE subclause of the GROUP BY clause provides an
-- abbreviated way to define multiple grouping sets.
------------------------------------------------------------
/**
	For example, CUBE(a, b, c) is equivalent to GROUPING SETS
	((a,b,c), (a,b), (a,c), (b,c), (a), (b), (c),()).
	In set theory, the set of all subsets of elements that can
	be produced from a particular set is called the power set.

	Instead of using the GROUPING SETS subclause in the previous
	query to define the four grouping sets(empid, custid), (empid),
	(custid), and (), you can simply use CUBE(empid, custid).
**/
USE TSQLV6;
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY CUBE(empid, custid);


------------------------------------------------------------
-- The ROLLUP subclause
------------------------------------------------------------
-- The ROLLUP subclause of the GROUP BY clause also provides
-- a way to define multiple grouping sets. ROLLUP assumes a
-- hierarchy among the input members and produces only 
-- grouping sets that form leading combinations of the input
-- members.
------------------------------------------------------------

/**
	For example, suppose you want to return total quantities
	for all grouping sets that can be defined based on the time
	hierarchy of order year, order month, order day. You can use
	the GROUPING SETS subclause and explicitly list all four
	possible grouping sets.
**/

GROUPING SETS(
	(YEAR(orderdate), MONTH(orderdate), DAY(orderdate)),
	(YEAR(orderdate), MONTH(orderdate)),
	(YEAR(orderdate)),
	()	)

-- The logical equivalent that use ROLLUP subclause is much more concise
 ROLLUP(YEAR(orderdate), MONTH(orderdate), DAY(orderdate))

 -- The complete query
 SELECT
	YEAR(orderdate) AS orderyear,
	MONTH(orderdate) AS ordermonth,
	DAY(orderdate) AS orderdate,
	SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY ROLLUP(YEAR(orderdate), MONTH(orderdate), DAY(orderdate));
