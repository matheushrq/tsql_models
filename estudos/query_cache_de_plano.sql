use master
go

SELECT TOP 10 
	qs.total_worker_time / qs.execution_count AS AvgCPU, 
	qs.execution_count, 
	qp.query_plan, 
	qt.text AS QueryText 
FROM	sys.dm_exec_query_stats qs 
CROSS	APPLY sys.dm_exec_sql_text(qs.sql_handle) qt 
CROSS	APPLY sys.dm_exec_query_plan(qs.plan_handle) qp 
ORDER	BY AvgCPU DESC