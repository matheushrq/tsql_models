use StackOverflow2010
go

  /*==================================================================================
ATIVIDADES ROTINEIRAS BÁSICAS DO DBA
PERFORMANCE
==================================================================================*/

--Baixar bases de dados stackoverflow
--https://www.brentozar.com/archive/2015/10/how-to-download-the-stack-overflow-database-via-bittorrent/

--baixar software stress
--SQL query stress simulator originally created by Adam Machanic 
--https://www.microsoft.com/pt-br/p/sqlquerystress/9n46qj5sbgkb?activetab=pivot:overviewtab#
--https://github.com/ErikEJ/SqlQueryStress

/*==================================================================================*/

-- Lab1


--0. Antes de começar, vamos no Virtual Box, disponibilizar mais nucleos da CPU para nossa VM e no SSMS verificar a configuração de memória para SQL SERVER e deixar pelo menos 2GB para Windows.

--1. Abrir task manager e verificar uso de cpu, memoria e disco
--2. abrir ssms e conectar base de dados StackOverflow2010
--3. Executar :


	DBCC DROPCLEANBUFFERS  -- vamos limpar os dados que estao em cache. Nao faça isto em producao.
	DBCC FREEPROCCACHE
	GO
    
   use StackOverflow2010
   go

   select * from [dbo].[Votes]
   go 10

--4. Verificar uso de cpu e memória e disco
--5. Rodar sys padroes do SQL SERVER e tentar descobrir o que está consumindo mais recursos
   sp_who2
   go
   sp_who
   go

--6. Acessar http://whoisactive.com/
--   Baixar a procedure e implantar em uma base de dados de apoio ou master

--7  Executar :
   
   -- Ligar o Plano de Execuçáo Estimado e Atual Plano de Execução. 
   -- e ligar 
              SET STATISTICS IO ON 
              SET STATISTICS TIME ON

   -- Abrir task manager e verificar utilizacao cpu quando a consulta rodar e reparar o uso da cpu quando os dados aparecem na tela e sao carregados

    DBCC DROPCLEANBUFFERS  -- vamos limpar os dados que estao em cache. Nao faça isto em producao.
    DBCC FREEPROCCACHE
    GO
  
   select * from [dbo].[Votes] order by CreationDate desc

   -- Alterar nivel de paralelismo na configuração da instancia e colocar para rodar novamente. Verificar nivel de cpu e tempo de execucao.

    DBCC DROPCLEANBUFFERS  -- vamos limpar os dados que estao em cache. Nao faça isto em producao.
    DBCC FREEPROCCACHE
    GO
  
   select * from [dbo].[Votes] order by CreationDate desc

--8. Rodar em outra aba sp_whoisactive e verificar se agora consegue identificar qual procedure estava a consumir mais recursos
   use master
   go
   sp_whoisactive

   --- Abra 3 sessoes novas no querie e coloque para rodar ao mesmo tempo 
    select * from [dbo].[Votes] 
    go 10

   --Verifique quais processos do sql server estáo sendo impactados com algum tipo de waits: 
    --https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-wait-stats-transact-sql?view=sql-server-ver15
    --Veja a lista dos waits

    --Através deste comando conseguirá ver os maiores waits desde ultimo sql server start
    select * from sys.dm_os_wait_stats 
    order by wait_time_ms desc

    --Posso forçar e apagar a lista para realizar um teste novo e verificar se os problemas continuam apos alguma intervençao:
    DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR);  
    GO 

    --Rodar novamente para ver os waits
    select * from sys.dm_os_wait_stats 
    order by wait_time_ms desc

   --Verificar a sessão com maior peso e matar o processo, apenas em situacoes muito criticas para evitar parar o sql server:
   
   Kill Session_id

   --obs> documentacao da sp_whoisactive 
        http://whoisactive.com/docs/

--9. Vamos usar um outro ótimo procedimento que basicamente faz a mesma coisa que a whoisactive com alguns elementos a mais
   
   --https://www.brentozar.com/archive/2017/10/get-live-query-plans-sp_blitzwho/    

   --Executar :
   select * from [dbo].[Votes]
   go 10

   --Em outra aba rodar: sp_BlitzWho e sp_blitzcache (ver o que está rodando com mais peso). Deixei o codigo sp_blitzcache no final deste arquivo, mas o ideal é baixar do site abaixo:

  --https://www.brentozar.com/blitzcache/

  -- Depois de rodar sp_blitzcache limpar os buffers e remover os 
  -- planos do cache e rodar novamente.

    use master
    go
    sp_BlitzCache
    go

    DBCC DROPCLEANBUFFERS  -- vamos limpar os dados que estao em cache. Nao faça isto em producao.
    DBCC FREEPROCCACHE
    GO
    use StackOverflow2010
    go
    select top 1000 * from [dbo].[Votes] order by CreationDate
    go 10

  -- Parar a execucao antes do final e verificar se entrou no buffercache com 
     use master
     go
     sp_blitzcache

  -- e rodar novamente este codigo mais rapido 
    use StackOverflow2010
    go
    select top 100 * from [dbo].[Votes] order by CreationDate

   -- e verificar novamente 
   use master
   go
   sp_blitzcache

   -- e no sp_blitzcache retirar do cache apenas o comando select (coluna remove plan handle from cache)
   -- DBCC FREEPROCCACHE (....);
   -- e verificar novamente 
    use master
    go
    sp_blitzcache

    -- Vamos rodar agora este select e vamos verificar o total de leituras e o custo: 
    -- ligar actual execution plan e ligar estatisticas de leitura e tempo de cpu

    DBCC DROPCLEANBUFFERS  -- vamos limpar os dados que estao em cache. Nao faça isto em producao.
    DBCC FREEPROCCACHE
    GO
    set statistics io, time on
    use StackOverflow2010
    go
    select top 10 id from [dbo].[Votes] order by CreationDate -- vai primeiro ordenar toda a tabela por creationdate para depois pegar os 10 primeiros
   
    -- Rode novamente o mesmo comando sem limpar o cache. O tempo será o mesmo porque
    -- o SQL SERVER roda o mesmo comando. O que ele guarda no cache sao os planos que 
    -- o otimizador de queires usa, dados que ja estavam na memoria mas nao por exemplo
    -- a ordenacao, ou transformacoes dos dados, filtros de busca, etc 

     select top 10 id from [dbo].[Votes] order by CreationDate

    -- AINDA, NAO ADIANTA COLOCAR TOP e colocar um order by em uma tabela grande, 
    -- sem um indice, porque o SQL Server ira ler toda a tabela para depois limitar 
    -- em top x para demonstrar.

    -- Veja a quantidade de leituras feitas em numeros de paginas, e agora rede sem o order by.

    select top 10 id from [dbo].[Votes] -- Verifique o plano de execucao e o custo e veja quantidade de paginas de dados lidas e o tempo

  -- Agora crie um indice pelo SSMS, no campo creationdate e rode novamente:

    select top 10 id from [dbo].[Votes] order by CreationDate

   -- Verificar o plano de execucao que agora fez index scan em uma faixa de 10 registros 
   -- no novo indice criado e verificar a quantidade de leituras logicas realizadas
    
    -- ver indice criado 
	sp_helpindex votes

    -- deletar o indice novo criado 
    drop index [...] on votes

    -- ver indice criado pelo script e no SSMS, modo GUI.
	 sp_helpindex votes

    -- e rodar novamente o comando com order by e vera que o problema de leitura 
	-- excessiva e perda de performance retorna

    select top 10 id from [dbo].[Votes] order by CreationDate

    -- e agora vamos colocar um filtro
   select top 10 * from [dbo].[Votes] where postid = 999999
   order by CreationDate

   -- e vamos ver o resultado em termos de quantidade de leitura, o 
   -- tempo e o tipo de leitura feito no plano.

  -- Agora vamos criar um indice por este campo postid

  USE [StackOverflow2010]
  GO
  CREATE NONCLUSTERED INDEX [idxVotesPostid1]
  ON [dbo].[Votes] ([PostId])
  go

-- e vamos rodar novamente e verificar a quantidade de leitura e o plano utilizado

   select top 10 id, postid from [dbo].[Votes] where postid = 999999

-- e agora rode estes dois processos e veja a diferença e resposta porque apareceu operador Key Lookup?

   select top 10 id, postid from [dbo].[Votes] where postid = 999999
   order by CreationDate
   go

   select top 10 * from [dbo].[Votes] where postid = 999999
   go

-- vamos relembrar os principais status dos waits
   select * from [dbo].[Votes] 
   order by CreationDate
   WAITFOR DELAY '00:10';
   go 100

-- abra uma nova janela e roda 
use master
go
sp_whoisactive

-- Main Status (waits):

-- Running means just that, the process is on the CPU, currently working.
-- Pending means The session is waiting for a worker thread to become available.
-- Runnable means it's waiting to be scheduled on to the CPU.
-- Suspended means it's waiting for something (eg lock, latch, memory grant, etc)

-- Verificar o TASK MANAGER,  ACTIVY MONITOR DO SQL SERVER 

-- Verificar PERFMON 

--  https://docs.microsoft.com/en-us/azure/monitoring/infrastructure-health/vmhealth-windows/winserver-memory-pagespersec
--  https://www.poweradmin.com/blog/pages-per-second-counters/

--  Vamos ligar o Contador (pages/sec) e colocar para rodar um bloco abaixo de cada vez e verificar o contador

   select  Id, Age from [dbo].[users] 
   go 100

   select  Id, Age, AboutMe from [dbo].[users] -- qual a caracteristica do campo aboutme?
   go 100

 -- Se o contador PAGES/SEC mostrar consistentemente mais de 40 páginas por segundo em um disco lento ou 300 páginas por segundo em um disco rápido,
 -- você deve investigar. A memória do seu sistema pode estar muito pequena para a carga de processamento.
 -- você pode resolver esse problema simplesmente adicionando mais memória ao servidor ou pode ser por falta de indices, falta atualizacao das estatisticas
 -- ou por exemplo codigo sql mal feito por exemplo que esta fazendo o SQL SERVER
 -- ler mais dados do disco do que é necessário e trazer mais dados para memória e assim retirar outros dados que ja estavam na memória.

-- Outros contadores. Os numeros são sugestoes mas depende de cada ambiente e criticidade do ambiente

/*
Processor:% Processor Time
*Should average below 75% (and preferably below 50%).

System: Processor Queue Length
*Should average below 2 per processor. For example, in a 2-processor machine, it should remain below 4.

Memory—Available Bytes
*Should remain above 50 MB.

Physical Disk—% Disk Time
*Should average below 50%.

Physical Disk—Avg. Disk Queue Length
*Should average below 2 per disk. For example, for an array of 5 disks, this figure should average below 10.

Physical Disk—Avg. Disk Reads/sec
*Used to size the disk and CPU. Should be below 85% of the capacity of the drive.

Physical Disk—Avg. Disk Writes/ sec
*Used to size the disk and CPU. Should be below 85% of the capacity of the drive.

Network Interface—Bytes Total/sec
*Used to size the network bandwidth.

SQL Server: Buffer Manager— Buffer Cache Hit Ratio
*Should exceed 90% (and ideally approach 99%).

SQL Server: Buffer Manager—Page Life Expectancy
*Used to size memory. Should remain above 300 seconds.

SQL Server: General Statistics— User Connections
*Used to size memory.

SQL Server: Databases— Transactions/sec
*Used to size disks and CPU.

SQL Server: Databases—Data File(s) Size KB
*Used to size the disk subsystem.

SQL Server: Databases—Percent Log Used
*Used to size the disk subsystem.
*/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Lab2

-- 1 Vamos rodar estes 2 codigos em duas sessoes de forma paralela e verificar o que esta ocorrendo no sql server com sp_whoisactive em outra sessao e verificar o campo blocking_session_id

  set statistics time, io on 
  use StackOverflow2010 
  select  id, age from [dbo].[users]

  use StackOverflow2010 
  select  * from [dbo].[users]

-- 2 Agora abra uma nova sessao e rode este codigo e verifique os waits e a coluna blocing_session_id no sp_whoisactive
begin tran
UPDATE users  
SET Age = 18  

-- 3 Verifique se os selects ja terminaram de executar e ler todos os dados e abra uma nova janela com este codigo
  use StackOverflow2010 
  select  id, age from [dbo].[users] with (nolock)

-- 4 Agora va para a sessao onde terminou de rodar o update, e vamos simular que houve um erro no update e náo pode ser completado. Vamos execucar um rollback e logo depois vamos
-- rodar novamente o comando select  id, age from [dbo].[users] with (nolock)
--.Como ficou os dados que foram alterados para 18 mas nao confirmados com o commando implicito ou explicito commit?
-- O que aconteceria se naquele momento tivesse gerado um relatorio e entregue para sua diretoria ou cliente?
-- Antes verifique o sp_whoisactive quais processos que ainda estao rodando.

-- 5 Algumas opcoes do sp_whoisactive
--http://whoisactive.com/docs/06_options/

 sp_whoisactive @help = 1

-- 6 Abrir uma nova sessao e rodar o codigo
  use StackOverflow2010 
  select  * from [dbo].[users] order by aboutme
  option (maxdop 0) -- com este maxdop ira utilizar todos os nucleos da cpu, mesmo que em nivel de instancia esteja marcado para nao fazer procesamento paralelo em max degree os paralelism
                    -- se um determinado processo estiver rodando com processamento em paralelo e gerando problemas de perda de performance recebera o wait CXPACKET no sp_whoisactive
  go 100

-- abrir uma nova sessao e rodar o sp_whoisactive com o parametro para ver o plan de execucao
use master
go
sp_whoisactive @get_plans = 1 -- this gives you the execution plans for running queries.


-- 7 Abrir a sessao do update e rodar novamente
use StackOverflow2010 
select  * from [dbo].[users] order by aboutme
go 10

-- abrir uma nova sessao e rodar
sp_whoisactive @get_locks = 1  –- gives you an XML snippet you can click on to see what table, row, object, etc locks each query owns. Useful when you’re trying to figure out why one query is blocking others.
-- Verificar a coluna locks

-- 8 Agora rodar este comando

begin tran
UPDATE users  
SET Age = 18  

-- e uma nova sessao verificar a coluna lock
sp_whoisactive @get_locks = 1 – gives you an XML snippet you can click on to see what table, row, object, etc locks each query owns. Useful when you’re trying to figure out why one query is blocking others.


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Lab 3

-- Vamos criar um job para ser executado ha cada 1 minuto e guardar o resultado da execucao do sp_whoisactive em uma tabela de auditoria no banco AUDITORIADBA
-- segue o codigo SQL

use master
go

SET NOCOUNT ON;
 
DECLARE @retention INT = 60,  -- Numero de dias que os dados serão guardados. Pode alterar para guardar por mais dias.
        @destination_table VARCHAR(500) = 'WhoIsActive', -- tabela que sera criada no banco de dados de auditoria.
        @destination_database sysname = 'AuditoriaDBA', -- deixar este nome do banco de auditoria ou criar banco novo, onde o script ira criar a tabela WhoisActive
        @schema VARCHAR(MAX),
        @SQL NVARCHAR(4000),
        @parameters NVARCHAR(500),
        @exists BIT;
 
SET @destination_table = @destination_database + '.dbo.' + @destination_table;
 
--create the logging table
IF OBJECT_ID(@destination_table) IS NULL
    BEGIN;
        EXEC dbo.sp_WhoIsActive @get_transaction_info = 1,
                                @get_outer_command = 1,
                                @get_plans = 1,
                                @return_schema = 1,
                                @schema = @schema OUTPUT;
        SET @schema = REPLACE(@schema, '<table_name>', @destination_table);
        EXEC ( @schema );
    END;
 
--create index on collection_time
SET @SQL
    = 'USE ' + QUOTENAME(@destination_database)
      + '; IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(@destination_table) AND name = N''cx_collection_time'') SET @exists = 0';
SET @parameters = N'@destination_table varchar(500), @exists bit OUTPUT';
EXEC sys.sp_executesql @SQL, @parameters, @destination_table = @destination_table, @exists = @exists OUTPUT;
 
IF @exists = 0
    BEGIN;
        SET @SQL = 'CREATE CLUSTERED INDEX cx_collection_time ON ' + @destination_table + '(collection_time ASC)';
        EXEC ( @SQL );
    END;
 
--collect activity into logging table
EXEC dbo.sp_WhoIsActive @get_transaction_info = 1,
                        @get_outer_command = 1,
                        @get_plans = 1,
                        @destination_table = @destination_table;
 
--purge older data
SET @SQL
    = 'DELETE FROM ' + @destination_table + ' WHERE collection_time < DATEADD(day, -' + CAST(@retention AS VARCHAR(10))
      + ', GETDATE());';
EXEC ( @SQL );


-- SEGUE JOB COMPLETO 

USE [msdb]
GO

