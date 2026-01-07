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

-------------------------------------------------------------------------
-- Filtering Date Ranges
-- When you need to filter a range of dates, such as a whole year or a
-- whole month, it seems natural to use functions such as YEAR or MONTH
-- However this limits SQL Server use of an index in an efficient manner.
-------------------------------------------------------------------------
/**
	Query to return all orders placed in the year 2021
**/
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE YEAR(orderdate) = 2021;

/**
	You should refrain from manipulating the filtered column. To achieve
	this, you can revise the filter predicate from the last query like 
	this:
**/
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE orderdate >= '20210101' AND orderdate < '20220101';

-- Instead of using functions to filter orders placed in a particular 
-- month,i.e:
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders
WHERE YEAR(orderdate) = 2022 AND MONTH(orderdate) = 2;

-- Use a range filter, as below:
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders 
WHERE orderdate >= '20220201' AND orderdate < '20220301';

---------------------------------------------------------------------------------
-- Date And Time Functions
-- Includes GETDATE, CURRENT_TIMESTAMP, GETUTCDATE, SYSDATETIME, SYSUTCDATETIME,
-- SYSDATETIMEOFFSET, CAST, CONVERT, PARSE, SWITCHOFFSET, TODATETIMEOFFSET, 
-- AT TIME ZONE, DATEADD, DATEDIFF and DATEDIFF_BIG, DATEPART, YEAR, MONTH, DAY,
-- DATENAME, DATETRUNC, DATE_BUCKET, ISDATE, various FROMPARTS functions, EOMONTH,
-- and GENERATE_SERIES.
----------------------------------------------------------------------------------
-- Current Date and Time
-- We cover niladic(parameterless) functions to return the current date and time
-- values in the system where SQL Server instances resides.
----------------------------------------------------------------------------------
/**
	Using the current date and time functions.
**/
SELECT
	GETDATE()			AS [GETDATE],
	CURRENT_TIMESTAMP	AS [CURRENT_TIMESTAMP],
	GETUTCDATE()		AS [GETUTCDATE],
	SYSDATETIME()		AS [SYSDATETIME],
	SYSUTCDATETIME()	AS [SYSUTCDATETIME],
	SYSDATETIMEOFFSET()	AS [SYSDATETIMEOFFSET];

/**
	Convert CURRENT_TIMESTAMP or SYSDATETIME  to DATE or TIME.
*/
SELECT
	SYSDATETIME()		AS [SYSDATETIME],
	CAST(SYSDATETIME() AS DATE) AS [current_date],
	CAST(SYSDATETIME() AS TIME) AS [current_time];

-------------------------------------------------------------------------------
-- The CAST, CONVERT, and PARSE functions and their TRY_ counterparts
-------------------------------------------------------------------------------
-- The CAST, CONVERT, and PARSE functions are use to convert an input value to
-- some target type. If the conversion succeeds, the functions return the 
-- converted value; otherwise, they cause the query to fail.
-- The three functions have counterparts called TRY_CAST, TRY_CONVERT, and 
-- TRY_PARSE, respectively. Which return NULL when conversion fails.
-- SYNTAX:
-- CAST(value AS datatype)
-- TRY_CAST(value AS datatype)
-- CONVERT(datatype, value [,style_number])
-- TRY_CONVERT(datatype, value [,style_number])
-- PARSE(value AS datatype[USING culture])
-- TRY_PARSE(value AS datatype[USING culture])
-- Note: CAST is standard and CONVERT and PARSE aren't, so unless you need to
-- use the style number or culture, it is recommended that you use the CAST
-- function.
-------------------------------------------------------------------------------
/**
	Code to convert the character string literal '20220212' to a DATE data type.
**/
SELECT CAST('20220212' AS DATE);

/**
	Code to convert the current system date and time value to a DATE data type,
	practically extracting only the current system date.
**/
SELECT CAST(SYSDATETIME() AS DATE);

/**
	Code to convert the current system date and time value to a TIME data type,
	practically extracting only the current system time.
**/
SELECT CAST(SYSDATETIME() AS TIME);

/**
	Code to convert the current date and time value to CHAR(8) by using style 112
	('YYYYMMDD')
**/
SELECT CONVERT(CHAR(8), CURRENT_TIMESTAMP, 112);

/**
	Convert the character string back to DATETIME and get the current date at
	midnight
**/
SELECT CONVERT(DATETIME, CONVERT(CHAR(8), CURRENT_TIMESTAMP, 112), 112);

/**
	Similarly, to the zero date portion to the base date, you can first convert the
	current date
**/
SELECT CONVERT(CHAR(12), CURRENT_TIMESTAMP, 114);

/**
	When the code is converted back to DATETIME, you get the current time on the
	base date
**/
SELECT CONVERT(DATETIME, CONVERT(CHAR(12), CURRENT_TIMESTAMP, 114), 114);

