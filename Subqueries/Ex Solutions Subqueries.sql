USE TSQLV6;
-------------------------------------------------------------
-- Ex1. Write a query that returns all orders placed on the
-- last day of activity that can be found in the Orders table
-------------------------------------------------------------
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = (SELECT MAX(O.orderdate)
				    FROM Sales.Orders AS O);

-------------------------------------------------------------
-- Ex2. Write a query that returns all orders placed by the
-- customer(s) who place the highest number of orders.
-------------------------------------------------------------
SELECT custid, orderid, orderdate, empid
FROM Sales.Orders AS O1
WHERE custid = (SELECT TOP (1) custid
			    FROM Sales.Orders
			    GROUP BY custid
			    ORDER BY COUNT(orderid) DESC);
/**
	The query below uses WITH TIES option to return all IDS
	of customers who placed the maximum number of orders,
	in case there is more than one.
**/
SELECT TOP (1) WITH TIES O.custid
FROM Sales.Orders AS O
GROUP BY O.custid
ORDER BY COUNT(*) DESC;
/**
	The next step is to write the query against the Orders table,
	returning all orders where the customer ID appears in the 
	result of the subquery.
**/
SELECT custid, orderid, orderdate, empid
FROM Sales.Orders
WHERE custid IN
  (SELECT TOP (1) WITH TIES  O.custid
   FROM Sales.Orders AS O
   GROUP BY O.custid
   ORDER BY COUNT(*) DESC);

-------------------------------------------------------------
-- Ex3. Write a query that returns employees who did not 
-- place orders on or after May 1,2022
-------------------------------------------------------------
SELECT empid, firstname, lastname
FROM HR.Employees AS E
WHERE NOT EXISTS (SELECT*
				  FROM Sales.Orders AS O
				  WHERE O.orderdate >= '20220501'
				  AND E.empid = O.empid );

/**
	Alternative Solution
**/
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE empid NOT IN
  (SELECT O.empid
   FROM Sales.Orders AS O
   WHERE O.orderdate >= '20220501');

-------------------------------------------------------------
-- Ex4. Write a query that returns countries where there are
-- customers but not employees
-------------------------------------------------------------
SELECT DISTINCT(C.country)
FROM Sales.Customers AS C
WHERE C.country NOT IN
	(SELECT E.country
	 FROM HR.Employees AS E)
ORDER BY C.country;

SELECT DISTINCT country
FROM Sales.Customers
WHERE country NOT IN
  (SELECT E.country FROM HR.Employees AS E);

-------------------------------------------------------------
-- Ex5. Write a query that returns for each customer all 
-- orders placed on the customer's last day of activity
-------------------------------------------------------------
SELECT custid, orderid, orderdate, empid
FROM Sales.Orders AS O1
WHERE O1.orderdate =
	(SELECT MAX(O2.orderdate)
	 FROM Sales.Orders O2
	 WHERE O1.custid = O2.custid)
ORDER BY custid ASC;

--------------------------------------------------------------
-- Ex6. Write a query that returns customers who placed orders
-- in 2021 but not in 2022.
--------------------------------------------------------------
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE EXISTS
	(SELECT * 
	 FROM SALES.Orders AS O
	 WHERE O.custid = C.custid
	   AND O.orderdate >= '20210101'
	   AND O.orderdate <  '20220101')
	AND NOT EXISTS
	(SELECT *
	 FROM Sales.Orders AS O
	 WHERE O.custid = C.custid
	   AND O.orderdate >= '20220101'
	   AND O.orderdate <  '20230101');


----------------------------------------------------------------
-- Ex7. Write a query that returns customers who ordered product
-- 12.
----------------------------------------------------------------

SELECT C.custid, C.companyname
FROM Sales.Customers AS C
WHERE C.custid IN
	(SELECT custid
	 FROM Sales.Orders AS O
	 WHERE C.custid = O.custid
	 AND O.orderid IN
	   (SELECT OD.orderid 
	    FROM  Sales.OrderDetails AS OD
	    WHERE O.orderid = OD.orderid
	    AND OD.productid = 12)
	);

/* Alternative Solution */
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE EXISTS
  (SELECT * 
   FROM Sales.Orders AS O
   WHERE O.custid = C.custid
   AND EXISTS
     (SELECT *
	  FROM Sales.OrderDetails AS OD
	  WHERE  OD.orderid = O.orderid
	    AND  OD.productid = 12));