/****** Object:  Job [WHOISACTIVE]    Script Date: 3/22/2021 12:49:37 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 3/22/2021 12:49:37 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'WHOISACTIVE', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [WHOISACTIVE_STEP1]    Script Date: 3/22/2021 12:49:38 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'WHOISACTIVE_STEP1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use master
go

SET NOCOUNT ON;
 
DECLARE @retention INT = 60,  -- Numero de dias que os dados serão guardados. Pode alterar para guardar por mais dias.
        @destination_table VARCHAR(500) = ''WhoIsActive'', -- tabela que sera criada no banco de dados de auditoria.
        @destination_database sysname = ''AuditoriaDBA'', -- deixar este nome do banco de auditoria ou criar banco novo, onde o script ira criar a tabela WhoisActive
        @schema VARCHAR(MAX),
        @SQL NVARCHAR(4000),
        @parameters NVARCHAR(500),
        @exists BIT;
 
SET @destination_table = @destination_database + ''.dbo.'' + @destination_table;
 
--create the logging table
IF OBJECT_ID(@destination_table) IS NULL
    BEGIN;
        EXEC dbo.sp_WhoIsActive @get_transaction_info = 1,
                                @get_outer_command = 1,
                                @get_plans = 1,
                                @return_schema = 1,
                                @schema = @schema OUTPUT;
        SET @schema = REPLACE(@schema, ''<table_name>'', @destination_table);
        EXEC ( @schema );
    END;
 
--create index on collection_time
SET @SQL
    = ''USE '' + QUOTENAME(@destination_database)
      + ''; IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(@destination_table) AND name = N''''cx_collection_time'''') SET @exists = 0'';
SET @parameters = N''@destination_table varchar(500), @exists bit OUTPUT'';
EXEC sys.sp_executesql @SQL, @parameters, @destination_table = @destination_table, @exists = @exists OUTPUT;
 
IF @exists = 0
    BEGIN;
        SET @SQL = ''CREATE CLUSTERED INDEX cx_collection_time ON '' + @destination_table + ''(collection_time ASC)'';
        EXEC ( @SQL );
    END;
 
--collect activity into logging table
EXEC dbo.sp_WhoIsActive @get_transaction_info = 1,
                        @get_outer_command = 1,
                        @get_plans = 1,
                        @destination_table = @destination_table;
 
--purge older data
SET @SQL
    = ''DELETE FROM '' + @destination_table + '' WHERE collection_time < DATEADD(day, -'' + CAST(@retention AS VARCHAR(10))
      + '', GETDATE());'';
EXEC ( @SQL );', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'WHOISACTIVE_ONEMINUTE', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20210322, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'e1ae4693-8a20-40e6-bfa2-eb94edbdb7eb'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

-- vERIFICAR O JOB CRIADO, ALTERAR O TEMPO DE EXECUCAO PARA 1 MINUTO, COLOCAR ALGUNS CODIGOS SQL SERVER PARA RODAR E COLOCAR PARA RODAR O JOB E VERIFICAR O CONTEUDO 
-- DA TABELA WHOISACTIVE NO BANCO AUDOTORIADBA

---------------------------------------------------------------------------------------------------------------------------------------------------------------FIM


-- Para baixar codigo sp_blitzcache, acesse https://www.brentozar.com/first-aid/

--------------------------- sp_BlitzCache

SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

IF (
SELECT
  CASE 
     WHEN CONVERT(NVARCHAR(128), SERVERPROPERTY ('PRODUCTVERSION')) LIKE '8%' THEN 0
     WHEN CONVERT(NVARCHAR(128), SERVERPROPERTY ('PRODUCTVERSION')) LIKE '9%' THEN 0
	 ELSE 1
  END 
) = 0
BEGIN
	DECLARE @msg VARCHAR(8000); 
	SELECT @msg = 'Sorry, sp_BlitzCache doesn''t work on versions of SQL prior to 2008.' + REPLICATE(CHAR(13), 7933);
	PRINT @msg;
	RETURN;
END;

IF OBJECT_ID('dbo.sp_BlitzCache') IS NULL
  EXEC ('CREATE PROCEDURE dbo.sp_BlitzCache AS RETURN 0;');
GO

IF OBJECT_ID('dbo.sp_BlitzCache') IS NOT NULL AND OBJECT_ID('tempdb.dbo.##BlitzCacheProcs', 'U') IS NOT NULL
    EXEC ('DROP TABLE ##BlitzCacheProcs;');
GO

IF OBJECT_ID('dbo.sp_BlitzCache') IS NOT NULL AND OBJECT_ID('tempdb.dbo.##BlitzCacheResults', 'U') IS NOT NULL
    EXEC ('DROP TABLE ##BlitzCacheResults;');
GO

CREATE TABLE ##BlitzCacheResults (
    SPID INT,
    ID INT IDENTITY(1,1),
    CheckID INT,
    Priority TINYINT,
    FindingsGroup VARCHAR(50),
    Finding VARCHAR(500),
    URL VARCHAR(200),
    Details VARCHAR(4000) 
);

CREATE TABLE ##BlitzCacheProcs (
        SPID INT ,
        QueryType NVARCHAR(258),
        DatabaseName sysname,
        AverageCPU DECIMAL(38,4),
        AverageCPUPerMinute DECIMAL(38,4),
        TotalCPU DECIMAL(38,4),
        PercentCPUByType MONEY,
        PercentCPU MONEY,
        AverageDuration DECIMAL(38,4),
        TotalDuration DECIMAL(38,4),
        PercentDuration MONEY,
        PercentDurationByType MONEY,
        AverageReads BIGINT,
        TotalReads BIGINT,
        PercentReads MONEY,
        PercentReadsByType MONEY,
        ExecutionCount BIGINT,
        PercentExecutions MONEY,
        PercentExecutionsByType MONEY,
        ExecutionsPerMinute MONEY,
        TotalWrites BIGINT,
        AverageWrites MONEY,
        PercentWrites MONEY,
        PercentWritesByType MONEY,
        WritesPerMinute MONEY,
        PlanCreationTime DATETIME,
		PlanCreationTimeHours AS DATEDIFF(HOUR, PlanCreationTime, SYSDATETIME()),
        LastExecutionTime DATETIME,
		LastCompletionTime DATETIME,
        PlanHandle VARBINARY(64),
		[Remove Plan Handle From Cache] AS 
			CASE WHEN [PlanHandle] IS NOT NULL 
			THEN 'DBCC FREEPROCCACHE (' + CONVERT(VARCHAR(128), [PlanHandle], 1) + ');'
			ELSE 'N/A' END,
		SqlHandle VARBINARY(64),
			[Remove SQL Handle From Cache] AS 
			CASE WHEN [SqlHandle] IS NOT NULL 
			THEN 'DBCC FREEPROCCACHE (' + CONVERT(VARCHAR(128), [SqlHandle], 1) + ');'
			ELSE 'N/A' END,
		[SQL Handle More Info] AS 
			CASE WHEN [SqlHandle] IS NOT NULL 
			THEN 'EXEC sp_BlitzCache @OnlySqlHandles = ''' + CONVERT(VARCHAR(128), [SqlHandle], 1) + '''; '
			ELSE 'N/A' END,
		QueryHash BINARY(8),
		[Query Hash More Info] AS 
			CASE WHEN [QueryHash] IS NOT NULL 
			THEN 'EXEC sp_BlitzCache @OnlyQueryHashes = ''' + CONVERT(VARCHAR(32), [QueryHash], 1) + '''; '
			ELSE 'N/A' END,
        QueryPlanHash BINARY(8),
        StatementStartOffset INT,
        StatementEndOffset INT,
		PlanGenerationNum BIGINT,
        MinReturnedRows BIGINT,
        MaxReturnedRows BIGINT,
        AverageReturnedRows MONEY,
        TotalReturnedRows BIGINT,
        LastReturnedRows BIGINT,
		/*The Memory Grant columns are only supported 
		  in certain versions, giggle giggle.
		*/
		MinGrantKB BIGINT,
		MaxGrantKB BIGINT,
		MinUsedGrantKB BIGINT, 
		MaxUsedGrantKB BIGINT,
		PercentMemoryGrantUsed MONEY,
		AvgMaxMemoryGrant MONEY,
		MinSpills BIGINT,
		MaxSpills BIGINT,
		TotalSpills BIGINT,
		AvgSpills MONEY,
        QueryText NVARCHAR(MAX),
        QueryPlan XML,
        /* these next four columns are the total for the type of query.
            don't actually use them for anything apart from math by type.
            */
        TotalWorkerTimeForType BIGINT,
        TotalElapsedTimeForType BIGINT,
        TotalReadsForType BIGINT,
        TotalExecutionCountForType BIGINT,
        TotalWritesForType BIGINT,
        NumberOfPlans INT,
        NumberOfDistinctPlans INT,
        SerialDesiredMemory FLOAT,
        SerialRequiredMemory FLOAT,
        CachedPlanSize FLOAT,
        CompileTime FLOAT,
        CompileCPU FLOAT ,
        CompileMemory FLOAT ,
		MaxCompileMemory FLOAT ,
        min_worker_time BIGINT,
        max_worker_time BIGINT,
        is_forced_plan BIT,
        is_forced_parameterized BIT,
        is_cursor BIT,
		is_optimistic_cursor BIT,
		is_forward_only_cursor BIT,
		is_fast_forward_cursor BIT,
		is_cursor_dynamic BIT,
        is_parallel BIT,
		is_forced_serial BIT,
		is_key_lookup_expensive BIT,
		key_lookup_cost FLOAT,
		is_remote_query_expensive BIT,
		remote_query_cost FLOAT,
        frequent_execution BIT,
        parameter_sniffing BIT,
        unparameterized_query BIT,
        near_parallel BIT,
        plan_warnings BIT,
        plan_multiple_plans INT,
        long_running BIT,
        downlevel_estimator BIT,
        implicit_conversions BIT,
        busy_loops BIT,
        tvf_join BIT,
        tvf_estimate BIT,
        compile_timeout BIT,
        compile_memory_limit_exceeded BIT,
        warning_no_join_predicate BIT,
        QueryPlanCost FLOAT,
        missing_index_count INT,
        unmatched_index_count INT,
        min_elapsed_time BIGINT,
        max_elapsed_time BIGINT,
        age_minutes MONEY,
        age_minutes_lifetime MONEY,
        is_trivial BIT,
		trace_flags_session VARCHAR(1000),
		is_unused_grant BIT,
		function_count INT,
		clr_function_count INT,
		is_table_variable BIT,
		no_stats_warning BIT,
		relop_warnings BIT,
		is_table_scan BIT,
	    backwards_scan BIT,
	    forced_index BIT,
	    forced_seek BIT,
	    forced_scan BIT,
		columnstore_row_mode BIT,
		is_computed_scalar BIT ,
		is_sort_expensive BIT,
		sort_cost FLOAT,
		is_computed_filter BIT,
		op_name VARCHAR(100) NULL,
		index_insert_count INT NULL,
		index_update_count INT NULL,
		index_delete_count INT NULL,
		cx_insert_count INT NULL,
		cx_update_count INT NULL,
		cx_delete_count INT NULL,
		table_insert_count INT NULL,
		table_update_count INT NULL,
		table_delete_count INT NULL,
		index_ops AS (index_insert_count + index_update_count + index_delete_count + 
					  cx_insert_count + cx_update_count + cx_delete_count +
					  table_insert_count + table_update_count + table_delete_count),
		is_row_level BIT,
		is_spatial BIT,
		index_dml BIT,
		table_dml BIT,
		long_running_low_cpu BIT,
		low_cost_high_cpu BIT,
		stale_stats BIT, 
		is_adaptive BIT,
		index_spool_cost FLOAT,
		index_spool_rows FLOAT,
		table_spool_cost FLOAT,
		table_spool_rows FLOAT,
		is_spool_expensive BIT,
		is_spool_more_rows BIT,
		is_table_spool_expensive BIT,
		is_table_spool_more_rows BIT,
		estimated_rows FLOAT,
		is_bad_estimate BIT, 
		is_paul_white_electric BIT,
		is_row_goal BIT,
		is_big_spills BIT,
		is_mstvf BIT,
		is_mm_join BIT,
        is_nonsargable BIT,
		select_with_writes BIT,
		implicit_conversion_info XML,
		cached_execution_parameters XML,
		missing_indexes XML,
        SetOptions VARCHAR(MAX),
        Warnings VARCHAR(MAX)
    );
GO 

ALTER PROCEDURE dbo.sp_BlitzCache
    @Help BIT = 0,
    @Top INT = NULL,
    @SortOrder VARCHAR(50) = 'CPU',
    @UseTriggersAnyway BIT = NULL,
    @ExportToExcel BIT = 0,
    @ExpertMode TINYINT = 0,
    @OutputServerName NVARCHAR(258) = NULL ,
    @OutputDatabaseName NVARCHAR(258) = NULL ,
    @OutputSchemaName NVARCHAR(258) = NULL ,
    @OutputTableName NVARCHAR(258) = NULL , -- do NOT use ##BlitzCacheResults or ##BlitzCacheProcs as they are used as work tables in this procedure
    @ConfigurationDatabaseName NVARCHAR(128) = NULL ,
    @ConfigurationSchemaName NVARCHAR(258) = NULL ,
    @ConfigurationTableName NVARCHAR(258) = NULL ,
    @DurationFilter DECIMAL(38,4) = NULL ,
    @HideSummary BIT = 0 ,
    @IgnoreSystemDBs BIT = 1 ,
    @OnlyQueryHashes VARCHAR(MAX) = NULL ,
    @IgnoreQueryHashes VARCHAR(MAX) = NULL ,
    @OnlySqlHandles VARCHAR(MAX) = NULL ,
	@IgnoreSqlHandles VARCHAR(MAX) = NULL ,
    @QueryFilter VARCHAR(10) = 'ALL' ,
    @DatabaseName NVARCHAR(128) = NULL ,
    @StoredProcName NVARCHAR(128) = NULL,
	@SlowlySearchPlansFor NVARCHAR(4000) = NULL,
    @Reanalyze BIT = 0 ,
    @SkipAnalysis BIT = 0 ,
    @BringThePain BIT = 0 ,
    @MinimumExecutionCount INT = 0,
	@Debug BIT = 0,
	@CheckDateOverride DATETIMEOFFSET = NULL,
	@MinutesBack INT = NULL,
	@Version     VARCHAR(30) = NULL OUTPUT,
	@VersionDate DATETIME = NULL OUTPUT,
	@VersionCheckMode BIT = 0
WITH RECOMPILE
AS
BEGIN
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT @Version = '8.01', @VersionDate = '20210222';


IF(@VersionCheckMode = 1)
BEGIN
	RETURN;
END;

DECLARE @nl NVARCHAR(2) = NCHAR(13) + NCHAR(10) ;
	
