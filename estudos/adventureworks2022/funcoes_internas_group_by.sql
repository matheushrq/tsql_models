-- Funções internas e group by
	-- Escalar: Operam em uma única linha e retornam um valor único.
	-- Lógico: Comparam vários valores para determinar uma única saída.
	-- Classificação: Operam em uma partição (conjunto) de linhas.
	-- Conjunto de linhas: Retornam uma tabela virtual que pode ser usada em uma cláusula FROM em uma instrução T-SQL.
	-- Agregado: Usam um ou mais valores de entrada, retornam um único valor de resumo.

/* 
	Função escalar
	- As funções escalares retornam um único valor e geralmente funcionam em uma única linha de dados. 
	O número de valores de entrada que elas assumem podem ser zero (por exemplo, GETDATE), um (por exemplo, UPPER) ou vários (por exemplo, ROUND).

	- Determinismo: se a função retornar o mesmo valor para o mesmo estado de entrada e banco de dados sempre que for chamada, dizemos que ela é determinística. 
	Por exemplo, ROUND(1.1, 0) sempre retorna o valor 1.0. Muitas funções internas são não determinísticas. 
	Por exemplo, GETDATE() retorna a data e hora atuais. 
	Os resultados de funções não determinísticas não podem ser indexados, o que afeta a capacidade do processador de consultas de criar um bom plano para executar a consulta.

	- Ordenação:ao usar funções que manipulam dados de caracteres, qual ordenação será usada? Algumas funções usam a ordenação (ordem de classificação) do valor de entrada,
	outras usam a colagem do banco de dados se não for fornecida nenhuma ordenação de entrada.
	
	Exemplos de função escalar:
	- Funções de configuração
	- Funções de conversão
	- Funções de cursor
	- Funções de data e hora
	- Funções matemáticas
	- Funções de metadados
	- Funções de segurança
	- Funções de cadeia de caracteres
	- Funções do sistema
	- Funções estatísticas de sistema
	- Funções de texto e imagem
*/

-- Exemplo de funções de data e hora:

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

-- Funções matemáticas:

SELECT	TaxAmt,
		ROUND(TaxAmt, 0) AS Rounded,
		FLOOR(TaxAmt) AS Floor,
		CEILING(TaxAmt) AS Ceiling,
		SQUARE(TaxAmt) AS Squared,
		SQRT(TaxAmt) AS Root,
		LOG(TaxAmt) AS Log,
		TaxAmt * RAND() AS Randomized
FROM	Sales.SalesOrderHeader;

-- Funções de cadeia de caracteres:

SELECT  CompanyName,
        UPPER(CompanyName) AS UpperCase,
        LOWER(CompanyName) AS LowerCase,
        LEN(CompanyName) AS Length,
        REVERSE(CompanyName) AS Reversed,
        CHARINDEX(' ', CompanyName) AS FirstSpace,
        LEFT(CompanyName, CHARINDEX(' ', CompanyName)) AS FirstWord,
        SUBSTRING(CompanyName, CHARINDEX(' ', CompanyName) + 1, LEN(CompanyName)) AS RestOfName
FROM	Sales.Customer;

/* -- Funções lógicas -- */

-- IIF: A função IIF avalia uma expressão de entrada booleana e retorna um valor especificado se a expressão for avaliada como True e um valor alternativo se a expressão for avaliada como False.
select	distinct AddressLine1, iif(City = 'Bothell', 'Monroe', 'Seattle') as UseAddressFor
from	Person.Address
order	by iif(City = 'Bothell', 'Monroe', 'Seattle') asc

-- Choose: A função CHOOSE avalia uma expressão integral e retorna o valor correspondente de uma lista com base em sua posição ordinal (baseada em 1).
SELECT	SalesOrderID, Status, CHOOSE(Status, 'Ordered', 'Shipped', 'Delivered') AS OrderStatus
FROM	Sales.SalesOrderHeader;

/* -- Funções de classificação -- */

-- Rank
SELECT	TOP 100 ProductID, Name, ListPrice,
RANK()	OVER(ORDER BY ListPrice DESC) AS RankByPrice
FROM	Production.Product AS p
ORDER	BY RankByPrice;

