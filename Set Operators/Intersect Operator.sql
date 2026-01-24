USE TSQLV6;
---------------------------------------------------------------
-- The INTERSECT Operator
---------------------------------------------------------------
-- The INTERSECT operator returns only the rows that are common
-- to the results of the two input queries
---------------------------------------------------------------


------------------------------------------------------------------
-- The INTERSECT (DISTINCT) Operator
------------------------------------------------------------------
-- The INTERSECT operator (implied DISTINCT) returns only distinct
-- rows that appear in both input query results. As long as a row,
-- appears at least once in both query results, it's returned
-- only once in the operator's result.
------------------------------------------------------------------
/**
	For example, the following code returns distinct locations that
	are both employee locations and customer locations
**/
SELECT country, region, city FROM  HR.Employees
INTERSECT
SELECT country, region , city FROM Sales.Customers;

--------------------------------------------------------------------
-- The INTERSECT ALL operator
--------------------------------------------------------------------
-- The SQL standard supports an ALL flavor of the INTERSECT operator
-- , but this flavor has not been implemented in T-SQL. However you
-- can write your own logical equivalent with T-SQL.
-- 
-- Remember the meaning of the ALL keyword in the UNION ALL operator
-- It returns all duplicate rows. Similarly, the keyword ALL in the
-- INTERSECT ALL operator means that duplicate intersections will
-- not be removed.
--
-- INTERSECT ALL returns the number of duplicate rows matching the
-- lower of the counts in both input multisets. It's as if this
-- operator looks for matches for each occurence of each row. If
-- there are x occurences of a row R in the first input multiset
-- and y occurences of R in the second, R appears minimum(x,y) times
-- in the result.
--------------------------------------------------------------------
/**
	For example, in the Employees table the four occurences of the
	location (UK, NULL, London) are numbered 1 through 4. In the
	customers table the six occurences of the same row are numbered
	1 through 6. Occurences 1 through 4 intersect between the two.
**/
SELECT
	ROW_NUMBER()
	  OVER(PARTITION BY country, region, city
		   ORDER	 BY (SELECT 0)) AS rownum,
	country, region, city
FROM HR.Employees

INTERSECT

SELECT
	ROW_NUMBER()
	  OVER(PARTITION BY country, region, city
		   ORDER	 BY (SELECT 0)),
	country, region, city
FROM Sales.Customers;

/**
	The standard INTERSECT ALL operator is not supposed to return any
	row numbers. To exclude those from the output, define a named
	table expression based on this query, and in  the outer query select
	only the attributes you want to return.
**/
WITH INTERSECT_ALL
AS
(
	SELECT
	  ROW_NUMBER()
	    OVER(PARTITION BY country, region, city
			 ORDER	   BY (SELECT 0)) AS rownum,
	  country, region, city
	FROM HR.Employees

	INTERSECT

	SELECT
	  ROW_NUMBER()
	    OVER(PARTITION BY country, region, city
		     ORDER	   BY (SELECT 0)),
	  country, region, city
	FROM Sales.Customers
)
SELECT country, region, city
FROM INTERSECT_ALL;