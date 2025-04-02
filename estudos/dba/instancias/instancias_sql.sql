/*==================================================================================
Informacoes sobre Instancia SQL, Bancos de Dados e objetos, via Script SQL
==================================================================================*/
use master
go

SELECT SERVERPROPERTY('productversion') VersaoSQL, 
       SERVERPROPERTY ('edition') Edicao,
	   SERVERPROPERTY('InstanceDefaultDataPath')LOCALIZACAO_DADOS,
	   SERVERPROPERTY('InstanceDefaultLogPath')LOCALIZACAO_LOGS,
	   SERVERPROPERTY('ServerName')SERVERNAME,
	   SERVERPROPERTY('InstanceName')INSTANCIA,
	   SERVERPROPERTY('IsHadrEnabled')HADR_Habilitado
	
--Verificando informações do servidor
Select @@version 
-- Verificar ultimas versões e correções CUs, https://docs.microsoft.com/en-us/sql/database-engine/install-windows/latest-updates-for-microsoft-sql-server?view=sql-server-ver15

-- Retorna o nome do idioma que está sendo usado atualmente.
SELECT @@LANGUAGE

-- Retorna o nome do servidor que está executando o SQL Server.
SELECT @@SERVERNAME

--Retorna a ID de sessão do processo de usuário atual.
SELECT @@SPID
-- kill para matar processos.

-- Retorna informacoes basica sobre os bancos de dados
select name, crdate,filename from sysdatabases

-- Retorna mais informacoes sobre os bancos de dados
SELECT name, create_date, recovery_model_desc, 
compatibility_level, collation_name, is_read_committed_snapshot_on,state_desc 
FROM sys.databases

-- Retorna alertas configurados. 
use msdb
go
select name, severity, enabled from sysalerts

-- Retorna informações sobre itens do servidor e banco de dados que estão sendo auditados
select audit_action_name from sys.server_audit_specification_details 
select distinct audit_action_name from sys.database_audit_specification_details

-- Retorna os parametros da instancia sql server
-- https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/server-configuration-options-sql-server?view=sql-server-ver15
sp_configure

-- Como alterar um parametro via SCRIPT SQL
EXEC sp_configure 'backup compression default', '1';
RECONFIGURE;

EXEC sp_configure 'backup compression default', '0';
RECONFIGURE;

-- Para verificar todas as opções do sp_configure
USE master;
GO
EXEC sp_configure 'show advanced option', '1'; --Enable advanced options
RECONFIGURE;
EXEC sp_configure --Show all the options
EXEC sp_configure 'show advanced option', '0'; --Always disable advanced options
RECONFIGURE;

-- Retorna dados de tabelas e views do banco de dados CLIENTES
use CLIENTES
go
SELECT 
    DISTINCT NAME,* 
FROM SYS.OBJECTS
WHERE TYPE IN ('U','V')
-- AND NAME= 'MYNAME'
-- U = User Table, V = View

-- Uma outra forma de retornar dados de tabelas e views
SELECT * FROM INFORMATION_SCHEMA.TABLES

-- Retornar dados especificos de views, inclusive o proprio script da view
SELECT * FROM INFORMATION_SCHEMA.VIEWS
