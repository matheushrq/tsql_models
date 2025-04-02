use clientes
go

-- CONECTANDO A INSTANCIA SQL SERVER 
-- 1. Criar Login DBA1 na Instancia SQL de forma Grafica pelo SSMS 
-- e USER DBA1 como db_owner do Banco CLIENTES. LOGIN DBA1 SENHA SQL2020@#

-- 2. Criar Login DBA2 via Script SQL com a senha SQL2020@# e USER DBA2 apenas com privilegio Public

USE [master]
GO
CREATE LOGIN [DBA2] WITH PASSWORD=N'123', DEFAULT_DATABASE=[CLIENTES], 
CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

USE [CLIENTES]
GO
CREATE USER [DBA2] FOR LOGIN [DBA2]
GO

/*
	Observação: Login <> User
	- Login deve ser criado sempre com a base master
	- User deve ser criado para o banco que ele irá trabalhar
*/

-- Verificar quem esta logado
select system_user

-- Se conectar com o user DBA1 e acessar o banco clientes
select system_user
go

-- VERIFICAR NO SSMS OS BANCOS QUE ESTAO APARECENDO. NO MEU CASO CLIENTES E DBSCHEMA. 
-- Está aparecendo o nome do banco DBSCHEMA porque por padrao
-- quando um login é criado, recebe privilegio Public para consultat os nomes dos bancos de dados, 
-- agora se tentar acessar vai dar erro, porque nao foi dado acesso a este banco.

-- SAIR E SE CONECTAR COMO DBA2. Ira conseguir se conectar ao Banco CLIENTE porque foi criado um user DBA2 
-- vinculado no login DBA2 no banco CLIENTE, mas nao foi dado
-- acesso a nenhum objeto do banco. Tente acessar algum objeto do banco ClIENTE. Não irá aparecer os objetos.

-- Desconectar como DBA2 e conectar como SA ou usuario de dominio que é sysadmin.

-- Concedendo ACESSO para DBA2 para dar SELECT em uma tabela especifica do banco Clientes
USE CLIENTES
GO
GRANT SELECT ON customer2 TO DBA2
DENY select on customer2 to DBA2 --> remove privilégios
GO

-- ou concedendo Acesso para DBA2 para ter acesso a todas as tabelas do squema dbo.
USE CLIENTES
GO
GRANT SELECT ON SCHEMA :: [dbo] TO DBA2
GO

-- ou dar acesso todas de SELECT para DBA2 em todos os objetos que podem receber este tipo de Grant, como tabelas, views e functions.
USE CLIENTES
GO
GRANT SELECT TO DBA2
GO

-- SIMULANDO ACESSO COM USUARIO DBA2
-- SE APARECER UM ERRO DE QUE NAO PODE FAZER IMPERSONATE DE USER, OU SEJA, NAO PODE RODAR SIMULANDO COMO 
-- SE FOSSE UM OUTRO USUARIO FOI PORQUE ESTA CONECTADO COMO DBA1.
-- NESTE CASO, DESCONECTE E CONECTE COMO UM USUARIO COM PRIVILEGIO DE SYSADMIN.

EXECUTE AS LOGIN = 'DBA2'; -- pra executar esse comando, o usuário conectado deve ser sysadmin
--Verify the execution context is now DBA2.  
SELECT SUSER_NAME(), USER_NAME(); 

-- Testando conexao no Banco Clientes. Verificar se as tabelas apareceram ja que foi dado direito de SELECT.
USE CLIENTES
select * from customer

--Revogando ACESSO. Retornando primeiro para DBA1
REVERT
SELECT SUSER_NAME(), USER_NAME(); 
GO

DENY SELECT TO DBA2
GO

-- VERIFICAR OS LOGINS CRIADOS

SELECT	
	name,
	create_date,
	modify_date,
	LOGINPROPERTY(name, 'DaysUntilExpiration') QTDiasParaExpirar,
	LOGINPROPERTY(name, 'PasswordLastSetTime') DatadaUltimaSenha,
	LOGINPROPERTY(name, 'IsExpired') Estaexpirado,
	is_disabled,
	type_desc,
	*
From sys.sql_logins

-- VAMOS CRIAR ALGUMAS PROCEDURES PARA REALIZAR TESTES DE ACESSO. CASO NAO TENHA
-- AS PROCEDURES E FUNCTIONS NA BASE CLIENTES, CRIE ESTAS :

USE [CLIENTES]
GO

/****** Object:  StoredProcedure [dbo].[AcharprodutoPorPreco]    Script Date: 12/30/2020 4:01:02 AM ******/
DROP PROCEDURE [dbo].[AcharprodutoPorPreco]
GO

