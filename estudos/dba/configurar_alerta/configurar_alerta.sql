/*==================================================================================
ATIVIDADES ROTINEIRAS BÁSICAS DO DBA
CONFIGURANDO ALERTA
==================================================================================*/

-- 1. Criar Banco de dados Novo chamado BASETESTEALERTS e desligar a opcao de aumento automatico do arquivo de dados
-- e criar uma tabela chamada TBDADOSALERTS com dois campos ID INT IDENTITY(1,1) PRIMARYKEY e DESCRICAO NCHAR(150).

SELECT SERVERPROPERTY('productversion') VersaoSQL, 
       SERVERPROPERTY ('edition') Edicao,
	   SERVERPROPERTY('InstanceDefaultDataPath')LOCALIZACAO_DADOS,
	   SERVERPROPERTY('InstanceDefaultLogPath')LOCALIZACAO_LOGS,
	   SERVERPROPERTY('ServerName')SERVERNAME,
	   SERVERPROPERTY('InstanceName')INSTANCIA,
	   SERVERPROPERTY('IsHadrEnabled')HADR_Habilitado

CREATE DATABASE [BASETESTEALERTS]
 ON  PRIMARY 
( NAME = N'BASETESTEALERTS', FILENAME = N'D:\Developer\Data\BASETESTEALERTS.mdf' , SIZE = 3072KB , 
FILEGROWTH = 0)
 LOG ON 
( NAME = N'BASETESTEALERTS_log', FILENAME = N'D:\Developer\Log\BASETESTEALERTS_log.ldf' , 
SIZE = 1024KB , FILEGROWTH = 65536KB )
GO

USE BASETESTEALERTS
GO
CREATE TABLE [dbo].[TBDADOSALERTS](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[descricao] [nchar](150) NULL,
 CONSTRAINT [PK_TBDADOSALERTS] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)
) ON [PRIMARY]
GO

-- 2. Vamos preparar um script para povoar tabela TBDADOSALERTS com dados atraves do seguinte script,
-- mas nao executar ainda antes de criar o alerta.

USE BASETESTEALERTS 
GO

DECLARE @CONTA INT = 0
   WHILE @CONTA < 50000
      BEGIN
         INSERT INTO TBDADOSALERTS(DESCRICAO) VALUES ('REGISTRO> ' + CAST(@CONTA AS VARCHAR))
         SET @CONTA = @CONTA + 1
      END
GO

-- 3. Vamos criar um alerta para testarmos o alerta quando o arquivo mdf do banco de dados 
-- BASETESTEALERTS encher.

-- 3.1 tipo de alerta 1
-- error 823, 824,825 deve rodar o dbcc checkdb completo e verificar o disco de dados e sql server instalado

-- 3.2 tipo de alerta 2
--18 Há um problema com o software do mecanismo de banco de dados do sql server.
--19 Os limites dos paramentros do mecanismo de banco de dados foram excedidos e o job foi encerrado.
--20 Um comando sql encontrou um problema com a tarefa que provavelmente não causará danos ao próprio banco de dados.
--21 Foi encontrado um problema que afeta todas as tarefas no banco de dados, provavelmente não causará danos ao próprio banco de dados.
--22 Uma tabela ou índice foi danificado por um problema de software ou hardware.
--23 A integridade de todo o banco de dados está em questão devido a um problema de hardware ou software.
--24 Falha de mídia. 
--25 Erros inesperados, generalizado para todo o Microsoft SQL Server.

-- 3.3 tipo de alerta 3
-- Exemplo de alertas do tipo WMI, como por exemplo criacao, alteracao e delecao de base de dados,
-- criacao e delecao de logins, mudança de senhas, criacao de planos de manutencao, e outras similares

--4. Devera ser ativados alguns recursos para alerta WMI funcionar:
--4.0 Ligar VM DC para envio email
--4.1. executar o comando para ativar token do alarm
EXEC msdb.dbo.sp_set_sqlagent_properties @alert_replace_runtime_tokens = 1
GO
--4.2. verificar se o service broker esta ativo, se nao tiver, devera ativar.
SELECT is_broker_enabled  FROM sys.databases WHERE name = 'msdb'
go

Use msdb
go
alter database [MSDB] set single_user with rollback immediate
GO
alter database [MSDB] set Enable_Broker
GO
alter database [MSDB] set multi_user with rollback immediate
GO

-- EXEMPLOS para ativar os alertas WMI, e enviar os emails:

-- Para monitorar criacao de bancos de dados
select * from CREATE_DATABASE
-- Para monitorar delecao de bancos de dados
select * from DROP_DATABASE
-- Para monitorar alteracao de bancos de dados
select * from ALTER_DATABASE

-- Configurando o Alerta WMI para responder a eventos de mudança de login (habilitar / desabilitar login)
select * from AUDIT_SERVER_PRINCIPAL_MANAGEMENT_EVENT where EventSubClass = 5 or EventSubClass = 6	

-- Configurando o Alerta WMI para Responder ao Evento de Alteração de Senha de Login
select * from AUDIT_LOGIN_CHANGE_PASSWORD_EVENT	

-- exemplo no site microsoft
https://docs.microsoft.com/en-us/sql/ssms/agent/create-a-wmi-event-alert?view=sql-server-ver15
