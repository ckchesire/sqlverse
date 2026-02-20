USE TSQLV6;
----------------------------------------------------------------
-- Window Functions
----------------------------------------------------------------
-- A window function is a function that, for each row, 
-- computes a scalar value based on a calculation against
-- a subset of the rows from the underlying query.
-- The subset of rows is known as a window and is based on
-- a window descriptor that relates to the current row.
-- The syntax for window functions uses a clause called
-- OVER, in which you provide the window specification.
--
-- Note: Unlike grouped functions, window functions don't
-- cause you to loose detail.
-- As for subqueries, you can use them to apply a scalar
-- aggregate calculation against a set, but their starting
-- point is a fresh view of the data rather than the underlying
-- query result set.
-- In contrast, a window function is applied to a subset of rows
-- from the underlying query's result set - not a fresh view of
-- the data.
-----------------------------------------------------------------
/**
	The following is an example of a query against the Sales.EmpOrders
	view in the TSQLV6 database that uses a window aggregate function
	to compute the running-total values for each employee and month.
**/
USE TSQLV6;
SELECT empid, ordermonth, val,
	SUM(val)  OVER(PARTITION BY empid
				   ORDER BY ordermonth
				   ROWS BETWEEN UNBOUNDED PRECEDING
						    AND CURRENT ROW) AS runval
FROM Sales.EmpOrders;

-----------------------------------------------------------------
-- Ranking Window Functions
-----------------------------------------------------------------
-- You use ranking window functions to rank each row with respect
-- to others in the window. T-SQL supports four ranking functions
-- : ROW_NUMBER, RANK, DENSE_RANK, and NTILE. 
-----------------------------------------------------------------
/**
	The following query demonstrates the use of these functions.

	1. The ROW_NUMBER function assigns incremental sequential integers
	  to the rows in the query result based on the mandatory window
	  ordering. However, note that the ROW_NUMBER function must produce 
	  unique values even when there are ties in the ordering values, 
	  making it nondeterministic when there are ties.
	2. If you want to produce the same rank value given the same ordering
	  value, use the RANK or DENSE_RANK function instead. The difference
	  between the two is that RANK reflects the count of rows that have
	  a lower ordering value than the current row(plus 1), whereas 
	  DENSE_RANK reflects the count of distinct ordering values that are
	  lower than the current row(plus 1).
	3. You use the NTILE function to associate the rows in the result with
	  tiles (equally sized groups of rows) by assigning a tile number to 
	  each row. You specify the number of tiles you are after and window
	  ordering.
**/
SELECT orderid, custid, val,
  ROW_NUMBER()  OVER(ORDER BY val) AS rownum,
  RANK()	    OVER(ORDER BY val) AS rank,
  DENSE_RANK()  OVER(ORDER BY val) AS dense_rank,
  NTILE(10)     OVER(ORDER BY val) AS ntile
FROM Sales.OrderValues
ORDER BY val;

/**
	Like all window functions, ranking functions support a window partition
	clause. Remember that window partitioning restricts the window to only
	those rows that have the same values in the partitioning attributes as
	in the current row.

	For example, the expression ROW_NUMBER() OVER(PARTITION BY custid ORDER
	BY val) assigns row numbers independently for each customer.
**/
SELECT orderid, custid, val,
  ROW_NUMBER() OVER(PARTITION BY custid
					ORDER BY val) AS rownum
FROM Sales.OrderValues
ORDER BY custid, val;

/**
	Remember that window ordering has nothing to do with presentation ordering
	and does not change the nature of the result from being relational. If you
	need to guarantee presentation ordering, you have to add a presentation
	ORDER BY clause.

	Window functions are logically evaluated as part of SELECT list, before
	the DISTINCT clause is evaluated. If you're wondering why it matters, We'll
	explain this with an example. Currently, the OrderValues view has 830 rows
	with 795 distinct values in the val column. 

	Consider the following query and its output:
**/

SELECT COUNT(DISTINCT(val)) FROM Sales.OrderValues;

