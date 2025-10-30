IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.p_consulta_tabela'))
   begin
		drop procedure dbo.p_consulta_tabela
   end
GO

create or alter procedure [dbo].[p_consulta_tabela]
(
	@tabela nvarchar(128),
	@quantidade int,
	@coluna nvarchar(300)
)
as
set nocount on
begin
	begin try
		declare
			@sql nvarchar(max),
			@qtdx nvarchar(max)

		set @qtdx = CONVERT(nvarchar(max), @quantidade)
		set @sql = N'select top ' + @qtdx +
					' * from ' + @tabela +
					' order by ' + @coluna + ' desc'

		exec sp_executesql @sql
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