/****** Object:  StoredProcedure [dbo].[AcharprodutoPorPreco]    Script Date: 12/30/2020 4:01:02 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[AcharprodutoPorPreco] (
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
GO


USE [CLIENTES]
GO

/****** Object:  StoredProcedure [dbo].[ProductList]    Script Date: 12/30/2020 4:01:52 AM ******/
DROP PROCEDURE [dbo].[ProductList]
GO

/****** Object:  StoredProcedure [dbo].[ProductList]    Script Date: 12/30/2020 4:01:52 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ProductList] (@min_listprice AS DECIMAL = 0, @max_listprice AS DECIMAL = NULL, @productname AS NVARCHAR(50))
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
GO


USE [CLIENTES]
GO

DROP PROCEDURE [dbo].[queryTOPX]
GO

/****** Object:  StoredProcedure [dbo].[queryTOPX]    Script Date: 12/30/2020 4:02:15 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   PROC [dbo].[queryTOPX](
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
GO


USE [CLIENTES]
GO

/****** Object:  UserDefinedFunction [dbo].[troca]    Script Date: 12/30/2020 4:02:48 AM ******/
DROP FUNCTION [dbo].[troca]
GO

/****** Object:  UserDefinedFunction [dbo].[troca]    Script Date: 12/30/2020 4:02:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[troca](
    @string VARCHAR(MAX), 
    @delimitador VARCHAR(50) = ' ')
RETURNS @partes TABLE
(    
idx INT IDENTITY PRIMARY KEY,
valor VARCHAR(MAX)   
)
AS
BEGIN

DECLARE @index INT = -1;

WHILE (LEN(@string) > 0) 
BEGIN 
    SET @index = CHARINDEX(@delimitador , @string)  ;
    
    IF (@index = 0) AND (LEN(@string) > 0)  
    BEGIN  
        INSERT INTO @partes 
        VALUES (@string);
        BREAK  
    END 

    IF (@index > 1)  
    BEGIN  
        INSERT INTO @partes 
        VALUES (LEFT(@string, @index - 1));
        
        SET @string = RIGHT(@string, (LEN(@string) - @index));  
    END 
    ELSE
    SET @string = RIGHT(@string, (LEN(@string) - @index)); 
    END
RETURN
END
GO


USE [CLIENTES]
GO

/****** Object:  UserDefinedFunction [dbo].[FuncDesconto]    Script Date: 12/30/2020 4:03:15 AM ******/
DROP FUNCTION [dbo].[FuncDesconto]
GO

