use NWMewes
go



begin tran

	update products
	set unitprice=unitprice+1
	where productid=72;
	
	update [order details]
	set unitprice=unitprice+1
	where orderid>11000
	and productid=72;
	
rollback tran;	