IF @Help = 1 
	BEGIN
	PRINT '
	sp_BlitzCache from http://FirstResponderKit.org
	
	This script displays your most resource-intensive queries from the plan cache,
	and points to ways you can tune these queries to make them faster.


	To learn more, visit http://FirstResponderKit.org where you can download new
	versions for free, watch training videos on how it works, get more info on
	the findings, contribute your own code, and more.

	Known limitations of this version:
	 - This query will not run on SQL Server 2005.
	 - SQL Server 2008 and 2008R2 have a bug in trigger stats, so that output is
	   excluded by default.
	 - @IgnoreQueryHashes and @OnlyQueryHashes require a CSV list of hashes
	   with no spaces between the hash values.

	Unknown limitations of this version:
	 - May or may not be vulnerable to the wick effect.

	Changes - for the full list of improvements and fixes in this version, see:
	https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit/



	MIT License

	Copyright (c) 2021 Brent Ozar Unlimited

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
	';

	
	SELECT N'@Help' AS [Parameter Name] ,
			N'BIT' AS [Data Type] ,
			N'Displays this help message.' AS [Parameter Description]

	UNION ALL
	SELECT N'@Top',
			N'INT',
			N'The number of records to retrieve and analyze from the plan cache. The following DMVs are used as the plan cache: dm_exec_query_stats, dm_exec_procedure_stats, dm_exec_trigger_stats.'

	UNION ALL
	SELECT N'@SortOrder',
			N'VARCHAR(10)',
			N'Data processing and display order. @SortOrder will still be used, even when preparing output for a table or for excel. Possible values are: "CPU", "Reads", "Writes", "Duration", "Executions", "Recent Compilations", "Memory Grant", "Unused Grant", "Spills", "Query Hash". Additionally, the word "Average" or "Avg" can be used to sort on averages rather than total. "Executions per minute" and "Executions / minute" can be used to sort by execution per minute. For the truly lazy, "xpm" can also be used. Note that when you use all or all avg, the only parameters you can use are @Top and @DatabaseName. All others will be ignored.'

	UNION ALL
	SELECT N'@UseTriggersAnyway',
			N'BIT',
			N'On SQL Server 2008R2 and earlier, trigger execution count is incorrect - trigger execution count is incremented once per execution of a SQL agent job. If you still want to see relative execution count of triggers, then you can force sp_BlitzCache to include this information.'

	UNION ALL
	SELECT N'@ExportToExcel',
			N'BIT',
			N'Prepare output for exporting to Excel. Newlines and additional whitespace are removed from query text and the execution plan is not displayed.'

	UNION ALL
	SELECT N'@ExpertMode',
			N'TINYINT',
			N'Default 0. When set to 1, results include more columns. When 2, mode is optimized for Opserver, the open source dashboard.'

	UNION ALL
	SELECT N'@OutputDatabaseName',
			N'NVARCHAR(128)',
			N'The output database. If this does not exist SQL Server will divide by zero and everything will fall apart.'

	UNION ALL
	SELECT N'@OutputSchemaName',
			N'NVARCHAR(258)',
			N'The output schema. If this does not exist SQL Server will divide by zero and everything will fall apart.'

	UNION ALL
	SELECT N'@OutputTableName',
			N'NVARCHAR(258)',
			N'The output table. If this does not exist, it will be created for you.'

	UNION ALL
	SELECT N'@DurationFilter',
			N'DECIMAL(38,4)',
			N'Excludes queries with an average duration (in seconds) less than @DurationFilter.'

	UNION ALL
	SELECT N'@HideSummary',
			N'BIT',
			N'Hides the findings summary result set.'

	UNION ALL
	SELECT N'@IgnoreSystemDBs',
			N'BIT',
			N'Ignores plans found in the system databases (master, model, msdb, tempdb, and resourcedb)'

	UNION ALL
	SELECT N'@OnlyQueryHashes',
			N'VARCHAR(MAX)',
			N'A list of query hashes to query. All other query hashes will be ignored. Stored procedures and triggers will be ignored.'

	UNION ALL
	SELECT N'@IgnoreQueryHashes',
			N'VARCHAR(MAX)',
			N'A list of query hashes to ignore.'
    
	UNION ALL
	SELECT N'@OnlySqlHandles',
			N'VARCHAR(MAX)',
			N'One or more sql_handles to use for filtering results.'
    
	UNION ALL
	SELECT N'@IgnoreSqlHandles',
			N'VARCHAR(MAX)',
			N'One or more sql_handles to ignore.'

	UNION ALL
	SELECT N'@DatabaseName',
			N'NVARCHAR(128)',
			N'A database name which is used for filtering results.'

	UNION ALL
	SELECT N'@StoredProcName',
			N'NVARCHAR(128)',
			N'Name of stored procedure you want to find plans for.'

	UNION ALL
	SELECT N'@SlowlySearchPlansFor',
			N'NVARCHAR(4000)',
			N'String to search for in plan text. % wildcards allowed.'

	UNION ALL
	SELECT N'@BringThePain',
			N'BIT',
			N'When using @SortOrder = ''all'' and @Top > 10, we require you to set @BringThePain = 1 so you understand that sp_BlitzCache will take a while to run.'

	UNION ALL
	SELECT N'@QueryFilter',
			N'VARCHAR(10)',
			N'Filter out stored procedures or statements. The default value is ''ALL''. Allowed values are ''procedures'', ''statements'', ''functions'', or ''all'' (any variation in capitalization is acceptable).'

	UNION ALL
	SELECT N'@Reanalyze',
			N'BIT',
			N'The default is 0. When set to 0, sp_BlitzCache will re-evalute the plan cache. Set this to 1 to reanalyze existing results'
           
	UNION ALL
	SELECT N'@MinimumExecutionCount',
			N'INT',
			N'Queries with fewer than this number of executions will be omitted from results.'
    
	UNION ALL
	SELECT N'@Debug',
			N'BIT',
			N'Setting this to 1 will print dynamic SQL and select data from all tables used.'

	UNION ALL
	SELECT N'@MinutesBack',
			N'INT',
			N'How many minutes back to begin plan cache analysis. If you put in a positive number, we''ll flip it to negtive.';


	/* Column definitions */
	SELECT N'# Executions' AS [Column Name],
			N'BIGINT' AS [Data Type],
			N'The number of executions of this particular query. This is computed across statements, procedures, and triggers and aggregated by the SQL handle.' AS [Column Description]

	UNION ALL
	SELECT N'Executions / Minute',
			N'MONEY',
			N'Number of executions per minute - calculated for the life of the current plan. Plan life is the last execution time minus the plan creation time.'

	UNION ALL
	SELECT N'Execution Weight',
			N'MONEY',
			N'An arbitrary metric of total "execution-ness". A weight of 2 is "one more" than a weight of 1.'

	UNION ALL
	SELECT N'Database',
			N'sysname',
			N'The name of the database where the plan was encountered. If the database name cannot be determined for some reason, a value of NA will be substituted. A value of 32767 indicates the plan comes from ResourceDB.'

	UNION ALL
	SELECT N'Total CPU',
			N'BIGINT',
			N'Total CPU time, reported in milliseconds, that was consumed by all executions of this query since the last compilation.'

	UNION ALL
	SELECT N'Avg CPU',
			N'BIGINT',
			N'Average CPU time, reported in milliseconds, consumed by each execution of this query since the last compilation.'

	UNION ALL
	SELECT N'CPU Weight',
			N'MONEY',
			N'An arbitrary metric of total "CPU-ness". A weight of 2 is "one more" than a weight of 1.'

	UNION ALL
	SELECT N'Total Duration',
			N'BIGINT',
			N'Total elapsed time, reported in milliseconds, consumed by all executions of this query since last compilation.'

	UNION ALL
	SELECT N'Avg Duration',
			N'BIGINT',
			N'Average elapsed time, reported in milliseconds, consumed by each execution of this query since the last compilation.'

	UNION ALL
	SELECT N'Duration Weight',
			N'MONEY',
			N'An arbitrary metric of total "Duration-ness". A weight of 2 is "one more" than a weight of 1.'

	UNION ALL
	SELECT N'Total Reads',
			N'BIGINT',
			N'Total logical reads performed by this query since last compilation.'

	UNION ALL
	SELECT N'Average Reads',
			N'BIGINT',
			N'Average logical reads performed by each execution of this query since the last compilation.'

	UNION ALL
	SELECT N'Read Weight',
			N'MONEY',
			N'An arbitrary metric of "Read-ness". A weight of 2 is "one more" than a weight of 1.'

	UNION ALL
	SELECT N'Total Writes',
			N'BIGINT',
			N'Total logical writes performed by this query since last compilation.'

	UNION ALL
	SELECT N'Average Writes',
			N'BIGINT',
			N'Average logical writes performed by each execution this query since last compilation.'

	UNION ALL
	SELECT N'Write Weight',
			N'MONEY',
			N'An arbitrary metric of "Write-ness". A weight of 2 is "one more" than a weight of 1.'

	UNION ALL
	SELECT N'Query Type',
			N'NVARCHAR(258)',
			N'The type of query being examined. This can be "Procedure", "Statement", or "Trigger".'

	UNION ALL
	SELECT N'Query Text',
			N'NVARCHAR(4000)',
			N'The text of the query. This may be truncated by either SQL Server or by sp_BlitzCache(tm) for display purposes.'

	UNION ALL
	SELECT N'% Executions (Type)',
			N'MONEY',
			N'Percent of executions relative to the type of query - e.g. 17.2% of all stored procedure executions.'

	UNION ALL
	SELECT N'% CPU (Type)',
			N'MONEY',
			N'Percent of CPU time consumed by this query for a given type of query - e.g. 22% of CPU of all stored procedures executed.'

	UNION ALL
	SELECT N'% Duration (Type)',
			N'MONEY',
			N'Percent of elapsed time consumed by this query for a given type of query - e.g. 12% of all statements executed.'

	UNION ALL
	SELECT N'% Reads (Type)',
			N'MONEY',
			N'Percent of reads consumed by this query for a given type of query - e.g. 34.2% of all stored procedures executed.'

	UNION ALL
	SELECT N'% Writes (Type)',
			N'MONEY',
			N'Percent of writes performed by this query for a given type of query - e.g. 43.2% of all statements executed.'

	UNION ALL
	SELECT N'Total Rows',
			N'BIGINT',
			N'Total number of rows returned for all executions of this query. This only applies to query level stats, not stored procedures or triggers.'

	UNION ALL
	SELECT N'Average Rows',
			N'MONEY',
			N'Average number of rows returned by each execution of the query.'

	UNION ALL
	SELECT N'Min Rows',
			N'BIGINT',
			N'The minimum number of rows returned by any execution of this query.'

	UNION ALL
	SELECT N'Max Rows',
			N'BIGINT',
			N'The maximum number of rows returned by any execution of this query.'

	UNION ALL
	SELECT N'MinGrantKB',
			N'BIGINT',
			N'The minimum memory grant the query received in kb.'

	UNION ALL
	SELECT N'MaxGrantKB',
			N'BIGINT',
			N'The maximum memory grant the query received in kb.'

	UNION ALL
	SELECT N'MinUsedGrantKB',
			N'BIGINT',
			N'The minimum used memory grant the query received in kb.'

	UNION ALL
	SELECT N'MaxUsedGrantKB',
			N'BIGINT',
			N'The maximum used memory grant the query received in kb.'

	UNION ALL
	SELECT N'MinSpills',
			N'BIGINT',
			N'The minimum amount this query has spilled to tempdb in 8k pages.'

	UNION ALL
	SELECT N'MaxSpills',
			N'BIGINT',
			N'The maximum amount this query has spilled to tempdb in 8k pages.'

	UNION ALL
	SELECT N'TotalSpills',
			N'BIGINT',
			N'The total amount this query has spilled to tempdb in 8k pages.'

	UNION ALL
	SELECT N'AvgSpills',
			N'BIGINT',
			N'The average amount this query has spilled to tempdb in 8k pages.'

	UNION ALL
	SELECT N'PercentMemoryGrantUsed',
			N'MONEY',
			N'Result of dividing the maximum grant used by the minimum granted.'

	UNION ALL
	SELECT N'AvgMaxMemoryGrant',
			N'MONEY',
			N'The average maximum memory grant for a query.'

	UNION ALL
	SELECT N'# Plans',
			N'INT',
			N'The total number of execution plans found that match a given query.'

	UNION ALL
	SELECT N'# Distinct Plans',
			N'INT',
			N'The number of distinct execution plans that match a given query. '
			+ NCHAR(13) + NCHAR(10)
			+ N'This may be caused by running the same query across multiple databases or because of a lack of proper parameterization in the database.'

	UNION ALL
	SELECT N'Created At',
			N'DATETIME',
			N'Time that the execution plan was last compiled.'

	UNION ALL
	SELECT N'Last Execution',
			N'DATETIME',
			N'The last time that this query was executed.'

	UNION ALL
	SELECT N'Query Plan',
			N'XML',
			N'The query plan. Click to display a graphical plan or, if you need to patch SSMS, a pile of XML.'

	UNION ALL
	SELECT N'Plan Handle',
			N'VARBINARY(64)',
			N'An arbitrary identifier referring to the compiled plan this query is a part of.'

	UNION ALL
	SELECT N'SQL Handle',
			N'VARBINARY(64)',
			N'An arbitrary identifier referring to a batch or stored procedure that this query is a part of.'

	UNION ALL
	SELECT N'Query Hash',
			N'BINARY(8)',
			N'A hash of the query. Queries with the same query hash have similar logic but only differ by literal values or database.'

	UNION ALL
	SELECT N'Warnings',
			N'VARCHAR(MAX)',
			N'A list of individual warnings generated by this query.' ;


           
	/* Configuration table description */
	SELECT N'Frequent Execution Threshold' AS [Configuration Parameter] ,
			N'100' AS [Default Value] ,
			N'Executions / Minute' AS [Unit of Measure] ,
			N'Executions / Minute before a "Frequent Execution Threshold" warning is triggered.' AS [Description]

	UNION ALL
	SELECT N'Parameter Sniffing Variance Percent' ,
			N'30' ,
			N'Percent' ,
			N'Variance required between min/max values and average values before a "Parameter Sniffing" warning is triggered. Applies to worker time and returned rows.'

	UNION ALL
	SELECT N'Parameter Sniffing IO Threshold' ,
			N'100,000' ,
			N'Logical reads' ,
			N'Minimum number of average logical reads before parameter sniffing checks are evaluated.'

	UNION ALL
	SELECT N'Cost Threshold for Parallelism Warning' AS [Configuration Parameter] ,
			N'10' ,
			N'Percent' ,
			N'Trigger a "Nearly Parallel" warning when a query''s cost is within X percent of the cost threshold for parallelism.'

	UNION ALL
	SELECT N'Long Running Query Warning' AS [Configuration Parameter] ,
			N'300' ,
			N'Seconds' ,
			N'Triggers a "Long Running Query Warning" when average duration, max CPU time, or max clock time is higher than this number.'

	UNION ALL
	SELECT N'Unused Memory Grant Warning' AS [Configuration Parameter] ,
			N'10' ,
			N'Percent' ,
			N'Triggers an "Unused Memory Grant Warning" when a query uses >= X percent of its memory grant.';
	RETURN;
	END; /* IF @Help = 1  */



/*Validate version*/
IF (
SELECT
  CASE 
     WHEN CONVERT(NVARCHAR(128), SERVERPROPERTY ('PRODUCTVERSION')) LIKE '8%' THEN 0
     WHEN CONVERT(NVARCHAR(128), SERVERPROPERTY ('PRODUCTVERSION')) LIKE '9%' THEN 0
	 ELSE 1
  END 
) = 0
BEGIN
	DECLARE @version_msg VARCHAR(8000); 
	SELECT @version_msg = 'Sorry, sp_BlitzCache doesn''t work on versions of SQL prior to 2008.' + REPLICATE(CHAR(13), 7933);
	PRINT @version_msg;
	RETURN;
END;

/* Lets get @SortOrder set to lower case here for comparisons later */
SET @SortOrder = LOWER(@SortOrder);

/* If they want to sort by query hash, populate the @OnlyQueryHashes list for them */
IF @SortOrder LIKE 'query hash%'
	BEGIN
	RAISERROR('Beginning query hash sort', 0, 1) WITH NOWAIT;

    SELECT qs.query_hash, 
           MAX(qs.max_worker_time) AS max_worker_time,
           COUNT_BIG(*) AS records
    INTO #query_hash_grouped
    FROM sys.dm_exec_query_stats AS qs
    CROSS APPLY (   SELECT pa.value
                    FROM   sys.dm_exec_plan_attributes(qs.plan_handle) AS pa
                    WHERE  pa.attribute = 'dbid' ) AS ca
    GROUP BY qs.query_hash, ca.value
    HAVING COUNT_BIG(*) > 1
    ORDER BY max_worker_time DESC,
             records DESC;
    
    SELECT TOP (1)
	         @OnlyQueryHashes = STUFF((SELECT DISTINCT N',' + CONVERT(NVARCHAR(MAX), qhg.query_hash, 1) 
    FROM #query_hash_grouped AS qhg 
    WHERE qhg.query_hash <> 0x00
    FOR XML PATH(N''), TYPE).value(N'.[1]', N'NVARCHAR(MAX)'), 1, 1, N'')
	OPTION(RECOMPILE);

	/* When they ran it, @SortOrder probably looked like 'query hash, cpu', so strip the first sort order out: */
    SELECT @SortOrder = LTRIM(REPLACE(REPLACE(@SortOrder,'query hash', ''), ',', ''));
	
	/* If they just called it with @SortOrder = 'query hash', set it to 'cpu' for backwards compatibility: */
	IF @SortOrder = '' SET @SortOrder = 'cpu';

	END


/* Set @Top based on sort */
IF (
     @Top IS NULL
     AND @SortOrder IN ( 'all', 'all sort' )
   )
   BEGIN
         SET @Top = 5;
   END;

IF (
     @Top IS NULL
     AND @SortOrder NOT IN ( 'all', 'all sort' )
   )
   BEGIN
         SET @Top = 10;
   END;

/* validate user inputs */
IF @Top IS NULL 
    OR @SortOrder IS NULL 
    OR @QueryFilter IS NULL 
    OR @Reanalyze IS NULL
BEGIN
    RAISERROR(N'Several parameters (@Top, @SortOrder, @QueryFilter, @renalyze) are required. Do not set them to NULL. Please try again.', 16, 1) WITH NOWAIT;
    RETURN;
END;

RAISERROR(N'Checking @MinutesBack validity.', 0, 1) WITH NOWAIT;
IF @MinutesBack IS NOT NULL
    BEGIN
        IF @MinutesBack > 0
            BEGIN
                RAISERROR(N'Setting @MinutesBack to a negative number', 0, 1) WITH NOWAIT;
				SET @MinutesBack *=-1;
            END;
        IF @MinutesBack = 0
            BEGIN
                RAISERROR(N'@MinutesBack can''t be 0, setting to -1', 0, 1) WITH NOWAIT;
				SET @MinutesBack = -1;
            END;
    END;


RAISERROR(N'Creating temp tables for results and warnings.', 0, 1) WITH NOWAIT;


IF OBJECT_ID('tempdb.dbo.##BlitzCacheResults') IS NULL
BEGIN
    CREATE TABLE ##BlitzCacheResults (
        SPID INT,
        ID INT IDENTITY(1,1),
        CheckID INT,
        Priority TINYINT,
        FindingsGroup VARCHAR(50),
        Finding VARCHAR(500),
        URL VARCHAR(200),
        Details VARCHAR(4000)
    );
END;

