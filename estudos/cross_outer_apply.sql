use northwind
go

-- cross apply
select	e.EmployeeID,
		e.FirstName,
		e.LastName,
		e.City,
		aux.OrderID
from	Employees e
cross	apply (select max(o.OrderID) orderID from orders o 
			   where o.EmployeeID = e.EmployeeID) aux

-- outer apply
select	od.OrderID,
		od.Quantity,
		od.UnitPrice,
		aux.OrderDate,
		aux.ShipRegion
from	[Order Details] od
outer	apply (select * from orders o
			   where o.OrderID = od.OrderID) aux