select * from person.Person
where LastName = 'Miller' and FirstName = 'Anna'

select	name, * 
from	Production.Product
where	Weight > 500 
and		Weight < 700

select	*
from	HumanResources.Employee
where	MaritalStatus = 'M'
and		SalariedFlag = 1

select	*
from	Person.Person pp
join	person.EmailAddress pea
on		pea.BusinessEntityID = pp.BusinessEntityID
where	pp.FirstName = 'Peter' and pp.LastName = 'Krebs'

select	count(FirstName) total_nomes
from	Person.Person
where	FirstName = 'Anna'

select	COUNT(*) total_produtos
from	Production.Product

select	count(size) tamanho_produtos
from	Production.Product

select	top 100 *
from	Person.Person

select	top 100 *
from	Person.Person
order	by FirstName asc, LastName desc

select	top 10 name, ProductID
from	Production.Product
order	by listprice desc

select	top 4 name, productnumber
from	Production.Product
order	by ProductID asc

select	firstName, count(firstName) as quantidade
from	Person.Person
group	by FirstName
having	count(FirstName) > 10
/*
	Diferença where e having
	- Where: é aplicado antes dos dados serem agrupados
	- Having: é aplicado depois dos dados serem agrupados
*/

select	sod.productId, convert(dec(10,2), sum(linetotal)) as total
from	sales.SalesOrderDetail sod
group	by ProductID
having	sum(LineTotal) between 162000 and 500000

select firstname, count(firstname) as qtde
from person.Person
where title like '%Mr%'
group by FirstName
having count(FirstName) > 10

select stateProvinceID, count(stateProvinceID) as qtde
from person.Address
group by StateProvinceID
having count(stateProvinceID) > 1000

select productId as codigo, round(avg(linetotal), 1) as qtde_vendas
from sales.SalesOrderDetail
group by ProductID
having avg(productId) < 1000000

select distinct top 10 firstName as Nome, lastName as Sobrenome
from person.Person

select top 10 productNumber as numProduto
from Production.Product

select distinct unitPrice as precoUnitario
from sales.SalesOrderDetail