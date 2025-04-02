/*==================================================================================
ATIVIDADES ROTINEIRAS BÁSICAS DO DBA
CONFIGURANDO AUDITORIA
==================================================================================*/

-- VAMOS CRIAR NOSSA BASE DE DADOS DE SUPORTE DO DBA E UMA TABELA DE APOIO
-- PARA GUARDAR DADOS NO BANCO DE AUDITORIA

CREATE DATABASE [AuditoriaDBA]
 CONTAINMENT = NONE
 ON  PRIMARY
( NAME = N'AuditoriaDBA', FILENAME = N'D:\Developer\Data\AuditoriaDBA.mdf' , SIZE = 10000KB , MAXSIZE = 30000KB , FILEGROWTH = 1000KB )
 LOG ON
( NAME = N'AuditoriaDBA_log', FILENAME = N'D:\Developer\Log\AuditoriaDBA_log.ldf' , SIZE = 3000KB , MAXSIZE = 6000KB , FILEGROWTH = 1000KB )
GO

USE [AuditoriaDBA]
GO

CREATE TABLE [dbo].[AuditoriaComando](
	[event_time] [datetime2](7) NOT NULL,
	[sequence_number] [int] NOT NULL,
	[action_id] [varchar](4) NULL,
	[succeeded] [bit] NOT NULL,
	[permission_bitmask] [varbinary](16) NOT NULL,
	[is_column_permission] [bit] NOT NULL,
	[session_id] [smallint] NOT NULL,
	[server_principal_id] [int] NOT NULL,
	[database_principal_id] [int] NOT NULL,
	[target_server_principal_id] [int] NOT NULL,
	[target_database_principal_id] [int] NOT NULL,
	[object_id] [int] NOT NULL,
	[class_type] [varchar](2) NULL,
	[session_server_principal_name] [nvarchar](128) NULL,
	[server_principal_name] [nvarchar](128) NULL,
	[server_principal_sid] [varbinary](85) NULL,
	[database_principal_name] [nvarchar](128) NULL,
	[target_server_principal_name] [nvarchar](128) NULL,
	[target_server_principal_sid] [varbinary](85) NULL,
	[target_database_principal_name] [nvarchar](128) NULL,
	[server_instance_name] [nvarchar](128) NULL,
	[database_name] [nvarchar](128) NULL,
	[schema_name] [nvarchar](128) NULL,
	[object_name] [nvarchar](128) NULL,
	[statement] [nvarchar](4000) NULL,
	[additional_information] [nvarchar](4000) NULL,
	[file_name] [nvarchar](260) NOT NULL,
	[audit_file_offset] [bigint] NOT NULL,
	[user_defined_event_id] [smallint] NOT NULL,
	[user_defined_information] [nvarchar](4000) NULL,
	[audit_schema_version] [int] NOT NULL,
	[sequence_group_id] [varbinary](85) NULL,
	[transaction_id] [bigint] NOT NULL,
	[client_ip] [nvarchar](128) NULL,
	[application_name] [nvarchar](128) NULL,
	[duration_milliseconds] [bigint] NOT NULL,
	[response_rows] [bigint] NOT NULL,
	[affected_rows] [bigint] NOT NULL,
	[connection_id] [uniqueidentifier] NULL,
	[data_sensitivity_information] [nvarchar](4000) NULL,
	[host_name] [nvarchar](128) NULL
) ON [PRIMARY]
GO


CREATE TABLE [dbo].[CLIENTE](
[idcliente] [int] NOT NULL,
[nomecliente] [varchar](30) NULL
) ON [PRIMARY]
GO

-- CONFIGURANDO AUDITORIA VIA SCRIPT
-- Quando for definir a auditoria, os dados gravados poderão ser salvos de 3 maneiras:
-- 1. File: É gerado um arquivo físico no disco contendo os dados coletados pela auditoria. Opcao interessante e no meu ponto de vista a melhor. 
--       Procure utilizar um disco rapido com bom tamanho e faça backup destes files. Se o disco náo for rapido, como seu disco de dados, se for bem mais lento
--       as gravacoes dos inserts, updates e deletes dos dados dos seus clientes, podem ser impactados se houver uma grande quantidade de processos ao mesmo tempo,
--       porque pode ser gerados waits na espera da gavacao dos logs no disco de dados, ou mesmo no event viewer que pode estar sendo salvo no disco c. Neste caso
--       se nao puder mudar o disco da auditoria, pode mudar o padrao do queue_delay de 1000(1 segundo) para por exemplo 30000(30 segundos), ou seja, a cada transacao
--       o sql server vai gerar as auditorias a cada 30 segundo, mas nao ira perder dados para auditoria, só ira retardar o envio para o arquivo de auditoria, mas reduzindo
--       assim o wait de aguarde de auditoria.
-- 2. Security Log: Os dados coletados pela auditoria ficam armazenados no log de segurança do servidor (event viewer)
-- 3. pplication Log: Os dados coletados pela auditoria ficam armazenados no log de aplicação do servidor (event viewer)

