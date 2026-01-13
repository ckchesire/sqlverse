-----------------------------------------------------------------
-- Correlated subqueries
-----------------------------------------------------------------
-- Correlated subqueries are subqueries that refer to attributes
-- from the table that appear in the outer query. This means the
-- subquery is dependent on the outer query and cannot be invoked
-- as a standalone query.
-- Logically, the subquery is evaluated separately for each outer
-- row in the logical processing step in which it appears
-----------------------------------------------------------------
/**
	For example the following query returns orders with the maximum
	order ID for each customer.
**/
USE TSQLV6;

SELECT custid, orderid, orderdate, empid
FROM Sales.Orders AS O1
WHERE orderid = 
  (SELECT MAX(O2.orderid)
   FROM Sales.Orders AS O2
   WHERE O2.custid = O1.custid);

SELECT custid, orderid, orderdate, empid
FROM Sales.Orders
WHERE custid = 85;

/**
	Another example, suppose you need to query the Sales.OrderValues
	and return for each order the percentage of the current order
	value out of the customer total.

	Solution: You can write an outer query against one instance of the
	OrderValues view called O1. In the SELECT list, divide the current
	value by the result of a correlated subquery against a second
	instance of OrderValues called 02 that returns the current customer's
	total.
**/

SELECT orderid, custid, val,
  CAST(100. * val/ (SELECT SUM(O2.val)
                    FROM Sales.OrderValues AS O2
					WHERE O2.custid = O1.custid)
		AS NUMERIC(5, 2)) AS pct
FROM Sales.OrderValues AS O1
ORDER BY custid, orderid;

--------------------------------------------------------------------
-- The EXISTS predicate
---------------------------------------------------------------------
-- T-SQL supports a predicate called EXISTS, which accepts a subquery
-- as input and returns TRUE if the subquery returns any rows and 
-- False otherwise.
---------------------------------------------------------------------
/**
	The following query returns customers from Spain who placed orders.

	The outer query against the Customers table filters only customers
	from Spain for whom the EXISTS predicate returns TRUE. The EXISTS
	predicate return TRUE if the current customer has related orders
	in the Orders table.
**/
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE country = N'Spain'
  AND EXISTS
    (SELECT * FROM Sales.Orders AS O
	 WHERE O.custid = C.custid);

/**
	As with other predicates, you can negate the EXISTS predicate with
	the NOT operator. For example, the following query returns customers
	from Spain who did not place orders:

	Note: EXISTS predicate lends itself to good optimization. That is, the
	database engine knows that it's enough to determine whether the subquery
	returns at least one row or none, and it doesn't need to process all
	qualifying rows. You can think of this capability as a kind of short-circuit
	evaluation. The same applies to the IN predicate.

	Note: EXISTS uses two-valued logic not three-valued logic i.e TRUE or FALSE.
**/
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE country = N'Spain'
  AND NOT EXISTS
    (SELECT * FROM Sales.Orders AS O
	 WHERE O.custid = C.custid);

