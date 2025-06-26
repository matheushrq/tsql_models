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

use ebook
go

select	tcc.cNome,
		convert(varchar(10), tcc.dAniversario, 103) dAniversario,
		ult.iIDPedido,
		convert(varchar(10), tmp.dPedido, 103) dPedido,
		round(tcc.mCredito, 2) mCredito,
		maior_credito = ROW_NUMBER() over(order by tcc.mCredito desc)
from	tCADCliente tcc
join	tMOVPedido tmp
on		tmp.iIDCliente = tcc.iIDCliente
cross	apply (select max(p.iIDPedido) iIDPedido
			   from tMOVPedido p
			   where p.iIDCliente = tcc.iIDCliente) ult
where	year(tcc.dAniversario) < 1975
and		year(tmp.dPedido) = 2008
order	by tcc.mCredito desc