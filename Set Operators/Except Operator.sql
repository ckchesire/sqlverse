USE TSQLV6;
--------------------------------------------------------------------
-- The EXCEPT operator
--------------------------------------------------------------------
-- The EXCEPT operator implements a minus, or a set difference, 
-- operation. It operates on the results of two input queries and
-- returns rows that appear in the first input but not the second.
--------------------------------------------------------------------


--------------------------------------------------------------------
-- The EXCEPT(DISTINCT) operator
--------------------------------------------------------------------
-- The EXCEPT operator (implied DISTINCT) returns only distinct rows
-- that appear in the first set but not the second. In other words
-- , a row is returned once in the output as long as it appears at
-- least once in the first input multiset and zero times in the
-- second.
-- Note: That unlike UNION and INTERSECT, EXCEPT is noncommutative;
-- that is, the order in which you specify the two input queries
-- matters.
--------------------------------------------------------------------
/**
	For example, the following code returns distinct locations that
	are employee locations but not customer locations.
**/
SELECT country, region, city FROM HR.Employees
EXCEPT
SELECT country, region, city FROM  Sales.Customers;

/**
	The following query returns distinct locations that are customer
	locations but not employee locations.
**/
SELECT country, region, city FROM Sales.Customers
EXCEPT
SELECT country, region, city FROM HR.Employees;

-----------------------------------------------------------------------
-- The EXCEPT ALL operator
-----------------------------------------------------------------------
-- The EXCEPT ALL operator is similar to the EXCEPT operator, but it
-- also takes into account the number of occurences of each row. If
-- a row R appears x times in the first multiset and y times in the
-- second, and x > y, R will appear x - y times in Query1 EXCEPT Query2
-- . In other words, EXCEPT ALL returns only occurences of a row from
-- the first multiset that do not have a corresponding occurence in
-- the second.
-----------------------------------------------------------------------
/**
	T-SQL does not provide a built-in EXCEPT ALL operator, but you can
	provide an alternative of your own similar to how you handled
	INTERSECT ALL. Namely, add a ROW_NUMBER calculation to each of
	the input queries to number the occurences of the rows, and use
	the EXCEPT operator between the two input queries. Only occurences
	that don't have matches will be returned.

	The following code returns occurences of employee locations that
	have no corresponding occurences of customer locations.
**/
WITH EXCEPT_ALL
AS
(
	SELECT
	  ROW_NUMBER()
	    OVER(PARTITION BY country, region, city
			 ORDER	   BY (SELECT 0)) AS rownum,
	  country, region, city
	FROM HR.Employees

	EXCEPT

	SELECT
	  ROW_NUMBER()
	    OVER(PARTITION BY country, region, city
			 ORDER	   BY (SELECT 0)),
	  country, region, city
	FROM Sales.Customers
)
SELECT country, region, city
FROM EXCEPT_ALL;