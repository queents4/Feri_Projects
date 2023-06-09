USE NORTHWIND;
GO 




---------------------------Unterabfragen(Subselect)

---------------------------verschachtelt(o. eingebettet)


select productid, productname, unitprice
from products
where unitprice<(	select unitprice
					from products
					where productid=25);


select	productid, productname, unitprice,
			(	select unitprice
				from products
				where productid=25) as preis25
from	products
where unitprice<(	select unitprice
					from products
					where productid=25);

									--Alternative mit Self-JOIN

select	p2.productid, p2.productname, p2.unitprice, p1.unitprice

from	products p1
join	products p2
on		p2.unitprice<p1.unitprice
where	p1.productid=25;



select 	productid, productname, unitprice, categoryid,
			(	select unitprice
				from products
				where productid=25) as preis25
from	products
where	unitprice<(	select unitprice
					from products
					where productid=25)
and		categoryid=(	select categoryid
						from products
						where productid=25);


/**************************************************
orderid, customerid, orderdate, shipcity
für die Bestellungen, die in dieselbe Stadt
geliefert werden sollen wie die, in der 
Lieferant Nr. 10 ansässig ist
***************************************************/


select orderid, customerid, orderdate, shipcity
from	orders
where shipcity=(	select city
					from suppliers
					where supplierid=10);

										--Alternative mit Join

select orderid, customerid, orderdate, shipcity
from	orders
join	suppliers
on		orders.shipcity=suppliers.city
where	supplierid=10;


/**************************************************
Produkte, deren unitprice unter dem Durchschnitt
für unitprice liegt
**************************************************/

select	productid, productname, unitprice,
			(	select avg(unitprice)
				from products			) as durchschnitt
from	products
where	unitprice<(	select avg(unitprice)
					from products);


/*************************************************
Pro Produkt die Summe der bestellten Einheiten,
sofern sie über der Summe von Produkt 13 liegen
*************************************************/

select	productid,
		sum(quantity) as gesamt_bestellmenge
from	[order details]
group by productid
having sum(quantity)>(	select	sum(quantity)
						from [order details]
						where productid=13);



/*****************************************************
Mitarbeiter, die im Mai 2022 Bestellungen aufgenommen
haben
*****************************************************/


										--Fehler
select	firstname +' '+lastname as empname,
			title
from	employees
where employeeid=(	select distinct employeeid
					from orders
					where year(orderdate)=2022
					and month(orderdate)=5);

										
										
										
										--so gehts
select firstname +' '+lastname as empname,
			title
from	employees
where employeeid in(	select distinct employeeid
						from orders
						where year(orderdate)=2022
						and month(orderdate)=5);

select	firstname +' '+lastname as empname,
			title
from	employees
where employeeid =any(	select distinct employeeid
						from orders
						where year(orderdate)=2022
						and month(orderdate)=5);



/*****************************************************
Mitarbeiter, die im Mai 2022 keine Bestellung
aufgenommen haben
*****************************************************/

										
select	firstname +' '+lastname as empname,
			title
from	employees
where employeeid not in(	select distinct employeeid
							from orders
							where year(orderdate)=2022
							and month(orderdate)=5);
																--Abfragepläne vergleichen

select	firstname +' '+lastname as empname,
			title
from	employees
left join orders
on		employees.employeeid=orders.employeeid
and		year(orderdate)=2022
		and month(orderdate)=5
where	orderid is null;

								--zurück zu ANY
								--falsches Ergebnis
								--falscher Operator
select	firstname +' '+lastname as empname,
			title
from	employees
where employeeid <>any(	select distinct employeeid
						from orders
						where year(orderdate)=2022
						and month(orderdate)=5);

					--so ist es wieder richtig

select	firstname +' '+lastname as empname,
			title
from	employees
where employeeid <>all(	select distinct employeeid
						from orders
						where year(orderdate)=2022
						and month(orderdate)=5);

					--außer Konkurrenz

select	firstname +' '+lastname as empname,
			title
from	employees
where employeeid =all(	select distinct employeeid
						from orders
						where year(orderdate)=2022
						and month(orderdate)=5);




/***************************************************
Alle Kunden, die...
****************************************************/

select customerid, companyname, contactname, city, phone
from customers
where customerid in	(	select  customerid
						from		orders
						where	year(orderdate)=2020
						and		orderid in
											(	select orderid
												from [order details]
												where productid=2
											)
					);	
									
									
										--Alternative mit JOIN
