/*==============================================================*/
/* STORED PROCEDURE                                             */
/*==============================================================*/

/*

- As Stored Procedures (procedimentos armazenados) do SQL Server são usados para agrupar uma ou mais instruções Transact-SQL em unidades lógicas. 
- As Stored Procedures são armazenadas como objetos nomeados no servidor de banco de dados do SQL Server.

- Quando você executa uma Stored Procedure pela primeira vez, o SQL Server cria um plano de execução e o armazena no cache. 

- Nas execuções subsequentes da Stored Procedure, o SQL Server reutiliza o plano de execução  para que a Stored Procedure
possa ser executado muito rapidamente !!!!


*/

SELECT TOP (1000) [Id]
      ,[ProductName]
      ,[SupplierId]
      ,[UnitPrice]
      ,[Package]
      ,[IsDiscontinued]
  FROM [CLIENTES].[dbo].[Product]
  ORDER BY [ProductName] DESC

-- CRIANDO PRIMEIRA STORED PROCEDURE

CREATE PROCEDURE ProductList
AS
BEGIN
   SELECT TOP (1000) [Id]
      ,[ProductName]
      ,[SupplierId]
      ,[UnitPrice]
      ,[Package]
      ,[IsDiscontinued]
  FROM [CLIENTES].[dbo].[Product]
  ORDER BY [ProductName] DESC
END;

-- VERIFICAR A STORED PROCEDURE CRIADA NO SSMS


-- EXECUTANDO A STORED PROCEDURE CRIADA

EXECUTE ProductList;

OU

EXEC ProductList;


-- MODIFICANDO A STORED PROCEDURE 

ALTER PROCEDURE ProductList
AS
BEGIN
    SELECT TOP (1000) [Id]
        ,[ProductName]
        ,[SupplierId]
        ,[UnitPrice]
    FROM [CLIENTES].[dbo].[Product]
    ORDER BY [ProductName] ASC
END;

-- EXECUTE NOVAMENTE E VEJA O RESULTADO
EXEC ProductList;


CREATE OR ALTER PROCEDURE ProductList
    AS
    BEGIN
       SELECT TOP (1000) [Id]
          ,[ProductName]
          ,[UnitPrice]
      FROM [CLIENTES].[dbo].[Product]   
    END;

EXEC ProductList;

-- DELETANDO STORED PROCEDURE

DROP PROCEDURE ProductList;

OU

DROP PROC ProductList;


-- Parameters nas Stored Procedures

CREATE OR ALTER PROCEDURE ProductList
    AS
    BEGIN
       SELECT [Id]
          ,[ProductName]
          ,[UnitPrice]
      FROM [CLIENTES].[dbo].[Product]   
      ORDER BY [UnitPrice] DESC
    END;

EXEC ProductList;

-- Passando Parametro para a Stored Procedure

ALTER PROCEDURE ProductList (@max_listprice AS DECIMAL)
AS
BEGIN
    SELECT [Id]
          ,[ProductName]
          ,[UnitPrice]
    FROM [CLIENTES].[dbo].[Product]  
    WHERE
        [UnitPrice] <= @max_listprice
    ORDER BY
       UnitPrice;
END;

EXEC ProductList 10;

-- Passando mais de 1 Parametro para a Stored Procedure

ALTER PROCEDURE ProductList (@min_listprice AS DECIMAL, @max_listprice AS DECIMAL)
AS
BEGIN
    SELECT [Id]
          ,[ProductName]
          ,[UnitPrice]
    FROM [CLIENTES].[dbo].[Product]  
    WHERE
         [UnitPrice] >= @min_listprice and
         [UnitPrice] <= @max_listprice 
    ORDER BY
    UnitPrice;
END;

EXECUTE ProductList 10, 200; -- a ordem da passagem dos parametros é essencial.

EXECUTE ProductList 12, 14;

-- Melhor Pratica para chamar Stored Procedure. Neste caso, a ordem da passagem dos parametros é indiferente.

EXECUTE ProductList 
    @min_listprice = 12, 
    @max_listprice = 15;

-- Alterando Stored Procedure


ALTER PROCEDURE ProductList (@min_listprice AS DECIMAL, @max_listprice AS DECIMAL, @productname AS NVARCHAR(50))
AS
BEGIN
    SELECT [Id]
          ,[ProductName]
          ,[UnitPrice]
    FROM [CLIENTES].[dbo].[Product]  
    WHERE
         ([UnitPrice] >= @min_listprice and
         [UnitPrice] <= @max_listprice) and
          ProductName LIKE '%' + @productname + '%'
    ORDER BY
    UnitPrice;
END;

EXECUTE ProductList 
    @min_listprice = 12, 
    @max_listprice = 15,
    @productname = 'hok';

-- Criação de parâmetros opcionais

