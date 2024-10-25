-- Verificando todas as triggers que existem no banco de dados
select * from sys.triggers where type = 'TR'

/* -- Criando trigger para fazer auditoria de usuários logados -- */
use master
go

-- Verificando primeiramente qual usuário está logado
select 
	SUSER_SNAME() username,
	APP_NAME() appname,
	HOST_NAME() hostname,
	@@SPID spid,
	GETDATE() datetimetoday,
	SESSION_USER sessionuser,
	ORIGINAL_LOGIN() originallogin

-- restringindo acesso do usuário 'sa'
create or alter trigger user_audit on all server
for logon
as
begin
	if(ORIGINAL_LOGIN() = 'sa' and HOST_NAME() <> 'nome_maquina') --> qualquer server fora do meu hostname não consegue acessar
	-- if(ORIGINAL_LOGIN() = 'sa' and HOST_NAME() = 'nome_maquina') -> não consigo acessar pela minha máquina
	begin
		rollback
	end
end

-- Verificar quais sessões estão ativas
select	is_user_process, original_login_name, *
from	sys.dm_exec_sessions
where	is_user_process = 1
order	by login_time desc
go

disable trigger user_audit on all server
drop trigger user_audit on all server
