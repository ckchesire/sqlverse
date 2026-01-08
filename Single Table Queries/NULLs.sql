--------------------------------------------------------------
-- NULLs
-- T-SQL supports the NULL marker to represent missing values
-- Uses three-valued predicate logic, meaning that predicates
-- can evaluate to TRUE, FALSE, or UNKNOWN.
-- SQL provides predicates IS NULL and IS NOT NULL to use instead
-- of = NULL and <> NULL
--------------------------------------------------------------

SELECT custid, country, region, city
FROM Sales.customers
WHERE region = N'WA';

/** 
	The IS NOT DISTINCT FROM is similar to the equality (=) operator,
	only it evaluates to TRUE when comparing two NULLs, and FALSE when
	comparing a NULL with a non-NULL value.
**/
SELECT custid, country, region, city
FROM Sales.Customers
WHERE region IS NOT DISTINCT FROM N'WA';


SELECT custid, country, region, city
FROM Sales.Customers
WHERE region = @region
	OR (region IS NULL  AND @region IS NULL);

SELECT custid, country, region, city
FROM Sales.Customers
WHERE region IS NOT DISTINCT FROM @region;


SELECT custid, country, region, city
FROM Sales.Customers
WHERE region <> N'WA';

/**
	If you return all rows for which region is NULL, do not use the predicate region=NULL,
	because the expression evaluates to UNKNOWN in all rows - both those in which the value
	is present and those in which the value is missing(is NULL).
**/
SELECT custid, country, region, city
FROM Sales.Customers
WHERE region = NULL;

/**
	Instead use IS NULL predicate
**/
SELECT custid, country, region, city
FROM Sales.Customers
WHERE region IS NULL;

SELECT custid, country, region, city
FROM Sales.Customers
WHERE region <> N'WA'
	OR region IS NULL;

/**
	The IS DISTINCT FROM predicate is similar to the different than (<>) operator,
	only it evaluates FALSE when comparing two NULLs, and to TRUE when comparing 
	NULL with a non-NULL value.
**/
SELECT custid, country, region, city
FROM Sales.Customers
WHERE region IS DISTINCT FROM N'WA';

SELECT custid, country, region, city
FROM Sales.Customers
WHERE region <> @region
	OR (region IS NULL AND @region IS NOT NULL)
	OR (region IS NOT NULL AND @region IS NULL);

SELECT custid, country, region, city
FROM Sales.Customers
WHERE region IS DISTINCT FROM @region;
