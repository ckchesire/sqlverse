USE TSQLV6;
--------------------------------------------------------------
-- Precedence
--------------------------------------------------------------
-- SQL defines precedence among set operators. The INTERSECT
-- operator precedes UNION and EXCEPT, and UNION and EXCEPT
-- are evaluated in order of appearance. Using the ALL variant
-- doesn't change the precedence. In a query that contains
-- multiple set operators, first INTERSECT operators are 
-- evaluated, and then operators with the same precedence are
-- evaluated based on their order of appearance.
--------------------------------------------------------------
/**
	Because INTERSECT precedes EXCEPT, the INTERSECT operator is evaluated
	first, even though it appears second in the code. The meaning of the 
	query is "locations that are supplier locations, but not(locations that
	are both employee and customer locations.)"
**/

SELECT country, region, city FROM Production.Suppliers
EXCEPT
SELECT country, region, city FROM HR.Employees
INTERSECT
SELECT country, region, city FROM Sales.Customers

/**
	To control the order of evaluation of set operators, use parentheses,
	because they have the highest precedence. Also, using parentheses
	increases the readability, thus reducing the chance for errors. For
	example, if you want "(locations that are supplier locations but 
	not employee locations) and that are also customer locations," use
	the following code.
**/
USE TSQLV6;
GO
(SELECT country, region, city FROM Production.Suppliers
 EXCEPT
 SELECT country, region, city FROM HR.Employees)
INTERSECT
SELECT country, region, city FROM Sales.Customers;