SELECT DISTINCT val, ROW_NUMBER() OVER (ORDER BY val) AS rownum
FROM Sales.OrderValues;

/**
	The ROW_NUMBER function is processed before the DISTINCT clause.
	First, unique row numbers are assigned to the 830 rows from the
	OrderValues view. Then the DISTINCT clause is processed - but there
	are no duplicate rows to remove. The DISTINCT clause has no effect
	here.

	If you want to assign row numbers to the 795 unique values, you need
	to come up with a different solution. For example, because the GROUP BY
	phase is processed before the SELECT phase, you can use the following 
	query:
**/
SELECT val, ROW_NUMBER() OVER(ORDER BY val) AS rownum
FROM Sales.OrderValues
GROUP BY val;

-----------------------------------------------------------------
-- Offset Window Functions
-----------------------------------------------------------------
-- You use offset window functions to return an element from a 
-- row that is at a certain offset from the current row or at the
-- beginning or end of a window frame. T-SQL supports two pairs
-- of offset functions: LAG and LEAD, and FIRST_VALUE and 
-- LAST_VALUE.
-- The LAG and LEAD functions support window partitions and
-- window-order clauses. There's no relevance to window framing
-- here. You use these functions to obtain an element from a row
-- that is at a certain offset from the current row within the 
-- partition, based on the indicated ordering.
--
-- The LAG function looks before the current row, and the LEAD
-- function looks ahead.
-- The first argument to the functions(which is mandatory) is the
-- element you want to return; the second argument (optional) is
-- the offset (1 if not specified); the third argument(optional)
-- is the default value to return if there is no row at the 
-- requested offset(which is NULL if not specified otherwise).
-----------------------------------------------------------------
/**
	As an example, the following query returns order information
	from the OrderValues view. For each customer order, the 
	query uses the LAG function to return the value of the previous
	customer's order and the LEAD function to return the value of
	the next customer's order.
**/
SELECT custid, orderid, val,
  LAG(val)	OVER(PARTITION BY custid
				 ORDER BY orderdate, orderid) AS prevval,
  LEAD(val)	OVER(PARTITION BY custid
				 ORDER BY orderdate, orderid) AS nextval
FROM Sales.OrderValues
ORDER BY custid, orderdate, orderid;

/**
	In this example, we just returned the values from the previous
	and next orders, but normally you compute something based on the
	returned values. For example, you can compute the difference between
	the values of the current and previous customers' order using
	val - LAG(val) OVER(...). Or you can compute the difference between
	the current and next customers' order using val - LEAD(val) OVER(...).
**/

SELECT custid, orderid, val,
  val - LAG(val) OVER(PARTITION BY custid
					  ORDER BY orderdate, orderid) AS cur_prevval_diff,
  val - LEAD(val) OVER(PARTITION BY custid
					   ORDER BY orderdate, orderid) AS cur_nextval_diff
FROM Sales.OrderValues

/**
	You use the FIRST_VALUE and LAST_VALUE functions to return an element
	from the first and last rows in the window frame, respectively. Therefore,
	these functions support window-partition, window-order, and window-frame
	clauses.

	If you want the element from the first row in the window partition, use
	FIRST_VALUE with the window-frame extent ROWS BETWEEN UNBOUNDED PRECEDING
	AND CURRENT ROW.

	If you want the element from the last row in the window partition, use
	LAST_VALUE with the window-frame extent ROWS BETWEEN CURRENT ROW and
	UNBOUNDED FOLLOWING.

	Note: That if you specify ORDER BY without a window-frame unit(such as ROWS)
	, the bottom delimiter will by default be CURRENT ROW, and clearly that's not
	what you want with LAST_VALUE. Also, for performance-related reasons, you 
	should be explicit about the window-frame extent even for FIRST_VALUE.

	As an example, the following query uses the FIRST_VALUE function to return
	the value of the first customer's order and the LAST_VALUE function to
	return the value of the last customer's order.
**/
SELECT custid, orderid, val,
  FIRST_VALUE(val) OVER(PARTITION BY custid
						ORDER BY orderdate, orderid
						ROWS BETWEEN UNBOUNDED PRECEDING
								 AND CURRENT ROW) AS firstval,
  LAST_VALUE(val)  OVER(PARTITION BY custid
						ORDER BY orderdate, orderid
						ROWS BETWEEN CURRENT ROW 
								 AND UNBOUNDED FOLLOWING) AS lastval
