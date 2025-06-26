use AdventureWorks2022
go

select	* from HumanResources.Department

select  pp.BusinessEntityID, pp.FirstName, pp.LastName, hre.JobTitle, hre.Gender from Person.Person pp
join	HumanResources.Employee hre
on		hre.BusinessEntityID = pp.BusinessEntityID
where	hre.BirthDate < '1970-01-01'

SELECT	* FROM Production.Product;

SELECT	ProductID AS ID,
		Name + '(' + ProductNumber + ')' AS ProductName,
		ListPrice - StandardCost AS Markup
FROM	Production.Product;

SELECT	TRY_CAST(Size AS integer) As NumericSize
FROM	Production.Product;

select	ModifiedDate,
		convert(varchar(20), ModifiedDate) startDate,
		CONVERT(varchar(20), ModifiedDate, 101) FormattedStartDate -- 101: formato de data
from	HumanResources.Employee

SELECT	PARSE('01/01/2021' AS date) AS DateValue,
		PARSE('$199.99' AS money) AS MoneyValue;

SELECT	ProductID,  '$' + STR(ListPrice) AS Price -- str: converte valor numérico em varchar
FROM	Production.Product
where	ListPrice <> 0

SELECT	SalesOrderID,
		ProductID,
		UnitPrice,
		NULLIF(UnitPriceDiscount, 0) AS Discount
FROM	Sales.SalesOrderDetail

SELECT	* FROM Sales.Customer;

SELECT	Name AS ProductName, ListPrice - StandardCost AS Markup
FROM	Production.Product;

SELECT	ProductNumber, Color, Size, Color + ', ' + Size AS ProductDetails
FROM	Production.Product;

-- CAST e CONVERT
SELECT	CAST(ProductID AS varchar(5)) + ': ' + Name AS ProductName
FROM	Production.Product; -- resultado: 1: Adjustable Race

SELECT	CONVERT(varchar(5), ProductID) + ': ' + Name AS ProductName
FROM	Production.Product;

SELECT	SellStartDate,
		CONVERT(nvarchar(30), SellStartDate) AS ConvertedDate,
		CONVERT(nvarchar(30), SellStartDate, 126) AS ISO8601FormatDate
FROM	Production.Product;

SELECT	Name, TRY_CAST(Size AS Integer) AS NumericSize
FROM	Production.Product
where	Size is not null

-- Case when
SELECT	Name,
		CASE
			WHEN SellEndDate IS NULL THEN 'Currently for sale'
			ELSE 'No longer available'
		END AS SalesStatus
FROM Production.Product

SELECT	Name,
		CASE Size
			WHEN 'S' THEN 'Small'
			WHEN 'M' THEN 'Medium'
			WHEN 'L' THEN 'Large'
			WHEN 'XL' THEN 'Extra-Large'
			ELSE ISNULL(Size, 'n/a')
		END AS ProductSize
FROM	Production.Product

SELECT	TOP 10 Name, ListPrice
FROM	Production.Product
ORDER	BY ListPrice DESC;

-- with ties
SELECT	TOP 10 WITH TIES Name, ListPrice
FROM	Production.Product
ORDER	BY ListPrice DESC;

-- percent
SELECT	TOP 10 PERCENT Name, ListPrice
FROM	Production.Product
ORDER	BY ListPrice DESC;

/*	OFFSET e FETCH: servem para paginação
	- FETCH: 'ignora' os 100 primeiros registros da tabela
	- OFFSET: faz a contagem de da quantidade de registros informados, iniciando na primeira linha depois das linhas que foram 'ignoradas'
*/
use AdventureWorks2022
go

-- Consulta com cláusula TOP
SELECT	top 10 ProductID, Name, ListPrice
FROM	Production.Product
ORDER	BY ListPrice DESC

-- Consulta com OFFSET e FETCH
SELECT	ProductID, Name, ListPrice
FROM	Production.Product
ORDER	BY ListPrice DESC 
OFFSET	0 ROWS -- Skip zero rows
FETCH	NEXT 10 ROWS ONLY; -- Get the next 10

