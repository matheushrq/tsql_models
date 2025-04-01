use	AdventureWorksDW2022
go

select	top 100 FirstName, LastName, Gender from DimCustomer

select	top 10 * from DimProduct
where	ListPrice is not null

/* buscando maior valor de dados por data */
select	organizationkey, year([Date]) ano, MONTH([Date]) mes, day([Date]) dia, max(Amount) amount from factfinance
group	by organizationkey, [Date]

-- year: busca somente o ano num campo completo de data
-- month: busca somente o mês num campo completo de data
-- day: busca somente o dia num campo completo de data

select	distinct year([Date]) anos from factfinance
order	by year([Date])

select	sum(amount) total from factfinance
where	year([Date]) = 2010

select	CurrencyAlternateKey, CurrencyName from DimCurrency
where	CurrencyName like 'C%' -- todos que iniciam com C

/* -- AGREGAÇÃO -- */

select	count(ParentAccountCodeAlternateKey) total, AccountDescription from DimAccount
where	AccountType = 'Assets'
group	by AccountDescription

select	distinct dc.CustomerKey, dc.FirstName, dc.LastName, year(dc.BirthDate) BirthYear, dc.Gender, dg.City, dg.StateProvinceName from DimCustomer dc
join	DimGeography dg
on		dg.GeographyKey = dc.GeographyKey
where	year(dc.BirthDate) = 1976
order	by dc.FirstName asc

select	distinct year(dc.BirthDate) BirthYear from DimCustomer dc
order	by year(dc.BirthDate) asc

select	min(year(BirthDate)) BirthYearMin, max(year(BirthDate)) BirthYearMax from DimCustomer
select	min(BirthDate) BirthYearMin, max(BirthDate) BirthYearMax from DimCustomer

select	distinct
		dp.ProductKey,
		dpc.ProductCategoryKey,
		dp.EnglishProductName,
		dpsc.EnglishProductSubcategoryName,
		dpc.EnglishProductCategoryName,
		dp.EnglishDescription,
		dp.SpanishProductName,
		dpsc.SpanishProductSubcategoryName,
		dpc.SpanishProductCategoryName,
		round(dp.ListPrice, 2) ListPrice,
		dp.Size,
		convert(date, dp.StartDate) StartDate,
		convert(date, dp.EndDate) EndDate
from	DimProduct dp
join	DimProductSubcategory dpsc
on		dpsc.ProductSubcategoryKey = dp.ProductSubcategoryKey
join	DimProductCategory dpc
on		dpc.ProductCategoryKey = dpsc.ProductCategoryKey

/* subquery (não é boa prática, join possui melhor processamento) */
select	ff.OrganizationKey, ff.AccountKey, convert(date, [Date]) dia, ff.Amount from FactFinance ff
where	ff.DepartmentGroupKey in (select ddg.DepartmentGroupKey
								 from DimDepartmentGroup ddg
								where ddg.ParentDepartmentGroupKey is not null)
and		year([Date]) = 2011
and		ff.Amount > 0 and ff.Amount < 500

/* -- HAVING -- */

select	dg.StateProvinceName, count(dc.CustomerKey) qtd from DimGeography dg
join	DimCustomer dc
on		dc.GeographyKey = dg.GeographyKey
group	by dg.StateProvinceName
having	count(dc.CustomerKey) >= 100
order	by count(dc.CustomerKey) desc

select	dg.StateProvinceName, avg(dc.TotalChildren) qtd from DimGeography dg
join	DimCustomer dc
on		dc.GeographyKey = dg.GeographyKey
group	by dg.StateProvinceName
having	avg(dc.TotalChildren) between 0 and 10

/* -- subquery com exists -- */
select	distinct ProductKey, EnglishProductName, EnglishDescription from DimProduct dp
where	exists (select EnglishProductSubcategoryName
				  from DimProductSubcategory dpsc
				 where dpsc.ProductSubcategoryKey = dp.ProductSubcategoryKey
				   and dpsc.EnglishProductSubcategoryName is not null)

/* -- UPDATE -- */
select	* from DimReseller where ResellerKey = 1

begin tran
update	DimReseller
   set	AddressLine2 = 'Suite 14'
 where	ResellerKey = 1

select	* from DimReseller where ResellerKey = 1

-- rollback
-- commit

