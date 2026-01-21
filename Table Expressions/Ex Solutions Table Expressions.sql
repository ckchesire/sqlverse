USE TSQLV6;

---------------------------------------------------------------
-- Ex1: The following query attempts to filter orders that were
-- not placed on the last day of the year. It's supposed to 
-- return the order ID, order date, customer ID, employee ID,
-- and respective end-of-year date for each order.
---------------------------------------------------------------
SELECT orderid, orderdate, custid, empid,
  DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
FROM Sales.Orders
WHERE orderdate <> endofyear;

/**
	Because of the logical order of query processing we have the 
	WHERE clause being evaluated before the SELECT clause, hence
	the endofyear being invalid. This means you are not allowed to
	refer to an alias you create in the SELECT clause within the
	WHERE clause.

	One way of solving this is to have the original computation
	being performed at the WHERE stage instead of using the alias.
**/

SELECT orderid, orderdate, custid, empid,
  DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
FROM Sales.Orders
WHERE orderdate <> DATEFROMPARTS(YEAR(orderdate), 12, 31);

-- Using subquery
SELECT orderid, orderdate, custid, empid,
  DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
FROM Sales.Orders
WHERE orderdate NOT IN 
(SELECT DATEFROMPARTS(YEAR(orderdate), 12, 31) FROM Sales.Orders);

/**
	Another solution that doesn't require you to repeat lengthy
	expressions is to define a table expression such as a CTE
	based on a query that defines the alias, and then refer to
	the alias multiple times in the outer query.
**/
WITH C AS
(
  SELECT *,
    DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
  FROM Sales.Orders
)
SELECT orderid, orderdate, custid, empid, endofyear
FROM C
where orderdate <> endofyear;