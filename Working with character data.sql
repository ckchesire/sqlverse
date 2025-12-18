-----------------------------------------------------------------------
-- We cover query manipulation of character data including: data types,
-- collations, and operators and functions, and pattern matching.
-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- Data types, SQL Server supports two kinds the regular kind and the 
-- N-Kind. The regular kind pair includes CHAR and VARCHAR, and the 
-- N-KIND includes NCHAR and NVARCHAR.
-----------------------------------------------------------------------

------------------------------------------------------------------------
-- Collation is a property of character data that encapsulates several:
-- language support, sort order, case sensitivity, and more.
------------------------------------------------------------------------

SELECT name, description
FROM sys.fn_helpcollations();

/**
	In an on-premises SQL Server implementation and Azure SQL Managed Instance
	; collation can be defined at four different levels: instance, database,
	column and expression.
**/

/**
	You can convert the collation of an expression by using the COLLATE clause.
	For example, in a case-insensitive environment, the following query uses a
	case-insensitive comparison:
**/

SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname = N'davis';

/**
	If you want to make the filter case insensitive even though the column's 
	collation is case insensitive, you can convert the collation of the 
	expression.
**/
SELECT empid, firstname, lastname
FROM HR.Employees
WHERE lastname COLLATE Latin1_General_CS_AS = N'davis';

/**
	This time the query returns an empty set because no match is found when
	a case-sensitive comparison is used
**/

------------------------------------------------------------------------------
-- Operators and Functions
------------------------------------------------------------------------------
-- For string concatenation, T-SQL provides the plus-sign (+) operator and 
-- the CONCAT and CONCAT_WS functions.

-- For the operations on character strings, T-SQL provides several functions, 
-- including SUB-STRING, LEFT, RIGHT, LEN, DATALENGTH, CHARINDEX, PATINDEX, 
-- REPLACE, TRANSLATE, REPLICATE, STUFF, UPPER, LOWER, RTRIM, LTRIM, TRIM, 
-- FORMAT, COMPRESS, DECOMPRESS, STRING_SPLIT, and STRING_AGG 


----------------------------------------------------------------------------
-- String concantenation (plus-sign [+] operator and CONCAT and CONCAT_WS
-- functions).
----------------------------------------------------------------------------

SELECT empid, firstname + N' ' + lastname AS fullname
FROM HR.Employees;

/**
	Standard SQL dictates that a concatenation with a NULL should yield a NULL.
**/
SELECT custid, country, region, city,
country + N',' + region + N',' + city AS location
FROM Sales.Customers;

/**
	To treat a NULL as an empty string, mainly substitute a NULL with an empty
	string, you can use the COALESCE function. This function accepts a list of
	input values and returns the first that is not NULL.
**/
SELECT custid, country, region, city,
	country + COALESCE(N',' + region, N'') + N',' + city AS location
FROM Sales.Customers;

/**
	T-SQL supports a function called CONCAT, which accepts a list of inputs for
	concatenation and automatically substitutes NULLs with empty strings. For
	example, the expression CONCAT('a',NULL,'b') returns the string 'ab'.
**/
SELECT custid, country, region, city,
	CONCAT(country, N',' + region, N',' + city) AS location
FROM Sales.Customers;

/**
	T-SQL also supports a function called CONCAT_WS, which accepts the separator as
	the first parameter, specifying it only once, and then the list of inputs for
	concatenation.
**/
SELECT custid, country, region, city,
	CONCAT_WS(N',', country, region, city) AS location
FROM Sales.Customers;