/**
	Trigger implementation to update OrderDetailsAudit table,
	when there is a change done on the OrderDetails table  unitprice,
	qty, and discount column.
**/
CREATE TRIGGER Sales.trg_OrderDetails_Audit
ON Sales.OrderDetails
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @dt DATETIME = SYSDATETIME();
	DECLARE @login sysname = ORIGINAL_LOGIN();

	/* unitprice */
	INSERT INTO Sales.OrderDetailsAudit
		(orderid, productid, dt, loginname, columnname, oldval, newval)
	SELECT
		i.orderid,
		i.productid,
		@dt,
		@login,
		'unitprice',
		d.unitprice,
		i.unitprice
	FROM inserted i
	JOIN deleted d
		ON i.orderid = d.orderid
	   AND i.productid = d.productid
	WHERE ISNULL(d.unitprice, 0) <> ISNULL(i.unitprice, 0)

	/* qty */
	INSERT INTO Sales.OrderDetailsAudit
		(orderid, productid, dt, loginname, columnname, oldval, newval)
	SELECT
		i.orderid,
		i.productid,
		@dt,
		@login,
		'qty',
		d.qty,
		i.qty
	FROM inserted i
	JOIN deleted d
		ON i.orderid = d.orderid
	   AND i.productid = d.productid
	WHERE ISNULL(d.qty, 0) <> ISNULL(i.qty, 0);

	/* discount */
	INSERT INTO Sales.OrderDetailsAudit
		(orderid, productid, dt, loginname, columnname, oldval, newval)
	SELECT
		i.orderid,
		i.productid,
		@dt,
		@login,
		'discount',
		d.discount,
		i.discount
	FROM inserted i
	JOIN deleted d
		ON i.orderid = d.orderid
		AND i.productid = d.productid
	WHERE ISNULL(d.discount, 0) <> ISNULL(i.discount, 0);
END;
GO
