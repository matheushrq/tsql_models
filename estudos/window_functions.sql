/* -- ROW_NUMBER() -- */
use master
go

-- usando order by
select
		id_seq = ROW_NUMBER() over(order by name asc), -- cria id sequencial com base na ordenação alfabética
		name,
		recovery_model_desc
from	sys.databases
where	database_id < 10

-- usando partition by
select
		id_seq = ROW_NUMBER() over(partition by recovery_model_desc order by name asc), -- cria id particionado com base no modelo de recuperação (recovery model) e ordenado alfabeticamente
		name,
		recovery_model_desc
from	sys.databases
where	database_id < 10



/*-- EXEMPLOS -- */

use northwind
go

select	
		id_seq = row_number() over(partition by o.ShipCountry order by o.Freight asc), -- id sequencial ordenado crescente por frete e particionado por país
		e.FirstName,
		e.LastName,
		c.ContactName,
		o.ShipCity,
		o.ShipCountry,
		o.Freight
from	Orders o
join	Customers c
on		c.CustomerID = o.CustomerID
join	Employees e
on		e.EmployeeID = o.EmployeeID