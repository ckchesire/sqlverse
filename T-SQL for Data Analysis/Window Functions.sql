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