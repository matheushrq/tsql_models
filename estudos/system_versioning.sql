use basebackup
go

-- criando tabela temporal
create table departamentos(
	id_departamento		int primary key,
	nome_departamento	varchar(60),
	validFrom			datetime2 generated always as row start,
	validTo				datetime2 generated always as row end,
	period for system_time (validFrom, validTo)
)
with (system_versioning = on (history_table = dbo.departamentos_history))