----------------------------------------------------------------
-- Ex8. Write a query that calculates a running-total quantity
-- for each customer and month
----------------------------------------------------------------
SELECT TOP (2) * FROM Sales.CustOrders;

SELECT O1.custid, O1.ordermonth , O1.qty,
 (SELECT SUM(O2.qty)
  FROM Sales.CustOrders AS O2
  WHERE O1.custid = O2.custid AND 
  O2.ordermonth <= O1.ordermonth) AS runqty
FROM Sales.CustOrders AS O1
ORDER BY custid , ordermonth ASC;

/** Right alternative Solution **/
SELECT custid, ordermonth, qty,
  (SELECT SUM(O2.qty)
   FROM Sales.CustOrders AS O2
   WHERE O2.custid = O1.custid
     AND O2.ordermonth <= O1.ordermonth) AS runqty
FROM Sales.CustOrders AS O1
ORDER BY custid, ordermonth;

----------------------------------------------------------------
-- Ex9. Explain the difference beween IN and EXISTS
----------------------------------------------------------------
/**
	Whereas the IN predicate uses three-valued logic, the EXISTS predicate
	uses two-valued logic. When no NULLs are involved in the data, IN and
	EXISTS give you the same meaning in both their positive and negative
	forms (with NOT). 

	When NULLs are involved, IN and EXISTS give you the same meaning in their
	positive form but not their negative form. In the positive form, when looking
	for a value that appears in the set of known values in the subquery, both 
	return TRUE, and when looking for a value that doesn't appear in the set of
	known values, both return FALSE.

	In the negative forms(with NOT), when looking for a value that appears in the
	set of known values, both return FALSE; however, when looking for a value that
	doesn't appear in the set of known values, NOT IN returns UNKNOWN(outer row is
	discarded), whereas NOT EXISTS returns TRUE(outer row returned).
**/

------------------------------------------------------------------
-- Ex10. Write a query that returns for each order the number of
-- days that passed since the same customer's previous order.
-- To determine recency among orders, use orderdate as the primary
-- sort element and orderid as the tiebreaker.
------------------------------------------------------------------
SELECT TOP(2) * FROM Sales.Orders;

/**
	You can handle the task in two steps:
	 1. Write a query that computes the date of the customer's previous order
	 2. Compute the difference between the date returned by the first step
	    and the current order date.
**/

SELECT custid, orderdate, orderid,
  (SELECT TOP (1) O2.orderdate
   FROM Sales.Orders AS O2
   WHERE O2.custid = O1.custid
	  AND ( O2.orderdate = O1.orderdate AND O2.orderid < O1.orderid
			OR O2.orderdate < O1.orderdate)
   ORDER BY O2.orderdate DESC, O2.orderid DESC) AS prevdate
FROM Sales.Orders AS O1
ORDER BY custid, orderdate, orderid;

/**
	To get a previous order date, the solution uses a correlated subquery
	with the TOP filter. The sub-query filters only orders where the inner
	customer ID is equal to the outer customer ID. It also filters only
	orders where either "the inner order date is equal to the outer order
	date and the inner order ID is smaller than the outer order ID" or
	"the inner order date is earlier than the outer order date." The 
	remaining orders are the ones considered earlier than the current
	customer's order. Using the TOP (1) filter based on the ordering of
	orderdate DESC, orderid DESC, you get the date of the customer's
	previous order.

	Note: Recency is determined first based on order-date ordering, and 
	then order ID is used as the tiebreaker.
**/

/**
	The second step, use the DATEDIFF function to compute the difference
	between the previous order date returned by the subquery and the current
	order date.
**/
SELECT custid, orderdate, orderid,
  DATEDIFF(day,
	(SELECT TOP (1) O2.orderdate
	 FROM Sales.Orders AS O2
	 WHERE O2.custid = O1.custid
	   AND (    O2.orderdate = O1.orderdate AND O2.orderid < O1.orderid
			 OR O2.orderdate < O1.orderdate )
	 ORDER BY O2.orderdate DESC, O2.orderid DESC),
	 orderdate) AS DIFF
FROM Sales.Orders AS O1
ORDER BY custid, orderdate, orderid;