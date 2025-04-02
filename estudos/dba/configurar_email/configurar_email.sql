/*==================================================================================
ATIVIDADES ROTINEIRAS BÁSICAS DO DBA
CONFIGURANDO EMAILS DE ALERTA
==================================================================================*/

-- Site outlook para criar conta email para teste 
https://www.microsoft.com/pt-pt/microsoft-365/outlook/email-and-calendar-software-microsoft-outlook

--MS SMTP NAME 
--smtp-mail.outlook.com
--port number 587

-- CHECANDO PORQUE OS EMAIL NAO ESTAO SENDO ENVIADOS
/*
1. verificar se o servidor de banco de dados está nas politicas que permitem enviar email.
   verificar com equipe de rede e seguranca. Devera ser liberado para este servidor enviar email.
   voce consegue realizar um teste no dos do servidor e demonstrar para pessoal de rede que o sql server esta bloqueado para envio de emails
   telnet mail.seudominio.com.br port

   exemplo>
   telnet smtp-mail.outlook.com 587

obs> se nao existir telnet, ir no server manager e instale em features
*/

--2. Database mail ativado?
sp_configure 'show advanced', 1; 
GO
RECONFIGURE;
GO
sp_configure;
GO

sp_configure 'Database Mail XPs', 1; 
GO
RECONFIGURE;
GO

--3 BUG SQL SERVER. 

--FIX: SQL Server 2016 Database Mail does not work on a computer that does not 
--have the .NET Framework 3.5 installed or stops working after applying SQL Server update
--https://support.microsoft.com/en-ie/help/3186435/sql-server-2016-database-mail-doesn-t-work-when-net-framework-3-5

--4 verifique se na pasta ...\MSSQL\BINN tem dois arquivos

--DatabaseMail e DatabaseMail.exe
--Se nao estiver, copie de outro servidor que tenha sql server instalado e funcionando o uso
--dos email ou pesquise na internet para realizar a instalacao do client de envio de email.
--A instalacao do .net framework deve resolver.

--5 realizar estas verificacoes nos logs das tentativas de envio de email as mensagens de emails nao enviados e emails enviados.

USE MSDB
GO

SELECT * FROM sysmail_event_log;
SELECT * FROM sysmail_faileditems; 
SELECT * FROM sysmail_sentitems; 

--6 verificar se o service broker esta ativo

USE master 
go 

SELECT database_id AS 'Database ID', 
       NAME        AS 'Database Name', 
       CASE 
         WHEN is_broker_enabled = 0 THEN 'Service Broker is disabled.' 
         WHEN is_broker_enabled = 1 THEN 'Service Broker is Enabled.' 
       END         AS 'Service Broker Status' 
FROM   sys.databases 
WHERE  NAME = 'msdb'

-- se nao estiver ativo no banco MSDB, ative atraves dos comandos abaixo.

use master
go
alter database [MSDB] set single_user with rollback immediate
GO
alter database [MSDB] set Enable_Broker
GO
alter database [MSDB] set multi_user with rollback immediate
GO
