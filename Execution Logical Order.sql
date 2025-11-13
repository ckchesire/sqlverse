--------------------------------------------------------------------
-- Understanding Elements of SELECT Statement
--------------------------------------------------------------------
SET STATISTICS IO ON;

USE TSQLV6;

SELECT empid, YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1
ORDER BY empid, orderyear;


---------------------------------------------------------------------
-- The FROM Clause
---------------------------------------------------------------------

SELECT orderid, custid, empid, orderdate, freight
FROM Sales.Orders;

---------------------------------------------------------------------
-- The WHERE Clause
---------------------------------------------------------------------

SELECT orderid, custid, empid, orderdate, freight
FROM Sales.Orders
WHERE custid = 71

---------------------------------------------------------------------
-- The GROUP BY Clause
---------------------------------------------------------------------

SELECT empid, YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate);


SELECT
	empid,
	YEAR(orderdate) AS orderyear,
	SUM(freight) AS totalfreight,
	COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate);

-- Number of Distinct customers

SELECT
	empid,
	YEAR(orderdate) AS orderyear,
	COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY empid, YEAR(orderdate);


/**SELECT
	empid,
	--YEAR(orderdate) AS orderyear,
	GREATEST(DISTINCT custid) AS numcusts
FROM Sales.Orders
**/

SELECT TOP 10 * FROM Sales.Orders;


/** SELECT orderid, GREATEST(freight, tax, discount) AS max_value
FROM Sales.Orders;
**/

---------------------------------------------------------------------
-- The HAVING Clause
---------------------------------------------------------------------

SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) As numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1;

---------------------------------------------------------------------
-- The SELECT Clause
---------------------------------------------------------------------

SELECT orderid, orderdate
FROM Sales.Orders;


SELECT orderid, YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE YEAR(orderdate) > 2021;

SELECT empid, YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE custid = 71;

SELECT DISTINCT empid, YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE custid = 71;

SELECT * FROM Sales.Shippers;

SELECT orderid,
	YEAR(orderdate) AS orderyear,
	YEAR(orderdate) + 1 AS nextyear
FROM Sales.Orders;


SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1
ORDER BY empid, orderyear;

SELECT empid, hiredate, firstname, lastname, country
FROM HR.Employees
ORDER BY hiredate;

SELECT DISTINCT country
FROM HR.Employees
--ORDER BY empid;


/** The TOP and OFFSET-FETCH filter **/
-- TOP filter
SELECT TOP (5) orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY  orderdate DESC;

-- SET STATISTICS IO ON;

---------------------------------------------------------------------
-- The TOP and OFFSET-FETCH Filters
---------------------------------------------------------------------

---------------------------------------------------------------------
-- The TOP Filter
---------------------------------------------------------------------

SELECT TOP (1) PERCENT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY  orderdate DESC;

SELECT TOP (5) WITH TIES orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate DESC;

---------------------------------------------------------------------
-- The OFFSET-FETCH Filter
---------------------------------------------------------------------

-- OFFSET-FETCH
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate, orderid
OFFSET 50 ROWS FETCH NEXT 25 ROWS ONLY;


---------------------------------------------------------------------
-- A Quick Look at Window Functions
---------------------------------------------------------------------
SELECT orderid, custid, val,
	ROW_NUMBER() OVER(PARTITION BY custid
						ORDER BY val) AS rownum
FROM Sales.OrderValues
ORDER BY custid, val