IF OBJECT_ID('tempdb.dbo.##BlitzCacheProcs') IS NULL
BEGIN
    CREATE TABLE ##BlitzCacheProcs (
        SPID INT ,
        QueryType NVARCHAR(258),
        DatabaseName sysname,
        AverageCPU DECIMAL(38,4),
        AverageCPUPerMinute DECIMAL(38,4),
        TotalCPU DECIMAL(38,4),
        PercentCPUByType MONEY,
        PercentCPU MONEY,
        AverageDuration DECIMAL(38,4),
        TotalDuration DECIMAL(38,4),
        PercentDuration MONEY,
        PercentDurationByType MONEY,
        AverageReads BIGINT,
        TotalReads BIGINT,
        PercentReads MONEY,
        PercentReadsByType MONEY,
        ExecutionCount BIGINT,
        PercentExecutions MONEY,
        PercentExecutionsByType MONEY,
        ExecutionsPerMinute MONEY,
        TotalWrites BIGINT,
        AverageWrites MONEY,
        PercentWrites MONEY,
        PercentWritesByType MONEY,
        WritesPerMinute MONEY,
        PlanCreationTime DATETIME,
		PlanCreationTimeHours AS DATEDIFF(HOUR, PlanCreationTime, SYSDATETIME()),
        LastExecutionTime DATETIME,
		LastCompletionTime DATETIME,
        PlanHandle VARBINARY(64),
		[Remove Plan Handle From Cache] AS 
			CASE WHEN [PlanHandle] IS NOT NULL 
			THEN 'DBCC FREEPROCCACHE (' + CONVERT(VARCHAR(128), [PlanHandle], 1) + ');'
			ELSE 'N/A' END,
		SqlHandle VARBINARY(64),
			[Remove SQL Handle From Cache] AS 
			CASE WHEN [SqlHandle] IS NOT NULL 
			THEN 'DBCC FREEPROCCACHE (' + CONVERT(VARCHAR(128), [SqlHandle], 1) + ');'
			ELSE 'N/A' END,
		[SQL Handle More Info] AS 
			CASE WHEN [SqlHandle] IS NOT NULL 
			THEN 'EXEC sp_BlitzCache @OnlySqlHandles = ''' + CONVERT(VARCHAR(128), [SqlHandle], 1) + '''; '
			ELSE 'N/A' END,
		QueryHash BINARY(8),
		[Query Hash More Info] AS 
			CASE WHEN [QueryHash] IS NOT NULL 
			THEN 'EXEC sp_BlitzCache @OnlyQueryHashes = ''' + CONVERT(VARCHAR(32), [QueryHash], 1) + '''; '
			ELSE 'N/A' END,
        QueryPlanHash BINARY(8),
        StatementStartOffset INT,
        StatementEndOffset INT,
		PlanGenerationNum BIGINT,
        MinReturnedRows BIGINT,
        MaxReturnedRows BIGINT,
        AverageReturnedRows MONEY,
        TotalReturnedRows BIGINT,
        LastReturnedRows BIGINT,
		MinGrantKB BIGINT,
		MaxGrantKB BIGINT,
		MinUsedGrantKB BIGINT, 
		MaxUsedGrantKB BIGINT,
		PercentMemoryGrantUsed MONEY,
		AvgMaxMemoryGrant MONEY,
		MinSpills BIGINT,
		MaxSpills BIGINT,
		TotalSpills BIGINT,
		AvgSpills MONEY,
        QueryText NVARCHAR(MAX),
        QueryPlan XML,
        /* these next four columns are the total for the type of query.
            don't actually use them for anything apart from math by type.
            */
        TotalWorkerTimeForType BIGINT,
        TotalElapsedTimeForType BIGINT,
        TotalReadsForType BIGINT,
        TotalExecutionCountForType BIGINT,
        TotalWritesForType BIGINT,
        NumberOfPlans INT,
        NumberOfDistinctPlans INT,
        SerialDesiredMemory FLOAT,
        SerialRequiredMemory FLOAT,
        CachedPlanSize FLOAT,
        CompileTime FLOAT,
        CompileCPU FLOAT ,
        CompileMemory FLOAT ,
		MaxCompileMemory FLOAT ,
        min_worker_time BIGINT,
        max_worker_time BIGINT,
        is_forced_plan BIT,
        is_forced_parameterized BIT,
        is_cursor BIT,
		is_optimistic_cursor BIT,
		is_forward_only_cursor BIT,
        is_fast_forward_cursor BIT,
		is_cursor_dynamic BIT,
        is_parallel BIT,
		is_forced_serial BIT,
		is_key_lookup_expensive BIT,
		key_lookup_cost FLOAT,
		is_remote_query_expensive BIT,
		remote_query_cost FLOAT,
        frequent_execution BIT,
        parameter_sniffing BIT,
        unparameterized_query BIT,
        near_parallel BIT,
        plan_warnings BIT,
        plan_multiple_plans INT,
        long_running BIT,
        downlevel_estimator BIT,
        implicit_conversions BIT,
        busy_loops BIT,
        tvf_join BIT,
        tvf_estimate BIT,
        compile_timeout BIT,
        compile_memory_limit_exceeded BIT,
        warning_no_join_predicate BIT,
        QueryPlanCost FLOAT,
        missing_index_count INT,
        unmatched_index_count INT,
        min_elapsed_time BIGINT,
        max_elapsed_time BIGINT,
        age_minutes MONEY,
        age_minutes_lifetime MONEY,
        is_trivial BIT,
		trace_flags_session VARCHAR(1000),
		is_unused_grant BIT,
		function_count INT,
		clr_function_count INT,
		is_table_variable BIT,
		no_stats_warning BIT,
		relop_warnings BIT,
		is_table_scan BIT,
	    backwards_scan BIT,
	    forced_index BIT,
	    forced_seek BIT,
	    forced_scan BIT,
		columnstore_row_mode BIT,
		is_computed_scalar BIT ,
		is_sort_expensive BIT,
		sort_cost FLOAT,
		is_computed_filter BIT,
		op_name VARCHAR(100) NULL,
		index_insert_count INT NULL,
		index_update_count INT NULL,
		index_delete_count INT NULL,
		cx_insert_count INT NULL,
		cx_update_count INT NULL,
		cx_delete_count INT NULL,
		table_insert_count INT NULL,
		table_update_count INT NULL,
		table_delete_count INT NULL,
		index_ops AS (index_insert_count + index_update_count + index_delete_count + 
			  cx_insert_count + cx_update_count + cx_delete_count +
			  table_insert_count + table_update_count + table_delete_count),
		is_row_level BIT,
		is_spatial BIT,
		index_dml BIT,
		table_dml BIT,
		long_running_low_cpu BIT,
		low_cost_high_cpu BIT,
		stale_stats BIT, 
		is_adaptive BIT,
		index_spool_cost FLOAT,
		index_spool_rows FLOAT,
		table_spool_cost FLOAT,
		table_spool_rows FLOAT,
		is_spool_expensive BIT,
		is_spool_more_rows BIT,
		is_table_spool_expensive BIT,
		is_table_spool_more_rows BIT,
		estimated_rows FLOAT,
		is_bad_estimate BIT, 
		is_paul_white_electric BIT,
		is_row_goal BIT,
		is_big_spills BIT,
		is_mstvf BIT,
		is_mm_join BIT,
        is_nonsargable BIT,
		select_with_writes BIT,
		implicit_conversion_info XML,
		cached_execution_parameters XML,
		missing_indexes XML,
        SetOptions VARCHAR(MAX),
        Warnings VARCHAR(MAX)
    );
END;

DECLARE @DurationFilter_i INT,
		@MinMemoryPerQuery INT,
        @msg NVARCHAR(4000),
		@NoobSaibot BIT = 0,
		@VersionShowsAirQuoteActualPlans BIT,
        @ObjectFullName NVARCHAR(2000),
        @user_perm_sql NVARCHAR(MAX) = N'',
        @user_perm_gb_out DECIMAL(10,2),
        @common_version DECIMAL(10,2),
        @buffer_pool_memory_gb DECIMAL(10,2),
        @user_perm_percent DECIMAL(10,2),
        @is_tokenstore_big BIT = 0,
        @sort NVARCHAR(MAX) = N'',
		@sort_filter NVARCHAR(MAX) = N'';


IF @SortOrder = 'sp_BlitzIndex'
BEGIN
	RAISERROR(N'OUTSTANDING!', 0, 1) WITH NOWAIT;
	SET @SortOrder = 'reads';
	SET @NoobSaibot = 1;

END


/* Change duration from seconds to milliseconds */
IF @DurationFilter IS NOT NULL
  BEGIN
  RAISERROR(N'Converting Duration Filter to milliseconds', 0, 1) WITH NOWAIT;
  SET @DurationFilter_i = CAST((@DurationFilter * 1000.0) AS INT);
  END; 

RAISERROR(N'Checking database validity', 0, 1) WITH NOWAIT;
SET @DatabaseName = LTRIM(RTRIM(@DatabaseName)) ;

IF SERVERPROPERTY('EngineEdition') IN (5, 6) AND DB_NAME() <> @DatabaseName
BEGIN
   RAISERROR('You specified a database name other than the current database, but Azure SQL DB does not allow you to change databases. Execute sp_BlitzCache from the database you want to analyze.', 16, 1);
   RETURN;
END;
IF (DB_ID(@DatabaseName)) IS NULL AND @DatabaseName <> N''
BEGIN
   RAISERROR('The database you specified does not exist. Please check the name and try again.', 16, 1);
   RETURN;
END;
IF (SELECT DATABASEPROPERTYEX(ISNULL(@DatabaseName, 'master'), 'Collation')) IS NULL AND SERVERPROPERTY('EngineEdition') NOT IN (5, 6, 8)
BEGIN
   RAISERROR('The database you specified is not readable. Please check the name and try again. Better yet, check your server.', 16, 1);
   RETURN;
END;

SELECT @MinMemoryPerQuery = CONVERT(INT, c.value) FROM sys.configurations AS c WHERE c.name = 'min memory per query (KB)';

SET @SortOrder = REPLACE(REPLACE(@SortOrder, 'average', 'avg'), '.', '');

SET @SortOrder = CASE 
                     WHEN @SortOrder IN ('executions per minute','execution per minute','executions / minute','execution / minute','xpm') THEN 'avg executions'
                     WHEN @SortOrder IN ('recent compilations','recent compilation','compile') THEN 'compiles'
                     WHEN @SortOrder IN ('read') THEN 'reads'
                     WHEN @SortOrder IN ('avg read') THEN 'avg reads'
                     WHEN @SortOrder IN ('write') THEN 'writes'
                     WHEN @SortOrder IN ('avg write') THEN 'avg writes'
                     WHEN @SortOrder IN ('memory grants') THEN 'memory grant'
                     WHEN @SortOrder IN ('avg memory grants') THEN 'avg memory grant'
                     WHEN @SortOrder IN ('unused grants','unused memory', 'unused memory grant', 'unused memory grants') THEN 'unused grant'
                     WHEN @SortOrder IN ('spill') THEN 'spills'
                     WHEN @SortOrder IN ('avg spill') THEN 'avg spills'
                     WHEN @SortOrder IN ('execution') THEN 'executions'
                 ELSE @SortOrder END							  
							  
RAISERROR(N'Checking sort order', 0, 1) WITH NOWAIT;
IF @SortOrder NOT IN ('cpu', 'avg cpu', 'reads', 'avg reads', 'writes', 'avg writes',
                       'duration', 'avg duration', 'executions', 'avg executions',
                       'compiles', 'memory grant', 'avg memory grant', 'unused grant',
					   'spills', 'avg spills', 'all', 'all avg', 'sp_BlitzIndex',
					   'query hash')
  BEGIN
  RAISERROR(N'Invalid sort order chosen, reverting to cpu', 16, 1) WITH NOWAIT;
  SET @SortOrder = 'cpu';
  END; 

SET @QueryFilter = LOWER(@QueryFilter);

IF LEFT(@QueryFilter, 3) NOT IN ('all', 'sta', 'pro', 'fun')
  BEGIN
  RAISERROR(N'Invalid query filter chosen. Reverting to all.', 0, 1) WITH NOWAIT;
  SET @QueryFilter = 'all';
  END;

IF @SkipAnalysis = 1
  BEGIN
  RAISERROR(N'Skip Analysis set to 1, hiding Summary', 0, 1) WITH NOWAIT;
  SET @HideSummary = 1;
  END; 

DECLARE @AllSortSql NVARCHAR(MAX) = N'';
DECLARE @VersionShowsMemoryGrants BIT;
IF EXISTS(SELECT * FROM sys.all_columns WHERE OBJECT_ID = OBJECT_ID('sys.dm_exec_query_stats') AND name = 'max_grant_kb')
    SET @VersionShowsMemoryGrants = 1;
ELSE
    SET @VersionShowsMemoryGrants = 0;

DECLARE @VersionShowsSpills BIT;
IF EXISTS(SELECT * FROM sys.all_columns WHERE OBJECT_ID = OBJECT_ID('sys.dm_exec_query_stats') AND name = 'max_spills')
    SET @VersionShowsSpills = 1;
ELSE
    SET @VersionShowsSpills = 0;

IF EXISTS(SELECT * FROM sys.all_columns WHERE OBJECT_ID = OBJECT_ID('sys.dm_exec_query_plan_stats') AND name = 'query_plan')
    SET @VersionShowsAirQuoteActualPlans = 1;
ELSE
    SET @VersionShowsAirQuoteActualPlans = 0;

IF @Reanalyze = 1 AND OBJECT_ID('tempdb..##BlitzCacheResults') IS NULL
  BEGIN
  RAISERROR(N'##BlitzCacheResults does not exist, can''t reanalyze', 0, 1) WITH NOWAIT;
  SET @Reanalyze = 0;
  END;

IF @Reanalyze = 0
  BEGIN
  RAISERROR(N'Cleaning up old warnings for your SPID', 0, 1) WITH NOWAIT;
  DELETE ##BlitzCacheResults
    WHERE SPID = @@SPID
	OPTION (RECOMPILE) ;
  RAISERROR(N'Cleaning up old plans for your SPID', 0, 1) WITH NOWAIT;
  DELETE ##BlitzCacheProcs
    WHERE SPID = @@SPID
	OPTION (RECOMPILE) ;
  END;  

IF @Reanalyze = 1 
	BEGIN
	RAISERROR(N'Reanalyzing current data, skipping to results', 0, 1) WITH NOWAIT;
    GOTO Results;
	END;




IF @SortOrder IN ('all', 'all avg')
	BEGIN
	RAISERROR(N'Checking all sort orders, please be patient', 0, 1) WITH NOWAIT;
    GOTO AllSorts;
	END;

RAISERROR(N'Creating temp tables for internal processing', 0, 1) WITH NOWAIT;
IF OBJECT_ID('tempdb..#only_query_hashes') IS NOT NULL
    DROP TABLE #only_query_hashes ;

IF OBJECT_ID('tempdb..#ignore_query_hashes') IS NOT NULL
    DROP TABLE #ignore_query_hashes ;

IF OBJECT_ID('tempdb..#only_sql_handles') IS NOT NULL
    DROP TABLE #only_sql_handles ;

IF OBJECT_ID('tempdb..#ignore_sql_handles') IS NOT NULL
    DROP TABLE #ignore_sql_handles ;
   
IF OBJECT_ID('tempdb..#p') IS NOT NULL
    DROP TABLE #p;

IF OBJECT_ID ('tempdb..#checkversion') IS NOT NULL
    DROP TABLE #checkversion;

IF OBJECT_ID ('tempdb..#configuration') IS NOT NULL
    DROP TABLE #configuration;

IF OBJECT_ID ('tempdb..#stored_proc_info') IS NOT NULL
    DROP TABLE #stored_proc_info;

IF OBJECT_ID ('tempdb..#plan_creation') IS NOT NULL
    DROP TABLE #plan_creation;

IF OBJECT_ID ('tempdb..#est_rows') IS NOT NULL
    DROP TABLE #est_rows;

IF OBJECT_ID ('tempdb..#plan_cost') IS NOT NULL
    DROP TABLE #plan_cost;

IF OBJECT_ID ('tempdb..#proc_costs') IS NOT NULL
    DROP TABLE #proc_costs;

IF OBJECT_ID ('tempdb..#stats_agg') IS NOT NULL
    DROP TABLE #stats_agg;

IF OBJECT_ID ('tempdb..#trace_flags') IS NOT NULL
    DROP TABLE #trace_flags;

IF OBJECT_ID('tempdb..#variable_info') IS NOT NULL
    DROP TABLE #variable_info;

IF OBJECT_ID('tempdb..#conversion_info') IS NOT NULL
    DROP TABLE #conversion_info;

IF OBJECT_ID('tempdb..#missing_index_xml') IS NOT NULL
    DROP TABLE #missing_index_xml;

IF OBJECT_ID('tempdb..#missing_index_schema') IS NOT NULL
    DROP TABLE #missing_index_schema;

IF OBJECT_ID('tempdb..#missing_index_usage') IS NOT NULL
    DROP TABLE #missing_index_usage;

IF OBJECT_ID('tempdb..#missing_index_detail') IS NOT NULL
    DROP TABLE #missing_index_detail;

IF OBJECT_ID('tempdb..#missing_index_pretty') IS NOT NULL
    DROP TABLE #missing_index_pretty;

IF OBJECT_ID('tempdb..#index_spool_ugly') IS NOT NULL
    DROP TABLE #index_spool_ugly;
	
IF OBJECT_ID('tempdb..#ReadableDBs') IS NOT NULL 
	DROP TABLE #ReadableDBs;	

IF OBJECT_ID('tempdb..#plan_usage') IS NOT NULL 
	DROP TABLE #plan_usage;	

CREATE TABLE #only_query_hashes (
    query_hash BINARY(8)
);

CREATE TABLE #ignore_query_hashes (
    query_hash BINARY(8)
);

CREATE TABLE #only_sql_handles (
    sql_handle VARBINARY(64)
);

CREATE TABLE #ignore_sql_handles (
    sql_handle VARBINARY(64)
);

CREATE TABLE #p (
    SqlHandle VARBINARY(64),
    TotalCPU BIGINT,
    TotalDuration BIGINT,
    TotalReads BIGINT,
    TotalWrites BIGINT,
    ExecutionCount BIGINT
);

CREATE TABLE #checkversion (
    version NVARCHAR(128),
    common_version AS SUBSTRING(version, 1, CHARINDEX('.', version) + 1 ),
    major AS PARSENAME(CONVERT(VARCHAR(32), version), 4),
    minor AS PARSENAME(CONVERT(VARCHAR(32), version), 3),
    build AS PARSENAME(CONVERT(VARCHAR(32), version), 2),
    revision AS PARSENAME(CONVERT(VARCHAR(32), version), 1)
);

CREATE TABLE #configuration (
    parameter_name VARCHAR(100),
    value DECIMAL(38,0)
);

CREATE TABLE #plan_creation
(
    percent_24 DECIMAL(5, 2),
    percent_4 DECIMAL(5, 2),
    percent_1 DECIMAL(5, 2),
	total_plans INT,
    SPID INT
);

CREATE TABLE #est_rows
(
    QueryHash BINARY(8),
    estimated_rows FLOAT
);

CREATE TABLE #plan_cost
(
    QueryPlanCost FLOAT,
    SqlHandle VARBINARY(64),
	PlanHandle VARBINARY(64),
    QueryHash BINARY(8),
    QueryPlanHash BINARY(8)
);

CREATE TABLE #proc_costs
(
    PlanTotalQuery FLOAT,
    PlanHandle VARBINARY(64),
    SqlHandle VARBINARY(64)
);

CREATE TABLE #stats_agg
(
    SqlHandle VARBINARY(64),
	LastUpdate DATETIME2(7),
    ModificationCount BIGINT,
    SamplingPercent FLOAT,
    [Statistics] NVARCHAR(258),
    [Table] NVARCHAR(258),
    [Schema] NVARCHAR(258),
    [Database] NVARCHAR(258),
);

CREATE TABLE #trace_flags
(
    SqlHandle VARBINARY(64),
    QueryHash BINARY(8),
    global_trace_flags VARCHAR(1000),
    session_trace_flags VARCHAR(1000)
);

CREATE TABLE #stored_proc_info
(
    SPID INT,
	SqlHandle VARBINARY(64),
    QueryHash BINARY(8),
    variable_name NVARCHAR(258),
    variable_datatype NVARCHAR(258),
	converted_column_name NVARCHAR(258),
    compile_time_value NVARCHAR(258),
    proc_name NVARCHAR(1000),
    column_name NVARCHAR(4000),
    converted_to NVARCHAR(258),
	set_options NVARCHAR(1000)
);

CREATE TABLE #variable_info
(
    SPID INT,
    QueryHash BINARY(8),
    SqlHandle VARBINARY(64),
    proc_name NVARCHAR(1000),
    variable_name NVARCHAR(258),
    variable_datatype NVARCHAR(258),
    compile_time_value NVARCHAR(258)
);

CREATE TABLE #conversion_info
(
    SPID INT,
    QueryHash BINARY(8),
    SqlHandle VARBINARY(64),
    proc_name NVARCHAR(258),
    expression NVARCHAR(4000),
    at_charindex AS CHARINDEX('@', expression),
    bracket_charindex AS CHARINDEX(']', expression, CHARINDEX('@', expression)) - CHARINDEX('@', expression),
    comma_charindex AS CHARINDEX(',', expression) + 1,
    second_comma_charindex AS
        CHARINDEX(',', expression, CHARINDEX(',', expression) + 1) - CHARINDEX(',', expression) - 1,
    equal_charindex AS CHARINDEX('=', expression) + 1,
    paren_charindex AS CHARINDEX('(', expression) + 1,
    comma_paren_charindex AS
        CHARINDEX(',', expression, CHARINDEX('(', expression) + 1) - CHARINDEX('(', expression) - 1,
    convert_implicit_charindex AS CHARINDEX('=CONVERT_IMPLICIT', expression)
);


CREATE TABLE #missing_index_xml
(
    QueryHash BINARY(8),
    SqlHandle VARBINARY(64),
    impact FLOAT,
    index_xml XML
);


CREATE TABLE #missing_index_schema
(
    QueryHash BINARY(8),
    SqlHandle VARBINARY(64),
    impact FLOAT,
    database_name NVARCHAR(128),
    schema_name NVARCHAR(128),
    table_name NVARCHAR(128),
    index_xml XML
);


CREATE TABLE #missing_index_usage
(
    QueryHash BINARY(8),
    SqlHandle VARBINARY(64),
    impact FLOAT,
    database_name NVARCHAR(128),
    schema_name NVARCHAR(128),
    table_name NVARCHAR(128),
	usage NVARCHAR(128),
    index_xml XML
);


CREATE TABLE #missing_index_detail
(
    QueryHash BINARY(8),
    SqlHandle VARBINARY(64),
    impact FLOAT,
    database_name NVARCHAR(128),
    schema_name NVARCHAR(128),
    table_name NVARCHAR(128),
    usage NVARCHAR(128),
    column_name NVARCHAR(128)
);


CREATE TABLE #missing_index_pretty
(
    QueryHash BINARY(8),
    SqlHandle VARBINARY(64),
    impact FLOAT,
    database_name NVARCHAR(128),
    schema_name NVARCHAR(128),
    table_name NVARCHAR(128),
	equality NVARCHAR(MAX),
	inequality NVARCHAR(MAX),
	[include] NVARCHAR(MAX),
	executions NVARCHAR(128),
	query_cost NVARCHAR(128),
	creation_hours NVARCHAR(128),
	is_spool BIT,
	details AS N'/* '
	           + CHAR(10) 
			   + CASE is_spool 
			          WHEN 0 
					  THEN N'The Query Processor estimates that implementing the '
					  ELSE N'We estimate that implementing the '
				 END 
			   + N'following index could improve query cost (' + query_cost + N')'
			   + CHAR(10) 
			   + N'by '
			   + CONVERT(NVARCHAR(30), impact)
			   + N'% for ' + executions + N' executions of the query'
			   + N' over the last ' + 
					CASE WHEN creation_hours < 24
					     THEN creation_hours + N' hours.'
						 WHEN creation_hours = 24
						 THEN ' 1 day.'
						 WHEN creation_hours > 24
						 THEN (CONVERT(NVARCHAR(128), creation_hours / 24)) + N' days.'
					     ELSE N''
					END
			   + CHAR(10)
			   + N'*/'
			   + CHAR(10) + CHAR(13) 
			   + N'/* '
			   + CHAR(10)
			   + N'USE '
			   + database_name
			   + CHAR(10)
			   + N'GO'
			   + CHAR(10) + CHAR(13)
			   + N'CREATE NONCLUSTERED INDEX ix_'
			   + ISNULL(REPLACE(REPLACE(REPLACE(equality,'[', ''), ']', ''),   ', ', '_'), '')
			   + ISNULL(REPLACE(REPLACE(REPLACE(inequality,'[', ''), ']', ''), ', ', '_'), '')
			   + CASE WHEN [include] IS NOT NULL THEN + N'_Includes' ELSE N'' END 
			   + CHAR(10)
			   + N' ON '
			   + schema_name
			   + N'.'
			   + table_name
			   + N' (' + 
			   + CASE WHEN equality IS NOT NULL 
					  THEN equality
						+ CASE WHEN inequality IS NOT NULL
							   THEN N', ' + inequality
							   ELSE N''
						  END
					 ELSE inequality
				 END			   
			   + N')' 
			   + CHAR(10)
			   + CASE WHEN include IS NOT NULL
					  THEN N'INCLUDE (' + include + N') WITH (FILLFACTOR=100, ONLINE=?, SORT_IN_TEMPDB=?, DATA_COMPRESSION=?);'
					  ELSE N' WITH (FILLFACTOR=100, ONLINE=?, SORT_IN_TEMPDB=?, DATA_COMPRESSION=?);'
				 END
			   + CHAR(10)
			   + N'GO'
			   + CHAR(10)
			   + N'*/'
);


CREATE TABLE #index_spool_ugly
(
    QueryHash BINARY(8),
    SqlHandle VARBINARY(64),
    impact FLOAT,
    database_name NVARCHAR(128),
    schema_name NVARCHAR(128),
    table_name NVARCHAR(128),
	equality NVARCHAR(MAX),
	inequality NVARCHAR(MAX),
	[include] NVARCHAR(MAX),
	executions NVARCHAR(128),
	query_cost NVARCHAR(128),
	creation_hours NVARCHAR(128)
);


CREATE TABLE #ReadableDBs 
(
database_id INT
);


CREATE TABLE #plan_usage
(
    duplicate_plan_handles BIGINT NULL,
    percent_duplicate NUMERIC(7, 2) NULL,
    single_use_plan_count BIGINT NULL,
    percent_single NUMERIC(7, 2) NULL,
    total_plans BIGINT NULL,
	spid INT
);


IF EXISTS (SELECT * FROM sys.all_objects o WHERE o.name = 'dm_hadr_database_replica_states')
BEGIN
	RAISERROR('Checking for Read intent databases to exclude',0,0) WITH NOWAIT;

    EXEC('INSERT INTO #ReadableDBs (database_id) SELECT DBs.database_id FROM sys.databases DBs INNER JOIN sys.availability_replicas Replicas ON DBs.replica_id = Replicas.replica_id WHERE replica_server_name NOT IN (SELECT DISTINCT primary_replica FROM sys.dm_hadr_availability_group_states States) AND Replicas.secondary_role_allow_connections_desc = ''READ_ONLY'' AND replica_server_name = @@SERVERNAME OPTION (RECOMPILE);');
END

RAISERROR(N'Checking plan cache age', 0, 1) WITH NOWAIT;
WITH x AS (
SELECT SUM(CASE WHEN DATEDIFF(HOUR, deqs.creation_time, SYSDATETIME()) <= 24 THEN 1 ELSE 0 END) AS [plans_24],
	   SUM(CASE WHEN DATEDIFF(HOUR, deqs.creation_time, SYSDATETIME()) <= 4 THEN 1 ELSE 0 END) AS [plans_4],
	   SUM(CASE WHEN DATEDIFF(HOUR, deqs.creation_time, SYSDATETIME()) <= 1 THEN 1 ELSE 0 END) AS [plans_1],
	   COUNT(deqs.creation_time) AS [total_plans]
FROM sys.dm_exec_query_stats AS deqs
)
INSERT INTO #plan_creation ( percent_24, percent_4, percent_1, total_plans, SPID )
SELECT CONVERT(DECIMAL(5,2), NULLIF(x.plans_24, 0) / (1. * NULLIF(x.total_plans, 0))) * 100 AS [percent_24],
	   CONVERT(DECIMAL(5,2), NULLIF(x.plans_4 , 0) / (1. * NULLIF(x.total_plans, 0))) * 100 AS [percent_4],
	   CONVERT(DECIMAL(5,2), NULLIF(x.plans_1 , 0) / (1. * NULLIF(x.total_plans, 0))) * 100 AS [percent_1],
	   x.total_plans,
	   @@SPID AS SPID
FROM x
OPTION (RECOMPILE);


RAISERROR(N'Checking for single use plans and plans with many queries', 0, 1) WITH NOWAIT;
WITH total_plans AS 
(
    SELECT COUNT_BIG(*) AS total_plans
    FROM sys.dm_exec_cached_plans AS deqs
    WHERE deqs.cacheobjtype = N'Compiled Plan'
),
     many_plans AS 
(
    SELECT SUM(x.duplicate_plan_handles) AS duplicate_plan_handles
    FROM (
        SELECT COUNT_BIG(DISTINCT plan_handle) AS duplicate_plan_handles
        FROM sys.dm_exec_query_stats qs
            CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) pa
        WHERE pa.attribute = N'dbid'
        GROUP BY qs.query_hash, pa.value
        HAVING COUNT_BIG(DISTINCT plan_handle) > 5
    ) AS x
),
     single_use_plans AS 
(
    SELECT COUNT_BIG(*) AS single_use_plan_count
    FROM sys.dm_exec_cached_plans AS cp
    WHERE cp.usecounts = 1
    AND   cp.objtype = N'Adhoc'
    AND   EXISTS ( SELECT 1/0
                   FROM sys.configurations AS c
                   WHERE c.name = N'optimize for ad hoc workloads'
                   AND   c.value_in_use = 0 )
    HAVING COUNT_BIG(*) > 1
)
INSERT #plan_usage ( duplicate_plan_handles, percent_duplicate, single_use_plan_count, percent_single, total_plans, spid )
SELECT m.duplicate_plan_handles, 
       CONVERT(DECIMAL(5,2), m.duplicate_plan_handles / (1. * NULLIF(t.total_plans, 0))) * 100. AS percent_duplicate,
       s.single_use_plan_count, 
       CONVERT(DECIMAL(5,2), s.single_use_plan_count / (1. * NULLIF(t.total_plans, 0))) * 100. AS percent_single,
       t.total_plans,
	   @@SPID
FROM   	many_plans AS m
		CROSS APPLY single_use_plans AS s 
		CROSS APPLY total_plans AS t;


UPDATE #plan_usage
	SET percent_duplicate = CASE WHEN percent_duplicate > 100 THEN 100 ELSE percent_duplicate END,
	percent_single = CASE WHEN percent_duplicate > 100 THEN 100 ELSE percent_duplicate END;

SET @OnlySqlHandles = LTRIM(RTRIM(@OnlySqlHandles)) ;
SET @OnlyQueryHashes = LTRIM(RTRIM(@OnlyQueryHashes)) ;
SET @IgnoreQueryHashes = LTRIM(RTRIM(@IgnoreQueryHashes)) ;

DECLARE @individual VARCHAR(100) ;

IF (@OnlySqlHandles IS NOT NULL AND @IgnoreSqlHandles IS NOT NULL)
BEGIN
RAISERROR('You shouldn''t need to ignore and filter on SqlHandle at the same time.', 0, 1) WITH NOWAIT;
RETURN;
END;

IF (@StoredProcName IS NOT NULL AND (@OnlySqlHandles IS NOT NULL OR @IgnoreSqlHandles IS NOT NULL))
BEGIN
RAISERROR('You can''t filter on stored procedure name and SQL Handle.', 0, 1) WITH NOWAIT;
RETURN;
END;

IF @OnlySqlHandles IS NOT NULL
    AND LEN(@OnlySqlHandles) > 0
BEGIN
    RAISERROR(N'Processing SQL Handles', 0, 1) WITH NOWAIT;
	SET @individual = '';

    WHILE LEN(@OnlySqlHandles) > 0
    BEGIN
        IF PATINDEX('%,%', @OnlySqlHandles) > 0
        BEGIN  
               SET @individual = SUBSTRING(@OnlySqlHandles, 0, PATINDEX('%,%',@OnlySqlHandles)) ;
               
               INSERT INTO #only_sql_handles
               SELECT CAST('' AS XML).value('xs:hexBinary( substring(sql:variable("@individual"), sql:column("t.pos")) )', 'varbinary(max)')
               FROM (SELECT CASE SUBSTRING(@individual, 1, 2) WHEN '0x' THEN 3 ELSE 0 END) AS t(pos)
			   OPTION (RECOMPILE) ;
               
               --SELECT CAST(SUBSTRING(@individual, 1, 2) AS BINARY(8));

               SET @OnlySqlHandles = SUBSTRING(@OnlySqlHandles, LEN(@individual + ',') + 1, LEN(@OnlySqlHandles)) ;
        END;
        ELSE
        BEGIN
               SET @individual = @OnlySqlHandles;
               SET @OnlySqlHandles = NULL;

               INSERT INTO #only_sql_handles
               SELECT CAST('' AS XML).value('xs:hexBinary( substring(sql:variable("@individual"), sql:column("t.pos")) )', 'varbinary(max)')
               FROM (SELECT CASE SUBSTRING(@individual, 1, 2) WHEN '0x' THEN 3 ELSE 0 END) AS t(pos)
			   OPTION (RECOMPILE) ;

               --SELECT CAST(SUBSTRING(@individual, 1, 2) AS VARBINARY(MAX)) ;
        END;
    END;
END;    

IF @IgnoreSqlHandles IS NOT NULL
    AND LEN(@IgnoreSqlHandles) > 0
BEGIN
    RAISERROR(N'Processing SQL Handles To Ignore', 0, 1) WITH NOWAIT;
	SET @individual = '';

    WHILE LEN(@IgnoreSqlHandles) > 0
    BEGIN
        IF PATINDEX('%,%', @IgnoreSqlHandles) > 0
        BEGIN  
               SET @individual = SUBSTRING(@IgnoreSqlHandles, 0, PATINDEX('%,%',@IgnoreSqlHandles)) ;
               
               INSERT INTO #ignore_sql_handles
               SELECT CAST('' AS XML).value('xs:hexBinary( substring(sql:variable("@individual"), sql:column("t.pos")) )', 'varbinary(max)')
               FROM (SELECT CASE SUBSTRING(@individual, 1, 2) WHEN '0x' THEN 3 ELSE 0 END) AS t(pos)
			   OPTION (RECOMPILE) ;
               
               --SELECT CAST(SUBSTRING(@individual, 1, 2) AS BINARY(8));

               SET @IgnoreSqlHandles = SUBSTRING(@IgnoreSqlHandles, LEN(@individual + ',') + 1, LEN(@IgnoreSqlHandles)) ;
        END;
        ELSE
        BEGIN
               SET @individual = @IgnoreSqlHandles;
               SET @IgnoreSqlHandles = NULL;

               INSERT INTO #ignore_sql_handles
               SELECT CAST('' AS XML).value('xs:hexBinary( substring(sql:variable("@individual"), sql:column("t.pos")) )', 'varbinary(max)')
               FROM (SELECT CASE SUBSTRING(@individual, 1, 2) WHEN '0x' THEN 3 ELSE 0 END) AS t(pos)
			   OPTION (RECOMPILE) ;

               --SELECT CAST(SUBSTRING(@individual, 1, 2) AS VARBINARY(MAX)) ;
        END;
    END;
END;  

IF @StoredProcName IS NOT NULL AND @StoredProcName <> N''

BEGIN
	RAISERROR(N'Setting up filter for stored procedure name', 0, 1) WITH NOWAIT;
	
    DECLARE @function_search_sql NVARCHAR(MAX) = N''
    
    INSERT #only_sql_handles
	        ( sql_handle )
	SELECT  ISNULL(deps.sql_handle, CONVERT(VARBINARY(64),'0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'))
	FROM sys.dm_exec_procedure_stats AS deps
	WHERE OBJECT_NAME(deps.object_id, deps.database_id) = @StoredProcName

    UNION ALL
    
    SELECT  ISNULL(dets.sql_handle, CONVERT(VARBINARY(64),'0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'))
	FROM sys.dm_exec_trigger_stats AS dets
	WHERE OBJECT_NAME(dets.object_id, dets.database_id) = @StoredProcName
	OPTION (RECOMPILE);

    IF EXISTS (SELECT 1/0 FROM sys.all_objects AS o WHERE o.name = 'dm_exec_function_stats')
        BEGIN
         SET @function_search_sql = @function_search_sql + N'
         SELECT  ISNULL(defs.sql_handle, CONVERT(VARBINARY(64),''0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000''))
	     FROM sys.dm_exec_function_stats AS defs
	     WHERE OBJECT_NAME(defs.object_id, defs.database_id) = @i_StoredProcName
         OPTION (RECOMPILE);
         '
        INSERT #only_sql_handles ( sql_handle )
        EXEC sys.sp_executesql @function_search_sql, N'@i_StoredProcName NVARCHAR(128)', @StoredProcName
       END
		
        IF (SELECT COUNT(*) FROM #only_sql_handles) = 0
			BEGIN
			RAISERROR(N'No information for that stored procedure was found.', 0, 1) WITH NOWAIT;
			RETURN;
			END;

END;



IF ((@OnlyQueryHashes IS NOT NULL AND LEN(@OnlyQueryHashes) > 0)
    OR (@IgnoreQueryHashes IS NOT NULL AND LEN(@IgnoreQueryHashes) > 0))
   AND LEFT(@QueryFilter, 3) IN ('pro', 'fun')
BEGIN
   RAISERROR('You cannot limit by query hash and filter by stored procedure', 16, 1);
   RETURN;
END;

/* If the user is attempting to limit by query hash, set up the
   #only_query_hashes temp table. This will be used to narrow down
   results.

   Just a reminder: Using @OnlyQueryHashes will ignore stored
   procedures and triggers.
 */
IF @OnlyQueryHashes IS NOT NULL
   AND LEN(@OnlyQueryHashes) > 0
BEGIN
	RAISERROR(N'Setting up filter for Query Hashes', 0, 1) WITH NOWAIT;
    SET @individual = '';

   WHILE LEN(@OnlyQueryHashes) > 0
   BEGIN
        IF PATINDEX('%,%', @OnlyQueryHashes) > 0
        BEGIN  
               SET @individual = SUBSTRING(@OnlyQueryHashes, 0, PATINDEX('%,%',@OnlyQueryHashes)) ;
               
               INSERT INTO #only_query_hashes
               SELECT CAST('' AS XML).value('xs:hexBinary( substring(sql:variable("@individual"), sql:column("t.pos")) )', 'varbinary(max)')
               FROM (SELECT CASE SUBSTRING(@individual, 1, 2) WHEN '0x' THEN 3 ELSE 0 END) AS t(pos)
			   OPTION (RECOMPILE) ;
               
               --SELECT CAST(SUBSTRING(@individual, 1, 2) AS BINARY(8));

               SET @OnlyQueryHashes = SUBSTRING(@OnlyQueryHashes, LEN(@individual + ',') + 1, LEN(@OnlyQueryHashes)) ;
        END;
        ELSE
        BEGIN
               SET @individual = @OnlyQueryHashes;
               SET @OnlyQueryHashes = NULL;

               INSERT INTO #only_query_hashes
               SELECT CAST('' AS XML).value('xs:hexBinary( substring(sql:variable("@individual"), sql:column("t.pos")) )', 'varbinary(max)')
               FROM (SELECT CASE SUBSTRING(@individual, 1, 2) WHEN '0x' THEN 3 ELSE 0 END) AS t(pos)
			   OPTION (RECOMPILE) ;

               --SELECT CAST(SUBSTRING(@individual, 1, 2) AS VARBINARY(MAX)) ;
        END;
   END;
END;

/* If the user is setting up a list of query hashes to ignore, those
   values will be inserted into #ignore_query_hashes. This is used to
   exclude values from query results.

   Just a reminder: Using @IgnoreQueryHashes will ignore stored
   procedures and triggers.
 */
IF @IgnoreQueryHashes IS NOT NULL
   AND LEN(@IgnoreQueryHashes) > 0
BEGIN
	RAISERROR(N'Setting up filter to ignore query hashes', 0, 1) WITH NOWAIT;
   SET @individual = '' ;

   WHILE LEN(@IgnoreQueryHashes) > 0
   BEGIN
        IF PATINDEX('%,%', @IgnoreQueryHashes) > 0
        BEGIN  
               SET @individual = SUBSTRING(@IgnoreQueryHashes, 0, PATINDEX('%,%',@IgnoreQueryHashes)) ;
               
               INSERT INTO #ignore_query_hashes
               SELECT CAST('' AS XML).value('xs:hexBinary( substring(sql:variable("@individual"), sql:column("t.pos")) )', 'varbinary(max)')
               FROM (SELECT CASE SUBSTRING(@individual, 1, 2) WHEN '0x' THEN 3 ELSE 0 END) AS t(pos) 
			   OPTION (RECOMPILE) ;
               
               SET @IgnoreQueryHashes = SUBSTRING(@IgnoreQueryHashes, LEN(@individual + ',') + 1, LEN(@IgnoreQueryHashes)) ;
        END;
        ELSE
        BEGIN
               SET @individual = @IgnoreQueryHashes ;
               SET @IgnoreQueryHashes = NULL ;

               INSERT INTO #ignore_query_hashes
               SELECT CAST('' AS XML).value('xs:hexBinary( substring(sql:variable("@individual"), sql:column("t.pos")) )', 'varbinary(max)')
               FROM (SELECT CASE SUBSTRING(@individual, 1, 2) WHEN '0x' THEN 3 ELSE 0 END) AS t(pos) 
			   OPTION (RECOMPILE) ;
        END;
   END;
END;

IF @ConfigurationDatabaseName IS NOT NULL
BEGIN
   RAISERROR(N'Reading values from Configuration Database', 0, 1) WITH NOWAIT;
   DECLARE @config_sql NVARCHAR(MAX) = N'INSERT INTO #configuration SELECT parameter_name, value FROM '
        + QUOTENAME(@ConfigurationDatabaseName)
        + '.' + QUOTENAME(@ConfigurationSchemaName)
        + '.' + QUOTENAME(@ConfigurationTableName)
        + ' ; ' ;
   EXEC(@config_sql);
END;

RAISERROR(N'Setting up variables', 0, 1) WITH NOWAIT;
DECLARE @sql NVARCHAR(MAX) = N'',
        @insert_list NVARCHAR(MAX) = N'',
        @plans_triggers_select_list NVARCHAR(MAX) = N'',
        @body NVARCHAR(MAX) = N'',
        @body_where NVARCHAR(MAX) = N'WHERE 1 = 1 ' + @nl,
        @body_order NVARCHAR(MAX) = N'ORDER BY #sortable# DESC OPTION (RECOMPILE) ',
        
        @q NVARCHAR(1) = N'''',
        @pv VARCHAR(20),
        @pos TINYINT,
        @v DECIMAL(6,2),
        @build INT;


