use master
go

SELECT TOP 10
	 wait_type,
	 wait_time_ms / 1000.0 AS wait_time_sec,
	 waiting_tasks_count
FROM	sys.dm_os_wait_stats 
WHERE	wait_time_ms > 0
ORDER	BY wait_time_ms DESC;

/*
	O que s�o waits?
	Waits (esperas) representam o tempo que uma thread gasta aguardando por algum recurso ou evento antes de continuar sua execu��o. Em outras palavras, � onde o SQL Server �empaca�.

	Por que os waits s�o importantes?
	Eles ajudam a diagnosticar gargalos de performance, indicando exatamente onde sua inst�ncia est� tendo dificuldades. Algumas das causas mais comuns incluem:
	� Falta de recursos (CPU, mem�ria, I/O).
	� Problemas em queries ou �ndices.
	� Bloqueios e conten��es.

	Como monitorar?
	Use a DMV sys.dm_os_wait_stats para identificar os principais waits no seu ambiente

	Dicas para otimiza��o:

	1. Analise queries que causam waits excessivos e otimize os planos de execu��o.
	2. Ajuste paralelismo para reduzir waits como CXPACKET.
	3. Monitore I/O e considere melhorar o hardware ou configurar corretamente o armazenamento.
	4. Use �ndices adequados para evitar bloqueios e waits LCK_*.
*/