-- Explicacoes sobre os tipos de auditorias
https://docs.microsoft.com/pt-br/sql/relational-databases/security/auditing/sql-server-audit-action-groups-and-actions?view=sql-server-ver15

-- OBSERVACAO IMPORTANTE> 
-- ATENCAO POIS QUANDO HABILITA OU DESABILITA QUALQUER AUDITORIA, O SQL SERVER REALIZA BLOQUEIOS EM TABELAS DOS BANCOS DE DADOS DOS USUARIOS
-- QUANDO FAZ DE FORMA GRAFICA, ELE TEM UM TIMEOUT PARA DESISTIR DO BLOQUEIO MAS USANDO CODIGO NAO. CUIDADO NO MOMENTO QUE APLICAR OU DESABILITAR
-- UMA AUDITORIA POIS PODE IMPACTAR A PRODUCAO. 

USE [master]
GO

/****** Object:  Audit [audit-ddl-dml]    Script Date: 1/31/2021 2:16:35 PM ******/
CREATE SERVER AUDIT [audit-ddl-dml]
TO APPLICATION_LOG
WITH
( QUEUE_DELAY = 30000
,ON_FAILURE = CONTINUE
,AUDIT_GUID = '5ddd7be9-6b8a-45a9-83c6-27233e5307ae'
)
WHERE ( NOT [server_principal_name] like 'NT SERVICE\%' AND NOT [server_principal_name] like 'NT AUTHORITY\%')
ALTER SERVER AUDIT [audit-ddl-dml] WITH (STATE = ON)
GO

USE [master]
GO

/****** Object:  Audit [audit-ddl-dml-TOFILE]    Script Date: 1/31/2021 2:18:00 PM ******/
CREATE SERVER AUDIT [audit-ddl-dml-TOFILE]
TO FILE
( FILEPATH = N'L:\SQLAUDIT\'
,MAXSIZE = 0 MB
,MAX_ROLLOVER_FILES = 2147483647
,RESERVE_DISK_SPACE = OFF
)
WITH
( QUEUE_DELAY = 30000
,ON_FAILURE = CONTINUE
,AUDIT_GUID = 'fb4d4f2b-6378-479b-9f2e-60344b1f2869'
)
WHERE (NOT [server_principal_name] like 'NT SERVICE\%' AND NOT [server_principal_name] like 'NT AUTHORITY\%')
ALTER SERVER AUDIT [audit-ddl-dml-TOFILE] WITH (STATE = ON)
GO

USE [master]
GO

/****** Object:  Audit [audit-fl-uc-cpu-ca]    Script Date: 1/31/2021 2:18:24 PM ******/
CREATE SERVER AUDIT [audit-fl-uc-cpu-ca]
TO APPLICATION_LOG
WITH
( QUEUE_DELAY = 30000
,ON_FAILURE = CONTINUE
,AUDIT_GUID = '2f41d0c4-2c1d-493d-a836-e2432364184f'
)
ALTER SERVER AUDIT [audit-fl-uc-cpu-ca] WITH (STATE = ON)
GO

USE [master]
GO

/****** Object:  Audit [audit-fl-uc-cpu-ca-TOFILE]    Script Date: 1/31/2021 2:18:46 PM ******/
CREATE SERVER AUDIT [audit-fl-uc-cpu-ca-TOFILE]
TO FILE
( FILEPATH = N'L:\SQLAUDIT\'
,MAXSIZE = 0 MB
,MAX_ROLLOVER_FILES = 2147483647
,RESERVE_DISK_SPACE = OFF
)
WITH
( QUEUE_DELAY = 30000
,ON_FAILURE = CONTINUE
,AUDIT_GUID = '65b83e69-9236-4392-874c-5c8be1dd36df'
)
WHERE (NOT [server_principal_name] like 'NT SERVICE\%' AND NOT [server_principal_name] like 'NT AUTHORITY\%')
ALTER SERVER AUDIT [audit-fl-uc-cpu-ca-TOFILE] WITH (STATE = ON)
GO

USE [master]
GO

/****** Object:  Audit [audit-logins]    Script Date: 1/31/2021 2:18:59 PM ******/
CREATE SERVER AUDIT [audit-logins]
TO APPLICATION_LOG
WITH
( QUEUE_DELAY = 30000
,ON_FAILURE = CONTINUE
,AUDIT_GUID = 'db57e6a0-5fb7-4f11-8856-ca6a2ec9406e'
)
ALTER SERVER AUDIT [audit-logins] WITH (STATE = ON)
GO