/* -- ambas trazem o mesmo resultado, porém, o OFFSET trabalha como uma forma de 'ignorar' os primeiros registros da tabela -- */

SELECT	ProductID, Name, ListPrice
FROM	Production.Product
ORDER	BY ListPrice DESC 
OFFSET	10 ROWS -- Skip 10 rows
FETCH	NEXT 10 ROWS ONLY; -- Get the next 10

-- utilizando LIKE
SELECT	Name, ListPrice
FROM	Production.Product
WHERE	Name LIKE 'Mountain Bike Socks, _';

SELECT	Name, ListPrice
FROM	Production.Product
WHERE	Name LIKE 'Mountain-[0-9][0-9][0-9] %, [0-9][0-9]'

SELECT	Name, ListPrice
FROM	Production.Product
ORDER	BY Name 
OFFSET	0 ROWS
FETCH	NEXT 10 ROWS ONLY

SELECT	Name, ListPrice
FROM	Production.Product
ORDER	BY Name
OFFSET	10 ROWS
FETCH	NEXT 10 ROWS ONLY

SELECT	ALL Color
FROM	Production.Product

SELECT	distinct Color
FROM	Production.Product

-- Subconsultas (subqueries)
SELECT	MAX(SalesOrderID)
FROM	Sales.SalesOrderHeader

SELECT	SalesOrderID, ProductID, OrderQty
FROM	Sales.SalesOrderDetail
WHERE	SalesOrderID = (SELECT MAX(SalesOrderID) FROM Sales.SalesOrderHeader);

SELECT	SalesOrderID, ProductID, OrderQty,
		(SELECT AVG(OrderQty) FROM Sales.SalesOrderDetail) AS AvgQty
FROM	Sales.SalesOrderDetail
WHERE	SalesOrderID = (SELECT MAX(SalesOrderID) FROM Sales.SalesOrderHeader) -- 75123

--SELECT	CustomerID, SalesOrderID
--FROM	Sales.SalesOrderHeader
--WHERE	CustomerID IN (
--			SELECT	Name
--			FROM	Person.CountryRegion
--			WHERE	CountryRegion = 'Canada');

exec sp_consulta 'CountryRegion'

SELECT	od.SalesOrderID, od.ProductID, od.OrderQty
FROM	Sales.SalesOrderDetail AS od
WHERE	od.OrderQty = (SELECT MAX(OrderQty) FROM Sales.SalesOrderDetail AS d WHERE od.ProductID = d.ProductID)
ORDER	BY od.ProductID;

SELECT	Name, ListPrice
FROM	Production.Product
WHERE	ListPrice > (SELECT MAX(UnitPrice) FROM Sales.SalesOrderDetail)

SELECT	DISTINCT ProductID
FROM	Sales.SalesOrderDetail
WHERE	OrderQty >= 20;

SELECT	Name 
FROM	Production.Product
WHERE	ProductID IN (SELECT DISTINCT ProductID FROM Sales.SalesOrderDetail WHERE OrderQty >= 20);

-- Produtos com preço de tabela de 100 ou mais que foram vendidos por menos de 100
SELECT	ProductID, Name, ListPrice
FROM	Production.Product
WHERE	ProductID IN
		(SELECT ProductID
		FROM Sales.SalesOrderDetail
		WHERE UnitPrice < 100.00)
AND		ListPrice >= 100.00
ORDER	BY ProductID;

-- Produtos que tenham um preço médio de venda inferior ao custo
SELECT	p.ProductID, p.Name, round(p.StandardCost, 2) StandardCost, p.ListPrice,
		(SELECT round(AVG(o.UnitPrice), 2) FROM Sales.SalesOrderDetail AS o WHERE p.ProductID = o.ProductID) AS AvgSellingPrice
FROM	Production.Product AS p
WHERE	StandardCost >
		(SELECT round(AVG(od.UnitPrice), 2) FROM Sales.SalesOrderDetail AS od WHERE p.ProductID = od.ProductID)
