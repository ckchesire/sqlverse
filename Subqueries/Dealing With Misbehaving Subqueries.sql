-----------------------------------------------------------------
-- Dealing With Misbehaving SubQueries
-----------------------------------------------------------------
-- This section introduces cases in which the use of subqueries
-- invlolves bugs, and it provides best practices that can help
-- you avoid those bugs.
-----------------------------------------------------------------


------------------------------------------------------------------
-- NULL Trouble
------------------------------------------------------------------
-- Remember that T-SQL uses three-valued logic because of its
-- support for NULLs. In this section we discuss problems that can
-- evolve when you forget about NULLs and the three-valued logic
------------------------------------------------------------------
/**
	Consider the following query, which is supposed to return customers
	who did not place orders.
**/
SELECT custid, companyname
FROM Sales.Customers
WHERE custid NOT IN(SELECT O.custid
					FROM Sales.Orders As O);

/**
	With the current sample data in the Orders table, the query seems to
	work the way you expect it to, and indeed, it returns the following two 
	customers.

	Next, run the following code to insert a new order into the Orders table
	with a NULL customer ID.
**/
INSERT INTO Sales.Orders
  (custid, empid, orderdate, requireddate, shippeddate, shipperid,
   freight, shipname, shipaddress, shipcity, shipregion,
   shippostalcode, shipcountry)
VALUES(NULL, 1, '20220212', '20220212',
       '20220212', 1, 123.00, N'abc', N'abc', N'abc',
	   N'abc', N'abc', N'abc');
/**
	Next, run the previous query again.

	The Output is an empty set. The culprit here being the NULL customer
	ID added to the Orders table. The NULL is one of the elements returned
	by the subquery.

	Why the empty set? When you evaluate each individual expression in the
	paranthesis to its truth value and you get NOT(FALSE OR FALSE OR ... OR
	UNKNOWN), which translates to NOT UNKNOWN, which evaluates to UNKNOWN.

	In short, when you use the NOT IN predicate against a subquery that returns
	at least one NULL, the query always returns an empty set.
**/
SELECT custid, companyname
FROM Sales.Customers
WHERE custid NOT IN(SELECT O.custid
					FROM Sales.Orders As O);

/**
	So what practices can you follow to avoid such trouble? First, when a column
	is not supposed to allow NULLs, be sure to define it as NOT NULL. Second, in
	all queries you write, you should consider NULLs and the three-valued logic.

	For example, our query returns an empty set because of the comparison with NULL.
	If you want to check whether a Customer ID appears only in the set of known values,
	you should exclude the NULLs - either explicitly or implicitly.

	To exclude them explicilty, add the predicate O.custid IS NOT NULL to the subquery,
	like so:
**/
SELECT custid, companyname
FROM Sales.Customers
WHERE custid NOT IN(SELECT O.custid
                    FROM Sales.Orders AS O
					WHERE O.custid IS NOT NULL);

/**
	You can also exclude the NULLs implicitly by using the NOT EXISTS
	predicate instead of NOT IN, like this:
**/
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE NOT EXISTS
  (SELECT * 
   FROM Sales.Orders AS O
   WHERE O.custid = C.custid);
/**
	Recall that unlike IN, EXISTS uses two-valued predicate logic. EXISTS
	always returns TRUE or FALSE and never UNKNOWN.

	It's safer to use NOT EXISTS than NOT IN.
**/

-- Code Cleanup.
DELETE FROM Sales.Orders WHERE custid IS NULL;

-----------------------------------------------------------------
-- Substitution Errors in Subquery Column Names
-----------------------------------------------------------------
-- Logical bugs in your code can sometimes be elusive. In this
-- section, we cover a bug related to an innocent substitution
-- error in a subquery column name.
-----------------------------------------------------------------
DROP TABLE IF EXISTS Sales.MyShippers;

CREATE TABLE Sales.MyShippers
(
	shipper_id	INT			  NOT NULL,
	companyname NVARCHAR(40)  NOT NULL,
	phone		NVARCHAR(24)  NOT NULL,
	CONSTRAINT PK_MyShippers PRIMARY KEY(shipper_id)
);

INSERT INTO Sales.MyShippers(shipper_id, companyname, phone)
  VALUES(1, N'Shipper GVSUA', N'(503) 555-0137'),
		(2, N'Shipper ETYNR', N'(425) 555-0136'),
		(3, N'Shipper ZHISN', N'(415) 555-0138');

/**
	Consider the following query, which is supposed to return
	shipped orders to customer 43
**/
SELECT shipper_id, companyname
FROM Sales.MyShippers
WHERE shipper_id IN
  (SELECT shipper_id
   FROM Sales.Orders
   WHERE custid = 43);
/**
	The column name in the Orders table holding the shipper ID is called
	not shipper_id but rather shippedid(no underscore). The column in the
	MyShippers table is called shipper_id, with an underscore. The resolution,
	or binding, of nonprefixed column names works in the context of sub-query
	from the inner scope outward.

	In our example, SQL Server first looks for the column shipper_id in the table
	in the inner query, Orders. Such a column is not found there, so SQL Server looks
	for it in the table in the outer query, MyShippers. Such a column is found in
	MyShippers, so that one is used.

	What was supposed to be a self-contained subquery unintentionally became a correlated
	subquery. As long as the Orders table has at least one row, all rows from the MyShippers
	table find a match when comparing the outer shipper ID with the very same shipper ID.
**/
SELECT shipperid
   FROM Sales.Orders
   WHERE custid = 43;

/**
	You can follow a couple of best practices to avoid such problems:
	 1. Use consistent attribute names across tables.
	 2. Prefix column names in subqueries with the source table name or alias(if assigned one).
**/
SELECT shipper_id, companyname
FROM Sales.MyShippers
WHERE shipper_id IN
  (SELECT O.shipper_id
   FROM Sales.Orders AS O
   WHERE O.custid = 43);

/**
	After getting the invalid column name error, you resolve the problem.
**/
SELECT shipper_id, companyname
FROM Sales.MyShippers
WHERE shipper_id IN
  (SELECT O.shipperid
   FROM Sales.Orders AS O
   WHERE O.custid = 43);

-- Run Code Cleanup.
DROP TABLE IF EXISTS Sales.MyShippers;