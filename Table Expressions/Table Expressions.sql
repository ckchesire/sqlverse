USE TSQLV6;
----------------------------------------------------------------
-- Table Expressions
----------------------------------------------------------------
-- A table expression is an expression-typically a query-that
-- conceptually returns a table result and as such can be nested
-- as an operand of another table expression.
-- Recall that a table in SQL is the counterpart to a relation
-- in relational theory. A table expression is therefore SQL's
-- counterpart to a relational expression.
-- A relational expression in relational theory is an expression
-- that returns a relation and as such can be nested as an
-- operand of another relational expression.
-- T-SQL supports four types of named table expressions:
--		1.) Derived tables
--		2.) Common Table Expressions(CTEs)
--		3.) Views
--		4.) Inline Table-Valued Functions(inline TVFs)
-- Table expressions are not physically materialized anywhere, 
-- they are virtual. When you query a table expression, the 
-- inner query gets unnested. In other words, the outer query
-- and the inner query are merged into one query directly against
-- the underlying objects.
-- We also cover the APPLY table operator as it is used in
-- conjuction with a table expression. 
----------------------------------------------------------------


----------------------------------------------------------------
-- Derived Tables
----------------------------------------------------------------
-- Derived tables are defined in the FROM clause of an outer
-- query. Their scope of existence is the outer query. As soon
-- as the outer query is finished, the derived table is gone.
----------------------------------------------------------------
/**
	You specify the query that defines the derived table within
	parantheses, followed by the AS clause and the derived table
	name. For example, the following code defines a derived table
	called USACusts based on a query that returns all customers 
	from the United States, and the outer query selects all rows 
	from the derived table
**/
USE TSQLV6;

SELECT *
FROM (SELECT custid, companyname
	  FROM Sales.Customers
	  WHERE country = N'USA') AS USACusts;

/**
	With all types of table expressions, a query must meet three requirements
	to be a valid inner query in a table-expression definition:
	 1.) Order is not guaranteed - A table expression is supposed to represent
		a table, and the rows in a table have no guaranteed order. This aspect
		of a relation stems from set theory.
	 2.) All columns must have names - All columns in a table must have names;
	    therefore, you must assign column aliases to all expressions in the
		SELECT list of the query that is used to define a table expression.
	 3.) All column names must be unique - All column names in a table must be
	    unique; therefore a table expression that has multiple columns with the
		same name is invalid.

	All three requirements are related to the fact that the table expression is
	supposed to represent a table - SQL's counterpart to a relation. All relation
	attributes must have names; all attribute names must be unique; and, because
	the relation's body is a set of tuples, there's no order.
**/

------------------------------------------------------------------
-- Assigning Column Aliases
------------------------------------------------------------------
-- One of the benefits of using table expressions is that, in 
-- any clause of the outer query, you can refer to column aliases 
-- that were assigned in the SELECT clause of the inner query.
------------------------------------------------------------------
/**
	For example, suppose you need to write a query against the Sales.Orders
	table and return the number of distinct customers handled in each order
	year. The following attempt is invalid because the GROUP BY clause refers
	to a column alias that was assigned in the SELECT clause, and the GROUP
	BY clause is logically processed prior to the SELECT clause.
**/
SELECT
  YEAR(orderdate) AS orderyear,
  COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY orderyear;

/**
	You can resolve the problem by referring to the expression YEAR(orderdate)
	in both the GROUP BY and SELECT clauses.
**/
SELECT
  YEAR(orderdate) AS orderyear,
  COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY YEAR(orderdate);

/**
	However, this  is an example with a short expression.
	What if the expression is much longer and you want to
	avoid the repetition of the code? You can achieve this
	using table expressions, as shown below:
**/
-- Query with a derived table using inline aliasing form
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM (SELECT YEAR(orderdate) AS orderyear, custid
	  FROM Sales.Orders) AS D
GROUP BY orderyear;

