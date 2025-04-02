-- Fun��es internas e group by
	-- Escalar: Operam em uma �nica linha e retornam um valor �nico.
	-- L�gico: Comparam v�rios valores para determinar uma �nica sa�da.
	-- Classifica��o: Operam em uma parti��o (conjunto) de linhas.
	-- Conjunto de linhas: Retornam uma tabela virtual que pode ser usada em uma cl�usula FROM em uma instru��o T-SQL.
	-- Agregado: Usam um ou mais valores de entrada, retornam um �nico valor de resumo.

/* 
	Fun��o escalar
	- As fun��es escalares retornam um �nico valor e geralmente funcionam em uma �nica linha de dados. 
	O n�mero de valores de entrada que elas assumem podem ser zero (por exemplo, GETDATE), um (por exemplo, UPPER) ou v�rios (por exemplo, ROUND).

	- Determinismo: se a fun��o retornar o mesmo valor para o mesmo estado de entrada e banco de dados sempre que for chamada, dizemos que ela � determin�stica. 
	Por exemplo, ROUND(1.1, 0) sempre retorna o valor 1.0. Muitas fun��es internas s�o n�o determin�sticas. 
	Por exemplo, GETDATE() retorna a data e hora atuais. 
	Os resultados de fun��es n�o determin�sticas n�o podem ser indexados, o que afeta a capacidade do processador de consultas de criar um bom plano para executar a consulta.

	- Ordena��o:ao usar fun��es que manipulam dados de caracteres, qual ordena��o ser� usada? Algumas fun��es usam a ordena��o (ordem de classifica��o) do valor de entrada,
	outras usam a colagem do banco de dados se n�o for fornecida nenhuma ordena��o de entrada.
	
	Exemplos de fun��o escalar:
	- Fun��es de configura��o
	- Fun��es de convers�o
	- Fun��es de cursor
	- Fun��es de data e hora
	- Fun��es matem�ticas
	- Fun��es de metadados
	- Fun��es de seguran�a
	- Fun��es de cadeia de caracteres
	- Fun��es do sistema
	- Fun��es estat�sticas de sistema
	- Fun��es de texto e imagem
*/

-- Exemplo de fun��es de data e hora:

use AdventureWorks2022
go

SELECT  SalesOrderID,
		OrderDate,
        YEAR(OrderDate) AS OrderYear,
        DATENAME(mm, OrderDate) AS OrderMonth,
        DAY(OrderDate) AS OrderDay,
        DATENAME(dw, OrderDate) AS OrderWeekDay,
        DATEDIFF(yy,OrderDate, GETDATE()) AS YearsSinceOrder
FROM	Sales.SalesOrderHeader;

-- Fun��es matem�ticas:

SELECT	TaxAmt,
		ROUND(TaxAmt, 0) AS Rounded,
		FLOOR(TaxAmt) AS Floor,
		CEILING(TaxAmt) AS Ceiling,
		SQUARE(TaxAmt) AS Squared,
		SQRT(TaxAmt) AS Root,
		LOG(TaxAmt) AS Log,
		TaxAmt * RAND() AS Randomized
FROM	Sales.SalesOrderHeader;

-- Fun��es de cadeia de caracteres:

SELECT  CompanyName,
        UPPER(CompanyName) AS UpperCase,
        LOWER(CompanyName) AS LowerCase,
        LEN(CompanyName) AS Length,
        REVERSE(CompanyName) AS Reversed,
        CHARINDEX(' ', CompanyName) AS FirstSpace,
        LEFT(CompanyName, CHARINDEX(' ', CompanyName)) AS FirstWord,
        SUBSTRING(CompanyName, CHARINDEX(' ', CompanyName) + 1, LEN(CompanyName)) AS RestOfName
FROM	Sales.Customer;

/* -- Fun��es l�gicas -- */

-- IIF: A fun��o IIF avalia uma express�o de entrada booleana e retorna um valor especificado se a express�o for avaliada como True e um valor alternativo se a express�o for avaliada como False.
select	distinct AddressLine1, iif(City = 'Bothell', 'Monroe', 'Seattle') as UseAddressFor
from	Person.Address
order	by iif(City = 'Bothell', 'Monroe', 'Seattle') asc

-- Choose: A fun��o CHOOSE avalia uma express�o integral e retorna o valor correspondente de uma lista com base em sua posi��o ordinal (baseada em 1).
SELECT	SalesOrderID, Status, CHOOSE(Status, 'Ordered', 'Shipped', 'Delivered') AS OrderStatus
FROM	Sales.SalesOrderHeader;

/* -- Fun��es de classifica��o -- */

-- Rank
SELECT	TOP 100 ProductID, Name, ListPrice,
RANK()	OVER(ORDER BY ListPrice DESC) AS RankByPrice
FROM	Production.Product AS p
ORDER	BY RankByPrice;

/* -- Fun��es do conjunto de linhas -- */
/*
	As fun��es de conjunto de linhas retornam uma tabela virtual que pode ser usada na cl�usula FROM como fonte de dados. 
	Essas fun��es assumem par�metros espec�ficos para a pr�pria fun��o de conjuntos de linhas. Eles incluem OPENDATASOURCE, OPENQUERY, OPENROWSET, OPENXML e OPENJSON.
	As fun��es OPENDATASOURCE, OPENQUERY e OPENROWSET permitem que voc� passe uma consulta para um servidor de banco de dados remoto.
	O servidor remoto retornar� um conjunto de linhas de resultado. Por exemplo, a consulta a seguir usa OPENROWSET para obter os resultados de uma consulta de uma inst�ncia do SQL Server chamada SalesDB.
*/
-- Fun��o OPENROWSET deve ser habilitada na inst�ncia que est� sendo utilizada.
use master
GO

