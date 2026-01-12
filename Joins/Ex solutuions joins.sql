USE TSQLV6;
-------------------------------------------------------------
-- Ex1-1: Query that generates five copied of each employee row
-------------------------------------------------------------
SELECT E.empid, E.firstname, E.lastname, N.n
FROM HR.Employees AS E
	CROSS JOIN dbo.Nums AS N
WHERE N.n <= 5
ORDER BY N.n, E.empid;

-------------------------------------------------------------
-- Ex1-2: Query that returns a row for each employee and day
-- in the range June 12,2022 through June 16,2022.
-------------------------------------------------------------
SELECT empid, CAST (DATEADD(day, value, '20220612' ) AS DATE)AS dt
FROM HR.Employees,
GENERATE_SERIES(0, DATEDIFF(day, '20220612' ,'20220616'))
ORDER BY empid, dt;

/**
	Alternative Solution
**/
SELECT E.empid, 
	DATEADD(day, D.n - 1, CAST('20220612' AS DATE)) AS dt
FROM HR.Employees AS E
	CROSS JOIN dbo.Nums AS D
WHERE D.n <= DATEDIFF(day, '20220612', '20220616') + 1
ORDER BY empid, dt;
-------------------------------------------------------------
-- Ex2: Explain what's wrong with the following query, and 
-- provide a correct alternative.
-- SELECT Customers.custid, Customers.companyname, Orders.orderid, Orders.orderdate
-- FROM Sales.Customers AS C
-- INNER JOIN Sales.Orders AS O
-- ON Customers.custid = Orders.custid;
-------------------------------------------------------------
/**
	The problem is with not utilizing the defined alias.
	Two approaches to solving this is either:
	1.) Using the the full column names of the tables as is.
	2.) Using the aliases to represent columns in the tables.	
**/

-- Approach One using full table name:
SELECT Customers.custid, Customers.companyname, Orders.orderid, Orders.orderdate
FROM Sales.Customers 
  INNER JOIN Sales.Orders
    ON Customers.custid = Orders.custid;

-- Approach two, using aliases:
SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  INNER JOIN Sales.Orders AS O
    ON C.custid = O.custid;

-------------------------------------------------------------
-- Ex3: Return US customers, and for each customer return the
-- total number of orders and total quantities.
-------------------------------------------------------------
SELECT C.custid, COUNT(DISTINCT(O.orderid)) AS numorders, SUM(OD.qty) AS totalqty
FROM Sales.Customers AS C
INNER JOIN
	(Sales.Orders AS O
	 INNER JOIN Sales.OrderDetails AS OD
		ON O.orderid = OD.orderid)
	ON C.custid = O.custid
WHERE C.country = 'USA'
GROUP BY C.custid;

SELECT C.custid, COUNT(DISTINCT O.orderid) AS numorders, SUM(OD.qty) AS totalqty
FROM Sales.Customers AS C
  INNER JOIN  Sales.Orders AS O
    ON O.custid = C.custid
  INNER JOIN Sales.OrderDetails AS OD
    ON OD.orderid = O.orderid
WHERE C.country = N'USA'
GROUP BY C.custid;

--------------------------------------------------------------
-- Ex4: Return customers and their orders, including customers
-- who placed no orders.
--------------------------------------------------------------
SELECT C.custid, C.companyname, O.orderid , orderdate
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O
  ON C.custid = O.custid;

--------------------------------------------------------------
-- Ex5: Return customers who placed no orders
--------------------------------------------------------------
SELECT C.custid, C.companyname, orderid
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O
  ON C.custid = O.custid
WHERE O.orderid IS NULL;

---------------------------------------------------------------
-- Ex6: Return customers with orders placed on February 12,2022
-- along with their orders.
---------------------------------------------------------------
SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O
  ON C.custid = O.custid
WHERE O.orderdate = '20220212';

/**
	Query to perform an inner join between Customers and Orders
	and filters only rows in which the order date is February 12, 2022
**/

SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  INNER JOIN Sales.Orders AS O
    ON O.custid = C.custid
WHERE O.orderdate = '20220212';

----------------------------------------------------------------
-- Ex7: Query that returns all customers, but matches them with 
-- their respective orders only if they were placed on 
-- February 12,2022
----------------------------------------------------------------
SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O
  ON C.custid = O.custid AND O.orderdate = '20220212';

----------------------------------------------------------------
-- Ex8: Explain why the following query isn't a correct solution
-- for Exercise 7
----------------------------------------------------------------
/**
	The query returns different results, it doesn't return all customers.
	The WHERE filter keeps only rows where the order date is February 12,2022
	or the order ID is NULL(a customer without orders at all).
	It filters customers who didn't place orders on February 12, 2022 but
	did place orders on other dates.
**/
SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid
WHERE O.orderdate = '20220212'
   OR O.orderid IS NULL;

-----------------------------------------------------------------
-- Ex9: Return all customers, and for each Yes/No value depending
-- on whether the customer placed orders on February 12,2022:
-----------------------------------------------------------------
SELECT DISTINCT C.custid, C.companyname, 
	CASE WHEN O.orderdate IS NULL THEN 'No'
	     ELSE 'Yes'
	END AS HasOrderOn20220212
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid AND O.orderdate = '20220212'
ORDER BY C.custid ASC;
