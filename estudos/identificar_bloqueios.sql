use master
go

SELECT
		r.blocking_session_id AS BlockingSession,
		r.session_id AS BlockedSession,
		s.host_name,
		s.program_name,
		s.login_name,
		r.wait_time / 1000 AS wait_time_sec,
		r.command,
		DB_NAME(r.database_id) AS database_name
FROM	sys.dm_exec_requests r
JOIN	sys.dm_exec_sessions s ON r.session_id = s.session_id
WHERE	r.blocking_session_id <> 0
ORDER	BY r.wait_time DESC