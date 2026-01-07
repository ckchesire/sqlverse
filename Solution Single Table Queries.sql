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
FROM Sales.Orders;

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