FROM Sales.OrderValues
ORDER BY custid, orderdate, orderid;

/**
	As with LAG and LEAD, normally you compute something based
	on the returned values. For example, you can compute the
	difference between the current and the first customer's order
	values: val - FIRST_VALUE(val) OVER(...). Or you can compute
	the difference between the current and last customer's order
	values: val - LAST_VALUE(val) OVER(...).
**/
SELECT custid, orderid, val,
  FIRST_VALUE(val) OVER(PARTITION BY custid
						ORDER BY orderdate, orderid
						ROWS BETWEEN UNBOUNDED PRECEDING
								 AND CURRENT ROW) As firstvalue,
  LAST_VALUE(val)  OVER(PARTITION BY custid
						ORDER BY orderdate, orderid
						ROWS BETWEEN CURRENT ROW
								 AND UNBOUNDED FOLLOWING) AS lastvalue,
  val - FIRST_VALUE(val) OVER(PARTITION BY custid
							  ORDER BY orderdate, orderid
							  ROWS BETWEEN UNBOUNDED PRECEDING
								       AND CURRENT ROW) As curr_firstvalue_diff,
  val -  LAST_VALUE(val)  OVER(PARTITION BY custid
							   ORDER BY orderdate, orderid
							   ROWS BETWEEN CURRENT ROW
									    AND UNBOUNDED FOLLOWING) AS lastvalue
FROM Sales.OrderValues;

/**
	SQL Server 2022 introduces support for the standard NULL treatment clause
	with offset window functions. The syntax for this clause is as follows:

	<function>( <expression> ) [ IGNORE NULLS | RESPECT NULLS ] OVER( <specification> )

	This clause allows you to indicate whether to ignore or respect NULLs returned
	by the input expression. The RESPECT NULLS option, which is the default, essentially
	treats NULLs just like normal values. So even if the input expression evaluates to
	NULL, the function will return it.

	The IGNORE NULLS option means that if the input expression is NULL, you want to 
	keep going in the applicable ordering direction until it finds a non-NULL value,
	if none exists, the function returns a NULL.

	Consider the following query, which returns shipped dates for orders by customers
	9, 20, 32, and 73 in or after 2022.
**/
SELECT orderid, custid, orderdate, shippeddate
FROM Sales.Orders
WHERE custid IN (9, 20, 32, 73)
  AND orderdate >= '20220101'
ORDER BY custid, orderdate, orderid;

/**
	Observe that orders that have not been shipped yet have a NULL shipped date. Suppose
	that you want to add a result column that shows the last known shipped date at that
	point for orders placed by the same customer in or after 2022, based on order date
	ordering, with order ID as a tiebreaker.

	Note: That the last known shipped date at that point (from the last row where the shipped
	date is not NULL) is not necessarily the maximum shipped date at that point.

	To achieve this, we use the LAST_VALUE function with the IGNORE NULLS option, like so:
**/
USE TSQLV6;
GO
SELECT orderid, custid, orderdate, shippeddate,
  LAST_VALUE(shippeddate) IGNORE NULLS
	OVER(PARTITION BY custid
		 ORDER BY orderdate, orderid
		 ROWS UNBOUNDED PRECEDING) AS lastknownshippeddate
FROM Sales.Orders
WHERE custid IN (9, 20, 32, 73)
  AND orderdate >= '20220101'
ORDER BY custid, orderdate, orderid;

/**
	In a similar way, if you want to return previously known
	shipped date for the customer, you use the LAG function
	with the IGNORE NULLS option, like so:
**/
SELECT orderid, custid, orderdate, shippeddate,
  LAG(shippeddate) IGNORE NULLS
    OVER(PARTITION BY custid
		 ORDER BY orderdate, orderid) AS prevknownshippeddate
