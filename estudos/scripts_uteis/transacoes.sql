/* -- Verificando transações -- */

DBCC OPENTRAN; -- identificar transação ativa mais antiga
GO


-- Verificando todas as transações abertas
SELECT 
    dtat.transaction_id,
    dtat.transaction_begin_time,
    dtat.transaction_type,
    dest.session_id,
    dest.login_time,
    dest.host_name,
    dest.program_name,
    dest.login_name
FROM sys.dm_tran_database_transactions dtat
JOIN sys.dm_tran_session_transactions dtst 
    ON dtat.transaction_id = dtst.transaction_id
JOIN sys.dm_exec_sessions dest 
    ON dtst.session_id = dest.session_id;