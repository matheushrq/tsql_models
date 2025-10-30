use master
go

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.sp_realiza_backup'))
   begin
		drop procedure dbo.sp_realiza_backup
   end
GO

create or alter procedure dbo.sp_realiza_backup
(
	@db			varchar(200),
	@diretorio	varchar(500)
)
as
set nocount on
begin
	begin try

	-- altera o caminho do arquivo
	select @diretorio = @diretorio + @db + '_' + REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(20),GETDATE(),120),'-',''),':',''),' ','_') + '_backup.bak'

	-- executa o backup
		begin
			backup database @db
			to disk = @diretorio
			with compression, stats
		end
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