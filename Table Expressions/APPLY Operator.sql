------------------------------------------------------------
-- The APPLY Operator
------------------------------------------------------------
-- The APPLY operator is a powerful table operator. Like all
-- table operators, APPLY is used in the FROM clause of the
-- query.
-- There are two supported types of APPLY: CROSS APPLY and
-- OUTER APPLY. Like the JOIN table operator, APPLY performs
-- its work in logical-query phases. CROSS APPLY implements
-- only one logical-query processing, whereas OUTER APPLY
-- implements two.
--
-- NOTE: APPLY isn't standard; the standard counterpart is
-- called LATERAL, but the standard form wasn't implemented
-- in SQL Server.
------------------------------------------------------------
/**
	The APPLY operator operates on two input tables; I'll refer
	to them as the "left" and "right" tables. The right table is
	typically a derived table or a TVF. The CROSS APPLY operator
	implements one logical-query processing phase-it applies the
	right table to each row from the left table and produces a 
	result with the unified results sets.

	It might sound like the CROSS APPLY operator is similar to a
	cross join, and in a sense that's true. For example the
	following two queries return the same result sets.
**/
USE TSQLV6;
SELECT S.shipperid, E.empid
FROM Sales.Shippers AS S
  CROSS JOIN HR.Employees AS E;

SELECT S.shipperid, E.empid
FROM Sales.Shippers AS S
  CROSS APPLY HR.Employees AS E;

/**
	Remember that a join treats its two inputs as a set, and therefore there's no
	order between them. This means you cannot refer on one side to elements from the
	other. With APPLY, the left side is evaluated first, and the right side is 
	evaluated per row from the left. So the right side can have references to elements
	from the left. Those references are essentially correlations. In other words, you
	can think of APPLY as a correlated join.

	For example, the following code uses the CROSS APPLY operator to return the three
	most recent orders for each customer.
**/
SELECT C.custid, A.orderid, A.orderdate
FROM Sales.Customers AS C
  CROSS APPLY
     (SELECT TOP (3) orderid, empid, orderdate, requireddate
	  FROM Sales.Orders AS O
	  WHERE O.custid = C.custid
	  ORDER BY orderdate DESC, orderid DESC) AS A;
/**
	You can think of the table expression A as a correlated derived table. In terms
	of logical-query processing, the right table expression(a derived table, in this
	case) is applied to each row from the Customers table.
	
	Notice in the inner query's filter the reference to the attribute C.custid from the
	left table. The derived table returns the three most recent orders for the
	current customer from the left row, the CROSS APPLY operator returns the three
	most recent orders for each customer.
**/

-- You can also use the standard OFFSET-FETCH option instead of TOP, like this:
SELECT C.custid, A.orderid, A.orderdate
FROM Sales.Customers AS C
  CROSS APPLY
    (SELECT orderid, empid, orderdate, requireddate
	 FROM Sales.Orders AS O
	 WHERE O.custid = C.custid
	 ORDER BY orderdate DESC, orderid DESC
	 OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY) AS A;

/**
	If you want to return rows from the left side even if there are no matches
	on the right side, use OUTER APPLY. This operator has a second logical phase
	that preserves all left rows. It keeps the rows from the left side for which
	there are no matches on the right side, and it uses NULLs as placeholders on
	the right side.

	You probably noticed that, in the sense that OUTER APPLY preserves all left
	rows, it's similar to a LEFT OUTER JOIN. Because of the way APPLY works, there's
	no APPLY equivalent of a RIGHT OUTER JOIN.
**/
SELECT C.custid, A.orderid, A.orderdate
FROM Sales.Customers AS C
  OUTER APPLY
    (SELECT TOP (3) orderid, empid, orderdate, requireddate
	 FROM Sales.Orders AS O
	 WHERE O.custid = C.custid
	 ORDER BY orderdate DESC, orderid DESC) AS A;

/**
	You might find it more convenient with inline TVF instead of derived
	tables. This way, your code will be simpler to follow and maintain.

	For example, the following code creates an inline TVF called TopOrders
	that accepts as inputs a customer ID (@custid) and a number(@n), and
	returns the @n most recent orders for customer @custid:
**/

CREATE OR ALTER FUNCTION dbo.TopOrders
  (@custid AS INT, @n AS INT)
  RETURNS TABLE
AS
RETURN
  SELECT TOP (@n) orderid, empid, orderdate, requireddate
  FROM Sales.Orders
  WHERE custid = @custid
  ORDER BY orderdate DESC, orderid DESC;
GO

/**
	You can now substitute the use of the derived table from
	the previous examples with the new function:
**/
SELECT
  C.custid, C.companyname,
  A.orderid, A.empid, A.orderdate, A.requireddate
FROM Sales.Customers AS C
  CROSS APPLY dbo.TopOrders(C.custid, 3) AS A
  ORDER BY custid ASC, orderdate DESC, orderid DESC;