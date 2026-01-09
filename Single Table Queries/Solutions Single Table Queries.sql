-- SET STATISTICS IO ON;
USE TSQLV6;
-----------------------------------------------------------
-- Ex1: Query to return orders place in June 2021
-----------------------------------------------------------
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate BETWEEN '2021-06-01' AND '2021-06-30';

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE YEAR(orderdate) = 2021 AND MONTH(orderdate) = 6;

/**
	If you apply manipulation to the filtered column, in
	most cases SQL Server can't use an index efficiently.
	Therefore, using a range filter is advised instead:
**/
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate >= '20210601'
  AND orderdate < '20210701';

-----------------------------------------------------------
-- Ex2: Query to return orders placed on the day 
-- before the last day of the month.
-----------------------------------------------------------

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = DATEADD(day, -1, EOMONTH(orderdate));

------------------------------------------------------------
-- Ex3: Query against HR.Employees that returns 
-- employees with a last name containing the letter e twice.
------------------------------------------------------------
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE LEN(lastname) - LEN(REPLACE(lastname, 'e', '')) = 2;

/**
	The percent sign(%) represents a character string of any size,
	including an empty string. Therefore you can use the pattern
	'%e%e%'to express atleast two occurences of the character 'e' 
	anywhere in the string
**/
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE '%e%e%';

---------------------------------------------------------------
-- Ex4: Query against the Sales.OrderDetails table that returns
-- orders with a total value (quantity * unitprice) greater
-- than 10,000, sorted by total value, descending
---------------------------------------------------------------
/**
	Wrong approach
**/
SELECT orderid, (qty * unitprice) AS totalvalue
FROM Sales.OrderDetails
WHERE (qty * unitprice) > 10000
ORDER BY totalvalue DESC;

/**
	Observe that the request said "return orders with total value 
	greater than 10,000" and not "return orders with value greater 
	than 10,000". In other words, it's not the individual order line
	row that is supposed to meet this requirement. This means that
	the query shouldn't have a filter in the WHERE clause like this:

	WHERE quantity * unitprice > 10000

	Rather, the query should group the data by the orderid attribute
	and have a filter in the HAVING clause, like this:

	HAVING SUM(quantity*unitprice) > 10000

	The following is the complete solution:
**/
SELECT orderid, SUM(qty*unitprice) AS totalvalue
FROM Sales.OrderDetails
GROUP BY orderid
HAVING SUM(qty*unitprice) > 10000
ORDER BY totalvalue DESC;

------------------------------------------------------------
-- Ex5: Query against the HR.Employees table that 
-- returns employees with a last name that starts with a
-- lowercase English letter in the range a through z.
------------------------------------------------------------
/**
	The expression WHERE clause uses the COLLATE clause to
	convert the current case-insensitive collation of the 
	lastname column to a case-sensitive one.
**/
SELECT empid, lastname
FROM HR.Employees
WHERE lastname COLLATE Latin1_General_CS_AS LIKE N'[a-z]%';

/**
	To look for only the lowercase letters a through z, one solution
	is to list them explicitly in the LIKE pattern.
**/
SELECT empid, lastname
FROM HR.Employees
WHERE lastname COLLATE Latin1_General_CS_AS LIKE N'[abcdefghijklmnopqrstuvwxyz]%';

/**
	Naturally, there are other possible solutions. For example, using a binary
	collation and then a simplified range of letters.
**/
SELECT empid, lastname
FROM HR.Employees
WHERE lastname COLLATE Latin1_General_BIN LIKE N'[a-z]%';

--------------------------------------------------------------
-- EX6: Explain the difference between the two queries
--------------------------------------------------------------
-- Query 1
SELECT empid, COUNT(*) AS numorders
FROM Sales.Orders
WHERE orderdate < '20220501'
GROUP BY empid;
-- Query 2
SELECT empid, COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY empid
HAVING MAX(orderdate) < '20220501';
/**
	The WHERE clause is a row filter, whereas the HAVING clause is 
	a group filter.

	Query1: Filters only orders placed before May 2022, groups them by
	employee ID, and returns the number of orders each employee handled
	among the filtered ones. In other words, it computes how many orders
	each employee handled prior to May 2022.
	
	Query2: Groups all orders by the employee ID, and then filters only
	groups having a maximum date of activity prior to May 2022. Then it
	computes the order count in each employee group. The query discards
	the entire employee group if the employee handled any orders since
	May 2022.
**/


