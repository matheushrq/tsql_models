use basebackup
go

declare @contador int
set	@contador = 1

set nocount on
while @contador <= 60000
	begin
		insert into registros (registro) values ('registro 200')
		set	@contador = @contador + 1
	end

sp_help 'registros' -- comando alt + F1

select	* from registros where id = 21357

create table dbo.teste_indice(
	id int identity primary key,
	nome varchar(100)
)

--declare @contador int
--set	@contador = 1

--set nocount on
--while @contador <= 60000
--	begin
--		insert into teste_indice (nome) values ('Matheus')
--		set	@contador = @contador + 1
--	end

select	* from teste_indice where id = 43729