/**
	Using the PARSE function

	The first example parses the input string by using a US English Culture,
	and the second one does so using a British English culture.

	Note: The PARSE function is significantly more expensive than the CONVERT
	function; it's recomended to use the latter.
**/
SELECT PARSE('02/12/2022' AS DATETIME USING 'en-US');
SELECT PARSE('02/12/2022' AS DATETIME USING 'en-GB');

------------------------------------------------------------------------------
-- The SWITCHOFFSET Function
-- Adjusts an input DATETIMEOFFSET value to a specified target offset from UTC
-- Syntax:
--	SWITCHOFFSET(SYSDATETIMEOFFSET(), UTC_offset);
------------------------------------------------------------------------------
/**
	The following code adjusts the current system datetimeoffset value to
	offset -05:00
**/
SELECT SWITCHOFFSET(SYSDATETIMEOFFSET(), '-05:00');

SELECT SYSDATETIME();

SELECT SYSDATETIMEOFFSET();

/**
	The following code adjusts the current datetimeoffset value to UTC
**/
SELECT SWITCHOFFSET(SYSDATETIMEOFFSET(), '+00:00');

------------------------------------------------------------------------------
-- The TODATETIMEOFFSET function
-- Constructs a DATETIMEOFFSET typed value from a local date and time value
-- and an offset from UTC.
-- Syntax:
--	TODATETIMEOFFSET(local_date_and_time_value, UTC_offset)
------------------------------------------------------------------------------
/**
	This function is different from SWITCHOFFSET in that its first input is a
	local date and time value without an offset component. 

	This function simply merges the input date and time value with the specified
	offset to create a new datetimeoffset value.
**/
SELECT TODATETIMEOFFSET(SYSDATETIME(), '+03:00');
SELECT SYSDATETIME()

------------------------------------------------------------------------------
-- The AT TIME ZONE function
-- Accepts an input date and time value and converts it to a datetimeoffset
-- value that corresponds to the specified target time zone.
-- Syntax:
--	dt_val AT TIME ZONE time_zone
------------------------------------------------------------------------------
/**
	Query to see the available time zones, their current offset from UTC, and
	whether it's currently daylight saving time(DST)
**/
SELECT name, current_utc_offset, is_currently_dst
FROM sys.time_zone_info;

SELECT name, current_utc_offset, is_currently_dst
FROM sys.time_zone_info
WHERE name LIKE '%east%';

SELECT name, current_utc_offset, is_currently_dst
FROM sys.time_zone_info
WHERE name LIKE '%africa%';

SELECT name, current_utc_offset, is_currently_dst
FROM sys.time_zone_info
WHERE is_currently_dst <> 0;

/**
	When it's not DST, the offset from UTC is -08:00; when it is DST, the offset
	is -07:00. The following code demonstrates the use of this function with 
	non-datetimeoffset inputs
**/
SELECT
	CAST('20220212 12:00:00.0000000' AS DATETIME2)
	  AT TIME ZONE 'Pacific Standard Time' AS val1,
	CAST('20220812 12:00:00.0000000' AS DATETIME2)
	  AT TIME ZONE 'Pacific Standard Time' AS val2;
-- The first happens when DST doesn't apply; hence offset -08:00 is assumed.
-- The second value happens during DST; hence, offset -07:00 is assumed.

/**
	When the input dt_val is datetimeoffset value, the AT TIME ZONE function behaves 
	more similarly to the SWITCHOFFSET function.
**/
SELECT
	CAST('20220212 12:00:00.0000000 -05:00' AS DATETIMEOFFSET)
	  AT TIME ZONE 'Pacific Standard Time' AS val1,
	CAST('20220812 12:00:00.0000000 -04:00' AS DATETIMEOFFSET)
	  AT TIME ZONE 'Pacific Standard Time' AS val2;

/**
	Computing the local date and time in a desired target time zone.

	The following expression will give you the current time in Pacific Time
	terms irrespective of the time zone setting of your target system.
**/
SELECT SYSDATETIMEOFFSET() AT TIME ZONE 'Pacific Standard Time';

SELECT SYSDATETIMEOFFSET() AT TIME ZONE 'E. Africa Standard Time';

------------------------------------------------------------------------------
-- The DATEADD function
-- You can use the DATEADD function to add a specified number of units of a 
-- specified date part to an input date and time value.
-- Syntax:
--  DATEADD(part,n,dt_val)
-- Valid values include year,quarter,month,dayofyear,day,week,weekday,hour,
-- minute,second,millisecond,and nanosecond.
------------------------------------------------------------------------------
/**
	The following code adds one year to February 12,2022:
**/
SELECT DATEADD(year, 1, '20220212');
SELECT DATEADD(day, 1, '20220212');

