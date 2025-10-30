use master
go

-- Captura as 10 consultas com maior consumo de CPU, incluindo o plano de execução, execuções totais e leituras lógicas.
SELECT TOP 10
	qs_cpu.total_worker_time / 1000 AS total_cpu_time_ms,
	qs_cpu.total_logical_reads,
	q.[text],
	p.query_plan,
	qs_cpu.execution_count,
	DB_NAME(q.dbid) AS nome_database,
	q.objectid,
	q.encrypted AS text_encrypted
FROM
	(SELECT TOP 500 qs.plan_handle,
	qs.total_worker_time,
	qs.execution_count,
	qs.total_logical_reads
	FROM sys.dm_exec_query_stats qs
	ORDER BY qs.total_worker_time DESC) AS qs_cpu
	CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS q
	CROSS APPLY sys.dm_exec_query_plan(plan_handle) p
	WHERE p.query_plan.exist('declare namespace qplan="https://lnkd.in/dHyycV4f"; 
	//qplan:MissingIndexes') = 1;