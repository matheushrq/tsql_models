-- Cláusula OUTPUT

use basebackup
go

if exists (select top 1 1 from sys.objects where name = 'produto_backup')
begin
	drop table dbo.produto_backup
end
create table produto_backup(
	id_produto		int identity(1,1) primary key,
	descricao		varchar(max) not null,
	categoria		varchar(300) not null,
	valor_unitario	decimal(19,2),
	ativo			bit not null default(1)
)

if exists (select top 1 1 from sys.objects where name = 'produto_log')
begin
	drop table dbo.produto_log
end

create table produto_log(
	id_produto_log		int identity(1,1) primary key,
	data_alteracao		datetime not null,
	login_alteracao		sysname,
	host_alteracao		sysname,
	operacao			varchar(50) not null,
	id_produto			int not null,
	valor_unitario		decimal(19,2) null,
	valor_unitario_old	decimal(19,2) null,
	ativo				bit null,
	ativo_old			bit null
) with (data_compression = page)

-- insert
insert	produto_backup(
		descricao,
		categoria,
		valor_unitario
)
output	getdate(), SUSER_SNAME(), HOST_NAME(), 'insert', inserted.id_produto, inserted.valor_unitario, null, inserted.ativo, null
into	produto_log
values	('Disco SSD 1 TB', 'Informática', 269.99)

insert	produto_backup(
		descricao,
		categoria,
		valor_unitario
)
output	getdate(), SUSER_SNAME(), HOST_NAME(), 'insert', inserted.id_produto, inserted.valor_unitario, null, inserted.ativo, null
into	produto_log
values	('Interface de som', 'Som e áudio', 309.99)

insert	produto_backup(
		descricao,
		categoria,
		valor_unitario
)
output	getdate(), SUSER_SNAME(), HOST_NAME(), 'insert', inserted.id_produto, inserted.valor_unitario, null, inserted.ativo, null
into	produto_log
values	('Caderno 200 folhas', 'Papelaria', 32.99)

select	* from produto_backup
select	* from produto_log

-- update
update	produto_backup
set		ativo = 0
output	getdate(), SUSER_SNAME(), HOST_NAME(), 'update', inserted.id_produto, inserted.valor_unitario, deleted.valor_unitario, inserted.ativo, deleted.ativo
into	produto_log
where	id_produto = 2

select	* from produto_backup
select	* from produto_log

-- delete
delete	produto_backup
output	getdate(), SUSER_SNAME(), HOST_NAME(), 'update', deleted.id_produto, null, deleted.valor_unitario, null, deleted.ativo
into	produto_log
where	id_produto = 3

select	* from produto_backup
select	* from produto_log