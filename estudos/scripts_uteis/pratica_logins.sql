/* -- Usuários e permissões -- */

use master
go

create login matheus
with password = N'sqlserverdeveloper',
default_database = [northwind],
CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF

-- associar user ao login criado: deve ser feito já no banco default definido
use northwind
go
create user matheus for login matheus
go

grant select, insert, update, delete
to matheus

grant execute, create view, create procedure, create function, alter
to matheus

-- dar permissão para conectar a outras bases de dados
use master
go
grant connect any database
to matheus

--execute as login = 'matheus'
--select SUSER_NAME(), USER_NAME()
--revert

--use AdventureWorksDW2022
--go

-- verificando as permissões dadas
use master
go
EXEC northwind.dbo.sp_helprotect @username = 'matheus'