------------------------------------------------------------------------------
-- The DATEDIFF and DATEDIFF_BIG Functions
-- Used to return the difference between two date and time values in terms
-- of a specified date part.
-- The former returns a value typed as INT(a 4-byte integer), and the latter
-- returns a value typed as BIGINT(an 8-byte integer).
-- Syntax:
--   DATEDIFF(part,dt_val1,dt_val2), DATEDIFF_BIG(part,dt_val1,dt_val2)
------------------------------------------------------------------------------

/**
	The following code returns the difference in terms of days between two
	values.
**/
SELECT DATEDIFF(day, '20210212', '20220212');

/**
	There are certain differences that result in an integer that is greater
	than the maximum INT value (2,147,483,647). For example, the difference
	in milliseconds between January 1,0001 and February 12,2022 is 
	63,780,220,800,000. You can't use the DATEDIFF function to compute such
	a difference, but you can achieve this with the DATEDIFF_BIG function.
**/
SELECT DATEDIFF_BIG(millisecond, '00010101', '20220212');
SELECT DATEDIFF(millisecond, '00010101', '20220212'); -- results in an overflow

/**
	If you need to compute the beginning of the day that corresponds to an input
	date and time value, you can simply cast the input value to the DATE type
	and then CAST the result to the target type.
**/
DECLARE @InputDateTime DATETIME = '2026-01-07 14:35:42';
SELECT CAST(CAST(@InputDateTime AS DATE) AS DATETIME) AS StartOfDay;

SELECT CAST(CAST(CURRENT_TIMESTAMP AS DATE) AS DATETIME) AS StartOfDay;

-- Using DATETIME2
DECLARE @InputDateTime2 DATETIME2 = '2026-01-07 14:35:42.1234567';

SELECT CAST(CAST(@InputDateTime2 AS DATE) AS DATETIME2) AS StartOfDay;

/**
	Compute the beginning of the day that corresponds to the input 
	date and time value
**/
SELECT
	DATEADD(
	  day,
	  DATEDIFF(day, '19000101', SYSDATETIME()), '19000101');

/**
	If you use this expression with a month part instead of a day
	and make sure to use an anchor that is the first day of a month
	(as in this example), you get the first day of the current month:
**/
SELECT
  DATEADD(
    month,
	DATEDIFF(month, '19000101', SYSDATETIME()), '19000101');

/**
	Similarly, by using a year part and an anchor that is the first 
	day of a year, you get back the first day of the current year.
**/
SELECT
  DATEADD(
    year,
	DATEDIFF(year, '19000101', SYSDATETIME()), '19000101');

SELECT
  DATEADD(
    year,
	DATEDIFF(year, '20000101', SYSDATETIME()), '20000101');

/**
	If you want the last day of the month or year, simply use an
	anchor that is the last day of the month or year.

	The following expression returns the last day of the current
	year.
**/
SELECT
  DATEADD(
    year,
	DATEDIFF(year, '18991231', SYSDATETIME()), '18991231');

/**
	Getting last day of the month
**/
SELECT
  DATEADD(
    month,
	DATEDIFF(month, '18991231', SYSDATETIME()), '18991231');

/**
	Getting the end of the quater
**/
SELECT
  DATEADD(
    quarter,
	DATEDIFF(quarter, '18991231', SYSDATETIME()), '18991231');

-------------------------------------------------------------------------------
-- The DATEPART function
-- Returns an integer representing a requested part of date and time value
-- Syntax:
--	DATEPART(part, dt_val)
-- Valid values for the part argument include year,quarter,month,dayofyear,day,
-- week,weekday,hour,minute,second,milllisecond,microsecond,nanosecond,tzoffset
-- (time zone offset), and iso_week(ISO-based week number)
-------------------------------------------------------------------------------

SELECT DATEPART(month, '20220212');

SELECT DATEPART(dayofyear, '20220212');

/**
	For this function, the parts day,weekday, and dayofyear, have different
	meanings. The part 'day' means the number of the day of the month. The
	part 'weekday' means the number of the day of the week. The part 'dayofyear'
	means the number of the day of the year.

	The following example extracts all three parts from an input date.
**/
SELECT
  DATENAME(weekday, '20220212') AS day_name,
  DATEPART(day, '20220212') AS part_day,
  DATEPART(weekday, '20220212') AS part_weekday,
  DATEPART(dayofyear, '20220212') AS part_dayofyear;

SELECT
  DATENAME(weekday, SYSDATETIME()) AS day_name,
  DATEPART(day, SYSDATETIME()) AS part_day,
  DATEPART(weekday, SYSDATETIME()) AS part_weekday,
  DATEPART(dayofyear, SYSDATETIME()) AS part_dayofyear;

