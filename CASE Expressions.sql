---------------------------------------------------------------------
-- CASE Expressions
-- CASE is a scalar expression with two forms : simple and searched
-- TSQL supports some functions you can consider abbreviations of the
-- CASE expression: ISNULL, COALESCE, IIF, and CHOOSE. Only COALESCE
-- is standard
---------------------------------------------------------------------

/** Simple CASE form **/
SELECT supplierid, COUNT(*) AS numproducts,
	CASE  COUNT(*) % 2
		WHEN 0 THEN 'Even'
		WHEN 1 THEN 'Odd'
		ELSE 'Unknown'
	END AS countparity
FROM Production.Products
GROUP BY supplierid;

/** Searched CASE form **/
SELECT orderid, custid, val, 
	CASE
		WHEN val < 1000.00 THEN  'Less than 1000'
		WHEN val <= 3000.00 THEN 'Between 1000 and 3000'
		WHEN val > 3000.00 THEN 'More than 3000'
		ELSE 'Unknown'
	END AS valuecategory
FROM Sales.OrderValues;

