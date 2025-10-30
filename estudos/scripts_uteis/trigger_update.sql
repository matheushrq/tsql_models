use aula
go

create table dbo.auditoria_trigger
(
	id int identity primary key,
	dt_alteracao date,
	status_alteracao varchar(30)
)

insert	into dbo.auditoria_trigger (dt_alteracao, status_alteracao) values (null, 'Pendente')
insert	into dbo.auditoria_trigger (dt_alteracao, status_alteracao) values (null, 'Pendente')
insert	into dbo.auditoria_trigger (dt_alteracao, status_alteracao) values (null, 'Pendente')

create or alter trigger dbo.validacao_alteracao on dbo.auditoria_trigger
after update
as
begin
	set nocount on
	update atr set atr.dt_alteracao = getdate()
	from dbo.auditoria_trigger atr
	join inserted i
	on i.id = atr.id
	and i.status_alteracao = 'Aprovado'
end
go

--alter table auditoria_trigger alter column dt_alteracao date
--go


/* -- Testando a trigger -- */
update	auditoria_trigger set status_alteracao = 'Aprovado'
where	id = 1

select	* from dbo.auditoria_trigger