ORDER	BY p.ProductID;

-- JOIN: sintaxe e conceito

/* 
	FROM e tabelas virtuais
	Sintaxe anterior com a cláusula where:
*/
SELECT	p.ProductID, m.Name AS Model, p.Name AS Product
FROM	Production.Product AS p, Production.ProductModel AS m
WHERE	p.ProductModelID = m.ProductModelID;

-- Sintaxe com join:
SELECT	p.ProductID, m.Name AS Model, p.Name AS Product
FROM	Production.Product AS p
JOIN	Production.ProductModel AS m
ON		p.ProductModelID = m.ProductModelID;

-- Inner Join
SELECT	p.ProductID, m.Name AS Model, p.Name AS Product
FROM	Production.Product AS p
INNER	JOIN Production.ProductModel AS m
ON		p.ProductModelID = m.ProductModelID
ORDER	BY p.ProductID;

SELECT	od.SalesOrderID, m.Name AS Model, p.Name AS ProductName, od.OrderQty
FROM	Production.Product AS p
INNER	JOIN Production.ProductModel AS m
ON		p.ProductModelID = m.ProductModelID
INNER	JOIN Sales.SalesOrderDetail AS od
ON		p.ProductID = od.ProductID
ORDER	BY od.SalesOrderID

/*
	LEFT OUTER JOIN: Ao gravar consultas usando OUTER JOIN, considere as seguintes diretrizes:

	- Como visto anteriormente, os aliases de tabela são preferenciais não apenas para a lista SELECT, mas também para a cláusula ON.
	- Assim como a INNER JOIN, a OUTER JOIN pode ser executada em uma única coluna correspondente ou em vários atributos correspondentes.
	- Ao contrário da INNER JOIN, a ordem na qual as tabelas são listadas e unidas na cláusula FROM é importante para a OUTER JOIN, pois ela vai determinar a escolha entre LEFT ou RIGHT da junção.
	- Junções de várias tabelas são mais complexas quando uma OUTER JOIN está presente. A presença de NULLs nos resultados de uma OUTER JOIN pode causar problemas se os resultados intermediários forem unidos a uma terceira tabela. Linhas com valores NULLs podem ser filtradas pelo predicado da segunda junção.
	- Para exibir somente as linhas nas quais não há correspondência, adicione um teste para NULL em uma cláusula WHERE após um predicado OUTER JOIN.
	- Uma FULL OUTER JOIN é usada raramente. Ela retorna as linhas correspondentes entre as duas tabelas, as linhas da primeira tabela sem correspondência na segunda e as linhas da segunda sem correspondência na primeira.
	- Não é possível prever a ordem em que as linhas vão retornar sem uma cláusula ORDER BY. Não há como saber se as linhas correspondentes ou as não correspondentes vão ser retornadas primeiro.
*/

SELECT	p.ProductID, 
		coalesce(m.Name, p.name) AS Model_coalesce, -- usando coalesce
		isnull(m.Name, p.name) AS Model_isnull, -- usando isnull
		p.Name AS Product
FROM	Production.Product AS p
left	outer join Production.ProductModel AS m
ON		p.ProductModelID = m.ProductModelID;

-- Cross Join
SELECT	emp.LoginID, prd.Name
FROM	HumanResources.Employee AS emp
CROSS	JOIN Production.Product AS prd;

SELECT	p.Name, c.FirstName, c.LastName, c.EmailAddress
FROM	Production.Product AS p
CROSS	JOIN Sales.Customer AS c;

-- Left Join
SELECT	p.Name As ProductName, oh.PurchaseOrderNumber
FROM	Production.Product AS p
LEFT	JOIN Sales.SalesOrderDetail AS od
ON		p.ProductID = od.ProductID
LEFT	JOIN Sales.SalesOrderHeader AS oh
ON		od.SalesOrderID = oh.SalesOrderID
ORDER	BY p.ProductID;

sp_consulta 'ProductCategoryID'
select	* from Production.ProductCategory

