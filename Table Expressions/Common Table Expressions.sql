USE TSQLV6;
--------------------------------------------------------------------
-- Common Table Expressions
--------------------------------------------------------------------
-- Common table expressions(CTEs) are another standard form of table
-- expressions similar to derived tables, yet with a couple of
-- important advantages.
-- CTEs are defined by using a WITH statement and have the following
-- general form:
--		WITH <CTE_Name>[(<target_column_list>)]
--		AS
--		(
--			<inner_query_defining_CTE>
--		)
--		<outer_query_against_CTE>;
--------------------------------------------------------------------
/**
	The following code defines a CTE called USACusts based on a query
	that returns all customers from the United States, and the outer
	query selects all rows from the CTE.

	Note: As with derived tables, as soon as the outer query finishes,
		  the CTE goes out of scope.
**/
WITH USACusts AS
(
	SELECT custid, companyname
	FROM Sales.Customers
	WHERE country = N'USA'
)
SELECT * FROM USACusts;

----------------------------------------------------------------------
-- Assigning Column Aliases in CTEs
----------------------------------------------------------------------
-- CTEs also support two forms of column aliasing: inline and external
-- For the inline form, specify:
--		<expression> AS <column_alias>
-- For the external form, specify the target column list in parentheses
-- immediately after the CTE name.
----------------------------------------------------------------------
/**
	Example of the inline form:
**/
WITH C AS
(
  SELECT YEAR(orderdate) AS orderyear, custid
  FROM Sales.Orders
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;

/**
	Example of the external form:
**/
WITH C(orderyear, custid) AS 
(
	SELECT YEAR(orderdate), custid
	FROM Sales.Orders
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;

--------------------------------------------------------------------
-- Using Arguments in CTEs
--------------------------------------------------------------------
-- As with derived queries, you can also use arguments in the inner
-- query used to define a CTE.
--------------------------------------------------------------------
DECLARE @empid AS INT = 3;

WITH C AS
(
  SELECT YEAR(orderdate) AS orderyear, custid
  FROM Sales.Orders
  WHERE empid = @empid
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;

---------------------------------------------------------------------
-- Defining multiple CTEs
---------------------------------------------------------------------
-- On the surface, the difference between derived tables and CTEs
-- might seem to be merely semantic. However, the fact that you first
-- name and define a CTE and then use it gives it several important
-- advantages over derived tables.
-- One advantage is that if you need to refer to one CTE from another,
-- you don't nest them; rather, you separate them by commas. Each
-- CTE can refer to all previously defined CTEs, and the outer query
-- can refer to all CTEs.
---------------------------------------------------------------------
/**
	For example, the following code is the CTE alternative to the 
	nested derived tables approach.
**/
WITH C1 AS
(
  SELECT YEAR(orderdate) AS orderyear, custid
  FROM Sales.Orders
),
C2 AS
(
  SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
  FROM C1
  GROUP BY orderyear
)
SELECT orderyear, numcusts
FROM C2
WHERE numcusts > 70;
/**
	This modular approach substantially improves the readability
	and maintainability of the code compared to the nested
	derived-table approach.

	Note: That even if you want to, you cannot nest CTEs in T-SQL,
	nor can you define a CTE within the parentheses of a derived
	table.
**/

---------------------------------------------------------------------
-- Multiple References In CTEs
---------------------------------------------------------------------
-- The fact that a CTE is named and defined first and then queried 
-- has another advantage; as far as the FROM clause of the outer 
-- query is concerned, the CTE already exists; therefore, you can
-- refer to multiple instances of the same CTE in table operators 
-- like joins.
---------------------------------------------------------------------
/**
	For example, the following code is the CTE alternative to the
	solution shown earlier with derived tables.

	The CTE YearlyCount is defined only once and accessed twice in
	the FROM clause of the outer query - once as Cur and once as Prv.
	You need to maintain only one copy of the inner query(the code
	inside the CTE). The solution is clearer and less prone to errors.
**/
WITH YearlyCount AS
(
	SELECT YEAR(orderdate) AS orderyear,
	  COUNT(DISTINCT custid) AS numcusts
	FROM Sales.Orders
	GROUP BY YEAR(orderdate)
)
SELECT Cur.orderyear,
	Cur.numcusts AS curnumcusts, Prv.numcusts AS prvnumcusts,
	Cur.numcusts - Prv.numcusts AS growth
FROM YearlyCount AS Cur
	LEFT OUTER JOIN YearlyCount As Prv
	  ON Cur.orderyear = Prv.orderyear + 1;

----------------------------------------------------------------------
-- Recursive CTEs
----------------------------------------------------------------------
-- CTEs are unique among table expressions in the sense that they
-- support recursion. Recursive CTEs, like nonrecursive ones, are
-- defined by the SQL standard. A recursive CTE is defined by atleast
-- two queries(more are possible)-at least one query known as the 
-- anchor member and at least one query known as the recursive member
-- The general form of a basic recursive CTE looks like the following.
--		WITH <CTE_NAME>[(<target_column_list>)]
--		AS
--		(
--			<anchor_member>
--			UNION ALL
--			<recursive_member>
--		)
--		<outer_query_against_CTE>;
--
-- The anchor member is a query that returns a valid relational result
-- table-like a query that is used to define a nonrecursive table
-- expression. The anchor member query is invoked only once.
-- 
-- The recursive member is a query that has a reference to the CTE 
-- name and is invoked repeatedly until it returns an empty set.
----------------------------------------------------------------------
/**
	The following code demonstrates how to return information about
	an employee(Don Funk, employee ID 2) and all the employee's
	subordinates at all levels(direct or indirect).
**/
WITH EmpsCTE AS
(
  -- The anchor member queries the HR.Employees table and simply returns the row for employee 2
  SELECT empid, mgrid, firstname, lastname, title
  FROM HR.Employees
  WHERE empid = 2

  UNION ALL

  -- The recursive member joins the CTE - representing the previous result set - with the Employees
  -- table to return the direct subordinates of the employees returned in the previous result set.
  SELECT C.empid, C.mgrid, C.firstname, C.lastname, C.title
  FROM EmpsCTE AS P
	INNER JOIN HR.Employees AS C
	  ON C.mgrid = P.empid
)
SELECT empid, mgrid, firstname, lastname, title
FROM EmpsCTE;

SELECT empid, mgrid, firstname, lastname, title 
FROM HR.Employees
ORDER BY mgrid;

/**

	Note: SQL server restricts the number of times the recursive
	member can be invoked to 100 by default.

	You can change the default maximum recursion limit(that is, the
	number of times the recursive member can be invoked) by specifying
	the hint OPTION(MAXRECURSION n) at the end of the outer query,
	where n is an integer in the range 0 through 32,767.

	If you want to remove the restriction altogether, specify
	MAXRECURSION 0. Note that SQL Server stores the intermediate
	result sets returned by the anchor and recursive members in a 
	work table in tempdb; if you remove the restriction and have a
	runaway query, the work table will quickly get very large, and
	the query will never finish.
**/
