-- Verificando todas as triggers que existem no banco de dados
select * from sys.triggers where type = 'TR'

/* -- Criando trigger para fazer auditoria de usu�rios logados -- */
use master
go

-- Verificando primeiramente qual usu�rio est� logado
select 
	SUSER_SNAME() username,
	APP_NAME() appname,
	HOST_NAME() hostname,
	@@SPID spid,
	GETDATE() datetimetoday,
	SESSION_USER sessionuser,
	ORIGINAL_LOGIN() originallogin

-- restringindo acesso do usu�rio 'sa'
create or alter trigger user_audit on all server
for logon
as
begin
	if(ORIGINAL_LOGIN() = 'sa' and HOST_NAME() <> 'BRNB-MATHEUS') --> qualquer server fora do meu hostname n�o consegue acessar
	-- if(ORIGINAL_LOGIN() = 'sa' and HOST_NAME() = 'BRNB-MATHEUS') -> n�o consigo acessar pela minha m�quina
	begin
		rollback
	end
end

-- Verificar quais sess�es est�o ativas
select	is_user_process, original_login_name, *
from	sys.dm_exec_sessions
where	is_user_process = 1
order	by login_time desc
go

-- 'matando' uma sess�o
kill 57

disable trigger user_audit on all server
drop trigger user_audit on all server