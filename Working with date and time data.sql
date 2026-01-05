---------------------------------------------------------------
-- Date and time data types
-- T-SQL supports six date and time data types: DATETIME and 
-- SMALLDATETIME, which are considered legacy types, as well as
-- DATE, TIME, DATETIME2 and DATETIMEOFFSET.
---------------------------------------------------------------
USE TSQLV6;

---------------------------------------------------------------
-- Literals
-- T-SQL doesn't provide the means to express a date and time
-- literal; instead you can specify a literal of a different
-- type that can be converted-explicitly or implicitly-to date
-- and time data type.
-- It is best practice to use character strings to express date
-- and time values.
---------------------------------------------------------------

/**
	Here the VARCHAR literal is converted into to the column's data 
	type(DATE) because character strings are considered lower in terms
	data-type precedence with respect to date and time data types.
**/
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE orderdate = '20220212';

/**
	This query is logically equivalent to the following one, which 
	explicitly converts the character string to a DATE data type
**/
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE orderdate = CAST('20220212' AS DATE);

/**
	You can override the default language in your session by using
	the SET LANGUAGE command.
**/
SELECT * FROM sys.syslanguages;
-- Check current session language
SELECT @@LANGUAGE AS CurrentLanguage
GO

/**
	The output literal is interpreted differently in the two language
	environments.

	Note: The LANGUAGE/DATEFORMAT setting affects only the way the values
	you enter are interpreted. These settings have no impact on the format
	used in the output for presentation purposes.
**/
SET LANGUAGE British; --dmy
SELECT CAST('02/12/2022' AS DATE);

SET LANGUAGE us_english;--mdy
SELECT CAST('02/12/2022' AS DATE);

/**
	The language setting has no impact on how a literal expressed
	with the format 'YYYYMMDD' is interpreted when it is converted
	to DATE.

	Note: Using language-neutral formats such as 'YYYYMMDD' is a 
	best practice, because such formats are interpreted the same
	way regardless of the LANGUAGE/DATEFORMAT settings.
**/
SET LANGUAGE British;
SELECT CAST('20220212' AS DATE);

SET LANGUAGE us_english;
SELECT CAST('20220212' AS DATE);

/**
	Using CONVERT function to explicitly convert the character-string
	literal to the requested data type, in the third argument, specify
	a number representing the style you used.

	The following is a query to specify the literal '02/12/2022' with
	the format MM/DD/YYYY, use style number 101.
**/
SELECT CONVERT(DATE, '02/12/2022', 101);

-- If you want to use the  format DD/MM/YYYY, use style number 103
SELECT CONVERT(DATE, '02/12/2022', 103);

/**
	Another option is to use the PARSE function. By using this function
	you can parse a value as a requested type and indicate the culture.

	The following query is the equivalent of using CONVERT with style
	101(US English)

	Note: The PARSE function is significantly more expensive than the
	CONVERT function, it's generally recommended to refrain from using
	it.
**/
SELECT PARSE('02/12/2022' AS DATE USING 'en-US');

-- Equivalent to using CONVERT with style 103 (British English)
SELECT PARSE('02/12/2022' AS DATE USING 'en-GB');

--------------------------------------------------------------------------
-- Working with date and time separately
-- If you need to work with only dates or only times, it's recommended
-- that you use the DATE and TIME data types, respectively.
--------------------------------------------------------------------------

DROP TABLE IF EXISTS Sales.Orders2;

SELECT orderid, custid, empid, CAST(orderdate AS DATETIME) AS orderdate
INTO Sales.Orders2
FROM Sales.Orders;

SELECT TOP 2 * FROM Sales.Orders;
SELECT TOP 2 * FROM Sales.Orders2;

-- Filter orders from a certain date using the equality operator
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders2
WHERE orderdate = '20220212';


SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE orderdate = '20220212';

/**
	When SQL Server converts a character-string literal that has
	only a date to DATETIME, it assumes midnight by default.

	Adding a CHECK constraint to ensure that only midnight is used
	for the time part.

	The CONVERT function extracts the time-only portion of the 
	orderdate value as a character string using style 114. The 
	CHECK constraint verifies that the string represents midnight.
**/
ALTER TABLE Sales.Orders2
	ADD CONSTRAINT CHK_Orders2_orderdate
	CHECK( CONVERT(CHAR(12), orderdate, 114) = '00:00:00:000' );

/**
	If the time component is stored with nonmidnight values, one
	can use a range filter like this:
**/
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders2
WHERE orderdate >= '20220212'
	AND orderdate < '20220213';

/**
	When SQL Server converts a character-string literal that contains
	only a time component to DATETIME or SMALLDATETIME, SQL Server
	assumes that the date is the base date i.e January 1,1900.
**/
SELECT CAST('12:30:15.123' AS DATETIME);

-- Code Cleanup
DROP TABLE IF EXISTS Sales.Orders2;