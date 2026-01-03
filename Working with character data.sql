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

------------------------------------------------------------------------------
-- SUBSTRING function extracts a substring from a string
-- Syntax : SUBSTRING(string,start,length)
------------------------------------------------------------------------------
SELECT SUBSTRING('abcde', 1, 3);


------------------------------------------------------------------------------
-- LEFT and RIGHT functions
-- Syntax : LEFT(string, n), RIGHT(string, n)
------------------------------------------------------------------------------
SELECT RIGHT('abcde', 3);
SELECT LEFT('abcde', 2);

-------------------------------------------------------------------------------
-- LEN and DATALENGTH functions
-- The LEN function returns the number of characters in the input string.
-- To get the number of bytes use the DATALENGTH function.
-------------------------------------------------------------------------------
SELECT LEN(N'abcde');
SELECT DATALENGTH(N'abcde');

---------------------------------------------------------------------------------
-- CHARINDEX function, returns the position of the first occurence of a substring
-- within a string.
-- Syntax: CHARINDEX(substring, string[,start_pos])
---------------------------------------------------------------------------------
SELECT CHARINDEX('G', 'Itzik Ben-Gan');

-------------------------------------------------------------------------------
-- PATINDEX function, returns the position of the first occurence of a pattern
-- within a string.
-- Syntax: PATINDEX(pattern, string)
-------------------------------------------------------------------------------
SELECT PATINDEX('%[0-9]%', 'abcd123efgh');

-------------------------------------------------------------------------------
-- REPLACE function replaces all occurences of a substring with another
-- Syntax: REPLACE(string,substring1,substring2)
-------------------------------------------------------------------------------
SELECT REPLACE('1-a 2-b 3-c 4-d', '-', ':');

/**
	You can use the REPLACE function to count the number of occurences of a
	character within a string.
**/
SELECT empid, lastname,
	LEN(lastname) - LEN(REPLACE(lastname, 'e', '')) AS numoccur
FROM HR.Employees;

-------------------------------------------------------------------------------
-- TRANSLATE Function, replaces in the string parameter all occurences of the 
-- individual characters in the characters parameter with the respective
-- individual characters in the translations paremeter.
-- Syntax: TRANSLATE(string,characters,translations)
-------------------------------------------------------------------------------
SELECT REPLACE(REPLACE('123.456.789,00', '.', ','), ',', '.')

SELECT REPLACE(REPLACE(REPLACE('123.456.789,00', '.', '~'), ',', '.'), '~', ',');

/**
	Using TRANSLATE
**/
SELECT TRANSLATE('123.456.789,00', '.,', ',.');

---------------------------------------------------------------------------
-- The REPLICATE function replicates a string a requested number of times
-- Syntax: REPLICATE(string, n)
---------------------------------------------------------------------------
SELECT REPLICATE('abc', 3);

/**
	The following demonstrates the use of the REPLICATE function, along with
	the RIGHT function and string concatenation.

	The following query runs against the Productions.Suppliers table generates
	a 10-digit string representation of the supplier ID integer with leading
	zeros
**/
SELECT supplierid,
	RIGHT(REPLICATE('0', 9) + CAST(supplierid AS VARCHAR(10)), 10) AS strsupplierid
FROM Production.Suppliers;

-----------------------------------------------------------------------------
-- The STUFF function to remove a substring from a string and insert a new 
-- substring instead.
-- Syntax: STUFF(string,pos,delete_length,insert_string)
-----------------------------------------------------------------------------
SELECT STUFF('xyz', 2, 1, 'abc');

/** Delete length of 0 **/
SELECT STUFF('xyz', 2, 0, 'abc');

----------------------------------------------------------------------------
-- The UPPER and LOWER functions return the input string with all uppercase
-- or lowercase characters respectively.
-- Syntax: UPPER(string), LOWER(string)
----------------------------------------------------------------------------

SELECT UPPER('Christian Chesire');

SELECT LOWER('Christian Chesire');