/* -- DELETE -- */
select	* from DimReseller

begin	tran
delete	from DimReseller
where	ResellerKey = 14

truncate table dimReseller

/*
	-- IMPORTANTE -- 
	delete <> truncate
	delete apaga a tabela toda, truncate apenas limpa os dados da tabela, deixando a estrutura existente
*/

-- rollback

/* -- VIEWS -- */
select	* from DimCustomer

create	view vw_DecemberCustomers
as
select	distinct dc.CustomerKey, dc.FirstName, dc.LastName, month(dc.BirthDate) BirthYear, dc.Gender, dg.City, dg.StateProvinceName from DimCustomer dc
join	DimGeography dg
on		dg.GeographyKey = dc.GeographyKey
where	month(dc.BirthDate) = 12

-- chamando a view
select	* from vw_DecemberCustomers

select	* from DimEmployee

select	ProductKey, EnglishProductName, ListPrice from DimProduct
where	ListPrice = (select max(ListPrice) from DimProduct)

/* -- Teste com a cláusula MAX_BY() */

/*
select	MAX_BY(ProductKey, EnglishProductName, ListPrice) produto_mais_caro
from	DimProduct
*/

/* 
	Cláusula OVER -- Determina a ordenação de um conjunto de linhas antes da aplicação da função aplicada 
	Exemplo: soma dos valores de preço - irá ordenar conforme a soma dos preços, apresentando o valor somado ao valor anterior
*/
select	EnglishProductName, round(ListPrice, 2) preco, sum(round(ListPrice, 2)) over(order by ListPrice, ProductKey) total from DimProduct
where	ListPrice is not null

select	SafetyStockLevel, count(SafetyStockLevel) qtd from DimProduct
where	SafetyStockLevel is not null
group	by SafetyStockLevel
order	by qtd desc

/* -- Validando a integridade do banco -- */

use master
go
dbcc checkdb (AdventureWorksDW2022)

use AdventureWorksDW2022
go

SELECT FirstName,
       LastName,
       StartDate AS FirstDay
FROM DimEmployee
ORDER BY LastName;

SELECT OrderDateKey,
       PromotionKey,
       AVG(SalesAmount) AS AvgSales,
       SUM(SalesAmount) AS TotalSales
FROM FactInternetSales
GROUP BY OrderDateKey, PromotionKey
ORDER BY OrderDateKey;

/* -- Wildcards -- */

use AdventureWorksDW2022
go

-- -- Percentual (%): Retorna todos que começam com 'A'
select	EmployeeKey, FirstName, LastName, title, HireDate, BirthDate, Gender, [Status]
from	DimEmployee
where	FirstName like 'a%'

-- Underscore (_): Retorna tudo que começa com 'A' e tem dois caracteres
select	* from DimGeography where City like 'a_'

-- Entre colchetes []: Retorna tudo aonde o sobrenome do colaborador começa entre 'C' e 'F'
select	EmployeeKey, FirstName, LastName, title, HireDate, BirthDate, Gender, [Status] 
from	DimEmployee
where	LastName like '[c-f]%'

-- Hífen (-): Retorna os registros que começam entre 'A' e 'F' (usando junto com colchetes para intervalos)
select	GeographyKey, city, StateProvinceName, EnglishCountryRegionName, PostalCode
from	DimGeography
where	City like '[a-f]%'

-- Exemplos:
-- Localizar tudo que termina com 'dom'
select	EmployeeKey, FirstName, LastName, title, HireDate, BirthDate, Gender, [Status]
from	DimEmployee
where	FirstName like '%dom'

-- Localizar tudo que a segunda letra é 'A'
select	ProductKey, EnglishProductName, EnglishDescription, ListPrice, Size, StartDate, EndDate
from	DimProduct
where	EnglishProductName like '_a%'

-- Localizar tudo que começa com 'A' ou 'D'
select	CustomerKey, FirstName, MiddleName, LastName, BirthDate, Gender, EnglishEducation, EnglishOccupation, AddressLine1, AddressLine2
from	DimCustomer
where	FirstName like '[AD]%'

/* 
	Localizar tudo que NÃO começa com 'A'
	Use o ^ para exceção, ou seja, diferente do especificado
*/
select	*
from	DimCurrency
where	CurrencyName like '[^a]%'
