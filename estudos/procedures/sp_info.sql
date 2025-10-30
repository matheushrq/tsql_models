/* -- Procedure para ser usada no SQL Server Management Studio -- */

create or alter procedure sp_info
as
begin
	begin try
		set nocount on

		SELECT	@@VERSION									AS 'Informations' -- Neste exemplo utilizo um `SELECT @@VERSION` para buscar informa��es do servidor.
				,SERVERPROPERTY('ProductLevel')				AS 'ProductLevel' -- O `SERVERPROPERTY` traz diversas informa��es do servidor, de forma organizada.
				,SERVERPROPERTY('MachineName')				AS 'Nome da M�quina' -- Voc� pode customizar os nomes de cada coluna utilizando o `AS`.
				,SERVERPROPERTY('Edition')					AS 'Edi��o do SQL Server'
				,SERVERPROPERTY('ProductVersion')			AS 'Vers�o do SQL Server'
				,SERVERPROPERTY('Collation')				AS 'Cola��o do Servidor'
				,SERVERPROPERTY('BuildClrVersion')			AS 'Vers�o CLR'
				,SERVERPROPERTY('BuildNumber')				AS 'N�mero da Compila��o'
				,SERVERPROPERTY('ProcessID')				AS 'ID do Processo SQL Server'
				,SERVERPROPERTY('IsClustered')				AS 'Clusterizado'
				,SERVERPROPERTY('IsFullTextInstalled')		AS 'Instalado Full Text'
				,SERVERPROPERTY('IsIntegratedSecurityOnly') AS 'Apenas Seguran�a Integrada'
				,SERVERPROPERTY('IsHadrEnabled')			AS 'HADR Habilitado';

		EXEC sp_helpdb -- Por �ltimo, adicionei um sp_helpdb para me trazer as informa��es dos meus bancos de dados.

	end try
	begin catch
		select
			error_number()		numero_erro,
			error_severity()	severidade_erro,
			error_state()		estado_erro,
			error_procedure()	erro_procedure,
			error_line()		linha_erro,
			error_message()		mensagem_erro
	end catch
end