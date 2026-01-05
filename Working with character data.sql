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

---------------------------------------------------------------------------------
-- RTRIM, LTRIM, and TRIM functions.
-- The various trim functions allow you to remove leading, trailing, or both
-- leading and trailing characters from an input string. 
-- The RTRIM and LTRIM functions return the input string with leading or trailing
-- spaces removed, respectively.
-- Syntax: RTRIM(string), LTRIM(string)
----------------------------------------------------------------------------------
/**
	Remove both leading and trailing spaces
**/

SELECT RTRIM(LTRIM('    abc     '));

/**
	Simpler option is to use the TRIM option
**/
SELECT TRIM('    abc   ');

--------------------------------------------------------------------------------
-- The TRIM function has more sophisticated capabilities
-- Syntax: TRIM([characters FROM]string)
-- Enhanced TRIM function's syntax
-- Syntax: TRIM([LEADING|TRAILING|BOTH][characters FROM]string)
-- As for RTRIM and LTRIM functions, here is their enhanced syntax
-- RTRIM(string,[characters]), LTRIM(string,[characters])
--------------------------------------------------------------------------------
SELECT
	TRANSLATE(TRIM(TRANSLATE(TRIM(TRANSLATE(
	'//\\ remove leading and trailing backward (\) and forward (/) slashes \\//',
	' /', '~ ')), ' \', '^ ')), ' ^~', '\/ ')
	AS outputstring;

SELECT TRIM( '/\'
			 FROM '//\\ remove leading and trailing backward (\) and forward (/) slashes  \\//' )
		AS outputstring;

/**
	Instead of using:
	RTRIM(string, [characters])

	You can use:
	TRIM(TRAILING [characters FROM] string)

	And instead of using:
	LTRIM(string, [characters])

	You can use:
	TRIM(LEADING [characters FROM] string)
**/

SELECT TRIM( LEADING '/\'
			 FROM '//\\ remove leading and trailing backward (\) and forward (/) slashes  \\//' )
		AS outputstring;

SELECT TRIM( TRAILING '/\'
			 FROM '//\\ remove leading and trailing backward (\) and forward (/) slashes  \\//' )
		AS outputstring;

SELECT TRIM( BOTH '/\'
			 FROM '//\\ remove leading and trailing backward (\) and forward (/) slashes  \\//' )
		AS outputstring;

-----------------------------------------------------------------------------------------
-- FORMAT function can be used to format an input value as a character string based on a 
-- Microsoft.NET format string and an optional culture specification.
-- Syntax: FORMAT(input,format_string,culture)
-----------------------------------------------------------------------------------------
SELECT supplierid,
	RIGHT(REPLICATE('0', 9) + CAST(supplierid AS VARCHAR(10)), 10) AS strsupplierid
FROM Production.Suppliers;

-- SELECT FORMAT(1759, '0000000000');
/**
	The FORMAT function is usually more expensive than alternative T-SQL functions
	that you use to format values. You should generally refrain from using it unless
	you are willing to accept the performance penalty.
**/
SELECT supplierid,
	FORMAT(supplierid, '0000000000') AS strsupplierid
FROM Production.Suppliers;

SELECT supplierid,
	FORMAT(supplierid, 'd10') AS strsupplierid
FROM Production.Suppliers;


----------------------------------------------------------------------------
-- The COMPRESS and DECOMPRESS functions, use the GZIP algorithm to compress
-- and decompress the input, respectively.
-- Syntax: COMPRESS(string), DECOMPRESS(string)
----------------------------------------------------------------------------
/**
	The COMPRESS function accepts a character or binary string as an input
	and returns a compressed VARBINARY(MAX) typed value.
**/
SELECT COMPRESS(N'This is my cv. Imagine it was much longer.');

/**
	Apply COMPRESS function to the input value and store result in a table
**/
INSERT INTO dbo.EmployeeCVs( empid, cv ) VALUES( @empid, COMPRESS(@cv) );

/**
	The DECOMPRESS function accepts a binary string as input and returns
	a decompressed VARBINARY(MAX) typed value.

	Note: if the value you originally compressed was of character string
	type, you will need to explicitly cast the result of the DECOMPRESS
	function to the target type
**/
SELECT DECOMPRESS(COMPRESS(N'This is my cv. Imagine it was much longer.'));

SELECT
	CAST(
		DECOMPRESS(COMPRESS(N'This is my cv. Imagine it was much longer.'))
			AS NVARCHAR(MAX));

/**
	Consider the EmployeeCVs table from the earlier example. To return the uncompressed
	form of the employee resume, use the following query.
**/
SELECT empid, CAST(DECOMPRESS(cv) AS NVARCHAR(MAX)) AS cv
FROM dbo.EmployeeCVs;

-----------------------------------------------------------------------------------
-- The STRING_SPLIT table function splits an input string with a separated list of 
-- values into individual elements.
-- Syntax: SELECT value FROM STRING_SPLIT(string, separator[,enable_ordinal]);
-----------------------------------------------------------------------------------
SELECT CAST(value AS INT) AS myvalue
FROM STRING_SPLIT('10248,10249,10250', ',') AS S;

/**
	In case you are using SQL Server 2022 or later, here's an example with the ordinal
	flag enabled.
**/
SELECT CAST(value AS INT) AS myvalue, ordinal
FROM STRING_SPLIT('10248,10249,10250', ',', 1) AS S;


-------------------------------------------------------------------------------------
-- The STRING_AGG function concatenates the values of the input expression in the
-- aggregated group. You can think of it as the inverse of the STRING_SPLIT function.
-- Syntax: STRING_AGG(input, separator)[WITHIN GROUP(order_specification)]
-------------------------------------------------------------------------------------
/**
	The function concatenates the values of the input argument expression in the
	target group, separated by the separator argument.To guarantee the order of
	concatenation, you specify the optional WITHIN GROUP clause along with the desired
	ordering specification.

	As an example, the following query returns the order IDs for each customer, ordered
	by recency, using a comma as a separator.
**/
SELECT custid,
	STRING_AGG(CAST(orderid AS VARCHAR(10)), ',')
		WITHIN GROUP(ORDER BY orderdate DESC, orderid DESC) AS custorders
FROM Sales.Orders
GROUP BY custid;


----------------------------------------------------------------------------------------
-- The LIKE Predicate
-- T-SQL provides a predicate called LIKE that you can use to check whether a character
-- string matches a specified pattern. Similar patterns are use by the PATINDEX function
----------------------------------------------------------------------------------------
-- The %(percent) wildcard
-- The percent sign represents a string of any size, including an empty string.
---------------------------------------------------------------------------------------
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'D%';

/**
	Note: Often you can use functions such as SUBSTRING and LEFT  instead of LIKE
	predicate to represent the same meaning. But the LIKE predicate tends to get
	optimized better - especially when the pattern starts with an known prefix.
**/
SELECT empid, lastname, SUBSTRING(lastname,1,1) AS lastnamefirstchar
FROM HR.Employees
WHERE SUBSTRING(lastname,1,1) = 'D';

SELECT empid, lastname, LEFT(lastname,1) AS lastnamefirstchar
FROM HR.Employees
WHERE LEFT(lastname,1) = 'D';

-------------------------------------------------------------------------
-- The _(underscore) wildcard
-- An underscore represents a single character
-------------------------------------------------------------------------
/**
	The following query returns employees where the second character in the
	last name is 'e';
**/
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'_e%';

SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'__w%';

------------------------------------------------------------------------------
-- The [<list of characters>] wildcard
-- Square brackets with a list of characters(such as [ABC]) represent a single
-- character that must be one of the characters specified in the list.
------------------------------------------------------------------------------
/**
	The following query returns employees where the first character in the last
	name is A,B,or C
**/
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'[ABC]%';

-----------------------------------------------------------------------------
-- The [<character>-<character>]wildcard
-- Square brackets with a character range (such as[A-E]) represent a single
-- character that must be within the specified range.
-----------------------------------------------------------------------------
/**
	The following query returns employees where the first character in the last
	name is a letter in the range A through E, inclusive.
**/
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'[A-E]%';

-----------------------------------------------------------------------------
-- The [^<character list or range>] wildcard
-- Square brackets with a caret sign(^) followed by a character list or range
-- (such as [^A-E]) represent a single character that is not in the specified
-- character list or range.
-----------------------------------------------------------------------------
SELECT empid, lastname
FROM HR.Employees
WHERE lastname LIKE N'[^A-E]%';

-------------------------------------------------------------------------
-- The ESCAPE character
-- If you want to search for a character that is also used as a wildcard
-- (such as %,_,[,or]), you can use an escape character. 
-------------------------------------------------------------------------
/**
	Specify the character that you know for sure doesn't appear in the data
	as the escape character in front of the character you are looking for,
	and specify the keyword ESCAPE followed by the escape character right
	after the pattern.

	For example; to check whether a column called col1 contains an underscore,
**/
-- USE 
col1 LIKE '%!_%' ESCAPE '!';

/**
	For the wildcards %,_,and [,you can use square brackets instead of an escape
	character. For example:
**/
-- INSTEAD OF 
col1 LIKE '%!_%' ESCAPE '!';
-- you can use
col1 LIKE '%[_]%';