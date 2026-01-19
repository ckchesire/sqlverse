------------------------------------------------------------
-- Inline Table-Valued Functions
------------------------------------------------------------
-- Inline TVFs are reusable table expressions that support
-- input parameters. In most respect, except for the support
-- for input parameters, inline TVFs are similar to views.
-- For this reason, we could think of inline TVFs as 
-- parameterized views, even though they are not formally
-- referred to this way.
-- T-SQL supports another type of table function called 
-- multi-statement TVF, which populates and returns a table
-- variable. This type isn't considered a table expression,
-- because it's not based on a query.
------------------------------------------------------------
/**
	For example, the following code creates an inline TVF
	called GetCustOrders in the TSQLV6 database.
**/
USE TSQLV6;
GO
CREATE OR ALTER FUNCTION dbo.GetCustOrders
  (@cid AS INT) RETURNS TABLE
AS
RETURN
  SELECT orderid, custid, empid, orderdate, requireddate,
    shippeddate, shipperid, freight, shipname, shipaddress, shipcity,
	shipregion, shippostalcode, shipcountry
  FROM Sales.Orders
  WHERE custid = @cid;
GO
/**
	You can see a couple of differences in the syntax for creating an
	inline TVF compared to creating a view. The inline TVF's header has
	a mandatory RETURNS TABLE clause, meaning that conceptually the function
	returns a table result.

	The inline TVF also has a mandatory RETURN clause before the inner query,
	which a view definition doesn't have.

	This inline TVF accepts an input parameter called @cid,
	representing a customer ID, and returns all orders placed
	by the input customer.

	For example, the following code queries the function to request
	all orders that were placed by customer 1.
**/
SELECT orderid, custid
FROM dbo.GetCustOrders(1) AS O;

SELECT orderid, custid
FROM dbo.GetCustOrders(91) AS O;

/**
	As with tables, you can refer to an inline TVF as part of a join. For example,
	the following query joins the inline TVF returning customer 1's orders with 
	the Sales.OrderDetails table, matching the orders with their respective order
	lines
**/
SELECT O.orderid, O.custid, OD.productid, OD.qty
FROM dbo.GetCustOrders(1) AS O
  INNER JOIN Sales.OrderDetails AS OD
     ON O.orderid = OD.orderid;

SELECT orderid, custid
FROM dbo.GetCustOrders(1)