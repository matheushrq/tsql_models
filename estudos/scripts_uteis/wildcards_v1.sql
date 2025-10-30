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
