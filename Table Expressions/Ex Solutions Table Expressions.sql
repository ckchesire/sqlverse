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

----------------------------------------------------------------
-- Ex5-2: Write a query against Sales.VEmpOrders that returns
-- the running total quantity for each employee and year.
----------------------------------------------------------------
SELECT empid, orderyear, qty,
	(SELECT SUM(A2.qty)
	 FROM Sales.VEmpOrders AS A2
	 WHERE A2.orderyear <= A1.orderyear
	 AND A1.empid = A2.empid
	 ) AS runqty
FROM Sales.VEmpOrders AS A1
ORDER BY empid, orderyear;

---------------------------------------------------------------------
-- Ex6-1: Create an inline TVF that accepts as inputs a supplier ID
-- (@supid AS INT) and a requested number of products (@n AS INT).
-- The function should return @n products with the highest unit prices
-- that are supplied by the specified supplier ID.
---------------------------------------------------------------------
USE TSQLV6;
GO

DROP FUNCTION IF EXISTS Production.TopProducts
GO

CREATE OR ALTER FUNCTION Production.TopProducts
	(@supid AS INT, @n AS INT) 
	RETURNS TABLE
AS
RETURN
	SELECT TOP (@n) productid, productname, unitprice
	FROM Production.Products
	WHERE supplierid = @supid
	ORDER BY unitprice DESC;
GO

SELECT * FROM Production.TopProducts(2, 3);

/**
	Alternatively you can use the OFFSET-FETCH filter. You replace the
	inner query in the function with the following one.
**/
USE TSQLV6;
GO

DROP FUNCTION IF EXISTS Production.TopProducts
GO

CREATE OR ALTER FUNCTION Production.TopProducts
	(@supid AS INT, @n AS INT) 
	RETURNS TABLE
AS
RETURN
	SELECT productid, productname, unitprice
	FROM Production.Products
	WHERE supplierid = @supid
	ORDER BY unitprice DESC
	OFFSET 0 ROWS FETCH NEXT @n ROWS ONLY;
GO

SELECT * FROM Production.TopProducts(2, 3);

---------------------------------------------------------------------
-- Ex6-2: Using the CROSS APPLY operator and the function you created
-- in Ex6-1, return the two most expensive products for each supplier
---------------------------------------------------------------------

-- SELECT * FROM Production.Suppliers 
SELECT S.supplierid, S.companyname, 
T.productid, T.productname, T.unitprice
FROM Production.Suppliers AS S
  CROSS APPLY Production.TopProducts(S.supplierid, 2) AS T;

/**
	Here we write a query against the Production.Suppliers table and
	use the CROSS APPLY operator to apply the function we defined 
	in the previous step to each supplier. The query is supposed to
	return the two most expensive products for each supplier. The
	following is the solution query.
**/
SELECT S.supplierid, S.companyname, P.productid, P.productname, P.unitprice
FROM Production.Suppliers AS S
  CROSS APPLY Production.TopProducts(S.supplierid, 2) AS P;