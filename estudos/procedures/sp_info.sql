/* -- Procedure para ser usada no SQL Server Management Studio -- */

create or alter procedure sp_info
as
begin
	begin try
		set nocount on

		SELECT	@@VERSION									AS 'Informations' -- Neste exemplo utilizo um `SELECT @@VERSION` para buscar informações do servidor.
				,SERVERPROPERTY('ProductLevel')				AS 'ProductLevel' -- O `SERVERPROPERTY` traz diversas informações do servidor, de forma organizada.
				,SERVERPROPERTY('MachineName')				AS 'Nome da Máquina' -- Você pode customizar os nomes de cada coluna utilizando o `AS`.
				,SERVERPROPERTY('Edition')					AS 'Edição do SQL Server'
				,SERVERPROPERTY('ProductVersion')			AS 'Versão do SQL Server'
				,SERVERPROPERTY('Collation')				AS 'Colação do Servidor'
				,SERVERPROPERTY('BuildClrVersion')			AS 'Versão CLR'
				,SERVERPROPERTY('BuildNumber')				AS 'Número da Compilação'
				,SERVERPROPERTY('ProcessID')				AS 'ID do Processo SQL Server'
				,SERVERPROPERTY('IsClustered')				AS 'Clusterizado'
				,SERVERPROPERTY('IsFullTextInstalled')		AS 'Instalado Full Text'
				,SERVERPROPERTY('IsIntegratedSecurityOnly') AS 'Apenas Segurança Integrada'
				,SERVERPROPERTY('IsHadrEnabled')			AS 'HADR Habilitado';

		EXEC sp_helpdb -- Por último, adicionei um sp_helpdb para me trazer as informações dos meus bancos de dados.

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