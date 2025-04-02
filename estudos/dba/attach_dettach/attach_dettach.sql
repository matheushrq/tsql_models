/*==================================================================================
ATIVIDADES ROTINEIRAS BÁSICAS DO DBA
ATTACH E DETTACH
==================================================================================*/

SELECT SERVERPROPERTY('productversion') VersaoSQL, 
       SERVERPROPERTY ('edition') Edicao,
	   SERVERPROPERTY('InstanceDefaultDataPath')LOCALIZACAO_DADOS,
	   SERVERPROPERTY('InstanceDefaultLogPath')LOCALIZACAO_LOGS,
	   SERVERPROPERTY('ServerName')SERVERNAME,
	   SERVERPROPERTY('InstanceName')INSTANCIA,
	   SERVERPROPERTY('IsHadrEnabled')HADR_Habilitado

USE [master]
GO

DROP DATABASE IF EXISTS [BASEHISTORICA]
GO

CREATE DATABASE [BASEHISTORICA]
 ON  PRIMARY 
( NAME = N'BASEHISTORICA', FILENAME = N'D:\Developer\Data\BASEHISTORICA.mdf' , SIZE = 10240KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'BASEHISTORICA_log', FILENAME = N'D:\Developer\Log\BASEHISTORICA_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )

GO

-- DETACH - DESANEXANDO
USE master;  
GO  
EXEC sp_detach_db @dbname = N'BASEHISTORICA';  
GO 

-- ATTACH - ANEXANDO
-- 1 COPIAR OS ARQUIVOS DA ANTIGA PASTA PARA A NOVA PASTA
-- sempre verificar se o usuário logado tem controle total sobre os arquivos MDF e LDF
-- se não, abrir propriedades do usuário e dar controle total para o usuário logado
CREATE DATABASE [BASEHISTORICA]   
    ON (FILENAME = 'D:\SQL_Developer\baseshistoricas\BASEHISTORICA.mdf'),
	   (FILENAME = 'D:\SQL_Developer\baseshistoricas\BASEHISTORICA_log.ldf')
    FOR ATTACH;  
GO
