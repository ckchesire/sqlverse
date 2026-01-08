---------------------------------------------------------------------
-- Predicates and Operators
-- E.g IN, BETWEEN, and LIKE
-- Comparison Operators: =, >, <, >=, <>, !=, !>, and !<
-- Logical Operators include OR and AND. 
-- To negate an expression use the NOT Operator
-- Arithmetic Operators: +, -, *, and /. Supports % operator (modulo)
---------------------------------------------------------------------
SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderid IN(10248, 10249, 10250);

SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderid BETWEEN 10300 AND 10310;

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname LIKE N'D%';

SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderdate >= '20220101';

SELECT orderid, empid, orderdate
FROM Sales.Orders
WHERE orderdate >= '20220101'
	AND empid NOT IN(1, 3, 5);

SELECT orderid, productid, qty, unitprice, discount,
	qty * unitprice * (1 - discount) AS val
FROM Sales.OrderDetails;

/**
	The following list describes the precedence among operators, from
	highes to lowest:
		1. () (Parentheses)
		2. *(Multiplication), /(Division), %(Modulo)
		3. +(Positive), -(Negative), +(Addition), +(Concatenation), -(Subtraction)
		4. =, >, <, >=, <=, <>, !=, !>, !< (Comparison Operators)
		5. NOT
		6. AND
		7. BETWEEN, IN, LIKE, OR
		8. = (Assignement)
**/
SET STATISTICS IO ON;
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE 
	(	custid = 1
		AND empid IN(1, 3, 5) )
	OR 
	(	custid = 85
		AND empid IN(2, 4, 6) );

SELECT 10 + 2 * 3;
SELECT (10 + 2) * 3;