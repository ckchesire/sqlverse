------------------------------------------------------------------
-- The GREATEST and LEAST functions operate on sets of rows that
-- are defined by the query's grouping set, the elements that you
-- group by.
--
-- Functions GREATEST and LEAST, are row-level alternatives to MAX
-- and MIN, respectively.
------------------------------------------------------------------

SELECT orderid, requireddate, shippeddate,
	GREATEST(requireddate, shippeddate) AS latestdate,
	LEAST(requireddate, shippeddate) AS earliestdate
FROM Sales.Orders
WHERE custid = 8;


-- In earlier versions of SQL Server, if you had two input arguments, you could handle
-- such needs with CASE expressions, like so:
SELECT orderid, requireddate, shippeddate,
	CASE
		WHEN requireddate > shippeddate OR shippeddate IS NULL THEN requireddate
		ELSE shippeddate
	END AS latestdate,
	CASE 
		WHEN requireddate < shippeddate OR shippeddate IS NULL THEN requireddate
		ELSE shippeddate
	END AS earliestdate
FROM Sales.Orders
WHERE custid = 8;