-- Ao executar Stored Procedure ProductList, você deve passar todos os três argumentos correspondentes aos três parâmetros.
-- O SQL Server permite que você especifique os valores padrão dos parâmetros para que, ao chamar a SP (Stored Procedure), 
-- você possa ignorar os parâmetros com os valores padrão.

ALTER PROCEDURE ProductList (@min_listprice AS DECIMAL = 0, @max_listprice AS DECIMAL = 999999, @productname AS NVARCHAR(50))
AS
BEGIN
    SELECT [Id]
          ,[ProductName]
          ,[UnitPrice]
    FROM [CLIENTES].[dbo].[Product]  
    WHERE
         ([UnitPrice] >= @min_listprice and
         [UnitPrice] <= @max_listprice) and
          ProductName LIKE '%' + @productname + '%'
    ORDER BY
    UnitPrice;
END;

EXECUTE ProductList 
    @min_listprice = 12, 
    @max_listprice = 15,
    @productname = 'hok';

EXECUTE ProductList 
     @productname = 'chef';

EXECUTE ProductList @min_listprice = 70, @productname = 'a';


-- Usandro NULL como parametros opcionais. Metodo mais usado, porque um dia se existir produtos com valores superiores a 999999 poderá ter que alterar a stored procedure. 

ALTER PROCEDURE ProductList (@min_listprice AS DECIMAL = 0, @max_listprice AS DECIMAL = NULL, @productname AS NVARCHAR(50))
AS
BEGIN
    SELECT [Id]
          ,[ProductName]
          ,[UnitPrice]
    FROM [CLIENTES].[dbo].[Product]  
    WHERE
         [UnitPrice] >= @min_listprice and
         (@max_listprice IS NULL OR [UnitPrice] <= @max_listprice) and
          ProductName LIKE '%' + @productname + '%'
    ORDER BY
    UnitPrice;
END;


EXECUTE ProductList @min_listprice = 70, @productname = 'a';

EXECUTE ProductList @min_listprice = 70, @max_listprice = 124, @productname = 'a';


-- DECLARANDO VARIAVEIS. Por default quando a variavel é declarada, o valor dela é NULL

DECLARE @orderdate SMALLINT
SET @orderdate = 2013 -- COLOCANDO VALORES NAS VARIAVEIS.

SELECT TOP (1000) [Id]
      ,[OrderDate]
      ,[OrderNumber]
      ,[CustomerId]
      ,[TotalAmount]
  FROM [CLIENTES].[dbo].[Order]
  where year([OrderDate]) = @orderdate 


-- Armazenando o resultado de uma consulta em uma variavel

DECLARE @supplier_count INT

SET @supplier_count = (
    SELECT 
        COUNT(*) 
    FROM 
        supplier
)

SELECT @supplier_count ; -- demonstrando o valor guardado na variavel @supplier_count

PRINT 'The number of suppliers is ' + CAST(@supplier_count AS VARCHAR(50)); -- Imprimindo o conteudo de uma variavel

-- Clique em message para verificar as mensagens do comando Print
-- Para esconder a mensagem do numero de linhas afetadas (1 row affected): SET NOCOUNT ON; 

SET NOCOUNT ON;  
DECLARE @supplier_count INT
SET @supplier_count = (
    SELECT 
        COUNT(*) 
    FROM 
        supplier
)
SELECT @supplier_count ; -- demonstrando o valor guardado na variavel @supplier_count
PRINT 'The number of suppliers is ' + CAST(@supplier_count AS VARCHAR(50)); -- Imprimindo o conteudo de uma variavel
SET NOCOUNT OFF;

-- Armazenando valores em variaveis

SELECT * from Product

DECLARE 
    @productname NVARCHAR(50),
    @listprice DECIMAL(10,2);

 SELECT     @productname = [ProductName]
          , @listprice  = [UnitPrice]
    FROM [CLIENTES].[dbo].[Product]  
    WHERE
        id = 1
 
 SELECT @productname AS [Nome do Produto]
 SELECT @listprice   as [Preco Unitario]


-- OBS se retirar o where, nao vai dar erro, mas vai trazer os dados do ultimo registro

-- Acumulando valores em variaveis

DECLARE 
    @productname NVARCHAR(50),
    @listprice DECIMAL(10,2),
	@todosprodutos varchar(MAX) -- 2GB de armazenamento, com cerca de 1 bilhao de caracteres devido unicode que gasta 2 bytes por caracterer armazenado

SET @todosprodutos = '';

 SELECT  @todosprodutos = @todosprodutos + [ProductName] + CHAR(10)
    FROM [CLIENTES].[dbo].[Product]  
   
 SELECT @todosprodutos   as [Nome de Todos Produtos]
 --PRINT @todosprodutos


-- Output Parameters

-- A seguinte SP (Stored Procedure) encontra produtos com passagem do valor unitario e retorna 
-- o número de produtos por meio do parâmetro de saída @produto_qt que tem parametro OUTPUT:

