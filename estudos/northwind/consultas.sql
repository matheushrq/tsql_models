use northwind
go

select
		emp.FirstName,
		emp.LastName,
		cust.CompanyName,
		convert(date, emp.BirthDate) birth,
		ord.OrderID,
		convert(date, ord.OrderDate) order_date,
		ord.ShipName
from	Customers cust
join	Orders ord
on		ord.CustomerID = cust.CustomerID
join	Employees emp
on		emp.EmployeeID = ord.EmployeeID

-- Cláusula OVER
select	top 100
		emp.FirstName,
		emp.LastName,
		convert(date, emp.BirthDate) birth,
		ord.OrderID,
		convert(date, ord.OrderDate) order_date,
		prd.UnitPrice,
		sum(round(prd.UnitPrice, 2)) over(order by prd.UnitPrice, ord.orderid) soma
from	Products prd
join	Suppliers sup
on		sup.SupplierID = prd.SupplierID
join	[Order Details] od
on		od.ProductID = prd.ProductID
join	Orders ord
on		ord.OrderID = od.OrderID
join	Employees emp
on		emp.EmployeeID = ord.EmployeeID
for		json auto

-- Função DENSE_RANK
select	top 100
		emp.FirstName,
		emp.LastName,
		od.Quantity,
		DENSE_RANK() over(order by od.Quantity DESC) RankQtdVendas
from	Products prd
join	[Order Details] od
on		od.ProductID = prd.ProductID
join	Orders ord
on		ord.OrderID = od.OrderID
join	Employees emp
on		emp.EmployeeID = ord.EmployeeID

select	emp.FirstName,
		emp.LastName,
		sum(round(prd.UnitPrice, 2)) soma_vendas
from	Products prd
join	Suppliers sup
on		sup.SupplierID = prd.SupplierID
join	[Order Details] od
on		od.ProductID = prd.ProductID
join	Orders ord
on		ord.OrderID = od.OrderID
join	Employees emp
on		emp.EmployeeID = ord.EmployeeID
group	by emp.FirstName, emp.LastName
having	SUM(prd.UnitPrice) > 300
order	by soma_vendas
for		json auto

select	FirstName, LastName, year(BirthDate) ano_nascimento, count(birthdate) qtd_ano from Employees
group	by FirstName, LastName, BirthDate

/* -- Validando a integridade do banco -- */

use master
go
dbcc checkdb (northwind)

/* -- Testando a trigger  -- */

use northwind
go

insert into dbo.Employees(
	lastname,
	firstname,
	title,
	titleofcourtesy,
	birthdate
)
values(
	'Tomaz',
	'Duda',
	'Pediatra',
	'Dra.',
	'2002/08/16'
)

/* -- Validando a alteração -- */

select	* from Employees
select	* from employee_auditoria