--Declare and initialize the variables.
DECLARE @numrows INT = 3, @catid INT = 2;
--Use variables to pass the parameters to the procedure.
EXEC Production.ProdsByCategory @numrows = @numrows, @catid = @catid;
GO

select	
		nome_completo = (p.FirstName + ' ' + isnull(MiddleName, '') + ' ' + p.LastName),
		e.JobTitle,
		convert(varchar(10), e.BirthDate, 103) BirthDate,
		e.Gender,
		data_contratacao = convert(varchar(10), e.HireDate, 103),
		estado_civil = case 
					      when e.MaritalStatus = 'S'
							then 'Solteiro'
						  when e.MaritalStatus = 'M'
							then 'Casado'
					      else 'Outros'
						end
from	HumanResources.Employee e
join	Person.BusinessEntity be
on		be.BusinessEntityID = e.BusinessEntityID
join	Person.Person p
on		p.BusinessEntityID = be.BusinessEntityID

sp_consulta 'businessentityid'

---WILDCARDS
use AdventureWorks2022
go

---First thing we will do is to simply select everything from a table
select	* from HumanResources.Employee

--Now we want to select columns from the same table.
select	BusinessEntityID, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours
from	HumanResources.Employee




--1--
---Percentage Symbol % (Used to specify the start of the wild card. Beginning of string, end of the string, and anywhere in the string)---
--All JobTitles starting with R 
select	BusinessEntityID, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours
from	HumanResources.Employee
where	JobTitle like 'R%'

--Ends with R**
select	BusinessEntityID, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours
from	HumanResources.Employee
where	JobTitle like '%R'

--Contains with Chief**
select	BusinessEntityID, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours
from	HumanResources.Employee
where	JobTitle like '%Chief%'



--2--
---Using the square brackets [] (Used to give a range of values)---
--All job titles that begins with the characters m through p--
select	BusinessEntityID, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours
from	HumanResources.Employee
where	JobTitle like '[m-p]%'

--All job titles that begins with either c, o or s (very specific)--
select	BusinessEntityID, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours
from	HumanResources.Employee 
where	JobTitle like '[c, o, s]%'



--3--
--Using the symbol ^ or ! exclamation (Used to specify what the results should NOT match. Easier to use Not like)
--This uses three out of the four wild card symbols
--Does not begin with R or M
select	BusinessEntityID, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours
from	HumanResources.Employee 
where	JobTitle like '[^R, M]%'

--Does not begin with P
select	BusinessEntityID, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours
from	HumanResources.Employee  
where	JobTitle like '[^P]%'

---This is easier, with the logical operator NOT LIKE
select	BusinessEntityID, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours
from	HumanResources.Employee  
where	JobTitle not like 'P%'



--4--
---Using the Symbol _ (Used to mark an empty value where we know there’s something, but not sure what, basically something for holding spaces)

--JobTitle where there is an 'e' after the first character
select	BusinessEntityID, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours
from	HumanResources.Employee  
where	JobTitle like '_e%'


--You can combine a few wild cards using 
--JobTitle where there is an 'e' after the first character and the JobTitle Contains the word 'Engineer'
select	BusinessEntityID, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours
from	HumanResources.Employee  
where	JobTitle like '_e%' and jobtitle like '%Engineer%'


--JoTitle Starts with D, then any charater then s, then any character then g
select	BusinessEntityID, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours
from	HumanResources.Employee  
where	JobTitle like 'D_s_g%' 


--Escape clause to escape a wild card symbol
--If we are looking for a name that contains the % symbol, We need to use the ESCAPE Clause to make it work
select	BusinessEntityID, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours
from	HumanResources.Employee  
where	jobtitle like '%T[]%' Escape 'T'



--TO DO
--Using AdventureWorks2019, answer the following with Syntax

---Retrieve just ID, Title, Marital status and gender
--1.) Retrieve the list of JobTitles who have Development in their name

---Retrieve just ID, Title and hire date
--2.) Retrieve all jobs with title ending in 'er'
