-- Consulta avançada para monitorar processos no SQL Server
SELECT
	s.session_id,
	r.request_id,
	DB_NAME(s.database_id) AS [Database],
	s.login_name,
	s.host_name,
	s.program_name,
	r.status,
	r.command,
	r.cpu_time AS [CPU (ms)],
	r.total_elapsed_time AS [Elapsed Time (ms)],
	r.reads,
	r.writes,
	r.logical_reads,
	r.wait_type,
	r.wait_time AS [Wait Time (ms)],
	r.blocking_session_id,
	t.text AS [SQL Query],
	qp.query_plan,
	r.transaction_isolation_level,
	s.open_transaction_count
FROM	sys.dm_exec_sessions s
LEFT	JOIN sys.dm_exec_requests r
ON		s.session_id = r.session_id
OUTER	APPLY sys.dm_exec_sql_text(r.sql_handle) t
OUTER	APPLY sys.dm_exec_query_plan(r.plan_handle) qp
WHERE	s.session_id > 50 -- Filtra sessões de sistema (opcional)
ORDER	BY r.cpu_time DESC

/*
	Principais Colunas Explicadas:
	session_id: ID da sessão no SQL Server.
	Database: Banco de dados em uso.
	login_name/host_name/program_name: Quem está conectado e de onde.
	status: Status da requisição (running, sleeping, suspended).
	command: Tipo de operação (SELECT, INSERT, UPDATE, etc.).
	CPU/Elapsed Time: Tempo de CPU e tempo total consumido.
	reads/writes/logical_reads: Operações de I/O.
	wait_type/wait_time: Recursos que estão causando espera (ex: LCK_M_X para bloqueios).
	blocking_session_id: Sessão que está bloqueando outra (útil para deadlocks).
	SQL Query: Texto da consulta em execução.
	query_plan: Plano de execução da consulta (XML).

	Como Usar:
	Bloqueios em Tempo Real: Procure por blocking_session_id não nulo.
	Consultas Custosas: Ordene por CPU (ms) ou Elapsed Time (ms) para encontrar gargalos.
	Sessões "Zumbis": Filtre por status = 'sleeping' e open_transaction_count > 0.

	Funcionalidades Avançadas Incluídas:
	Identificação de Bloqueios: A coluna blocking_session_id mostra quem está bloqueando outros processos.
	Plano de Execução: Use query_plan para analisar otimizações (clique no resultado para visualizar gráficamente no SSMS).
	Filtro de Sessões de Sistema: WHERE session_id > 50 remove processos internos do SQL Server (ajuste conforme necessário).
*/