select	customers.customerid, 
		companyname, contactname, city, phone,
		orders.orderid, orderdate, shipcity
from		customers
join		orders
on			customers.customerid=orders.customerid
join		[order details] od
on			orders.orderid=od.orderid
where	year(orderdate)=2020
and		productid=2;






-----------------------------------------------------korreliert


/**************************************************
Produkte, deren unitprice unter dem Durchschnitt
für unitprice liegt
**************************************************/


															--noch nicht korreliert
select	productid, productname, unitprice,
			(	select avg(unitprice)
				from products		) as durchschnitt
from	products
where	unitprice<(	select avg(unitprice)
					from products);



/**************************************************
Produkte, deren unitprice unter dem Durchschnitt
für unitprice für die Kategorie des Produktes liegt
**************************************************/

select	productid, productname, unitprice, categoryid,
		(	select avg(unitprice)
			from products) as durchschnitt,
		(	select avg(unitprice)
			from products
			where categoryid=aussen.categoryid)	as kategorie_durchschnitt

from	products as aussen
where unitprice<(	select	avg(unitprice)
					from	products
					where	categoryid=aussen.categoryid);


/******************************************************
Daten für die Kunden, die mehr als 10 Bestellungen haben
*******************************************************/

select	customerid,
			companyname,
			contactname,
			city,
			phone,
			(	select	count(*)
				from orders
				where customerid=customers.customerid)	as anzahl_bestellungen
from customers
where 10<(	select	count(*)
			from	orders
			where	customerid=customers.customerid);



								/***	Äquivalent zur korrelierten Unterabfrage	***/
								
select	customers.customerid,
		companyname,
		contactname,
		city,
		phone,
		count(*) as anzahl_bestellungen
from	customers
join	orders
on		customers.customerid=orders.customerid
group by	customers.customerid,
			companyname,
			contactname,
			city,
			phone
having count(*)>10;	



/******************************************************
Daten für die Kunden, die im Jahr 2020 das Produkt
Nr. 10 bestellt haben
*******************************************************/

select	customerid,
			companyname,
			contactname,
			city,
			phone
from		customers
where	exists(	select *
				from orders
				join [order details] od
				on orders.orderid=od.orderid
						
				where year(orderdate)=2020
				and productid=10
						
				and customerid=customers.customerid
				);


select	customerid,
			companyname,
			contactname,
			city,
			phone
from		customers
where	not exists(	select *
					from orders
					join [order details] od
					on orders.orderid=od.orderid
						
					where year(orderdate)=2020
					and productid=10
						
					and customerid=customers.customerid
				);







--------------------------------------------------------------------------------------------------
--	Unterabfragen 
--	als Alternativen
--	zu anderen Abfragetechniken
--------------------------------------------------------------------------------------------------


					--Verschachteln von Aggregatfunktionen
					--geht nicht

select count(min(unitprice)) from products;
	

					--so fragt man das gewünschte Ergebnis ab
select	count(*)					
from	products
where	unitprice=(	select min(unitprice) from products);



					--Kunden ohne auftrag

select 	customers.*
from 		customers 
left join	orders
on 		customers.customerid=orders.customerid
where 	orderid is null;


select * from customers
where customerid not in(	select distinct customerid 
							from orders	);


select 	* from customers
where 	not exists(	select * from orders
					where orders.customerid=customers.customerid)

						--mit Zeiteinschränkung
select 	customers.*
from 		customers 
left join	orders
on 		customers.customerid=orders.customerid
and		year(orderdate)=2022
and		month(orderdate)<=3
where 	orderid is null;


select * from customers
where customerid not in(	select distinct customerid 
							from orders
							where	year(orderdate)=2022
							and		month(orderdate)<=3);

select 	* from customers
where 	not exists(	select * from orders
					where orders.customerid=customers.customerid
					and		year(orderdate)=2022
					and		month(orderdate)<=3)



					--Self-Join vs. Subselect

select * from customers

					--Kunden, die am selben Wohnort
					--wohnen wie Kunde Nr. AROUT

					--SelfJoin
select  c2.customerid,
		c2.companyname,
		c2.city,
		c1.companyname			
from	customers c1 join customers c2
on		c1.customerid='arout'
and		c1.city=c2.city
and		c1.customerid<>c2.customerid

					--Unterabfrage

select * from customers			--Äußere Abfrage liefert Ergebnisdaten
where city=(	select city from customers	--Innere Abfrage liefert einen Prüfwert
				where customerid='arout')
and customerid<>'arout'





