/**
	Note: We usually use table expressions for logical(not
	performance-related) reasons.

	The syntax for inline aliasing is <expression> [AS] <alias>.

	In some cases, you might prefer to use a second aliasing form,
	which you can think of as external aliasing. With this form, you
	do not assign column aliases following the expressions in the
	SELECT list - you specify all target column names (not only the
	aliased ones) in parantheses following the table expression's name,
	like so:
**/
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM (SELECT YEAR(orderdate), custid
	  FROM Sales.Orders) AS D(orderyear, custid)
GROUP BY orderyear;

------------------------------------------------------------------
-- Using Arguments
------------------------------------------------------------------
-- In the query that defines a derived table, you can refer to 
-- arguments. The arguments can be local variables and input 
-- parameters to a routine such as a stored procedure or function
------------------------------------------------------------------
/**
	For example, the following code declares and initializes a
	variable called @empid, and the query in the derived table D
	refers to that variable in the WHERE clause.

	This query returns the number of distinct customers per year
	whose orders were handled by the input employee(the employee
	whose ID is stored in the variable @empid, in this case employee
	ID 3).
**/
DECLARE @empid AS INT = 3;

SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM (SELECT YEAR(orderdate) AS orderyear, custid
	  FROM Sales.Orders
	  WHERE empid = @empid) AS D
GROUP BY orderyear;

--------------------------------------------------------------------
-- Nesting
--------------------------------------------------------------------
-- If you need to define a derived table based on a query that 
-- itself is based on a derived table, you can nest those.
-- Nesting tends to complicate the code and reduces its readability.
--------------------------------------------------------------------
/**
	Return order years and the number of customers handled in each
	year only for years in which more than 70 customers were handled.
**/
SELECT orderyear, numcusts
FROM (SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
	  FROM (SELECT YEAR(orderdate) AS orderyear, custid
	        FROM Sales.Orders) AS D1
	  GROUP BY orderyear) AS D2
WHERE numcusts > 70;

/**
	The whole purpose of using table expressions here is to simplify
	the code by reusing column aliases. However, with the complexity
	added by the nesting, its uncertain whether that solution is
	really simpler the the alternative without table expressions.
**/
SELECT YEAR(orderdate) AS orderyear, COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY YEAR(orderdate)
HAVING COUNT(DISTINCT custid) > 70;

--------------------------------------------------------------------
-- Multiple References
--------------------------------------------------------------------
-- Another problematic aspect of derived tables is related to cases
-- where you need to join multiple instances of the same one. A join
-- treats its two inputs as a set, and as you know, a set has no
-- order to its elements. This means that if you define a derived
-- table and alias it as one input of the join, you can't refer to
-- the same alias in the other input of the join.
--------------------------------------------------------------------
/**
	Multiple derived tables based on the same query
**/
SELECT Cur.orderyear,
  Cur.numcusts AS curnumcusts, Prv.numcusts AS prvnumcusts,
  Cur.numcusts - Prv.numcusts AS growth
FROM (SELECT YEAR(orderdate) AS orderyear,
		COUNT(DISTINCT custid) AS numcusts
	 FROM Sales.Orders
	 GROUP BY YEAR(orderdate)) AS Cur
  LEFT OUTER JOIN
	 (SELECT YEAR(orderdate) AS orderyear,
		COUNT(DISTINCT custid) AS numcusts
	  FROM Sales.Orders
	  GROUP BY YEAR(orderdate)) AS Prv
  ON Cur.orderyear = Prv.orderyear + 1;

/**
	Using LAG window function.
**/
SELECT
	orderyear,
	numcusts AS curnumcusts,
	LAG(numcusts) OVER(ORDER BY orderyear) AS prvnumcusts,
	numcusts - LAG(numcusts) OVER (ORDER BY orderyear) AS growth
FROM (
	SELECT
		YEAR(orderdate) AS orderyear,
		COUNT(DISTINCT custid) AS numcusts
	FROM Sales.Orders
	GROUP BY YEAR(orderdate)
) AS Y;