FROM Sales.Orders
WHERE custid IN (9, 20, 32, 73)
  AND orderdate >= '20220101'
ORDER BY custid, orderdate, orderid;

-----------------------------------------------------------------
-- Aggregate Window Functions
-----------------------------------------------------------------
-- You use aggregate window functions to aggregate the row in the
-- defined window. They support window-partition, window-order, 
-- and window-frame clauses.
-----------------------------------------------------------------
/**
	Here's a query against OrderValues that returns, along with each
	order, the grand total of all order values, as well as the 
	customer total.
**/
USE TSQLV6;
SELECT orderid, custid, val,
  SUM(val) OVER() AS totalvalue,
  SUM(val) OVER(PARTITION BY custid) AS custtotalvalue
FROM Sales.OrderValues;

-- SELECT 814.50 + 878.00 + 330.00 + 845.80 + 471.20 + 933.50;
-- SELECT SUM(val) FROM Sales.OrderValues;

/**
	As an example of mixing detail and aggregates, the following query
	calculates for each row the percentage of the current value out of
	the grand total, as well as out of the customer total.
**/
SELECT orderid, custid, val, 
  100. * val / SUM(val) OVER() as pctall,
  100. * val / SUM(val) OVER(PARTITION BY custid) AS pctcust
FROM Sales.OrderValues;

/**
	Aggregate window functions also support a window frame. The frame
	allows for more sophisticated  calculations, such as running and
	moving aggregates, YTD and MTD calculations, and other. Let's
	re-examine the query used in the introduction to the section about
	window functions.

	For the below, we apply the calculation to each employee independently
	, we partition the window by empid. Then we define ordering based on
	ordermonth, giving meaning to the window frame: ROWS BETWEEN UNBOUNDED
	PRECEDING AND CURRENT ROW. This frame means "all activity from the
	beginning of the partition until the current month."
**/
SELECT empid, ordermonth, val,
  SUM(val) OVER(PARTITION BY empid
				ORDER BY ordermonth
				ROWS BETWEEN UNBOUNDED PRECEDING
				         AND CURRENT ROW) AS runval
FROM Sales.EmpOrders;

/**
	T-SQL supports other delimiters for the ROWS window-frame unit. You can
	indicate an offset back from the current row as well as an offset forward.
	For example, to capture all rows from two rows before the current row 
	until one row ahead, you use ROWS BETWEEN 2 PRECEDING AND 1 FOLLOWING.

	Also, if you do not want an upper bound, you can use UNBOUNDED FOLLOWING.
**/

-------------------------------------------------------------------------
-- The WINDOW clause
-------------------------------------------------------------------------
-- The WINDOW clause allows you to name an entire window specification or
-- part of it in a query, and then use the window name in the OVER clause
-- of window functions in that query. Its main purpose is to shorten the
-- length of your query string when you have repetitive window 
-- specifications.
-------------------------------------------------------------------------
/**
	Check compatability level of your database
**/
SELECT name
FROM sys.databases
WHERE name = 'TSQLV6';

USE TSQLV6;
SELECT DATABASEPROPERTYEX(N'TSQLV6', N'CompatibilityLevel');

SELECT DATABASEPROPERTYEX(N'TSQLV6', N'CompatibilityLevel');

/**
	When considering all major query clauses(SELECT,FROM,WHERE,GROUP BY,HAVING,ORDER BY),
	you place the WINDOW clause between the HAVING and ORDER BY clauses of the query.

	Consider the following.
**/

SELECT empid, ordermonth, val,
	SUM(val) OVER(PARTITION BY empid
				  ORDER BY ordermonth
				  ROWS BETWEEN UNBOUNDED PRECEDING
						   AND CURRENT ROW) AS runsum,
	MIN(val) OVER(PARTITION BY empid
				  ORDER BY ordermonth
				  ROWS BETWEEN UNBOUNDED PRECEDING
						   AND CURRENT ROW) AS runmin,
	MAX(val) OVER(PARTITION BY empid
				  ORDER BY ordermonth
				  ROWS BETWEEN UNBOUNDED PRECEDING
						   AND CURRENT ROW) AS runmax,
	AVG(val) OVER(PARTITION BY empid
				  ORDER BY ordermonth
				  ROWS BETWEEN UNBOUNDED PRECEDING
						   AND CURRENT ROW) AS runavg
