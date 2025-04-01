create or alter procedure dbo.sp_consulta(
	@str varchar(50)
)
as
begin
	begin try
		set nocount on

		-- tabelas
		print '-------------------'
		select name as tabelas from sysobjects where type = 'U' and name like '%' + @str + '%' order by name
		print ' '

		-- procedures
		print '-------------------'
		select name as nome_procedure from sysobjects where type = 'P' and name like '%' + @str + '%' order by name
		print ' '

		-- views
		print '-------------------'
		select name as nome_views from sysobjects where type = 'P' and name like '%' + @str + '%' order by name
		print ' '

		-- conteúdo de views
		print '-------------------'
		select	distinct o.name as conteudo_views
		from	sysobjects o
		join	syscomments c
		on		c.id = o.id
		where	o.type = 'V'
		and		c.text like '%' + @str + '%'
		order	by o.name
		print ' '

		-- conteúdo de procedures
		print '-------------------'
		select	distinct o.name as conteudo_procedures
		from	sysobjects o
		join	syscomments c
		on		c.id = o.id
		where	o.type = 'P'
		and		c.text like '%' + @str + '%'
		order	by o.name
		print ' '

		-- conteúdo de functions
		print '-------------------'
		select	distinct o.name as conteudo_views
		from	sysobjects o
		join	syscomments c
		on		c.id = o.id
		where	o.type = 'FN'
		and		c.text like '%' + @str + '%'
		order	by o.name
		print ' '

		-- triggers
		print '-------------------'
		select name as triggers from sysobjects where type = 'TR' and name like '%' + @str + '%' order by name
		print ' '

		-- campos
		print '-------------------'
		select	convert(varchar(30), c.name) as campo, t.name as tabela
		from	sysobjects t
		join	syscolumns c
		on		t.id = c.id
		where	t.type = 'U'
		and		c.name like '%' + @str + '%'
		order	by t.name
		print ' '
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