EXECUTE sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

EXECUTE sp_configure 'Ad Hoc Distributed Queries', 1;
GO
RECONFIGURE;
GO

SELECT a.*
FROM OPENROWSET ('MSOLEDBSQL', 'Server=Seattle1;Trusted_Connection=yes;', 'SELECT GroupName, Name, DepartmentID
      FROM AdventureWorks2022.HumanResources.Department
      ORDER BY GroupName, Name') AS a;
GO

use AdventureWorks2022
go

SELECT a.*
FROM OPENROWSET('SQLNCLI', 'Server=SalesDB;Trusted_Connection=yes;',
    'SELECT Name, ListPrice
    FROM AdventureWorks.Production.Product') AS a;

EXECUTE sp_configure 'show advanced options', 0;
GO
RECONFIGURE;
GO

/* -- Fun��es de agrega��o internas -- */
SELECT	AVG(ListPrice) AS AveragePrice, -- m�dia
		MIN(ListPrice) AS MinimumPrice, -- menor valor
		MAX(ListPrice) AS MaximumPrice  -- maior valor
FROM	Production.Product;

-- Considere a seguinte consulta, que tenta incluir o campo ProductID nos resultados agregados
SELECT	Production.Product.ProductID,
		AVG(ListPrice) AS AveragePrice,
		MIN(ListPrice) AS MinimumPrice,
		MAX(ListPrice) AS MaximumPrice
FROM	Production.Product
WHERE	ProductID = 15;
-- vai gerar o seguinte erro: Column 'Production.Product.ProductID' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.
-- O erro foi gerado devido � coluna 'ProductId' n�o estar contida na cl�usula GROUP BY

-- Essa consulta retorna a primeira e a �ltima empresa por nome, usando MIN e MAX
SELECT	MIN(AccountNumber) AS MinCustomer, 
		MAX(AccountNumber) AS MaxCustomer
FROM	Sales.Customer;

-- A fun��o escalar YEAR � usada no exemplo a seguir para retornar apenas a parte do ano da data do pedido, antes de MIN e MAX serem avaliados
SELECT	MIN(YEAR(OrderDate)) AS Earliest,
		MAX(YEAR(OrderDate)) AS Latest
FROM	Sales.SalesOrderHeader;

/* -- Usando distinct com fun��es de agrega��o -- */

-- O exemplo abaixo retorna o n�mero de clientes que fizeram pedidos, independentemente de quantos pedidos tenham feito
SELECT	COUNT(DISTINCT CustomerID) AS UniqueCustomers
FROM	Sales.SalesOrderHeader;
-- COUNT (<alguma_coluna>) simplesmente conta quantas linhas t�m algum valor na coluna. Se n�o houver nenhum valor NULL, COUNT (<alguma_coluna>) ser� o mesmo que Count(*).
-- COUNT (DISTINCT <alguma_coluna>) conta quantos valores diferentes existem na coluna.

/* -- Usando a cl�usula GROUP BY -- */
SELECT	CustomerID
FROM	Sales.SalesOrderHeader
GROUP	BY CustomerID

SELECT	DISTINCT CustomerID
FROM	Sales.SalesOrderHeader

/*
	A fun��o de agrega��o mais simples � COUNT(*). A consulta a seguir usa as 830 linhas de origem originais do CustomerID e as agrupa em 89 grupos, com base nos valores de CustomerID. 
	Cada valor CustomerID distinto gera uma linha de sa�da na consulta GROUP BY.
*/

SELECT	CustomerID, COUNT(*) AS OrderCount
FROM	Sales.SalesOrderHeader
GROUP	BY CustomerID;

/*
	Observe que GROUP BY n�o garante a ordem dos resultados. Frequentemente, como resultado da maneira como a opera��o de agrupamento � executada pelo processador de consultas, os resultados s�o retornados na ordem dos valores do grupo.
	No entanto, voc� n�o deve contar com isso. Se precisar que os resultados sejam classificados, inclua explicitamente uma cl�usula ORDER.
*/

SELECT	CustomerID, COUNT(*) AS OrderCount
FROM	Sales.SalesOrderHeader
GROUP	BY CustomerID
ORDER	BY CustomerID;

/* -- HAVING -- */
/*
	A cl�usula HAVING atua como um filtro em grupos. Isso � semelhante � forma como a cl�usula WHERE atua como um filtro em linhas retornadas pela cl�usula FROM.
	Uma cl�usula HAVING permite que voc� crie um crit�rio de pesquisa, conceitualmente semelhante ao predicado de uma cl�usula WHERE, que, em seguida, testa cada grupo retornado pela cl�usula GROUP BY.
*/

-- O exemplo a seguir conta os pedidos de cada cliente e filtra os resultados para incluir somente os clientes que tenham feito mais de 10 pedidos:
SELECT	CustomerID,
		COUNT(*) AS OrderCount
FROM	Sales.SalesOrderHeader
GROUP	BY CustomerID
HAVING	COUNT(*) > 10;