/****** Object:  UserDefinedFunction [dbo].[FuncDesconto]    Script Date: 12/30/2020 4:03:15 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FuncDesconto](
    @qt INT,
    @precounitario DEC(10,2),
    @desconto DEC(4,2)
)
RETURNS DEC(10,2)
AS 
BEGIN
    RETURN @qt * @precounitario * (1 - @desconto);
END;
GO

-- VAMOS REALIZAR ALGUNS TESTES A PARTIR DA TABELAS CUSTOMER2 E CUSTOMER3, PROCEDURES E FUNCTIONS

USE CLIENTES
GO

GRANT UPDATE ON CUSTOMER2 TO DBA2;
GRANT INSERT ON CUSTOMER2 TO DBA2;
GRANT DELETE ON CUSTOMER2 TO DBA2;

-- Concedendo acesso de SELECT para DBA2 e dando permissao para DBA2 dar este acesso para outro usuario.
GRANT SELECT ON CUSTOMER2 TO DBA2 WITH GRANT OPTION;

-- Concedendo acesso de SELECT para DBA2 na tabela CUSTOMER4 mas apenas em alguns campos
GRANT SELECT ON CUSTOMER4(id,firstname,lastname) TO DBA2

-- Concedendo permissao para DBA2 criar VIEW, PROCEDURES E FUNCTIONS no banco de dados Clientes
USE CLIENTES
GO
GRANT CREATE VIEW TO DBA2;
GRANT CREATE PROCEDURE TO DBA2;
GRANT CREATE FUNCTION TO DBA2;

-- DANDO ACESSOS GERAIS A TODOS OS OBJETOS DE UM BANCO DE DADOS.
USE CLIENTES
GO
GRANT SELECT TO DBA2;
GRANT INSERT TO DBA2;
GRANT UPDATE TO DBA2;
GRANT DELETE TO DBA2;
GRANT EXECUTE TO DBA2;

-- OU

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE TO DBA2;

-- DANDO DIREITO DO USUARIO DBA2 EXECUTAR UMA PROCEDURE ESPECIFICA
GRANT EXECUTE ON queryTOPX TO DBA2

-- DANDO DIREITO DO USUARIO DBA2 PARA ACESSAR UMA FUNCTION ESPECIFICA
GRANT EXECUTE ON FuncDesconto TO DBA2

-- VAMOS VERIFICAR AGORA AS PERMISSOES DADAS
EXEC clientes.dbo.sp_helprotect @username = 'DBA2'

-- SEGUE EXEMPLO DE TODAS AS OPCOES DE GRANT QUE PODE SER DADO PARA UM USER
USE CLIENTES
GO
GRANT    
CREATE AGGREGATE,
CREATE ASSEMBLY,
CREATE DEFAULT,
CREATE FUNCTION,
CREATE PROCEDURE,
CREATE SYNONYM,
CREATE TABLE,
CREATE VIEW,
DELETE,
EXECUTE,
INSERT,
REFERENCES,
SELECT,
SHOWPLAN,
UPDATE,
ALTER,
ALTER ANY ASSEMBLY,
AUTHENTICATE,
CONNECT,  
VIEW DATABASE STATE,
VIEW DEFINITION
TO DBA2;
GO

EXEC CLIENTES.dbo.sp_helprotect @username = 'DBA2'

-- VAMOS RETIRAR PERMISSAO DE SELECT TO DBA2 DA TABELA CUSTOMER4
use clientes
go
DENY SELECT ON CUSTOMER4 TO DBA2
GO

EXEC CLIENTES.dbo.sp_helprotect @username = 'DBA2' 

-- VAMOS DAR PERMISSAO DE SELECT EM APENAS ALGUNS CAMPOS
GRANT SELECT ON CUSTOMER4(id,firstname,lastname) TO DBA2

-- IR EM USERS NO SSMS E VERIFICAR AS PERMISSOES DADAS AO DBA2 e DBA1

-- REALIZANDO TESTES. 
-- DESCONECTAR TODOS OS USERS E CONECTAR NO SSMS COM O USER DBA2


-- 1. TESTAR ACESSO QUE FOI DADO PARA ESTES CAMPOS
-- GRANT SELECT ON CUSTOMER4(id,firstname,lastname) TO DBA2, ATRAVÉS DO COMANDO: 
USE CLIENTES
SELECT id,firstname,lastname FROM CUSTOMER4
-- AGORA TESTAR ESTE ACESSO: 
USE CLIENTES
SELECT * FROM CUSTOMER4

-- DESCONECTAR E CONECTAR NOVAMENTE NOVAMENTE COMO SYSADMIN
-- E REVOGAR A PERMISSAO DADA PARA SELECIONAR OS 3 CAMPOS
USE CLIENTES
REVOKE SELECT ON CUSTOMER4(id,firstname,lastname) FROM DBA2

/*
	Revoke x Deny
	- Revoke: retira a permissão
	- Deny: "proíbe" de executar comando
*/

-- SIMULE SE CONECTANDO COMO DBA2
EXECUTE AS LOGIN = 'DBA2';
SELECT SUSER_NAME(), USER_NAME(); 
--Verify the execution context is now DBA2.  
SELECT id,firstname,lastname FROM CUSTOMER4

-- REVERTA PARA SYSADMIN E TESTE ACESSO NOVAMENTE
REVERT
GO
SELECT id,firstname,lastname FROM CUSTOMER4

-- NEGANDO A PERMISSAO DIREITO DE CRIAR OBJETOS
DENY CREATE VIEW TO DBA2;
DENY CREATE TABLE TO DBA2;
DENY CREATE PROCEDURE TO DBA2;
DENY CREATE FUNCTION TO DBA2;

-- NEGANDO A PERMISSAO PARA EXECUTAR A PROCEDURE E FUNCTION FuncDesconto E queryTOPX
DENY EXECUTE ON FuncDesconto to DBA2
GO
DENY EXECUTE ON queryTOPX to DBA2
GO

-- VERIFICAR NOVAMENTE
-- Verificando as permissões do usuário "DBA2"
EXEC CLIENTES.dbo.sp_helprotect  @username = 'DBA2'

/*==============================================================
ROLES
==============================================================*/
-- CRIAR Role Via Script chamado ALLCustomer que vai dar permissao de select e 
-- insert na tabela Customer

USE [CLIENTES]
GO
CREATE ROLE [ALLCustomer]
GO
use [CLIENTES]
GO
GRANT INSERT ON [dbo].[Customer] TO [ALLCustomer]
GO
use [CLIENTES]
GO
GRANT SELECT ON [dbo].[Customer] TO [ALLCustomer]
GO

-- Criar uma Role de forma grafica no SSMS

-- Vincular USERS nestas roles

USE [CLIENTES]
GO
ALTER ROLE [ALLCustomer] ADD MEMBER [DBA1]
GO

-- e remover 

USE [CLIENTES]
GO
ALTER ROLE [ALLCustomer] DROP MEMBER [DBA1]
GO

/*==============================================================
SCHEMAS
==============================================================*/

CREATE DATABASE DBSCHEMA
GO

USE DBSCHEMA
GO

CREATE SCHEMA SALE
GO