CREATE PROCEDURE AcharprodutoPorPreco (
    @precounitario SMALLINT,
    @produto_qt INT OUTPUT
) AS
BEGIN
    SELECT 
        productname,
        unitprice
    FROM
        product
    WHERE
        unitprice = @precounitario;

    SELECT @produto_qt = @@ROWCOUNT; -- @@ROWCOUNT is a system variable that returns the number of rows read 
END;

-- CHAMANDO A SP, passando parametro @precounitario = 18

DECLARE @count INT;

EXEC AcharprodutoPorPreco
    @precounitario = 18,
    @produto_qt = @count OUTPUT;

SELECT @count AS 'Numero de Produtos Encontrados';


-- ELSE IF


    DECLARE @vendas INT;

    SELECT 
        @vendas = SUM(unitprice * quantity)
    FROM
        orderitem i
    INNER JOIN [Order] oo ON oo.id = i.OrderId
    WHERE
        YEAR(oo.orderdate) = 2012;

    SELECT @vendas;

    IF @vendas > 10000
    BEGIN
        PRINT 'Vendas de 2012 estao maiores que 10000';
    END
    ELSE
    BEGIN
        PRINT 'Vendas de 2012 estao maiores que 10000';
    END


-- WHILE

DECLARE @qt INT = 1;

WHILE @qt <= 5
BEGIN
    PRINT @qt;
    SET @qt = @qt + 1;
END

-- BREAK

DECLARE @qt INT = 0;

WHILE @qt <= 5
BEGIN
    SET @qt = @qt + 1;
    IF @qt = 4
        BREAK;
    PRINT @qt;
END


-- SQL Server Dynamic SQL
-- exemplo 1

DECLARE 
    @tabela NVARCHAR(128),
    @sql NVARCHAR(MAX);

SET @tabela = N'product';

SET @sql = N'SELECT * FROM ' + @tabela;

EXEC sp_executesql @sql;


-- exemplo 2

CREATE OR ALTER PROC queryTOPX(
    @tabela NVARCHAR(128),
    @topx INT,
    @byColumn NVARCHAR(128)
)
AS
BEGIN
    DECLARE 
        @sql NVARCHAR(MAX),
        @topxStr NVARCHAR(MAX);

    SET @topxStr  = CAST(@topx as nvarchar(max));

    SET @sql = N'SELECT TOP ' +  @topxStr  + 
                ' * FROM ' + @tabela + 
                    ' ORDER BY ' + @byColumn + ' DESC';
    
    EXEC sp_executesql @sql;
    
END;

-- chamando a procedure passando parametros

EXEC queryTOPX 
        'product',
        10, 
        'unitprice';

EXEC queryTOPX 
        'customer',
        10, 
        'FirstName';


-- SQL Injection

-- Vamos criar uma tabela de teste 
CREATE TABLE VENDASTESTE(id INT); 

-- criar SP
CREATE or alter PROCEDURE SPVENDAS (@tabela nchar(250))
AS
declare @sql nchar(250)
set @sql = 'select * from ' + @tabela
EXEC sp_executesql @sql;

-- executar sp
exec SPVENDAS 'customer'

-- capturando a chamada da sp e a alterando
exec SPVENDAS 'customer;drop table VENDASTESTE'

-- Veja o que aconteceu com a tabela.


-- Para evitar essa injeção de SQL, você pode usar a função QUOTENAME () conforme mostrado na seguinte consulta:
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/quotename-transact-sql?view=sql-server-ver15

CREATE or alter PROCEDURE SPVENDAS (@schema NVARCHAR(128), @tabela NVARCHAR(128))
AS
declare @sql nchar(128)
set @sql = N'select * from ' 
            + QUOTENAME(@schema) 
            + '.' 
            + QUOTENAME(@tabela)  ;

EXEC sp_executesql @sql;

exec SPVENDAS 'dbo' ,'customer'

exec SPVENDAS 'dbo','customer;drop table VENDASTESTE'

-- maiores informacoes e tecnicas para evitar sql injection https://docs.microsoft.com/en-us/sql/relational-databases/security/sql-injection?view=sql-server-ver15


-- TRY CATCH

CREATE PROC usp_divide(
    @a decimal,
    @b decimal,
    @c decimal output
) AS
BEGIN
    BEGIN TRY
        SET @c = @a / @b;
    END TRY
    BEGIN CATCH
        SELECT  
            ERROR_NUMBER() AS ErrorNumber  
            ,ERROR_SEVERITY() AS ErrorSeverity  
            ,ERROR_STATE() AS ErrorState  
            ,ERROR_PROCEDURE() AS ErrorProcedure  
            ,ERROR_LINE() AS ErrorLine  
            ,ERROR_MESSAGE() AS ErrorMessage;  
    END CATCH
END;
GO

-- Chamar as SP

DECLARE @r decimal;
EXEC usp_divide 10, 2, @r output;
PRINT @r;

DECLARE @r decimal;
EXEC usp_divide 10, 0, @r output;
PRINT @r;











