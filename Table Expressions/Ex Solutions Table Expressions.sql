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

--  Another solution using derived table
SELECT orderid, orderdate, custid, empid, endofyear
FROM (SELECT *,
	  DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
	  FROM Sales.Orders) AS D;

---------------------------------------------------------------
-- Ex2-1: Write a query that returns the maximum value in the
-- orderdate column for each employee
---------------------------------------------------------------

SELECT empid, MAX(orderdate) AS maxorderdate
FROM Sales.Orders
GROUP BY empid;

----------------------------------------------------------------
-- Ex2-2: Encapsulate the query from Exercise 2-1 in a derived
-- table. Write a join query between the derived table and the
-- Orders table to return the orders with the maximum order date
-- for each employee.
----------------------------------------------------------------
SELECT 
	O.empid, O.orderdate, O.orderid, O.custid 
FROM Sales.Orders AS O
  INNER JOIN
	(SELECT empid, MAX(orderdate) AS maxorderdate
	FROM Sales.Orders 
	GROUP BY empid) AS D
  ON O.empid = D.empid
  AND O.orderdate = D.maxorderdate;

----------------------------------------------------------------
-- Ex3-1: Write a query that calculates a row number for each
-- order based on orderdate, orderid ordering.
----------------------------------------------------------------
SELECT
	orderid, orderdate, custid, empid,
	ROW_NUMBER() OVER(ORDER BY orderdate, orderid) AS rownum
FROM Sales.Orders;

----------------------------------------------------------------
-- Ex3-2: Write a query that returns rows with row numbers 11 
-- through 20 based on the row-number definition in Ex3-1. Use
-- CTE to encapsulate the code from Ex3-1.
----------------------------------------------------------------
WITH C AS
(
	SELECT orderid, orderdate, custid, empid,
	 ROW_NUMBER() OVER(ORDER BY orderdate, orderid) AS rownum
	FROM Sales.Orders
)
SELECT * FROM C WHERE rownum >= 11 AND rownum <= 20;

WITH OrdersRN AS
(
	SELECT orderid, orderdate, custid, empid, 
	 ROW_NUMBER() OVER(ORDER BY orderdate, orderid) AS rownum
	FROM Sales.Orders
)
SELECT * FROM OrdersRN WHERE rownum BETWEEN 11 AND 20;

/**
	You might wonder why you need a table expression here. Window functions
	(such as the ROW_NUMBER function)are allowed only in SELECT and ORDER BY
	clauses of a query, and not directly in the WHERE clause.

	By using a table expression, you can invoke the ROW_NUMBER function in the
	SELECT clause, assign an alias to the result column, and refer to that 
	alias in the WHERE clause of the outer query.
**/

----------------------------------------------------------------
-- Ex4: Write a solution using recursive CTE that returns the
-- management chain leading to Patricia Doyle (employee id 9)
----------------------------------------------------------------
-- The general form of a basic recursive CTE looks like the following.
--		WITH <CTE_NAME>[(<target_column_list>)]
--		AS
--		(
--			<anchor_member>
--			UNION ALL
--			<recursive_member>
--		)
--		<outer_query_against_CTE>;
--
WITH Mgt_Chain AS
(
	SELECT empid, mgrid, firstname, lastname
	FROM HR.Employees
	WHERE empid = 9

	UNION ALL
	
	SELECT C.empid, C.mgrid, C.firstname, C.lastname
	FROM Mgt_Chain AS P
	 INNER JOIN HR.Employees AS C
	 ON P.mgrid =  C.empid
)
SELECT empid, mgrid, firstname, lastname
FROM Mgt_Chain;

-- Complete solution query.
WITH EmpsCTE AS
(
	SELECT empid, mgrid, firstname, lastname
	FROM HR.Employees
	WHERE empid = 9

	UNION ALl

	SELECT P.empid, P.mgrid, P.firstname, P.lastname
	FROM EmpsCTE AS C
	  INNER JOIN HR.Employees AS P
	  ON C.mgrid = P.empid
)
SELECT empid, mgrid, firstname, lastname
FROM EmpsCTE;

----------------------------------------------------------------
-- Ex5-1: Create a view that returns the total quantity for each
-- employee and year
----------------------------------------------------------------
USE TSQLV6;
GO
DROP VIEW IF EXISTS Sales.VEmpOrders;
GO

CREATE OR ALTER VIEW Sales.VEmpOrders
AS

SELECT 
	empid,
	YEAR(orderdate) AS orderyear,
	SUM(qty) AS qty
FROM Sales.Orders AS O
	INNER JOIN Sales.OrderDetails AS OD
	  ON O.orderid = OD.orderid
GROUP BY
	empid,
	YEAR(orderdate);
GO

SELECT * FROM Sales.VEmpOrders ORDER BY empid, orderyear;