CREATE SCHEMA FINANCIAL
GO

-- CRIANDO TABELA REQUEST NO SCHEMA SALE
CREATE TABLE SALE.REQUESTS(
	ID_ORDER int NOT NULL PRIMARY KEY,
	ID_CUSTUMER varchar(50) NULL,
	DELIVERY_DATE DATE NOT NULL,
	VALUE decimal(18, 0) NULL
) 

-- CRIANDO TABELA ACCOUNTS_PAY no Schema VENDAS
CREATE TABLE SALE.ACCOUNTS_PAY(
	ID_ORDER int NOT NULL PRIMARY KEY,
	ID_CUSTUMER varchar(50) NULL,
	EXPIRYDATE DATE NOT NULL,
	DATE_PAID DATE NOT NULL,
	VALUE decimal(18, 0) NULL
) 

CREATE TABLE SALE.ACCOUNTS_PAY_NEW(
	ID_ORDER int NOT NULL PRIMARY KEY,
	ID_CUSTUMER varchar(50) NULL,
	EXPIRYDATE DATE NOT NULL,
	DATE_PAID DATE NOT NULL,
	VALUE decimal(18, 0) NULL
) 

-- Changing the Schema of the table ACCOUNTS_PAY.
-- Transferido a tabela accounts_pay do schema SALE para FINANCIAL
ALTER SCHEMA FINANCIAL TRANSFER SALE.ACCOUNTS_PAY
GO

-- TESTING...
select * from FINANCIAL.ACCOUNTS_PAY
select * from SALE.REQUESTS

--DROP SCHEMAS
DROP SCHEMA SALE

ALTER SCHEMA FINANCIAL TRANSFER SALE.ACCOUNTS_PAY_NEW
GO
ALTER SCHEMA FINANCIAL TRANSFER SALE.REQUESTS
GO

--DROP SCHEMAS
DROP SCHEMA SALE

--VERIFICANDO TODOS SCHEMAS
USE DBSCHEMA
GO
select * from sys.schemas 

-- VERIFICAR AS TABELAS QUE FICARAM COM SCHEMA FINANCIAL

--CRIAR NOVO LOGIN PARA TER ACESSO AS TABELAS COM SCHEMA FINANCIAL

USE [master]
GO
CREATE LOGIN [USRFINANC] WITH PASSWORD=N'R$ABC178', 
	DEFAULT_DATABASE=[DBSCHEMA]

USE [DBSCHEMA]
GO
CREATE USER [USRFINANC] FOR LOGIN [USRFINANC]
GO

SELECT SYSTEM_USER

--Permissões
GRANT SELECT,INSERT ON SCHEMA::FINANCIAL TO USRFINANC
DENY DELETE ON SCHEMA::FINANCIAL TO USRFINANC

--TESTANDO SELECT SIMULANDO USUARIO USRFINANC

EXECUTE AS USER='USRFINANC'
SELECT SYSTEM_USER
GO

SELECT * FROM FINANCIAL.REQUESTS
SELECT * FROM FINANCIAL.ACCOUNTS_PAY
SELECT * FROM FINANCIAL.ACCOUNTS_PAY_NEW

DELETE FROM FINANCIAL.REQUESTS
DELETE FROM FINANCIAL.ACCOUNTS_PAY
DELETE FROM FINANCIAL.ACCOUNTS_PAY_NEW

REVERT
SELECT SYSTEM_USER

GRANT DELETE ON SCHEMA::FINANCIAL TO USRFINANC
GO

EXECUTE AS USER='USRFINANC'
SELECT SYSTEM_USER
GO

DELETE FROM FINANCIAL.REQUESTS
DELETE FROM FINANCIAL.ACCOUNTS_PAY
DELETE FROM FINANCIAL.ACCOUNTS_PAY_NEW

REVERT
SELECT SYSTEM_USER

-- DICAS
-- Desabilite a conta sa, ou altera o nome da conta sa. Os hackers ja sabem desta conta e na grande maioria dos casos não tem impacto no sql server e nas aplicaçóes. Faça teste em dev/qa antes.
-- Procure substituir o privilegio db_onwer para usuários ou conta de servico para db_datareader, db_datawriter, db_ddladmin e direito de executar as procedures.
-- Evite dar privilegio de db_securityadmin porque este usuario pode ser dar o privilegio depois de sysadmin e ser o dono da instancia sql.

-- Se ligar no sql server algum processo de auditoria, verificar o login_original, caso contrário, pode achar que está pegando o usuário que fez 
-- alguma alteracao em alguma tabela critica e na verdade estava rodando um comando como outro usuario atraves de um método IMPERSONATE:
   SELECT is_user_process, original_login_name, *
         FROM sys.dm_exec_sessions 
         where is_user_process=1
         ORDER BY login_time DESC