USE [master]
GO

/****** Object:  Audit [audit-logins-TOFILE]    Script Date: 1/31/2021 2:19:53 PM ******/
CREATE SERVER AUDIT [audit-logins-TOFILE]
TO FILE
( FILEPATH = N'L:\SQLAUDIT\'
,MAXSIZE = 0 MB
,MAX_ROLLOVER_FILES = 2147483647
,RESERVE_DISK_SPACE = OFF
)
WITH
( QUEUE_DELAY = 30000
,ON_FAILURE = CONTINUE
,AUDIT_GUID = '580dc6b0-26d5-4b2d-8fea-c4d74d1ce870'
)
WHERE (NOT [server_principal_name] like 'NT SERVICE\%' AND NOT [server_principal_name] like 'NT AUTHORITY\%')
ALTER SERVER AUDIT [audit-logins-TOFILE] WITH (STATE = ON)
GO

--------- server audit specifications

USE [master]
GO

CREATE SERVER AUDIT SPECIFICATION [fl-uc-cpu-ca]
FOR SERVER AUDIT [audit-fl-uc-cpu-ca]
ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP),
ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP),
ADD (AUDIT_CHANGE_GROUP),
ADD (DATABASE_PERMISSION_CHANGE_GROUP),
ADD (DATABASE_OBJECT_PERMISSION_CHANGE_GROUP),
ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP),
ADD (SERVER_OBJECT_PERMISSION_CHANGE_GROUP),
ADD (SERVER_PERMISSION_CHANGE_GROUP),
ADD (FAILED_LOGIN_GROUP),
ADD (DATABASE_PRINCIPAL_CHANGE_GROUP),
ADD (SERVER_PRINCIPAL_CHANGE_GROUP),
ADD (LOGIN_CHANGE_PASSWORD_GROUP),
ADD (DATABASE_OWNERSHIP_CHANGE_GROUP),
ADD (DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP),
ADD (SERVER_OBJECT_OWNERSHIP_CHANGE_GROUP),
ADD (USER_CHANGE_PASSWORD_GROUP)
WITH (STATE = ON)
GO

USE [master]
GO

CREATE SERVER AUDIT SPECIFICATION [fl-uc-cpu-ca-TOFILE]
FOR SERVER AUDIT [audit-fl-uc-cpu-ca-TOFILE]
ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP),
ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP),
ADD (AUDIT_CHANGE_GROUP),
ADD (DATABASE_PERMISSION_CHANGE_GROUP),
ADD (DATABASE_OBJECT_PERMISSION_CHANGE_GROUP),
ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP),
ADD (SERVER_OBJECT_PERMISSION_CHANGE_GROUP),
ADD (SERVER_PERMISSION_CHANGE_GROUP),
ADD (FAILED_LOGIN_GROUP),
ADD (DATABASE_PRINCIPAL_CHANGE_GROUP),
ADD (SERVER_PRINCIPAL_CHANGE_GROUP),
ADD (LOGIN_CHANGE_PASSWORD_GROUP),
ADD (DATABASE_OWNERSHIP_CHANGE_GROUP),
ADD (DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP),
ADD (SERVER_OBJECT_OWNERSHIP_CHANGE_GROUP),
ADD (USER_CHANGE_PASSWORD_GROUP)
WITH (STATE = ON)
GO

USE [master]
GO

CREATE SERVER AUDIT SPECIFICATION [logins]
FOR SERVER AUDIT [audit-logins]
ADD (FAILED_LOGIN_GROUP),
ADD (SUCCESSFUL_LOGIN_GROUP)
WITH (STATE = ON)
GO

USE [master]
GO

CREATE SERVER AUDIT SPECIFICATION [logins-TOFILE]
FOR SERVER AUDIT [audit-logins-TOFILE]
ADD (FAILED_LOGIN_GROUP),
ADD (SUCCESSFUL_LOGIN_GROUP)
WITH (STATE = ON)
GO

--- database audity specifications

USE [AUDITORIADBA]
GO
CREATE DATABASE AUDIT SPECIFICATION [audit-ddl-dml]
FOR SERVER AUDIT [audit-ddl-dml]
ADD (SCHEMA_OBJECT_CHANGE_GROUP),
ADD (DELETE ON SCHEMA::[dbo] BY [public]),
ADD (EXECUTE ON SCHEMA::[dbo] BY [public]),
ADD (INSERT ON SCHEMA::[dbo] BY [public]),
ADD (UPDATE ON SCHEMA::[dbo] BY [public]),
ADD (DELETE ON SCHEMA::[dbo] BY [dbo]),
ADD (EXECUTE ON SCHEMA::[dbo] BY [dbo]),
ADD (INSERT ON SCHEMA::[dbo] BY [dbo]),
ADD (UPDATE ON SCHEMA::[dbo] BY [dbo])
WITH (STATE = ON)
GO

