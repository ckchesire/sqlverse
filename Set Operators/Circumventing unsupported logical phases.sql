USE TSQLV6;
---------------------------------------------------------
-- Circumventing unsupported logical phases 
---------------------------------------------------------
-- The individual queries that are used as inputs to
-- a set operator support all logical-query processing
-- phases (such as table operators, WHERE, GROUP BY, and
-- HAVING) except for ORDER BY. However, only the ORDER BY
-- phase is allowed on the result of the operator.
-- 
-- What if you need to apply other logical phases besides
-- ORDER BY to the result of the operator? This is not
-- supported directly by using table expressions. Define
-- a named table expression based on a query with a set 
-- operator, and apply any logical-query processing phases
-- you want in the outer query
----------------------------------------------------------
/**
	For example the following query returns the number of
	distinct locations that are either employee or customer
	locations in each country
**/
SELECT country, COUNT(*) AS numlocations
FROM (SELECT country, region, city FROM HR.Employees
	  UNION
	  SELECT country, region, city FROM Sales.Customers) AS U
GROUP BY country;

/**
	The above query demonstrates how to group the result of a UNION
	operator; similarly, you can, of course, apply other logical-query
	phases in the outer query.
**/

/**
	Remember that the ORDER BY clause is not allowed in the input queries.
	What if you need to restrict the number of rows in those queries with 
	the TOP or OFFSET-FETCH filter? Again, you can resolve this problem 
	with table expressions.

	Recall that an ORDER BY clause is allowed in an inner query with TOP
	or OFFSET-FETCH. In such a case, the ORDER BY clause serves only the
	filtering-related purpose and has no presenation meaning.

	For example the following code uses TOP queries to return the two most
	recent orders for employees 3 and 5.
**/
SELECT empid, orderid, orderdate
FROM (SELECT TOP (2) empid, orderid, orderdate
	  FROM Sales.Orders
	  WHERE empid = 3
	  ORDER BY orderdate DESC, orderid DESC) AS D1
	  
UNION ALL

SELECT empid, orderid, orderdate
FROM (SELECT TOP (2) empid, orderid, orderdate
	  FROM Sales.Orders
	  WHERE empid = 5
	  ORDER BY orderdate DESC, orderid DESC) AS D2;