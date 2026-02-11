/* -- Identificando local dos arquivos de data e log dos bancos de dados -- */

SELECT 
	db.name AS DatabaseName,
	mf.name AS LogicalName,
	mf.type_desc AS FileType,
	mf.physical_name
FROM	sys.databases db
JOIN	sys.master_files mf 
ON		db.database_id = mf.database_id
ORDER	BY db.name