-------------------------------------------------------------------------------
-- The DATENAME function
-- Returns a character string representing a part of a date and time value.
-- Syntax:
--   DATENAME(dt_val,part)
-------------------------------------------------------------------------------
/**
	The following code returns the month name of the given input value
**/
SELECT DATENAME(month, '20220212');

/**
	If a part is requested that has no name and only a numeric value (such
	as year), the DATENAME function returns its numeric value as a character
	string.

	For example, the following code returns '2022'
**/
SELECT DATENAME(year, '20220212');

-- Returns 1 for Q1.
SELECT DATENAME(quarter, '20220212');

-------------------------------------------------------------------------------
-- The DATETRUNC function
-- Truncates, or floors, the input date and time value to the beginning of the
-- specified part.
-- Syntax:
--   DATETRUNC(part,dt_val)
-------------------------------------------------------------------------------
/**
	The following code returns the beginning of month date corresponding to the
	input value, at midnight, as a DATETIME2(7)-typed value:
**/
SELECT DATETRUNC(month, '20220212');

SELECT DATETRUNC(day, '20220212');

SELECT DATETRUNC(year, '20220212');

-------------------------------------------------------------------------------
-- The ISDATE function
-- Accepts a character string as input and returns 1 if it is convertible to a
-- date and time data type and 0 if it isn't
-- Syntax:
--   ISDATE(string)
-------------------------------------------------------------------------------
/**
	For example the following code returns 1
**/
SELECT ISDATE('20220212');
/**
	And the following code returns 0
**/
SELECT ISDATE('20220230');

----------------------------------------------------------------------------------------
-- The FROMPARTS function
----------------------------------------------------------------------------------------
-- Accepts integer inputs representing parts of a date and time value and
-- construct a value of the requested type from those parts.
-- Syntax:
--		DATEFROMPARTS(year,month,day)
--		DATETIME2FROMPARTS(year,month,day,hour,minute,seconds,fractions,precision)
--		DATETIMEFROMPARTS(year,month,day,hour,minute,seconds,milliseconds)
--		DATETIMEOFFSETFROMPARTS(year,month,day,hour,minute,seconds,fractions,hour_offset,
--		minute_offset,precision)
--		SMALLDATETIMEFROMPARTS(year,month,day,hour,minute)
--		TIMEFROMPARTS(hour,minute,seconds,fractions,precision)
-----------------------------------------------------------------------------------------

SELECT
	DATEFROMPARTS(2022, 02, 12),
	DATETIME2FROMPARTS(2022, 02, 12, 13, 30, 5, 1, 7),
	DATETIMEFROMPARTS(2022, 02, 12, 13, 30, 5, 997),
	DATETIMEOFFSETFROMPARTS(2022, 02, 12, 13, 30, 5, 1, -8, 0, 7),
	SMALLDATETIMEFROMPARTS(2022, 02, 12, 13, 30),
	TIMEFROMPARTS(13, 30, 5, 1, 7);

----------------------------------------------------------------------------------------
-- The EOMONTH function 
-- Accepts an input date and time value and returns the respective end-of-month date as
-- a DATE typed value. The function also supports an optional second argument indicating
-- how many months to add (or subtract, if negative).
-- Syntax:
--	EOMONTH(input[,months_to_add])
----------------------------------------------------------------------------------------
/**
	The following code returns the end of the current month
**/
SELECT EOMONTH(SYSDATETIME());

/**
	The following query returns orders placed on the last day of the month.
**/
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = EOMONTH(orderdate);

/**
	Alternative for computing the last day of the month that corresponds
	to the input date value:
**/
SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
WHERE orderdate = DATEADD(month, DATEDIFF(month, '18991231', orderdate), '18991231');

----------------------------------------------------------------------------------------
-- The GENERATE_SERIES function
-- Is a table function that returns a sequence of numbers in the requested range.
-- Syntax:
--	SELECT value FROM GENERATE_SERIES(start_value, stop_value[,step_value]);
-- The start_value and stop_value inputs can be of any of the types TINYINT, SMALLINT,
-- INT, BIGINT, DECIMAL, or NUMERIC, and the two must have matching types. The type of
-- the result column value is the same as the type of the inputs start_value and
-- stop_value
----------------------------------------------------------------------------------------
/**
	The following code returns a sequence of integers between 1 and 10:
**/
SELECT value
FROM GENERATE_SERIES( 1, 10 ) AS N;

/**
	The following code generates a sequence of all dates in the year
	2022:
**/
DECLARE @startdate AS DATE = '20220101', @enddate AS DATE = '20221231';

SELECT DATEADD(day, value, @startdate) AS dt
FROM GENERATE_SERIES( 0, DATEDIFF(day, @startdate, @enddate) ) AS N