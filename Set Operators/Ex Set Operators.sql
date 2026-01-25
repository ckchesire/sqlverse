USE TSQLV6;
---------------------------------------------------------
-- Ex1: Explain the difference between UNION ALL and
-- UNION operators. In what cases are the two equivalent?
-- When they are equivalent, which one should you use?
---------------------------------------------------------
/**
	UNION - Combines different sets with implicit distinct
	implied. There are no duplicates, only one instance of 
	the row is maintained.

	UNION ALL - Combines different sets, maintaining duplicates.

	The UNION ALL operator unifies the two input query result sets
	and doesn't remove duplicates from the result. The UNION operator
	(implied DISTINCT)also unifies the two input query result sets,
	but it does remove duplicates from the result.

	The two have different meanings when the result can potentially
	have duplicates. They have an equivalent meaning when the result
	can't have duplicates, such as when you are unifying disjoint sets
	(for example, sales 2021 with sales 2022).

	When they do have the same meaning, you need to use UNION ALL by
	default. That's to avoid paying unnecessary performance penalties
	for the work involved in removing duplicates when they don't exist.
**/

---------------------------------------------------------
-- Ex2: Write a query that generates a virtual auxiliary
-- table of 10 numbers in the range 1 through 10 without
-- using a looping construct or the GENERATE_SERIES
-- function. You don't need to guarantee any presentation
-- order of the rows in the output of your solution.
---------------------------------------------------------
SELECT value AS n FROM GENERATE_SERIES(1, 10);

SELECT 1 AS n
UNION ALL SELECT 2
UNION ALL SELECT 3
UNION ALL SELECT 4
UNION ALL SELECT 5
UNION ALL SELECT 6
UNION ALL SELECT 7
UNION ALL SELECT 8
UNION ALL SELECT 9
UNION ALL SELECT 10;

/**
	Using a table value constructor to provide a solution to this
	exercise instead of using the UNION ALL operator
**/
SELECT n
FROM (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) AS Nums(n);

---------------------------------------------------------
-- Ex3: Write a query that returns customer and employee
-- pairs that had order activity in January 2022 but not
-- in February 2022.
---------------------------------------------------------
SELECT custid, empid FROM Sales.Orders
WHERE YEAR(orderdate) = 2022 AND MONTH(orderdate) = 01
EXCEPT
SELECT custid, empid FROM Sales.Orders
WHERE YEAR(orderdate) = 2022 AND MONTH(orderdate) = 02;

SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20220101' AND orderdate < '20220201'
EXCEPT
SELECT custid, empid
FROM Sales.Orders 
WHERE orderdate >= '20220201' AND orderdate < '20220301';

---------------------------------------------------------
-- Ex4: Write a query that returns customer and employee
-- pairs that had order activity in both January 2022
-- and February 2022.
---------------------------------------------------------
SELECT custid, empid 
FROM Sales.Orders
WHERE orderdate >= '20220101' AND orderdate < '20220201'
INTERSECT
SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20220201' AND orderdate < '20220301';

SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20220101' AND orderdate < '20220201'
INTERSECT
SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20220201' AND orderdate < '20220301';

---------------------------------------------------------
-- Ex5: Write a query that returns customer and employee
-- pairs that had order activity in both January 2022 and
-- February 2022 but not in 2021.
---------------------------------------------------------
SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20220101' and orderdate < '20220201'

INTERSECT

SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20220201' and orderdate < '20220301'

EXCEPT

SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20210101' and orderdate < '20220101';

/**
	Keep in mind that the INTERSECT operator precedes EXCEPT. In this case,
	the default precedence is also the precedence you want, so you don't 
	need to intervene by using parenteses. But you might prefer to add them
	for clarity, as shown below.
**/
(SELECT custid, empid
 FROM Sales.Orders
 WHERE orderdate >= '20220101' AND orderdate < '20220201'

 INTERSECT

 SELECT custid, empid
 FROM Sales.Orders
 WHERE orderdate >= '20220201' AND orderdate < '20220301')

EXCEPT

SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20210101' AND orderdate < '20220101';

------------------------------------------------------------
-- Ex6: You are given the following query. You are asked
-- to add logic to the query so that it guarantees that
-- the rows from Employees are returned in the output
-- before the rows from Suppliers. Also, within each segment
-- , the rows should be sorted by country, region, and city.
------------------------------------------------------------
-- Using Common Table Expression (CTE)
WITH AddLogic
AS
(
	SELECT country, region, city, 1 AS SortOrder
	FROM HR.Employees

	UNION ALL

	SELECT country, region, city, 2 AS SortOrder
	FROM Production.Suppliers
)
SELECT country, region, city FROM AddLogic
ORDER BY SortOrder, country, region, city ASC;

-- Using a derived table expression
SELECT country, region, city
FROM (SELECT 1 AS sortcol, country, region, city
	  FROM HR.Employees

	  UNION ALL
	  
	  SELECT 2, country, region, city
	  FROM Production.Suppliers) AS D
ORDER BY sortcol, country, region, city;