USE [AUDITORIADBA]
GO
CREATE DATABASE AUDIT SPECIFICATION [audit-ddl-dml-TOFILE]
FOR SERVER AUDIT [audit-ddl-dml-TOFILE]
ADD (SCHEMA_OBJECT_CHANGE_GROUP),
ADD (DELETE ON SCHEMA::[dbo] BY [public]),
ADD (EXECUTE ON SCHEMA::[dbo] BY [public]),
ADD (INSERT ON SCHEMA::[dbo] BY [public]),
ADD (UPDATE ON SCHEMA::[dbo] BY [public]),
ADD (DELETE ON SCHEMA::[dbo] BY [dbo]),
ADD (EXECUTE ON SCHEMA::[dbo] BY [dbo]),
ADD (INSERT ON SCHEMA::[dbo] BY [dbo]),
ADD (UPDATE ON SCHEMA::[dbo] BY [dbo])
WITH (STATE = ON)
GO

-- REALIZANDO TEESTES DE INSERT, DELETE E UPDATE EM UMA TABELA NO BANCO DE DADOS AUDITORIADBA

--Verificando conteudo em uma system sql table 
select  * from sys.fn_get_audit_file
('L:\SQLAUDIT\*.sqlaudit', default, default)

-- Se quiser ser mais restritivo e quiser excluir alguns comandos e usuarios
select  * from sys.fn_get_audit_file
('L:\SQLAUDIT\*.sqlaudit', default, default)
where
statement is not null           and
statement <> ''                 and
action_id <> 'LGIS'             

-- realizar algumas operacoes de inserts, deletes e updates na tabela AuditoriaComandos do banco AuditoriaDBA e verificar novamente o conteudo da tabela
-- sys.fn_get_audit_file
USE AUDITORIADBA
GO
insert into CLIENTE (idcliente,nomecliente) values (1,'Pedro Ambrosio silva')
go
insert into CLIENTE (idcliente,nomecliente) values (2,'Jose Mario')
go
delete from CLIENTE where idcliente = 1
go
update CLIENTE set nomecliente = 'Jose Mario FILHO'
where idcliente = 2
go
select * from cliente
go

-- Vamos ver o resultado
select  * from sys.fn_get_audit_file
('L:\SQLAUDIT\*.sqlaudit', default, default)
where
statement is not null           and
statement <> ''                 and
action_id <> 'LGIS'            


-- Vamos agora criar o job que ira rodar todos os dias, pegar os dados que foram alterados, de dentro da system table e salvar em nossa tabela de auditoria

USE [msdb]
GO

/****** Object:  Job [AuditDB_ExecComandos_No_Banco]    Script Date: 2/1/2021 2:07:33 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 2/1/2021 2:07:33 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'AuditDB_ExecComandos_No_Banco', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'dbas', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Checa Comandos SQL de Usuários]    Script Date: 2/1/2021 2:07:33 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Checa Comandos SQL de Usuários', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE AUDITORIADBA
insert into AuditoriaDBA..AuditoriaComando
select  * from sys.fn_get_audit_file
(''L:\SQLAUDIT\*.sqlaudit'', default, default)
where
statement is not null           and
statement <> ''''                 and
action_id <> ''LGIS''           
-- AND day(event_time) = day(getdate()) -- colocar esta clausula no job para inserir apenas as auteracoes que ocorreram no dia corrente e colocar job para rodar todos os dia no final do dia
GO
', 
		@database_name=N'AuditoriaDBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Checa Comandos SQL vindos Usuarios', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200201, 
		@active_end_date=99991231, 
		@active_start_time=235559, 
		@active_end_time=235959, 
		@schedule_uid=N'9c8ddbe5-6b1b-4c3e-a780-461c67d80c92'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

-- Vamos verificar o conteudo da tabela que ira receber os dados da auditoria, antes de rodar o job
select * from  AuditoriaDBA..AuditoriaComando

-- Vamos rodar o job para ler as alteracoes realizadas na tabela CLIENTE e verificar novamente o conteudo da tabela
select * from  AuditoriaDBA..AuditoriaComando

-- NOTA IMPORTANTE:
-- Se ligar no sql server algum processo de auditoria, verificar o login_original, caso contrário, pode achar que está pegando o usuário que fez 
-- alguma alteracao em alguma tabela critica e na verdade estava rodando um comando como outro usuario atraves de um método IMPERSONATE:
   SELECT is_user_process, original_login_name, *
         FROM sys.dm_exec_sessions 
         where is_user_process=1
         ORDER BY login_time DESC
