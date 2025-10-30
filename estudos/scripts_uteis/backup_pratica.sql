/* -- Prática com backup e restore -- */

-- criando base de dados, tabela e inserindo registros

create database basebackup
go

use basebackup
go

drop table if exists dbo.registros
create table dbo.registros(
	id int identity primary key,
	nome varchar(50)
)
go

insert into dbo.registros values ('teste 1')
--go 300

select count(*) from dbo.registros

-- alterando o recovery model
SELECT	name, recovery_model, recovery_model_desc
FROM	sys.databases
where	name = 'basebackup'
GO

alter database basebackup set recovery full
go

SELECT	name, recovery_model, recovery_model_desc
FROM	sys.databases
where	name = 'basebackup'
GO

-------------------------------------------------------------------------------------------------------------------------

/* -- Realizando o backup -- */

-- backup full
BACKUP DATABASE basebackup
TO DISK = 'D:\SQLServer\basebackup\backup\basebackup_1_FULL.BAK'
WITH STATS -- Stats: mostra o percentual do backup sendo realizado

--DROP DATABASE (imagine situacao de um crash do banco ou DBA sem querer deletando o banco de dados)
USE MASTER
GO
DROP DATABASE basebackup

-- restaurando a base
RESTORE DATABASE basebackup
FROM DISK = 'D:\SQLServer\basebackup\backup\basebackup_1_FULL.BAK'
WITH STATS, NORECOVERY -- norecovery: usu�rios ainda n�o tem acesso

--COLOCANDO O BANCO ONLINE
RESTORE DATABASE basebackup WITH RECOVERY

-- validando
use basebackup
go
select count(*) from dbo.registros

-- inserindo novos registros
insert into dbo.registros values ('teste 2')
--go 300

select count(*) from dbo.registros

-- backup differential
BACKUP DATABASE basebackup TO DISK = 'D:\SQLServer\basebackup\backup\basebackup_BK-DFF1.DIF' WITH DIFFERENTIAL

insert into dbo.registros values ('teste 3')
--go 300

select	nome, count(*) from dbo.registros
group	by nome

-- backup do log
backup log basebackup TO DISK = 'D:\SQLServer\basebackup\backup\basebackup_BK-LOG1.TRN'

-- deletando a base de dados
USE MASTER
GO
DROP DATABASE basebackup

/* 
	- Restaurando o banco em ordem dos backups 
	1� - Backup Full
	2� - Backup Differential
	3� - Backup Log
*/

-- restaurando backup full
USE MASTER
GO
RESTORE DATABASE basebackup FROM DISK = 'D:\SQLServer\basebackup\backup\basebackup_1_FULL.BAK' 
WITH NORECOVERY, STATS
GO

-- restaurando backup differential
RESTORE DATABASE basebackup FROM DISK = 'D:\SQLServer\basebackup\backup\basebackup_BK-DFF1.DIF' 
WITH NORECOVERY, REPLACE, STATS

-- restaurando backup log
RESTORE LOG basebackup FROM DISK = 'D:\SQLServer\basebackup\backup\basebackup_BK-LOG1.TRN'
WITH NORECOVERY, STATS

-- DISPONIBILIZANDO O DB
USE MASTER
GO
RESTORE DATABASE basebackup WITH RECOVERY

-- Verificando os dados
USE basebackup
SELECT COUNT(*), nome FROM registros
GROUP BY nome
ORDER BY nome