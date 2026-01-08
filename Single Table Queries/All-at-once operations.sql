------------------------------------------------------------------------
-- SQL supports a concept called 'all-at-once operations', which means
-- that all expressions that appear in the same logical query processing
-- phase are evaluated logically at the same point in time.
------------------------------------------------------------------------

/**
	'orderyear' is invalid because logically there is no order of evaluation
	of the expression in the SELECT clause - it is a set of expressions

	Conceptually, all the expressions are evaluated at the same point in time.
**/
SELECT
	orderid,
	YEAR(orderdate) AS orderyear,
	orderyear + 1 AS nextyear
FROM Sales.Orders;

/**
	SQL Server usually makes decisions based on cost estimations

	Return all rows for which col2/col1 is greater than 2, and
	take into account divide-by-zero error.
**/
SELECT col1, col2
FROM dbo.T1
WHERE col1 <> 0 AND col2/col1 > 2;


/**
	SQL Server does support short circuits, but because of the all-at-once 
	operations concept, it is free to process the expressions in the WHERE
	clause in any order.

	If SQL Server decides to process the expression col2/col1 > 2 first, the
	above query might fail, because of a divide-by-zero error.

	Using CASE Expressions to evaluate, the order in which the WHEN clause are
	evaluated is guaranteed.
**/

SELECT col1, col2
FROM dbo.T1
WHERE
	CASE
		WHEN col1 = 0  THEN 'no' -- or 'yes' if row should be returned
		WHEN col2/col1 > 2 THEN 'yes'
		ELSE 'no'
	END = 'yes';


/**
	The workaround above turned out to be quite convoluted. You can use
	a mathematical workaround that avoids division altogether.
**/

SELECT col1, col2
FROM dbo.T1
WHERE (col1 > 0 AND col2 > 2*col1) OR (col1 < 0 AND col2 < 2*col1);


