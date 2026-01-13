USE TSQLV6;
-----------------------------------------------------------
-- SQL supports writing queries within queries, or nesting
-- queries. The outermost query is a query whose result set
-- is used by the outer query and is known as a subquery.
-- The inner query acts in place of an expression that is
-- based on constants or variables and is evaluated at run
-- time.
-- A subquery can either be self-contained or correlated.
-- A self-contained query has no dependency on tables from
-- the outer query, whereas a correlated subquery does.
-- A subquery can be single-valued, multivalued, or 
-- table-valued
-----------------------------------------------------------

---------------------------------------------------------------
-- Self-contained subqueries
----------------------------------------------------------------
-- Self-contained subqueries are subqueries that are independent
-- of the tables in the outer query. Self-contineed subqueries 
-- are convenient to debug, because you can always highlight the
-- inner query, run it, and ensure that it does what it's 
-- supposed to do. Logically, the subquery code is evaluated 
-- only once before the outer query is evaluated, and then the
-- outer query uses the result of the subquery.
----------------------------------------------------------------

/**
	For example, suppose you want to query the Orders table in
	the TSQLV6 database and return information about the order
	that has the maximum order ID in the table.

	First we solve this using a variable. The code retrieves 
	the maximum order ID from the Orders table and store the
	result in a variable. Then the code queries the Orders table
	and filter the order where the order ID is equal to the value
	stored in the variable.
**/
DECLARE @maxid AS INT  = (SELECT MAX(orderid)
						  FROM Sales.Orders);

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderid = @maxid;

/**
	Substituting the variable with a scalar self-contained subquery
**/

SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE orderid = (SELECT MAX(O.orderid)
				 FROM Sales.Orders AS O);

/**
	For a scalar to be valid, it must return no more than one value. 
	If a scalar subquery returns more than one value, it fails at run
	time.

	This query happens to run without failure because currently the 
	Employees table contains only one employee whose last name starts
	with C(Maria Cameron with employee ID 8).
**/
SELECT orderid
FROM Sales.Orders
WHERE empid = 
	(SELECT E.empid
	 FROM HR.Employees AS E
	 WHERE E.lastname LIKE N'C%');

/**
	If the subquery returns more than one value, the query fails. For
	example, lets try running the query with employees whose lastsnames
	start with D:
**/
SELECT orderid
FROM Sales.Orders
WHERE empid =
  (SELECT E.empid
   FROM HR.Employees AS E
   WHERE E.lastname LIKE N'D%');

/**
	If a scalar subquery returns no value, the empty result is converted
	to a NULL. Recall that a comparison with a NULL yields UNKNOWN and 
	that query filters do not return a row for which the filter expressions
	evaluates to UNKNOWN. For example, the Employees table currrently has
	no employees whose last names start with A; therefore the following query
	returns an empty set.
**/
SELECT orderid
FROM Sales.Orders
WHERE empid = 
  (SELECT E.empid
   FROM HR.Employees AS E
   WHERE E.lastname LIKE N'A%');

----------------------------------------------------------------
-- Self-contained multivalued subquery examples
----------------------------------------------------------------
-- A multivalued subquery is a subquery that returns multiple
-- values as a single column. Some predicates, such as the IN
-- predicate, operate on a multivalued subquery.
-- SQL supports other predicates that operate on a multivalued 
-- subquery; those are SOME, ANY, and ALL.
-- The form of the IN predicate is:
--		<scalar_expression> IN (<multivalued subquery>)
-- The predicate evaluates to TRUE if scalar_expression is equal
-- to any values returned by the subquery.
----------------------------------------------------------------
/**
	For example, the following query returns orders placed by employees
	with a last name starting with D.

	Because this solution uses the IN predicate, this query is valid 
	with any number of values returned-none, one, or more.
**/
SELECT orderid
FROM Sales.Orders
WHERE empid IN
  (SELECT E.empid
   FROM HR.Employees AS E
   WHERE E.lastname LIKE N'D%');

/**
	You might wonder why we don't implement this task by using a join
	instead of subqueries, as shown below.

	Overally, in some cases the database engine optimizes both the same
	way, sometimes joins perform better, and sometimes subqueries perform
	better.
**/
SELECT O.orderid
FROM HR.Employees AS E
  INNER JOIN Sales.Orders AS O
    ON E.empid = O.empid
WHERE E.lastname LIKE N'D%';

/**
	Suppose you need to write a query that returns orders placed by 
	customers from the United States. You can write a query against
	the Orders table that returns orders where the customer ID is in
	the set of customer IDs of customers from the United States. You
	can implement the last part in a self-contained, multivalued
	subquery.
**/
SELECT custid, orderid, orderdate, empid
FROM Sales.Orders
WHERE custid IN
  (SELECT C.custid
   FROM Sales.Customers AS C
   WHERE C.country = N'USA');

/**
	As with any predicate, you can negate the IN predicate with the
	NOT operator.

	For example, the following query returns customers who did not
	place any orders.

	Note: It's considered a best practice to qualify the subquery, namely
	add a filter, to exclude NULLs.
**/
SELECT custid, companyname
FROM Sales.Customers
WHERE custid NOT IN
  (SELECT O.custid
   FROM Sales.Orders AS O);

/**
	The last example in this section demonstrates the use of multiple
	self-contained subqueries in the same query-both single-valued and
	multivalued.

	Create a table called dbo.Orders, and populate it with even-numbered
	order IDs from the Sales.Orders table.
**/
USE TSQLV6;
DROP TABLE IF EXISTS dbo.Orders;
CREATE TABLE dbo.Orders(
	orderid INT NOT NULL 
	CONSTRAINT Pk_Orders PRIMARY KEY
);

INSERT INTO dbo.Orders(orderid)
  SELECT orderid
  FROM Sales.Orders
  WHERE orderid % 2 = 0;

/**
	Write a query that returns all individual order IDs that are missing
	between the minimum and maximum ones in the table.

	In the following example we will use the Nums table. To return all
	missing order IDs, query the Nums table and filter only numbers that
	are between minimum and maximum ones in dbo.Orders table, and that 
	do not appear as order IDs in the Orders table.

	You can use scalar self-contained subqueries to return the minimum and
	maximum order IDs and a multivalued self-contained subquery to return
	the set of all existing order IDs.
**/
SELECT n
FROM dbo.Nums
WHERE n BETWEEN (SELECT MIN(O.orderid) FROM dbo.Orders AS O)
			AND (SELECT MAX(O.orderid) FROM dbo.Orders AS O)
   AND n NOT IN (SELECT O.orderid FROM dbo.Orders AS O);

-- Code for cleanup
DROP TABLE IF EXISTS dbo.Orders;