RAISERROR (N'Determining SQL Server version.',0,1) WITH NOWAIT;

INSERT INTO #checkversion (version)
SELECT CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128))
OPTION (RECOMPILE);


SELECT @v = common_version ,
       @build = build
FROM   #checkversion
OPTION (RECOMPILE);

IF (@SortOrder IN ('memory grant', 'avg memory grant')) AND @VersionShowsMemoryGrants = 0
BEGIN
   RAISERROR('Your version of SQL does not support sorting by memory grant or average memory grant. Please use another sort order.', 16, 1);
   RETURN;
END;

IF (@SortOrder IN ('spills', 'avg spills') AND @VersionShowsSpills = 0)
BEGIN
   RAISERROR('Your version of SQL does not support sorting by spills. Please use another sort order.', 16, 1);
   RETURN;
END;

IF ((LEFT(@QueryFilter, 3) = 'fun') AND (@v < 13))
BEGIN
   RAISERROR('Your version of SQL does not support filtering by functions. Please use another filter.', 16, 1);
   RETURN;
END;

RAISERROR (N'Creating dynamic SQL based on SQL Server version.',0,1) WITH NOWAIT;

SET @insert_list += N'
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
INSERT INTO ##BlitzCacheProcs (SPID, QueryType, DatabaseName, AverageCPU, TotalCPU, AverageCPUPerMinute, PercentCPUByType, PercentDurationByType,
                    PercentReadsByType, PercentExecutionsByType, AverageDuration, TotalDuration, AverageReads, TotalReads, ExecutionCount,
                    ExecutionsPerMinute, TotalWrites, AverageWrites, PercentWritesByType, WritesPerMinute, PlanCreationTime,
                    LastExecutionTime, LastCompletionTime, StatementStartOffset, StatementEndOffset, PlanGenerationNum, MinReturnedRows, MaxReturnedRows, AverageReturnedRows, TotalReturnedRows,
                    LastReturnedRows, MinGrantKB, MaxGrantKB, MinUsedGrantKB, MaxUsedGrantKB, PercentMemoryGrantUsed, AvgMaxMemoryGrant, MinSpills, MaxSpills, TotalSpills, AvgSpills, 
					QueryText, QueryPlan, TotalWorkerTimeForType, TotalElapsedTimeForType, TotalReadsForType,
                    TotalExecutionCountForType, TotalWritesForType, SqlHandle, PlanHandle, QueryHash, QueryPlanHash,
                    min_worker_time, max_worker_time, is_parallel, min_elapsed_time, max_elapsed_time, age_minutes, age_minutes_lifetime) ' ;

