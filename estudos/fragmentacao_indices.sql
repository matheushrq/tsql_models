use master
go

SELECT
	 OBJECT_NAME(ips.OBJECT_ID) AS TableName,
	 i.name AS IndexName,
	 ips.avg_fragmentation_in_percent
FROM	sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
JOIN	sys.indexes i
ON		ips.object_id = i.object_id
AND		ips.index_id = i.index_id
WHERE	ips.avg_fragmentation_in_percent > 10
ORDER	BY ips.avg_fragmentation_in_percent DESC

/*
	Como resolver?
	1. Para fragmentação de 10%-30%: use REORGANIZE.
	2. Para fragmentação acima de 30%: use REBUILD.

	Exemplo:
	ALTER INDEX [IndiceExemplo] ON [TabelaExemplo] REBUILD
*/