USE TSQLV6;
----------------------------------------------------------
-- The UNION Operator
---------------------------------------------------------------
-- The UNION operator unifies the results of two input queries.
-- If a row appears in any of the input sets, it will appear in
-- the result of the UNION operator. T-SQL supports both the
-- UNION ALL and UNION(implicit DISTINCT) flavors of the UNION
-- operator.
---------------------------------------------------------------

---------------------------------------------------------------
-- The UNION ALL operator
---------------------------------------------------------------
-- The UNION ALL operator unifies the two input query results
-- without attempting to remove duplicates from the result.
-- Assuming that Query1 returns m rows and Query2 returns n 
-- rows, Query1 UNION ALL Query2 returns m + n rows.
---------------------------------------------------------------
/**
	For example the following code uses the UNION ALL operator
	to unify employee locations and customer locations.
**/
SELECT country, region, city FROM HR.Employees
UNION ALL
SELECT country, region, city FROM Sales.Customers;
/**
	Because UNION ALL doesn't eliminate duplicates, the result is
	a multiset and not a set. The same row can appear multiple 
	times in the result of a query.
**/

----------------------------------------------------------------
-- The UNION (DISTINCT) operator
----------------------------------------------------------------
-- The UNION(implicit DISTINCT) operator unifies the results of
-- the two queries and eliminates duplicates.
-- Note: That if a row appears in both input sets, it will
-- appear only once in the result; in other words, the result is
-- a set and not a multiset.
----------------------------------------------------------------
/**
	For example, the following code returns distinct locations 
	that are either employee locations or customer locations.
**/
SELECT country, region, city FROM HR.Employees
UNION
SELECT country, region, city FROM Sales.Customers;

/**
	So when should you use UNION ALL and when should you use UNION?
	if duplicates are possible in the unified result and you do not
	need to return them, use UNION. Otherwise, use UNION ALL.
**/