--------------------------------------------------------------
-- Ex7: Query against the Sales.Orders table that returns the
-- three shipped to countries with the highest average freight
-- for orders placed in 2021
--------------------------------------------------------------
SELECT TOP 3 shipcountry, AVG(freight) AS avgfreight
FROM Sales.Orders
WHERE YEAR(Orderdate) = 2021 
GROUP BY shipcountry
ORDER BY avgfreight DESC;

/**
	The above solution may be inefficient as it is unable to
	maximize on indexes.

	The following approach is recommended.
**/
SELECT TOP (3) shipcountry, AVG(freight) AS avgfreight
FROM Sales.Orders
WHERE orderdate >= '20210101' AND  orderdate < '20220101'
GROUP BY shipcountry
ORDER BY avgfreight DESC;

/**
	You can use the standard OFFSET-FETCH filter instead of
	the proprietary TOP filter.

	Revised solution using OFFSET-FETCH filter
**/
SELECT shipcountry, AVG(freight) AS avgfreight
FROM Sales.Orders
WHERE orderdate >= '20210101' AND  orderdate < '20220101'
GROUP BY shipcountry
ORDER BY avgfreight DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;

----------------------------------------------------------------
-- Ex8: Query against the Sales.Orders table that calculates 
-- row numbers for orders based on order date ordering(using
-- the order ID as the tiebreaker) for each customer separately.
----------------------------------------------------------------

/**
	Wrong approach
**/
SELECT custid, orderdate, orderid,
	ROW_NUMBER() OVER (ORDER BY orderdate) AS rownum
FROM Sales.Orders
ORDER BY custid ASC;

/**
	The row number calculation should be done for each customer
	separately, the expression should partition the window by 
	custid (PARTITION BY custid).

	In addition, the request was to use ordering based on the
	orderdate column, with the orderid column as a tiebreaker
	(ORDER BY orderdate, orderid)
**/
SELECT custid, orderdate, orderid,
	ROW_NUMBER() OVER(PARTITION BY custid ORDER BY orderdate, orderid) AS rownum
FROM Sales.Orders
ORDER BY custid, rownum;

----------------------------------------------------------------------
-- Ex9: Using the HR.Employees table, write a SELECT statement that
-- that returns for each employee the gender based on the title of
-- courtesy. For  'Ms.' and 'Mrs.' return 'Female'; for 'Mr.' return
-- 'Male'; and in all other cases(for example, 'Dr.')return 'Unknown'
----------------------------------------------------------------------
SELECT empid, firstname, lastname, titleofcourtesy,
  CASE titleofcourtesy
	WHEN 'Ms.' THEN 'Female'
	WHEN 'Mrs.' THEN 'Female'
	WHEN 'Mr.' THEN 'Male'
	ELSE 'Unknown'
  END AS gender
FROM HR.Employees;

/**
	You can also use the searched CASE form with two predicates-one
	to handle all cases in which the gender is female and one for 
	all cases in which the gender is male-and an ELSE clause with 
	'Unknown'.
**/
SELECT empid, firstname, lastname, titleofcourtesy,
  CASE
    WHEN titleofcourtesy IN ('Ms.', 'Mrs.') THEN 'Female'
	WHEN titleofcourtesy = 'Mr.'			THEN 'Male'
	ELSE					'Unknown'
  END AS gender
FROM HR.Employees;

----------------------------------------------------------------------
-- Ex10: Query against the Sales.Customers table that returns for each
-- customer the customer ID and region. Sort the rows in the output by
-- region, ascending, having NULLs sort last(after non-NULL values).
-- Note that the default sort behavior for NULLs in T-SQL is to sort
-- first (before non-NULL values):
----------------------------------------------------------------------
/**
	By default, SQL Server sorts NULL before non-NULLs values.
**/
SELECT custid, region
FROM Sales.Customers
ORDER by region ASC;

/**
	To use NULLs to sort last, you can use a CASE expression that
	returns 1 when the region column is NULL and 0 when it is not
	NULL.
**/
SELECT custid, region
FROM Sales.Customers
ORDER BY
	CASE WHEN region IS NULL THEN 1 ELSE 0 END, region;