FROM Sales.EmpOrders;

/**
	Here you have four window functions with identical window specifications.
	Using the WINDOW clause, you can shorten the query string like so:
**/
SELECT empid, ordermonth, val,
	SUM(val) OVER W AS runsum,
	MIN(val) OVER W AS runmin,
	MAX(val) OVER W AS runmax,
	AVG(val) OVER W AS runavg
FROM Sales.EmpOrders
WINDOW W AS (PARTITION BY empid
			 ORDER BY ordermonth
			 ROWS BETWEEN UNBOUNDED PRECEDING
					  AND CURRENT ROW);

/**	
	You can use the WINDOW clause to name part of a window specification.
	In such a case, when using the window name in an OVER clause you can
	specify it in parentheses at the beginning, before the remaining
	windowing elements.
**/
SELECT custid, orderid, val,
	FIRST_VALUE(val) OVER(PO
						  ROWS BETWEEN UNBOUNDED PRECEDING
								   AND CURRENT ROW) AS firstval,
	LAST_VALUE(val) OVER(PO
						 ROWS BETWEEN CURRENT ROW
								  AND UNBOUNDED FOLLOWING) AS lastval
FROM Sales.OrderValues
WINDOW PO AS (PARTITION BY custid
			  ORDER BY orderdate, orderid)
ORDER BY custid, orderdate, orderid;

/**
	In a similar way you can define multiple window names, and recursively
	reuse one window name within another.
**/
SELECT orderid, custid, orderdate, qty, val,
	ROW_NUMBER() OVER PO AS ordernum,
	MAX(orderdate) OVER P AS maxorderdate,
	SUM(qty) OVER POF AS runsumqty,
	SUM(val) OVER POF AS runsumval
FROM Sales.OrderValues
WINDOW P AS ( PARTITION BY custid ),
	   PO AS ( P ORDER BY orderdate, orderid ),
	   POF AS ( PO ROWS UNBOUNDED PRECEDING )
ORDER BY custid, orderdate, orderid;

----------------------------------------------------------
-- Pivoting Data
-- Involves rotating data from  a state of rows to a state
-- of columns, possibly aggregating values along the way.
--
-- In many cases, the pivoting of data is handled by the
-- presentation layer for purposes such as reporting.
----------------------------------------------------------
USE TSQLV6;

DROP TABLE IF EXISTS dbo.Orders;

CREATE TABLE dbo.Orders
(
	orderid		INT		NOT NULL
	   CONSTRAINT PK_Orders PRIMARY KEY,
	orderdate	DATE	NOT NULL,
	empid		INT		NOT NULL,
	custid		VARCHAR(5) NOT NULL,
	qty			INT		NOT NULL
);

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
VALUES
	(30001, '20200802', 3, 'A', 10),
	(10001, '20201224', 2, 'A', 12),
	(10005, '20201224', 1, 'B', 20),
	(40001, '20210109', 2, 'A', 40),
	(10006, '20210118', 1, 'C', 14),
	(20001, '20210212', 2, 'B', 12),
	(40005, '20220212', 3, 'A', 10),
	(20002, '20220216', 1, 'C', 20),
	(30003, '20220418', 2, 'B', 15),
	(30004, '20200418', 3, 'C', 22),
	(30007, '20220907', 3, 'D', 30);

SELECT * FROM dbo.Orders;

/**
	Suppose you need to query the above table and return the total
	order quantity for each employee and customer. The following
	grouped query achieves this task.
**/
SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid;

