/* 
	Teste backup com compressão de dados: Backup com compressão diz respeito a basicamente realizar um backup
	do banco de dados onde iremos comprimir o arquivo do banco, o que é uma boa prática, o arquivo ficará menor,
	porém, exige mais do disco de dados onde irá ser alocado o arquivo do backup.
*/

use master
go

-- criando o banco
create database db_compressao
go

use db_compressao
go

-- verificando o recovery model do banco (lembrar de deixar sempre model full para realizarmos o backup full)
SELECT	name, recovery_model, recovery_model_desc FROM sys.databases
where	name = 'db_compressao'

use db_compressao
go
drop table if exists dbo.dados
create table dbo.dados(
	id_dados int identity(1,1) primary key,
	nome varchar(30)
)

insert into dados values ('tipo 1')
go 200

select	count(*) from dados

-- backup full com compressão (diminui o tamanho do backup, porém, consome mais do disco)
backup database db_compressao
to disk = ''
with compression, stats -- cláusula 'compression' irá comprimir o arquivo do backup

-- Observação importante: backup com compressão acontece somente numa versão Developer do SSMS, a versão Express não é possível realizar

insert into dados values ('tipo 2')
go 200

select	nome, count(*) total from dbo.dados
group	by nome

backup log db_compressao to disk = ''

use master
go
drop database db_compressao

-- restaurando o backup full
restore database db_compressao
from disk = ''
with norecovery, stats

-- restaurando o primeiro lote do log
restore log db_compressao
from disk = ''
with norecovery, stats

-- colocando o banco online
restore database db_compressao with recovery

-- testando
use db_compressao
go
select	* from dados