SET @body += N'
FROM   (SELECT TOP (@Top) x.*, xpa.*,
               CAST((CASE WHEN DATEDIFF(mi, cached_time, GETDATE()) > 0 AND execution_count > 1
                          THEN DATEDIFF(mi, cached_time, GETDATE()) 
                          ELSE NULL END) as MONEY) as age_minutes,
               CAST((CASE WHEN DATEDIFF(mi, cached_time, last_execution_time) > 0 AND execution_count > 1
                          THEN DATEDIFF(mi, cached_time, last_execution_time) 
                          ELSE Null END) as MONEY) as age_minutes_lifetime
        FROM   sys.#view# x
               CROSS APPLY (SELECT * FROM sys.dm_exec_plan_attributes(x.plan_handle) AS ixpa 
                            WHERE ixpa.attribute = ''dbid'') AS xpa ' + @nl ;


IF @VersionShowsAirQuoteActualPlans = 1
    BEGIN
    SET @body += N'     CROSS APPLY sys.dm_exec_query_plan_stats(x.plan_handle) AS deqps ' + @nl ;
    END

SET @body += N'        WHERE  1 = 1 ' +  @nl ;

	IF EXISTS (SELECT * FROM sys.all_objects o WHERE o.name = 'dm_hadr_database_replica_states')
    BEGIN
    RAISERROR(N'Ignoring readable secondaries databases by default', 0, 1) WITH NOWAIT;
    SET @body += N'               AND CAST(xpa.value AS INT) NOT IN (SELECT database_id FROM #ReadableDBs)' + @nl ;
    END

IF @IgnoreSystemDBs = 1
    BEGIN
	RAISERROR(N'Ignoring system databases by default', 0, 1) WITH NOWAIT;
	SET @body += N'               AND COALESCE(DB_NAME(CAST(xpa.value AS INT)), '''') NOT IN (''master'', ''model'', ''msdb'', ''tempdb'', ''32767'') AND COALESCE(DB_NAME(CAST(xpa.value AS INT)), '''') NOT IN (SELECT name FROM sys.databases WHERE is_distributor = 1)' + @nl ;
	END; 

IF @DatabaseName IS NOT NULL OR @DatabaseName <> N''
	BEGIN 
    RAISERROR(N'Filtering database name chosen', 0, 1) WITH NOWAIT;
	SET @body += N'               AND CAST(xpa.value AS BIGINT) = DB_ID(N'
                 + QUOTENAME(@DatabaseName, N'''')
                 + N') ' + @nl;
	END; 

IF (SELECT COUNT(*) FROM #only_sql_handles) > 0
BEGIN
    RAISERROR(N'Including only chosen SQL Handles', 0, 1) WITH NOWAIT;
	SET @body += N'               AND EXISTS(SELECT 1/0 FROM #only_sql_handles q WHERE q.sql_handle = x.sql_handle) ' + @nl ;
END;      

IF (SELECT COUNT(*) FROM #ignore_sql_handles) > 0
BEGIN
    RAISERROR(N'Including only chosen SQL Handles', 0, 1) WITH NOWAIT;
	SET @body += N'               AND NOT EXISTS(SELECT 1/0 FROM #ignore_sql_handles q WHERE q.sql_handle = x.sql_handle) ' + @nl ;
END;    

IF (SELECT COUNT(*) FROM #only_query_hashes) > 0
   AND (SELECT COUNT(*) FROM #ignore_query_hashes) = 0
   AND (SELECT COUNT(*) FROM #only_sql_handles) = 0
   AND (SELECT COUNT(*) FROM #ignore_sql_handles) = 0
BEGIN
    RAISERROR(N'Including only chosen Query Hashes', 0, 1) WITH NOWAIT;
	SET @body += N'               AND EXISTS(SELECT 1/0 FROM #only_query_hashes q WHERE q.query_hash = x.query_hash) ' + @nl ;
END;

/* filtering for query hashes */
IF (SELECT COUNT(*) FROM #ignore_query_hashes) > 0
   AND (SELECT COUNT(*) FROM #only_query_hashes) = 0
BEGIN
    RAISERROR(N'Excluding chosen Query Hashes', 0, 1) WITH NOWAIT;
	SET @body += N'               AND NOT EXISTS(SELECT 1/0 FROM #ignore_query_hashes iq WHERE iq.query_hash = x.query_hash) ' + @nl ;
END;
/* end filtering for query hashes */


IF @DurationFilter IS NOT NULL
    BEGIN 
	RAISERROR(N'Setting duration filter', 0, 1) WITH NOWAIT;
	SET @body += N'       AND (total_elapsed_time / 1000.0) / execution_count > @min_duration ' + @nl ;
	END; 

IF @MinutesBack IS NOT NULL
	BEGIN
	RAISERROR(N'Setting minutes back filter', 0, 1) WITH NOWAIT;
	SET @body += N'       AND DATEADD(MILLISECOND, (x.last_elapsed_time / 1000.), x.last_execution_time) >= DATEADD(MINUTE, @min_back, GETDATE()) ' + @nl ;
	END;

IF @SlowlySearchPlansFor IS NOT NULL
    BEGIN
    RAISERROR(N'Setting string search for @SlowlySearchPlansFor, so remember, this is gonna be slow', 0, 1) WITH NOWAIT;
    SET @SlowlySearchPlansFor = REPLACE((REPLACE((REPLACE((REPLACE(@SlowlySearchPlansFor, N'[', N'_')), N']', N'_')), N'^', N'_')), N'''', N'''''');
    SET @body_where += N'       AND CAST(qp.query_plan AS NVARCHAR(MAX)) LIKE N''%' + @SlowlySearchPlansFor + N'%'' ' + @nl;
    END


/* Apply the sort order here to only grab relevant plans.
   This should make it faster to process since we'll be pulling back fewer
   plans for processing.
 */
RAISERROR(N'Applying chosen sort order', 0, 1) WITH NOWAIT;
SELECT @body += N'        ORDER BY ' +
                CASE @SortOrder  WHEN N'cpu' THEN N'total_worker_time'
                                 WHEN N'reads' THEN N'total_logical_reads'
                                 WHEN N'writes' THEN N'total_logical_writes'
                                 WHEN N'duration' THEN N'total_elapsed_time'
                                 WHEN N'executions' THEN N'execution_count'
                                 WHEN N'compiles' THEN N'cached_time'
								 WHEN N'memory grant' THEN N'max_grant_kb'
								 WHEN N'unused grant' THEN N'max_grant_kb - max_used_grant_kb'
								 WHEN N'spills' THEN N'max_spills'
                                 /* And now the averages */
                                 WHEN N'avg cpu' THEN N'total_worker_time / execution_count'
                                 WHEN N'avg reads' THEN N'total_logical_reads / execution_count'
                                 WHEN N'avg writes' THEN N'total_logical_writes / execution_count'
                                 WHEN N'avg duration' THEN N'total_elapsed_time / execution_count'
								 WHEN N'avg memory grant' THEN N'CASE WHEN max_grant_kb = 0 THEN 0 ELSE max_grant_kb / execution_count END'
                                 WHEN N'avg spills' THEN N'CASE WHEN total_spills = 0 THEN 0 ELSE total_spills / execution_count END'
								 WHEN N'avg executions' THEN 'CASE WHEN execution_count = 0 THEN 0
            WHEN COALESCE(CAST((CASE WHEN DATEDIFF(mi, cached_time, GETDATE()) > 0 AND execution_count > 1
                          THEN DATEDIFF(mi, cached_time, GETDATE())
                          ELSE NULL END) as MONEY), CAST((CASE WHEN DATEDIFF(mi, cached_time, last_execution_time) > 0 AND execution_count > 1
                          THEN DATEDIFF(mi, cached_time, last_execution_time)
                          ELSE Null END) as MONEY), 0) = 0 THEN 0
            ELSE CAST((1.00 * execution_count / COALESCE(CAST((CASE WHEN DATEDIFF(mi, cached_time, GETDATE()) > 0 AND execution_count > 1
                          THEN DATEDIFF(mi, cached_time, GETDATE())
                          ELSE NULL END) as MONEY), CAST((CASE WHEN DATEDIFF(mi, cached_time, last_execution_time) > 0 AND execution_count > 1
                          THEN DATEDIFF(mi, cached_time, last_execution_time)
                          ELSE Null END) as MONEY))) AS money)
            END '
                END + N' DESC ' + @nl ;


                          
SET @body += N') AS qs 
	   CROSS JOIN(SELECT SUM(execution_count) AS t_TotalExecs,
                         SUM(CAST(total_elapsed_time AS BIGINT) / 1000.0) AS t_TotalElapsed,
                         SUM(CAST(total_worker_time AS BIGINT) / 1000.0) AS t_TotalWorker,
                         SUM(CAST(total_logical_reads AS BIGINT)) AS t_TotalReads,
                         SUM(CAST(total_logical_writes AS BIGINT)) AS t_TotalWrites
                  FROM   sys.#view#) AS t
       CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) AS pa
       CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
       CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp ' + @nl ;

IF @VersionShowsAirQuoteActualPlans = 1
    BEGIN
    SET @body += N'     CROSS APPLY sys.dm_exec_query_plan_stats(qs.plan_handle) AS deqps ' + @nl ;
    END

SET @body_where += N'       AND pa.attribute = ' + QUOTENAME('dbid', @q ) + @nl ;


IF @NoobSaibot = 1
BEGIN
	SET @body_where += N'       AND qp.query_plan.exist(''declare namespace p="http://schemas.microsoft.com/sqlserver/2004/07/showplan";//p:StmtSimple//p:MissingIndex'') = 1' + @nl ;
END

SET @plans_triggers_select_list += N'
SELECT TOP (@Top)
       @@SPID ,
       ''Procedure or Function: '' 
	   + QUOTENAME(COALESCE(OBJECT_SCHEMA_NAME(qs.object_id, qs.database_id),''''))
	   + ''.''
	   + QUOTENAME(COALESCE(OBJECT_NAME(qs.object_id, qs.database_id),'''')) AS QueryType,
       COALESCE(DB_NAME(database_id), CAST(pa.value AS sysname), N''-- N/A --'') AS DatabaseName,
       (total_worker_time / 1000.0) / execution_count AS AvgCPU ,
       (total_worker_time / 1000.0) AS TotalCPU ,
       CASE WHEN total_worker_time = 0 THEN 0
            WHEN COALESCE(age_minutes, DATEDIFF(mi, qs.cached_time, qs.last_execution_time), 0) = 0 THEN 0
            ELSE CAST((total_worker_time / 1000.0) / COALESCE(age_minutes, DATEDIFF(mi, qs.cached_time, qs.last_execution_time)) AS MONEY)
            END AS AverageCPUPerMinute ,
       CASE WHEN t.t_TotalWorker = 0 THEN 0
            ELSE CAST(ROUND(100.00 * (total_worker_time / 1000.0) / t.t_TotalWorker, 2) AS MONEY)
            END AS PercentCPUByType,
       CASE WHEN t.t_TotalElapsed = 0 THEN 0
            ELSE CAST(ROUND(100.00 * (total_elapsed_time / 1000.0) / t.t_TotalElapsed, 2) AS MONEY)
            END AS PercentDurationByType,
       CASE WHEN t.t_TotalReads = 0 THEN 0
            ELSE CAST(ROUND(100.00 * total_logical_reads / t.t_TotalReads, 2) AS MONEY)
            END AS PercentReadsByType,
       CASE WHEN t.t_TotalExecs = 0 THEN 0
            ELSE CAST(ROUND(100.00 * execution_count / t.t_TotalExecs, 2) AS MONEY)
            END AS PercentExecutionsByType,
       (total_elapsed_time / 1000.0) / execution_count AS AvgDuration ,
       (total_elapsed_time / 1000.0) AS TotalDuration ,
       total_logical_reads / execution_count AS AvgReads ,
       total_logical_reads AS TotalReads ,
       execution_count AS ExecutionCount ,
       CASE WHEN execution_count = 0 THEN 0
            WHEN COALESCE(age_minutes, DATEDIFF(mi, qs.cached_time, qs.last_execution_time), 0) = 0 THEN 0
            ELSE CAST((1.00 * execution_count / COALESCE(age_minutes, DATEDIFF(mi, qs.cached_time, qs.last_execution_time))) AS money)
            END AS ExecutionsPerMinute ,
       total_logical_writes AS TotalWrites ,
       total_logical_writes / execution_count AS AverageWrites ,
       CASE WHEN t.t_TotalWrites = 0 THEN 0
            ELSE CAST(ROUND(100.00 * total_logical_writes / t.t_TotalWrites, 2) AS MONEY)
            END AS PercentWritesByType,
       CASE WHEN total_logical_writes = 0 THEN 0
            WHEN COALESCE(age_minutes, DATEDIFF(mi, qs.cached_time, qs.last_execution_time), 0) = 0 THEN 0
            ELSE CAST((1.00 * total_logical_writes / COALESCE(age_minutes, DATEDIFF(mi, qs.cached_time, qs.last_execution_time), 0)) AS money)
            END AS WritesPerMinute,
       qs.cached_time AS PlanCreationTime,
       qs.last_execution_time AS LastExecutionTime,
	   DATEADD(MILLISECOND, (qs.last_elapsed_time / 1000.), qs.last_execution_time) AS LastCompletionTime,
       NULL AS StatementStartOffset,
       NULL AS StatementEndOffset,
	   NULL AS PlanGenerationNum, 
       NULL AS MinReturnedRows,
       NULL AS MaxReturnedRows,
       NULL AS AvgReturnedRows,
       NULL AS TotalReturnedRows,
       NULL AS LastReturnedRows,
       NULL AS MinGrantKB,
       NULL AS MaxGrantKB,
       NULL AS MinUsedGrantKB, 
	   NULL AS MaxUsedGrantKB,
	   NULL AS PercentMemoryGrantUsed, 
	   NULL AS AvgMaxMemoryGrant,';

    IF @VersionShowsSpills = 1
    BEGIN
        RAISERROR(N'Getting spill information for newer versions of SQL', 0, 1) WITH NOWAIT;
		SET @plans_triggers_select_list += N'
           min_spills AS MinSpills,
           max_spills AS MaxSpills,
           total_spills AS TotalSpills,
		   CAST(ISNULL(NULLIF(( total_spills * 1. ), 0) / NULLIF(execution_count, 0), 0) AS MONEY) AS AvgSpills, ';
    END;
    ELSE
    BEGIN
        RAISERROR(N'Substituting NULLs for spill columns in older versions of SQL', 0, 1) WITH NOWAIT;
		SET @plans_triggers_select_list += N'
           NULL AS MinSpills,
           NULL AS MaxSpills,
           NULL AS TotalSpills, 
		   NULL AS AvgSpills, ' ;
    END;		       
	     
	SET @plans_triggers_select_list +=  
	 N'st.text AS QueryText ,';

    IF @VersionShowsAirQuoteActualPlans = 1
        BEGIN
        SET @plans_triggers_select_list += N' CASE WHEN DATALENGTH(COALESCE(deqps.query_plan,'''')) > DATALENGTH(COALESCE(qp.query_plan,'''')) THEN deqps.query_plan ELSE qp.query_plan END AS QueryPlan, ' + @nl ;
        END;
    ELSE   
        BEGIN
        SET @plans_triggers_select_list += N' qp.query_plan AS QueryPlan, ' + @nl ;
        END;

	SET @plans_triggers_select_list +=  
    N't.t_TotalWorker,
       t.t_TotalElapsed,
       t.t_TotalReads,
       t.t_TotalExecs,
       t.t_TotalWrites,
       qs.sql_handle AS SqlHandle,
       qs.plan_handle AS PlanHandle,
       NULL AS QueryHash,
       NULL AS QueryPlanHash,
       qs.min_worker_time / 1000.0,
       qs.max_worker_time / 1000.0,
       CASE WHEN qp.query_plan.value(''declare namespace p="http://schemas.microsoft.com/sqlserver/2004/07/showplan";max(//p:RelOp/@Parallel)'', ''float'')  > 0 THEN 1 ELSE 0 END,
       qs.min_elapsed_time / 1000.0,
       qs.max_elapsed_time / 1000.0,
       age_minutes, 
       age_minutes_lifetime ';


IF LEFT(@QueryFilter, 3) IN ('all', 'sta')
BEGIN
    SET @sql += @insert_list;
    
    SET @sql += N'
    SELECT TOP (@Top)
           @@SPID ,
           ''Statement'' AS QueryType,
           COALESCE(DB_NAME(CAST(pa.value AS INT)), N''-- N/A --'') AS DatabaseName,
           (total_worker_time / 1000.0) / execution_count AS AvgCPU ,
           (total_worker_time / 1000.0) AS TotalCPU ,
           CASE WHEN total_worker_time = 0 THEN 0
                WHEN COALESCE(age_minutes, DATEDIFF(mi, qs.creation_time, qs.last_execution_time), 0) = 0 THEN 0
                ELSE CAST((total_worker_time / 1000.0) / COALESCE(age_minutes, DATEDIFF(mi, qs.creation_time, qs.last_execution_time)) AS MONEY)
                END AS AverageCPUPerMinute ,
           CASE WHEN t.t_TotalWorker = 0 THEN 0
                ELSE CAST(ROUND(100.00 * total_worker_time / t.t_TotalWorker, 2) AS MONEY)
                END AS PercentCPUByType,
           CASE WHEN t.t_TotalElapsed = 0 THEN 0
                ELSE CAST(ROUND(100.00 * total_elapsed_time / t.t_TotalElapsed, 2) AS MONEY)
                END AS PercentDurationByType,
           CASE WHEN t.t_TotalReads = 0 THEN 0
                ELSE CAST(ROUND(100.00 * total_logical_reads / t.t_TotalReads, 2) AS MONEY)
                END AS PercentReadsByType,
           CAST(ROUND(100.00 * execution_count / t.t_TotalExecs, 2) AS MONEY) AS PercentExecutionsByType,
           (total_elapsed_time / 1000.0) / execution_count AS AvgDuration ,
           (total_elapsed_time / 1000.0) AS TotalDuration ,
           total_logical_reads / execution_count AS AvgReads ,
           total_logical_reads AS TotalReads ,
           execution_count AS ExecutionCount ,
           CASE WHEN execution_count = 0 THEN 0
                WHEN COALESCE(age_minutes, DATEDIFF(mi, qs.creation_time, qs.last_execution_time), 0) = 0 THEN 0
                ELSE CAST((1.00 * execution_count / COALESCE(age_minutes, DATEDIFF(mi, qs.creation_time, qs.last_execution_time))) AS money)
                END AS ExecutionsPerMinute ,
           total_logical_writes AS TotalWrites ,
           total_logical_writes / execution_count AS AverageWrites ,
           CASE WHEN t.t_TotalWrites = 0 THEN 0
                ELSE CAST(ROUND(100.00 * total_logical_writes / t.t_TotalWrites, 2) AS MONEY)
                END AS PercentWritesByType,
           CASE WHEN total_logical_writes = 0 THEN 0
                WHEN COALESCE(age_minutes, DATEDIFF(mi, qs.creation_time, qs.last_execution_time), 0) = 0 THEN 0
                ELSE CAST((1.00 * total_logical_writes / COALESCE(age_minutes, DATEDIFF(mi, qs.creation_time, qs.last_execution_time), 0)) AS money)
                END AS WritesPerMinute,
           qs.creation_time AS PlanCreationTime,
           qs.last_execution_time AS LastExecutionTime,
		   DATEADD(MILLISECOND, (qs.last_elapsed_time / 1000.), qs.last_execution_time) AS LastCompletionTime,
           qs.statement_start_offset AS StatementStartOffset,
           qs.statement_end_offset AS StatementEndOffset,
		   qs.plan_generation_num AS PlanGenerationNum, ';
    
    IF (@v >= 11) OR (@v >= 10.5 AND @build >= 2500)
    BEGIN
        RAISERROR(N'Adding additional info columns for newer versions of SQL', 0, 1) WITH NOWAIT;
		SET @sql += N'
           qs.min_rows AS MinReturnedRows,
           qs.max_rows AS MaxReturnedRows,
           CAST(qs.total_rows as MONEY) / execution_count AS AvgReturnedRows,
           qs.total_rows AS TotalReturnedRows,
           qs.last_rows AS LastReturnedRows, ' ;
    END;
    ELSE
    BEGIN
		RAISERROR(N'Substituting NULLs for more info columns in older versions of SQL', 0, 1) WITH NOWAIT;
        SET @sql += N'
           NULL AS MinReturnedRows,
           NULL AS MaxReturnedRows,
           NULL AS AvgReturnedRows,
           NULL AS TotalReturnedRows,
           NULL AS LastReturnedRows, ' ;
    END;

    IF @VersionShowsMemoryGrants = 1
    BEGIN
        RAISERROR(N'Getting memory grant information for newer versions of SQL', 0, 1) WITH NOWAIT;
		SET @sql += N'
           min_grant_kb AS MinGrantKB,
           max_grant_kb AS MaxGrantKB,
           min_used_grant_kb AS MinUsedGrantKB,
           max_used_grant_kb AS MaxUsedGrantKB,
           CAST(ISNULL(NULLIF(( max_used_grant_kb * 1.00 ), 0) / NULLIF(min_grant_kb, 0), 0) * 100. AS MONEY) AS PercentMemoryGrantUsed,
		   CAST(ISNULL(NULLIF(( max_grant_kb * 1. ), 0) / NULLIF(execution_count, 0), 0) AS MONEY) AS AvgMaxMemoryGrant, ';
    END;
    ELSE
    BEGIN
        RAISERROR(N'Substituting NULLs for memory grant columns in older versions of SQL', 0, 1) WITH NOWAIT;
		SET @sql += N'
           NULL AS MinGrantKB,
           NULL AS MaxGrantKB,
           NULL AS MinUsedGrantKB, 
		   NULL AS MaxUsedGrantKB,
		   NULL AS PercentMemoryGrantUsed, 
		   NULL AS AvgMaxMemoryGrant, ' ;
    END;

	IF @VersionShowsSpills = 1
    BEGIN
        RAISERROR(N'Getting spill information for newer versions of SQL', 0, 1) WITH NOWAIT;
		SET @sql += N'
           min_spills AS MinSpills,
           max_spills AS MaxSpills,
           total_spills AS TotalSpills,
		   CAST(ISNULL(NULLIF(( total_spills * 1. ), 0) / NULLIF(execution_count, 0), 0) AS MONEY) AS AvgSpills,';
    END;
    ELSE
    BEGIN
        RAISERROR(N'Substituting NULLs for spill columns in older versions of SQL', 0, 1) WITH NOWAIT;
		SET @sql += N'
           NULL AS MinSpills,
           NULL AS MaxSpills,
           NULL AS TotalSpills, 
		   NULL AS AvgSpills, ' ;
    END;		       
    
    SET @sql += N'
           SUBSTRING(st.text, ( qs.statement_start_offset / 2 ) + 1, ( ( CASE qs.statement_end_offset
                                                                            WHEN -1 THEN DATALENGTH(st.text)
                                                                            ELSE qs.statement_end_offset
                                                                          END - qs.statement_start_offset ) / 2 ) + 1) AS QueryText , ' + @nl ;


    IF @VersionShowsAirQuoteActualPlans = 1
        BEGIN
        SET @sql += N'           CASE WHEN DATALENGTH(COALESCE(deqps.query_plan,'''')) > DATALENGTH(COALESCE(qp.query_plan,'''')) THEN deqps.query_plan ELSE qp.query_plan END AS QueryPlan, ' + @nl ;
        END
    ELSE
        BEGIN
        SET @sql += N'           query_plan AS QueryPlan, ' + @nl ;
        END

    SET @sql += N'
           t.t_TotalWorker,
           t.t_TotalElapsed,
           t.t_TotalReads,
           t.t_TotalExecs,
           t.t_TotalWrites,
           qs.sql_handle AS SqlHandle,
           qs.plan_handle AS PlanHandle,
           qs.query_hash AS QueryHash,
           qs.query_plan_hash AS QueryPlanHash,
           qs.min_worker_time / 1000.0,
           qs.max_worker_time / 1000.0,
           CASE WHEN qp.query_plan.value(''declare namespace p="http://schemas.microsoft.com/sqlserver/2004/07/showplan";max(//p:RelOp/@Parallel)'', ''float'')  > 0 THEN 1 ELSE 0 END,
           qs.min_elapsed_time / 1000.0,
           qs.max_worker_time  / 1000.0,
           age_minutes,
           age_minutes_lifetime ';
    
    SET @sql += REPLACE(REPLACE(@body, '#view#', 'dm_exec_query_stats'), 'cached_time', 'creation_time') ;

	SET @sort_filter += CASE @SortOrder  WHEN N'cpu' THEN N'AND total_worker_time > 0'
                                WHEN N'reads' THEN N'AND total_logical_reads > 0'
                                WHEN N'writes' THEN N'AND total_logical_writes > 0'
                                WHEN N'duration' THEN N'AND total_elapsed_time > 0'
                                WHEN N'executions' THEN N'AND execution_count > 0'
                                /* WHEN N'compiles' THEN N'AND (age_minutes + age_minutes_lifetime) > 0'  BGO 2021-01-24 commenting out for https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit/issues/2772 */
								WHEN N'memory grant' THEN N'AND max_grant_kb > 0'
								WHEN N'unused grant' THEN N'AND max_grant_kb > 0'
								WHEN N'spills' THEN N'AND max_spills > 0'
                                /* And now the averages */
                                WHEN N'avg cpu' THEN N'AND (total_worker_time / execution_count) > 0'
                                WHEN N'avg reads' THEN N'AND (total_logical_reads / execution_count) > 0'
                                WHEN N'avg writes' THEN N'AND (total_logical_writes / execution_count) > 0'
                                WHEN N'avg duration' THEN N'AND (total_elapsed_time / execution_count) > 0'
								WHEN N'avg memory grant' THEN N'AND CASE WHEN max_grant_kb = 0 THEN 0 ELSE (max_grant_kb / execution_count) END > 0'
                                WHEN N'avg spills' THEN N'AND CASE WHEN total_spills = 0 THEN 0 ELSE (total_spills / execution_count) END > 0'
                                WHEN N'avg executions' THEN N'AND CASE WHEN execution_count = 0 THEN 0
            WHEN COALESCE(age_minutes, age_minutes_lifetime, 0) = 0 THEN 0
            ELSE CAST((1.00 * execution_count / COALESCE(age_minutes, age_minutes_lifetime)) AS money)
            END > 0'
            ELSE N' /* No minimum threshold set */ '
               END;

    SET @sql += REPLACE(@body_where, 'cached_time', 'creation_time') ;

	SET @sql += @sort_filter + @nl;
    
    SET @sql += @body_order + @nl + @nl + @nl;

    IF @SortOrder = 'compiles'
    BEGIN
        RAISERROR(N'Sorting by compiles', 0, 1) WITH NOWAIT;
		SET @sql = REPLACE(@sql, '#sortable#', 'creation_time');
    END;
END;


IF (@QueryFilter = 'all' 
   AND (SELECT COUNT(*) FROM #only_query_hashes) = 0 
   AND (SELECT COUNT(*) FROM #ignore_query_hashes) = 0) 
   AND (@SortOrder NOT IN ('memory grant', 'avg memory grant', 'unused grant'))
   OR (LEFT(@QueryFilter, 3) = 'pro')
BEGIN
    SET @sql += @insert_list;
    SET @sql += REPLACE(@plans_triggers_select_list, '#query_type#', 'Stored Procedure') ;

    SET @sql += REPLACE(@body, '#view#', 'dm_exec_procedure_stats') ; 
    SET @sql += @body_where ;

    IF @IgnoreSystemDBs = 1
       SET @sql += N' AND COALESCE(DB_NAME(database_id), CAST(pa.value AS sysname), '''') NOT IN (''master'', ''model'', ''msdb'', ''tempdb'', ''32767'') AND COALESCE(DB_NAME(database_id), CAST(pa.value AS sysname), '''') NOT IN (SELECT name FROM sys.databases WHERE is_distributor = 1)' + @nl ;

	SET @sql += @sort_filter + @nl;

	SET @sql += @body_order + @nl + @nl + @nl ;
END;

IF (@v >= 13
   AND @QueryFilter = 'all'
   AND (SELECT COUNT(*) FROM #only_query_hashes) = 0 
   AND (SELECT COUNT(*) FROM #ignore_query_hashes) = 0) 
   AND (@SortOrder NOT IN ('memory grant', 'avg memory grant', 'unused grant'))
   AND (@SortOrder NOT IN ('spills', 'avg spills'))
   OR (LEFT(@QueryFilter, 3) = 'fun')
BEGIN
    SET @sql += @insert_list;
    SET @sql += REPLACE(REPLACE(@plans_triggers_select_list, '#query_type#', 'Function')
			, N'
           min_spills AS MinSpills,
           max_spills AS MaxSpills,
           total_spills AS TotalSpills,
		   CAST(ISNULL(NULLIF(( total_spills * 1. ), 0) / NULLIF(execution_count, 0), 0) AS MONEY) AS AvgSpills, ', 
		   N'
           NULL AS MinSpills,
           NULL AS MaxSpills,
           NULL AS TotalSpills, 
		   NULL AS AvgSpills, ') ;

    SET @sql += REPLACE(@body, '#view#', 'dm_exec_function_stats') ; 
    SET @sql += @body_where ;

    IF @IgnoreSystemDBs = 1
       SET @sql += N' AND COALESCE(DB_NAME(database_id), CAST(pa.value AS sysname), '''') NOT IN (''master'', ''model'', ''msdb'', ''tempdb'', ''32767'') AND COALESCE(DB_NAME(database_id), CAST(pa.value AS sysname), '''') NOT IN (SELECT name FROM sys.databases WHERE is_distributor = 1)' + @nl ;

	SET @sql += @sort_filter + @nl;

	SET @sql += @body_order + @nl + @nl + @nl ;
END;

/*******************************************************************************
 *
 * Because the trigger execution count in SQL Server 2008R2 and earlier is not
 * correct, we ignore triggers for these versions of SQL Server. If you'd like
 * to include trigger numbers, just know that the ExecutionCount,
 * PercentExecutions, and ExecutionsPerMinute are wildly inaccurate for
 * triggers on these versions of SQL Server.
 *
 * This is why we can't have nice things.
 *
 ******************************************************************************/
IF (@UseTriggersAnyway = 1 OR @v >= 11)
   AND (SELECT COUNT(*) FROM #only_query_hashes) = 0
   AND (SELECT COUNT(*) FROM #ignore_query_hashes) = 0
   AND (@QueryFilter = 'all')
   AND (@SortOrder NOT IN ('memory grant', 'avg memory grant', 'unused grant'))
BEGIN
   RAISERROR (N'Adding SQL to collect trigger stats.',0,1) WITH NOWAIT;

   /* Trigger level information from the plan cache */
   SET @sql += @insert_list ;

   SET @sql += REPLACE(@plans_triggers_select_list, '#query_type#', 'Trigger') ;

   SET @sql += REPLACE(@body, '#view#', 'dm_exec_trigger_stats') ;

   SET @sql += @body_where ;

   IF @IgnoreSystemDBs = 1
      SET @sql += N' AND COALESCE(DB_NAME(database_id), CAST(pa.value AS sysname), '''') NOT IN (''master'', ''model'', ''msdb'', ''tempdb'', ''32767'') AND COALESCE(DB_NAME(database_id), CAST(pa.value AS sysname), '''') NOT IN (SELECT name FROM sys.databases WHERE is_distributor = 1)' + @nl ;

   SET @sql += @sort_filter + @nl;   

   SET @sql += @body_order + @nl + @nl + @nl ;
END;



SELECT @sort = CASE @SortOrder  WHEN N'cpu' THEN N'total_worker_time'
                                WHEN N'reads' THEN N'total_logical_reads'
                                WHEN N'writes' THEN N'total_logical_writes'
                                WHEN N'duration' THEN N'total_elapsed_time'
                                WHEN N'executions' THEN N'execution_count'
                                WHEN N'compiles' THEN N'cached_time'
								WHEN N'memory grant' THEN N'max_grant_kb'
								WHEN N'unused grant' THEN N'max_grant_kb - max_used_grant_kb'
								WHEN N'spills' THEN N'max_spills'
                                /* And now the averages */
                                WHEN N'avg cpu' THEN N'total_worker_time / execution_count'
                                WHEN N'avg reads' THEN N'total_logical_reads / execution_count'
                                WHEN N'avg writes' THEN N'total_logical_writes / execution_count'
                                WHEN N'avg duration' THEN N'total_elapsed_time / execution_count'
								WHEN N'avg memory grant' THEN N'CASE WHEN max_grant_kb = 0 THEN 0 ELSE max_grant_kb / execution_count END'
                                WHEN N'avg spills' THEN N'CASE WHEN total_spills = 0 THEN 0 ELSE total_spills / execution_count END'
                                WHEN N'avg executions' THEN N'CASE WHEN execution_count = 0 THEN 0
            WHEN COALESCE(age_minutes, age_minutes_lifetime, 0) = 0 THEN 0
            ELSE CAST((1.00 * execution_count / COALESCE(age_minutes, age_minutes_lifetime)) AS money)
            END'
               END ;

SELECT @sql = REPLACE(@sql, '#sortable#', @sort);

SET @sql += N'
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
INSERT INTO #p (SqlHandle, TotalCPU, TotalReads, TotalDuration, TotalWrites, ExecutionCount)
SELECT  SqlHandle,
        TotalCPU,
        TotalReads,
        TotalDuration,
        TotalWrites,
        ExecutionCount
FROM    (SELECT  SqlHandle,
                 TotalCPU,
                 TotalReads,
                 TotalDuration,
                 TotalWrites,
                 ExecutionCount,
                 ROW_NUMBER() OVER (PARTITION BY SqlHandle ORDER BY #sortable# DESC) AS rn
         FROM    ##BlitzCacheProcs
		 WHERE SPID = @@SPID) AS x
WHERE x.rn = 1
OPTION (RECOMPILE);

/* 
    This block was used to delete duplicate queries, but has been removed.
    For more info: https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit/issues/2026
WITH d AS (
SELECT  SPID,
        ROW_NUMBER() OVER (PARTITION BY SqlHandle, QueryHash ORDER BY #sortable# DESC) AS rn
FROM    ##BlitzCacheProcs
WHERE SPID = @@SPID
)
DELETE d
WHERE d.rn > 1
AND SPID = @@SPID
OPTION (RECOMPILE); 
*/
';

SELECT @sort = CASE @SortOrder  WHEN N'cpu' THEN N'TotalCPU'
                                WHEN N'reads' THEN N'TotalReads'
                                WHEN N'writes' THEN N'TotalWrites'
                                WHEN N'duration' THEN N'TotalDuration'
                                WHEN N'executions' THEN N'ExecutionCount'
                                WHEN N'compiles' THEN N'PlanCreationTime'
								WHEN N'memory grant' THEN N'MaxGrantKB'
								WHEN N'unused grant' THEN N'MaxGrantKB - MaxUsedGrantKB'
								WHEN N'spills' THEN N'MaxSpills'
                                /* And now the averages */
                                WHEN N'avg cpu' THEN N'TotalCPU / ExecutionCount'
                                WHEN N'avg reads' THEN N'TotalReads / ExecutionCount'
                                WHEN N'avg writes' THEN N'TotalWrites / ExecutionCount'
                                WHEN N'avg duration' THEN N'TotalDuration / ExecutionCount'
								WHEN N'avg memory grant' THEN N'AvgMaxMemoryGrant'
                                WHEN N'avg spills' THEN N'AvgSpills'
                                WHEN N'avg executions' THEN N'CASE WHEN ExecutionCount = 0 THEN 0
            WHEN COALESCE(age_minutes, age_minutes_lifetime, 0) = 0 THEN 0
            ELSE CAST((1.00 * ExecutionCount / COALESCE(age_minutes, age_minutes_lifetime)) AS money)
            END'
               END ;

SELECT @sql = REPLACE(@sql, '#sortable#', @sort);


IF @Debug = 1
    BEGIN
        PRINT SUBSTRING(@sql, 0, 4000);
        PRINT SUBSTRING(@sql, 4000, 8000);
        PRINT SUBSTRING(@sql, 8000, 12000);
        PRINT SUBSTRING(@sql, 12000, 16000);
        PRINT SUBSTRING(@sql, 16000, 20000);
        PRINT SUBSTRING(@sql, 20000, 24000);
        PRINT SUBSTRING(@sql, 24000, 28000);
        PRINT SUBSTRING(@sql, 28000, 32000);
        PRINT SUBSTRING(@sql, 32000, 36000);
        PRINT SUBSTRING(@sql, 36000, 40000);
    END;

IF @Reanalyze = 0
BEGIN
    RAISERROR('Collecting execution plan information.', 0, 1) WITH NOWAIT;

    EXEC sp_executesql @sql, N'@Top INT, @min_duration INT, @min_back INT', @Top, @DurationFilter_i, @MinutesBack;
END;

IF @SkipAnalysis = 1
    BEGIN
	RAISERROR(N'Skipping analysis, going to results', 0, 1) WITH NOWAIT; 
	GOTO Results ;
	END; 


/* Update ##BlitzCacheProcs to get Stored Proc info 
 * This should get totals for all statements in a Stored Proc
 */
RAISERROR(N'Attempting to aggregate stored proc info from separate statements', 0, 1) WITH NOWAIT;
;WITH agg AS (
    SELECT 
        b.SqlHandle,
        SUM(b.MinReturnedRows) AS MinReturnedRows,
        SUM(b.MaxReturnedRows) AS MaxReturnedRows,
        SUM(b.AverageReturnedRows) AS AverageReturnedRows,
        SUM(b.TotalReturnedRows) AS TotalReturnedRows,
        SUM(b.LastReturnedRows) AS LastReturnedRows,
		SUM(b.MinGrantKB) AS MinGrantKB,
		SUM(b.MaxGrantKB) AS MaxGrantKB,
		SUM(b.MinUsedGrantKB) AS MinUsedGrantKB,
		SUM(b.MaxUsedGrantKB) AS MaxUsedGrantKB,
        SUM(b.MinSpills) AS MinSpills,
        SUM(b.MaxSpills) AS MaxSpills,
        SUM(b.TotalSpills) AS TotalSpills
    FROM ##BlitzCacheProcs b
    WHERE b.SPID = @@SPID
	AND b.QueryHash IS NOT NULL
    GROUP BY b.SqlHandle
)
UPDATE b
    SET 
        b.MinReturnedRows     = b2.MinReturnedRows,
        b.MaxReturnedRows     = b2.MaxReturnedRows,
        b.AverageReturnedRows = b2.AverageReturnedRows,
        b.TotalReturnedRows   = b2.TotalReturnedRows,
        b.LastReturnedRows    = b2.LastReturnedRows,
		b.MinGrantKB		  = b2.MinGrantKB,
		b.MaxGrantKB		  = b2.MaxGrantKB,
		b.MinUsedGrantKB	  = b2.MinUsedGrantKB,
		b.MaxUsedGrantKB      = b2.MaxUsedGrantKB,
        b.MinSpills           = b2.MinSpills,
        b.MaxSpills           = b2.MaxSpills,
        b.TotalSpills         = b2.TotalSpills
FROM ##BlitzCacheProcs b
JOIN agg b2
ON b2.SqlHandle = b.SqlHandle
WHERE b.QueryHash IS NULL
AND b.SPID = @@SPID
OPTION (RECOMPILE) ;

/* Compute the total CPU, etc across our active set of the plan cache.
 * Yes, there's a flaw - this doesn't include anything outside of our @Top
 * metric.
 */
RAISERROR('Computing CPU, duration, read, and write metrics', 0, 1) WITH NOWAIT;
DECLARE @total_duration BIGINT,
        @total_cpu BIGINT,
        @total_reads BIGINT,
        @total_writes BIGINT,
        @total_execution_count BIGINT;

SELECT  @total_cpu = SUM(TotalCPU),
        @total_duration = SUM(TotalDuration),
        @total_reads = SUM(TotalReads),
        @total_writes = SUM(TotalWrites),
        @total_execution_count = SUM(ExecutionCount)
FROM    #p 
OPTION (RECOMPILE) ;

DECLARE @cr NVARCHAR(1) = NCHAR(13);
DECLARE @lf NVARCHAR(1) = NCHAR(10);
DECLARE @tab NVARCHAR(1) = NCHAR(9);

/* Update CPU percentage for stored procedures */
RAISERROR(N'Update CPU percentage for stored procedures', 0, 1) WITH NOWAIT;
UPDATE ##BlitzCacheProcs
SET     PercentCPU = y.PercentCPU,
        PercentDuration = y.PercentDuration,
        PercentReads = y.PercentReads,
        PercentWrites = y.PercentWrites,
        PercentExecutions = y.PercentExecutions,
        ExecutionsPerMinute = y.ExecutionsPerMinute,
        /* Strip newlines and tabs. Tabs are replaced with multiple spaces
           so that the later whitespace trim will completely eliminate them
         */
        QueryText = REPLACE(REPLACE(REPLACE(QueryText, @cr, ' '), @lf, ' '), @tab, '  ')
FROM (
    SELECT  PlanHandle,
            CASE @total_cpu WHEN 0 THEN 0
                 ELSE CAST((100. * TotalCPU) / @total_cpu AS MONEY) END AS PercentCPU,
            CASE @total_duration WHEN 0 THEN 0
                 ELSE CAST((100. * TotalDuration) / @total_duration AS MONEY) END AS PercentDuration,
            CASE @total_reads WHEN 0 THEN 0
                 ELSE CAST((100. * TotalReads) / @total_reads AS MONEY) END AS PercentReads,
            CASE @total_writes WHEN 0 THEN 0
                 ELSE CAST((100. * TotalWrites) / @total_writes AS MONEY) END AS PercentWrites,
            CASE @total_execution_count WHEN 0 THEN 0
                 ELSE CAST((100. * ExecutionCount) / @total_execution_count AS MONEY) END AS PercentExecutions,
            CASE DATEDIFF(mi, PlanCreationTime, LastExecutionTime)
                WHEN 0 THEN 0
                ELSE CAST((1.00 * ExecutionCount / DATEDIFF(mi, PlanCreationTime, LastExecutionTime)) AS MONEY)
            END AS ExecutionsPerMinute
    FROM (
        SELECT  PlanHandle,
                TotalCPU,
                TotalDuration,
                TotalReads,
                TotalWrites,
                ExecutionCount,
                PlanCreationTime,
                LastExecutionTime
        FROM    ##BlitzCacheProcs
        WHERE   PlanHandle IS NOT NULL
		AND SPID = @@SPID
        GROUP BY PlanHandle,
                TotalCPU,
                TotalDuration,
                TotalReads,
                TotalWrites,
                ExecutionCount,
                PlanCreationTime,
                LastExecutionTime
    ) AS x
) AS y
WHERE ##BlitzCacheProcs.PlanHandle = y.PlanHandle
      AND ##BlitzCacheProcs.PlanHandle IS NOT NULL
	  AND ##BlitzCacheProcs.SPID = @@SPID
OPTION (RECOMPILE) ;


RAISERROR(N'Gather percentage information from grouped results', 0, 1) WITH NOWAIT;
UPDATE ##BlitzCacheProcs
SET     PercentCPU = y.PercentCPU,
        PercentDuration = y.PercentDuration,
        PercentReads = y.PercentReads,
        PercentWrites = y.PercentWrites,
        PercentExecutions = y.PercentExecutions,
        ExecutionsPerMinute = y.ExecutionsPerMinute,
        /* Strip newlines and tabs. Tabs are replaced with multiple spaces
           so that the later whitespace trim will completely eliminate them
         */
        QueryText = REPLACE(REPLACE(REPLACE(QueryText, @cr, ' '), @lf, ' '), @tab, '  ')
FROM (
    SELECT  DatabaseName,
            SqlHandle,
            QueryHash,
            CASE @total_cpu WHEN 0 THEN 0
                 ELSE CAST((100. * TotalCPU) / @total_cpu AS MONEY) END AS PercentCPU,
            CASE @total_duration WHEN 0 THEN 0
                 ELSE CAST((100. * TotalDuration) / @total_duration AS MONEY) END AS PercentDuration,
            CASE @total_reads WHEN 0 THEN 0
                 ELSE CAST((100. * TotalReads) / @total_reads AS MONEY) END AS PercentReads,
            CASE @total_writes WHEN 0 THEN 0
                 ELSE CAST((100. * TotalWrites) / @total_writes AS MONEY) END AS PercentWrites,
            CASE @total_execution_count WHEN 0 THEN 0
                 ELSE CAST((100. * ExecutionCount) / @total_execution_count AS MONEY) END AS PercentExecutions,
            CASE  DATEDIFF(mi, PlanCreationTime, LastExecutionTime)
                WHEN 0 THEN 0
                ELSE CAST((1.00 * ExecutionCount / DATEDIFF(mi, PlanCreationTime, LastExecutionTime)) AS MONEY)
            END AS ExecutionsPerMinute
    FROM (
        SELECT  DatabaseName,
                SqlHandle,
                QueryHash,
                TotalCPU,
                TotalDuration,
                TotalReads,
                TotalWrites,
                ExecutionCount,
                PlanCreationTime,
                LastExecutionTime
        FROM    ##BlitzCacheProcs
		WHERE SPID = @@SPID
        GROUP BY DatabaseName,
                SqlHandle,
                QueryHash,
                TotalCPU,
                TotalDuration,
                TotalReads,
                TotalWrites,
                ExecutionCount,
                PlanCreationTime,
                LastExecutionTime
    ) AS x
) AS y
WHERE   ##BlitzCacheProcs.SqlHandle = y.SqlHandle
        AND ##BlitzCacheProcs.QueryHash = y.QueryHash
        AND ##BlitzCacheProcs.DatabaseName = y.DatabaseName
        AND ##BlitzCacheProcs.PlanHandle IS NULL
OPTION (RECOMPILE) ;



/* Testing using XML nodes to speed up processing */
RAISERROR(N'Begin XML nodes processing', 0, 1) WITH NOWAIT;
WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS p)
SELECT  QueryHash ,
        SqlHandle ,
		PlanHandle,
        q.n.query('.') AS statement,
        0 AS is_cursor
INTO    #statements
FROM    ##BlitzCacheProcs p
        CROSS APPLY p.QueryPlan.nodes('//p:StmtSimple') AS q(n) 
WHERE p.SPID = @@SPID
OPTION (RECOMPILE) ;

WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS p)
INSERT #statements
SELECT  QueryHash ,
        SqlHandle ,
		PlanHandle,
        q.n.query('.') AS statement,
        1 AS is_cursor
FROM    ##BlitzCacheProcs p
        CROSS APPLY p.QueryPlan.nodes('//p:StmtCursor') AS q(n) 
WHERE p.SPID = @@SPID
OPTION (RECOMPILE) ;

WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS p)
SELECT  QueryHash ,
        SqlHandle ,
        q.n.query('.') AS query_plan
INTO    #query_plan
FROM    #statements p
        CROSS APPLY p.statement.nodes('//p:QueryPlan') AS q(n) 
OPTION (RECOMPILE) ;

WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS p)
SELECT  QueryHash ,
        SqlHandle ,
        q.n.query('.') AS relop
INTO    #relop
FROM    #query_plan p
        CROSS APPLY p.query_plan.nodes('//p:RelOp') AS q(n) 
OPTION (RECOMPILE) ;

-- high level plan stuff
RAISERROR(N'Gathering high level plan information', 0, 1) WITH NOWAIT;
UPDATE  ##BlitzCacheProcs
SET     NumberOfDistinctPlans = distinct_plan_count,
        NumberOfPlans = number_of_plans ,
        plan_multiple_plans = CASE WHEN distinct_plan_count < number_of_plans THEN number_of_plans END
FROM (
        SELECT  COUNT(DISTINCT QueryHash) AS distinct_plan_count,
                COUNT(QueryHash) AS number_of_plans,
                QueryHash,
				DatabaseName
        FROM    ##BlitzCacheProcs
		WHERE SPID = @@SPID
        GROUP BY QueryHash,
		         DatabaseName
) AS x
WHERE ##BlitzCacheProcs.QueryHash = x.QueryHash
AND   ##BlitzCacheProcs.DatabaseName = x.DatabaseName
OPTION (RECOMPILE) ;

-- query level checks
RAISERROR(N'Performing query level checks', 0, 1) WITH NOWAIT;
WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS p)
UPDATE  ##BlitzCacheProcs
SET     missing_index_count = query_plan.value('count(//p:QueryPlan/p:MissingIndexes/p:MissingIndexGroup)', 'int') ,
		unmatched_index_count = CASE WHEN is_trivial <> 1 THEN query_plan.value('count(//p:QueryPlan/p:UnmatchedIndexes/p:Parameterization/p:Object)', 'int') END ,
        SerialDesiredMemory = query_plan.value('sum(//p:QueryPlan/p:MemoryGrantInfo/@SerialDesiredMemory)', 'float') ,
        SerialRequiredMemory = query_plan.value('sum(//p:QueryPlan/p:MemoryGrantInfo/@SerialRequiredMemory)', 'float'),
        CachedPlanSize = query_plan.value('sum(//p:QueryPlan/@CachedPlanSize)', 'float') ,
        CompileTime = query_plan.value('sum(//p:QueryPlan/@CompileTime)', 'float') ,
        CompileCPU = query_plan.value('sum(//p:QueryPlan/@CompileCPU)', 'float') ,
        CompileMemory = query_plan.value('sum(//p:QueryPlan/@CompileMemory)', 'float'),
		MaxCompileMemory = query_plan.value('sum(//p:QueryPlan/p:OptimizerHardwareDependentProperties/@MaxCompileMemory)', 'float')
FROM    #query_plan qp
WHERE   qp.QueryHash = ##BlitzCacheProcs.QueryHash
AND     qp.SqlHandle = ##BlitzCacheProcs.SqlHandle
AND SPID = @@SPID
OPTION (RECOMPILE);

-- statement level checks
RAISERROR(N'Performing compile timeout checks', 0, 1) WITH NOWAIT;
WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS p)
UPDATE b
SET     compile_timeout = 1 
FROM    #statements s
JOIN ##BlitzCacheProcs b
ON  s.QueryHash = b.QueryHash
AND SPID = @@SPID
WHERE statement.exist('/p:StmtSimple/@StatementOptmEarlyAbortReason[.="TimeOut"]') = 1
OPTION (RECOMPILE);

RAISERROR(N'Performing compile memory limit exceeded checks', 0, 1) WITH NOWAIT;
WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS p)
UPDATE b
SET     compile_memory_limit_exceeded = 1 
FROM    #statements s
JOIN ##BlitzCacheProcs b
ON  s.QueryHash = b.QueryHash
AND SPID = @@SPID
WHERE statement.exist('/p:StmtSimple/@StatementOptmEarlyAbortReason[.="MemoryLimitExceeded"]') = 1
OPTION (RECOMPILE);

IF @ExpertMode > 0
BEGIN
RAISERROR(N'Performing unparameterized query checks', 0, 1) WITH NOWAIT;
WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS p),
unparameterized_query AS (
	SELECT s.QueryHash,
		   unparameterized_query = CASE WHEN statement.exist('//p:StmtSimple[@StatementOptmLevel[.="FULL"]]/p:QueryPlan/p:ParameterList') = 1 AND
                                             statement.exist('//p:StmtSimple[@StatementOptmLevel[.="FULL"]]/p:QueryPlan/p:ParameterList/p:ColumnReference') = 0 THEN 1
                                        WHEN statement.exist('//p:StmtSimple[@StatementOptmLevel[.="FULL"]]/p:QueryPlan/p:ParameterList') = 0 AND
                                             statement.exist('//p:StmtSimple[@StatementOptmLevel[.="FULL"]]/*/p:RelOp/descendant::p:ScalarOperator/p:Identifier/p:ColumnReference[contains(@Column, "@")]') = 1 THEN 1
                                   END
	FROM #statements AS s
			)
UPDATE b
SET b.unparameterized_query = u.unparameterized_query
FROM ##BlitzCacheProcs b
JOIN unparameterized_query u
ON  u.QueryHash = b.QueryHash
AND SPID = @@SPID
WHERE u.unparameterized_query = 1
OPTION (RECOMPILE);
END;


IF @ExpertMode > 0
BEGIN
RAISERROR(N'Performing index DML checks', 0, 1) WITH NOWAIT;
WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS p),
index_dml AS (
	SELECT	s.QueryHash,	
			index_dml = CASE WHEN statement.exist('//p:StmtSimple/@StatementType[.="CREATE INDEX"]') = 1 THEN 1
							 WHEN statement.exist('//p:StmtSimple/@StatementType[.="DROP INDEX"]') = 1 THEN 1
						END
	FROM    #statements s
			)
	UPDATE b
		SET b.index_dml = i.index_dml
	FROM ##BlitzCacheProcs AS b
	JOIN index_dml i
	ON i.QueryHash = b.QueryHash
	WHERE i.index_dml = 1
	AND b.SPID = @@SPID
	OPTION (RECOMPILE);
END;


IF @ExpertMode > 0
BEGIN
RAISERROR(N'Performing table DML checks', 0, 1) WITH NOWAIT;
WITH XMLNAMESPACES('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS p),
table_dml AS (
	SELECT s.QueryHash,			
		   table_dml = CASE WHEN statement.exist('//p:StmtSimple/@StatementType[.="CREATE TABLE"]') = 1 THEN 1
							WHEN statement.exist('//p:StmtSimple/@StatementType[.="DROP OBJECT"]') = 1 THEN 1
							END
		 FROM #statements AS s
		 )
	UPDATE b
		SET b.table_dml = t.table_dml
	FROM ##BlitzCacheProcs AS b
	JOIN table_dml t
	ON t.QueryHash = b.QueryHash
	WHERE t.table_dml = 1
	AND b.SPID = @@SPID
	OPTION (RECOMPILE);
END; 


IF @ExpertMode > 0
BEGIN
RAISERROR(N'Gathering row estimates', 0, 1) WITH NOWAIT;
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS p )
INSERT INTO #est_rows
SELECT DISTINCT 
		CONVERT(BINARY(8), RIGHT('0000000000000000' + SUBSTRING(c.n.value('@QueryHash', 'VARCHAR(18)'), 3, 18), 16), 2) AS QueryHash,
		c.n.value('(/p:StmtSimple/@StatementEstRows)[1]', 'FLOAT') AS estimated_rows
FROM   #statements AS s
CROSS APPLY s.statement.nodes('/p:StmtSimple') AS c(n)
WHERE  c.n.exist('/p:StmtSimple[@StatementEstRows > 0]') = 1;

	UPDAT