/**
	Suppose you have a requirement to produce the output, a pivoted
	view of total quantity per employee (on rows) and customer (on columns)

	Every pivoting request involves three logical processing phases, each
	with associated elements:
	1. A grouping phase with an associated grouping or on rows element
	2. A spreading phase with an associated spreading or on cols element
	3. An aggregation phase with an associated aggregation element and 
	   aggregate function.

	In summary, pivoting involves grouping, spreading and aggregating.
**/

---------------------------------------------------------------------
-- Pivoting with a grouped query
---------------------------------------------------------------------
-- The solution using a grouped query handles all three phases in 
-- an explicit and straightforward manner. 
--	1. The grouping phase is achieved with a GROUP BY clause-in this
--    case, GROUP BY empid.
--  2. The spreading phase is achieved in the SELECT clause with a
--    a CASE Expression for each target column.
--  3. Finally, the aggregation phase is achieved by applying the 
--	  relevant aggregate function (SUM, in this case) to the result
--    column for customer A.
---------------------------------------------------------------------
/**
	Complete solution query that pivots order data, returning the total
	quantity for each employee (on rows) and customer (on columns).
**/

SELECT * FROM dbo.Orders;

SELECT * FROM dbo.Orders
WHERE custid = 'A' AND empid = 2;

SELECT empid,
  SUM(CASE WHEN custid = 'A' THEN qty END) AS A,
  SUM(CASE WHEN custid = 'B' THEN qty END) AS B, 
  SUM(CASE WHEN custid = 'C' THEN qty END) AS C,
  SUM(CASE WHEN custid = 'D' THEN qty END) AS D
FROM dbo.Orders
GROUP BY empid;

---------------------------------------------------------------------
-- Pivoting with the PIVOT operator
---------------------------------------------------------------------
-- The solution for pivoting based on an explicit grouped query is
-- standard. T-SQL also supports a proprietary operator called PIVOT
-- that you can use to achieve pivoting in a more concise manner.
--
-- As a table operator, PIVOT operates in the context of the FROM
-- clause like any other table operator (for example, JOIN).
-- 
-- The PIVOT operator involves the same logical processing phases as
-- described earlier (grouping, spreading, and aggregating), only it
-- requires less code than the previous solution.
--
-- The general form of a query with the PIVOT operator is:
--	SELECT ...
--	FROM <input_table>
--		PIVOT(<agg_function>(<aggregation_element>)
--				FOR <spreading_element> IN (<list_of_target_columns>)) AS <result_table_alias>
--	WHERE ...;
---------------------------------------------------------------------
/**
	Solution query to the original pivoting request, using the PIVOT
	operator.
**/
SELECT empid, A, B, C, D
FROM (SELECT empid, custid, qty
	  FROM dbo.Orders) AS D
  PIVOT(SUM(qty) FOR custid IN(A, B, C, D)) AS P;

/**
	To understand why you're required to use table expressions, consider
	the following query, which applies the PIVOT operator directly to the
	dbo.Orders table.
**/
SELECT empid, A, B, C, D
FROM dbo.Orders
  PIVOT(SUM(qty) FOR custid IN(A, B, C, D)) AS P;

/**
	The logical equivalent of this query that uses the standard solution for
	pivoting has orderid, orderdate, and empid listed in the GROUP BY list as
	follows.
**/
SELECT empid,
  SUM(CASE WHEN custid = 'A' THEN qty END) AS A,
  SUM(CASE WHEN custid = 'B' THEN qty END) AS B,
  SUM(CASE WHEN custid = 'C' THEN qty END) AS C,
  SUM(CASE WHEN custid = 'D' THEN qty END) AS D
FROM dbo.Orders
GROUP BY orderid, orderdate, empid;

/**
	After you learn the "template" for a pivoting solution (with the
	grouped query or with the PIVOT operator), it's just a matter 
	of fitting those elements in the right places. The following 
	solution query uses the PIVOT operator to achieve the result.
**/
SELECT custid, [1], [2], [3]
FROM (SELECT empid, custid, qty
	  FROM dbo.Orders) AS D
	PIVOT(SUM(qty) FOR  empid IN([1], [2], [3])) AS P;