/* -- Funções do conjunto de linhas -- */
/*
	As funções de conjunto de linhas retornam uma tabela virtual que pode ser usada na cláusula FROM como fonte de dados. 
	Essas funções assumem parâmetros específicos para a própria função de conjuntos de linhas. Eles incluem OPENDATASOURCE, OPENQUERY, OPENROWSET, OPENXML e OPENJSON.
	As funções OPENDATASOURCE, OPENQUERY e OPENROWSET permitem que você passe uma consulta para um servidor de banco de dados remoto.
	O servidor remoto retornará um conjunto de linhas de resultado. Por exemplo, a consulta a seguir usa OPENROWSET para obter os resultados de uma consulta de uma instância do SQL Server chamada SalesDB.
*/
-- Função OPENROWSET deve ser habilitada na instância que está sendo utilizada.
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

/* -- Funções de agregação internas -- */
SELECT	AVG(ListPrice) AS AveragePrice, -- média
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
-- O erro foi gerado devido à coluna 'ProductId' não estar contida na cláusula GROUP BY

-- Essa consulta retorna a primeira e a última empresa por nome, usando MIN e MAX
SELECT	MIN(AccountNumber) AS MinCustomer, 
		MAX(AccountNumber) AS MaxCustomer
FROM	Sales.Customer;

-- A função escalar YEAR é usada no exemplo a seguir para retornar apenas a parte do ano da data do pedido, antes de MIN e MAX serem avaliados
SELECT	MIN(YEAR(OrderDate)) AS Earliest,
		MAX(YEAR(OrderDate)) AS Latest
FROM	Sales.SalesOrderHeader;

/* -- Usando distinct com funções de agregação -- */

-- O exemplo abaixo retorna o número de clientes que fizeram pedidos, independentemente de quantos pedidos tenham feito
SELECT	COUNT(DISTINCT CustomerID) AS UniqueCustomers
FROM	Sales.SalesOrderHeader;
-- COUNT (<alguma_coluna>) simplesmente conta quantas linhas têm algum valor na coluna. Se não houver nenhum valor NULL, COUNT (<alguma_coluna>) será o mesmo que Count(*).
-- COUNT (DISTINCT <alguma_coluna>) conta quantos valores diferentes existem na coluna.

/* -- Usando a cláusula GROUP BY -- */
SELECT	CustomerID
FROM	Sales.SalesOrderHeader
GROUP	BY CustomerID

SELECT	DISTINCT CustomerID
FROM	Sales.SalesOrderHeader

/*
	A função de agregação mais simples é COUNT(*). A consulta a seguir usa as 830 linhas de origem originais do CustomerID e as agrupa em 89 grupos, com base nos valores de CustomerID. 
	Cada valor CustomerID distinto gera uma linha de saída na consulta GROUP BY.
*/

SELECT	CustomerID, COUNT(*) AS OrderCount
FROM	Sales.SalesOrderHeader
GROUP	BY CustomerID;

/*
	Observe que GROUP BY não garante a ordem dos resultados. Frequentemente, como resultado da maneira como a operação de agrupamento é executada pelo processador de consultas, os resultados são retornados na ordem dos valores do grupo.
	No entanto, você não deve contar com isso. Se precisar que os resultados sejam classificados, inclua explicitamente uma cláusula ORDER.
*/

SELECT	CustomerID, COUNT(*) AS OrderCount
FROM	Sales.SalesOrderHeader
GROUP	BY CustomerID
ORDER	BY CustomerID;

/* -- HAVING -- */
/*
	A cláusula HAVING atua como um filtro em grupos. Isso é semelhante à forma como a cláusula WHERE atua como um filtro em linhas retornadas pela cláusula FROM.
	Uma cláusula HAVING permite que você crie um critério de pesquisa, conceitualmente semelhante ao predicado de uma cláusula WHERE, que, em seguida, testa cada grupo retornado pela cláusula GROUP BY.
*/

-- O exemplo a seguir conta os pedidos de cada cliente e filtra os resultados para incluir somente os clientes que tenham feito mais de 10 pedidos:
SELECT	CustomerID,
		COUNT(*) AS OrderCount
FROM	Sales.SalesOrderHeader
GROUP	BY CustomerID
HAVING	COUNT(*) > 10;