use ebook
go

select	distinct top 500
		tcc.iIDCliente,
		tcc.cNome,
		tced.cLogradouro,
		tced.cBairro,
		tced.cCEP,
		tced.cComplemento,
		tclo.cRegiao,
		tclo.lCapital,
		tclo.nAliquotaICMS
from	tCADEndereco tced
join	tCADCliente tcc
on		tcc.iIDCliente = tced.iIDCliente
join	tCADLocalidade tclo
on		tclo.iIDLocalidade = tced.iIDLocalidade
order	by tcc.cNome asc

select	distinct
		tcl.cTitulo,
		tca.cNome,
		convert(date, tca.dNascimento) dNascimento,
		tcl.nAno,
		tcl.nEdicao
from	tCADAutor tca
join	tRELAutorLivro tral
on		tral.iIDAutor = tca.iIDAutor
join	tCADLivro tcl
on		tcl.iIDLivro = tral.iIDLivro

select
		count(tcl.cTitulo) qtd_livros,
		tmpi.nQuantidade qtd_vendidos
from	tMOVPagamento tmp
join	tMOVPedido tmpe
on		tmpe.iIDPedido = tmp.iIDPedido
join	tMOVPedidoItem tmpi
on		tmpi.iIDPedido = tmp.iIDPedido
join	tCADLivro tcl
on		tcl.iIDLivro = tmpi.IDLivro
where	tmpi.nQuantidade = 2
group	by tmpi.nQuantidade

/* -- Validando a integridade do banco -- */

use master
go
dbcc checkdb (ebook)

use eBook
go

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.sp_consulta_livro_ano'))
begin
	drop procedure dbo.sp_consulta_livro_ano
end

create or alter procedure sp_consulta_livro_ano(
	@nAnoInicio int,
	@nAnoFim int
)
as
begin
	begin try
		select	distinct
				tcl.cTitulo,
				tca.cNome,
				convert(date, tca.dNascimento) dNascimento,
				tcl.nAno,
				tcl.nEdicao
		from	tCADAutor tca
		join	tRELAutorLivro tral
		on		tral.iIDAutor = tca.iIDAutor
		join	tCADLivro tcl
		on		tcl.iIDLivro = tral.iIDLivro
		where	tcl.nAno between @nAnoInicio and @nAnoFim
		order	by tcl.nAno
	end try
	begin catch
		select
			error_number() ErrorNumber, -- número do erro
			error_severity() ErrorSeverity, -- severidade do erro
			error_state() ErrorState, --  estado do erro
			error_procedure() ErrorProcedure, -- procedure que apresentou o erro
			error_line() ErrorLine, -- linha do erro
			error_message() ErrorMessage -- mensagem de erro
	end catch
end

exec sp_consulta_livro_ano 1890, 1910

--sp_helptext 'stp_atualizacredito'

--use master
--go

--SELECT TOP 1 local_tcp_port 
--FROM sys.dm_exec_connections
--WHERE local_tcp_port IS NOT NULL

/* -- backup e restore do banco porque tive que formatar o notebook -- */
use master
go

backup database ebook
to disk = 'D:\SQLServer\ebook\backup\ebook_full.bak'
with compression, stats

backup database ebook
to disk = 'D:\SQLServer\ebook\backup\ebook_differential.dif'
with differential, stats

restore database ebook
from disk = 'D:\SQLServer\ebook\backup\ebook_full.bak'
with norecovery, replace, stats

restore database ebook
from disk = 'D:\SQLServer\ebook\backup\ebook_differential.dif'
with norecovery, replace, stats

restore database ebook with recovery

/* -- Wildcards -- */

-- Percentual (%): Retorna todos que começam com 'A'
select * from tCADCliente where cNome like 'a%'

-- Underscore (_): Retorna tudo que começa com 'A' e tem dois caracteres
select * from tCADCliente where cNome like 'a_'

-- Entre colchetes []: Retorna tudo que começa entre 'A' e 'C'
select * from tCADCliente where cNome like '[a-c]%'

-- Hífen (-): Retorna tudo que começa entre 'A' e 'F' (usando junto com colchetes para intervalos)
select * from tCADCliente where cNome like '[a-f]%'

-- Exemplos:
-- Localizar tudo que termina com 'dom'
select * from tCADCliente where cNome like '%dom'

-- Localizar tudo que a segunda letra é 'A'
select * from tCADCliente where cNome like '_a%'

-- Localizar tudo que começa com 'A' ou 'D'
select * from tCADCliente where cNome like '[AD]%'

/* 
	Localizar tudo que NÃO começa com 'A'
	Use o ^ para exceção, ou seja, diferente do especificado
*/
select * from tCADCliente where cNome like '[^a]%'

/* ----------------------------------------------------------------------------------- */

/*
-- teste de procedure com wildcards

if exists (select * from sys.objects where type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.sp_pesquisatabela_wildcards'))
begin
	drop procedure dbo.sp_pesquisatabela_wildcards
end

create or alter procedure dbo.sp_pesquisatabela_wildcards(
	@tabela		nvarchar(150),
	@campo		nvarchar(200),
	@pesquisa	nvarchar(200)
)
as
begin
	begin try
		declare @sql nvarchar(max)
		set @sql = N' select * from ' + @tabela +
					' where ' + @campo + ' like ' + @pesquisa + ''
	end try
	begin catch
		select
			error_number() ErrorNumber, -- número do erro
			error_severity() ErrorSeverity, -- severidade do erro
			error_state() ErrorState, --  estado do erro
			error_procedure() ErrorProcedure, -- procedure que apresentou o erro
			error_line() ErrorLine, -- linha do erro
			error_message() ErrorMessage -- mensagem de erro

	end catch
end

exec sp_pesquisatabela_wildcards 'tCadCliente', 'cNome', '%dom'
*/

select	mCredito, cNome from tCADCliente where iIDCliente = 151
exec stp_AtualizaCredito @iidCliente = 151, @mcredito = default

sp_helptext 'stp_AtualizaCredito'

/*	Utilizando OFFSET e FETCH para paginação
	- FETCH: 'ignora' os 100 primeiros registros da tabela
	- OFFSET: faz a contagem de da quantidade de registros informados, iniciando na primeira linha depois das linhas que foram 'ignoradas'
*/

use ebook
go

select	iIDCliente, cNome, mCredito 
from	tCADCliente
order	by iIDCliente
offset	100 rows
fetch	next 20 rows only

select	iIDCliente, cNome, mCredito 
from	tCADCliente
where	iIDCliente between 101 and 120
order	by iIDCliente

select	top 50 with ties iIDCliente, cNome, mCredito
from	tCADCliente
order	by iIDCliente
--offset	100 rows
--fetch	next 40 rows only

-- Like coringa 1: '[CS]ha%' busca valores onde se inicia com Cha ou Sha
select	* from tCADCliente
where	cNome like '[CS]ha%'

-- Like localiza valores que começam com "L" e possuem pelo menos 3 caracteres de comprimento

select	* from tCADCliente
where	cNome like 'L_%_%'

sp_consulta 'iidTipoEndereco'

select	* from tCADEndereco
where	iIDCliente = 1

select	* from tCADLocalidade

select	* from tCADCliente
where	cNome = 'Germane Delgado'

select	* from tTIPEndereco

-- cursores
declare	@iidcliente int,
		@cnome varchar(50),
		@mcredito smallmoney

declare c_cursor_teste cursor local for

	select	iIDCliente, cNome, mCredito 
	from	tCADCliente
	order	by iIDCliente

open	c_cursor_teste
fetch	next from c_cursor_teste into @iidcliente, @cnome, @mcredito