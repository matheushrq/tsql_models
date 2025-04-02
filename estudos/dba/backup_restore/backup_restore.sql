/*==================================================================================
ATIVIDADES ROTINEIRAS BÁSICAS DO DBA
BACKUP AND RESTORE
==================================================================================*/

SELECT SERVERPROPERTY('productversion') VersaoSQL, 
       SERVERPROPERTY ('edition') Edicao,
	   SERVERPROPERTY('InstanceDefaultDataPath')LOCALIZACAO_DADOS,
	   SERVERPROPERTY('InstanceDefaultLogPath')LOCALIZACAO_LOGS,
	   SERVERPROPERTY('ServerName')SERVERNAME,
	   SERVERPROPERTY('InstanceName')INSTANCIA,
	   SERVERPROPERTY('IsHadrEnabled')HADR_Habilitado

-- Para verificar o recovery mode das bases de dados da instancia via SQL script
SELECT name, recovery_model,recovery_model_desc FROM sys.databases  
GO

-- Para alterar o recovery mode de uma base de dados via script sql 

USE master
GO
ALTER DATABASE CLIENTES SET RECOVERY SIMPLE ;  
GO
SELECT name, recovery_model,recovery_model_desc FROM sys.databases  
GO 

USE master
GO
ALTER DATABASE CLIENTES SET RECOVERY FULL;  
GO
SELECT name, recovery_model,recovery_model_desc FROM sys.databases  
GO 

-- 1. Alterar o Recovery Mode pelo SSMS de forma grafica e realizando backup e restore pelo SSMS


-- 2. Fazendo Backup via Script SQL

--BACKUP NORMAL
BACKUP DATABASE CLIENTES
TO DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_1_FULL.BAK'
WITH STATS -- Stats: mostra o percentual do backup sendo realizado

--DROP DATABASE (imagine situacao de um crash do banco ou DBA sem querer deletando o banco de dados)
USE MASTER
GO
DROP DATABASE CLIENTES

RESTORE DATABASE CLIENTES
FROM DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_1_FULL.BAK'
WITH STATS, NORECOVERY -- norecovery: usuários ainda não tem acesso

--COLOCAR ONLINE
RESTORE DATABASE CLIENTES WITH RECOVERY

-- FAZENDO UM NOVO BACKUP COM COMPRESS
BACKUP DATABASE CLIENTES
TO DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_3_FULL.BAK'
WITH COMPRESSION, STATS

-- CRIANDO NOVA TABELA NO BANCO DE DADOS CLIENTES
USE CLIENTES
GO
DROP TABLE IF EXISTS dbo.RECORD
GO
CREATE TABLE RECORD(
	Idrecord INT IDENTITY(1,1) PRIMARY KEY,
	load VARCHAR (50),	
)
GO

-- Inserindo dados na Tabela RECORD 1000 REGISTRO
INSERT INTO RECORD VALUES ('1 CARREGAMENTO')
GO 1000

--Verificando registros
SELECT COUNT(*) FROM RECORD

--  Criando Backup com Arquivos de Log
BACKUP LOG CLIENTES TO DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_BK-LOG1.TRN'

-- Inserindo mais registros
INSERT INTO RECORD VALUES ('2 CARREGAMENTO')
GO 1000

---- Criando Backup com Arquivos de Log
BACKUP LOG CLIENTES TO DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_BK-LOG2.TRN'

--Verificando
USE CLIENTES
SELECT COUNT(*),LOAD FROM RECORD
GROUP BY LOAD
ORDER BY LOAD

-- Deletando Banco de dados (imagina que houve um crash no disco ou sem querer deletou o banco de dados)
USE MASTER
GO
DROP DATABASE CLIENTES

-- RESTAURANDO BACKUP FULL DO BANCO DE DADOS CLIENTES E OS LOGS COM NORECOVERY
USE MASTER
GO
RESTORE DATABASE CLIENTES FROM DISK='D:\SQLServer\clientes\Backup\CLIENTES_1_FULL.BAK' 
WITH NORECOVERY, STATS

--Restauracao 1º LOTE DE LOG
USE MASTER
GO
RESTORE LOG CLIENTES FROM DISK='D:\SQLServer\clientes\Backup\CLIENTES_BK-LOG1.TRN' 
WITH NORECOVERY, STATS

--Restauracao 2º LOTE DE LOG
USE MASTER
GO
RESTORE LOG CLIENTES FROM DISK='D:\SQLServer\clientes\Backup\CLIENTES_BK-LOG2.TRN' 
WITH RECOVERY, STATS

-- Verificando
USE CLIENTES
SELECT COUNT(*), LOAD FROM RECORD
GROUP BY LOAD 

-- Recuperando bases de dados com Backup Diferential

--Realizando um novo Backup FULL
BACKUP DATABASE CLIENTES TO DISK= 'D:\SQLServer\clientes\Backup\CLIENTES_4_FULL.BAK' WITH STATS
GO 

-- Limpando os dados da tabela RECORD
USE CLIENTES
SELECT COUNT(*) FROM RECORD
GO
TRUNCATE TABLE RECORD
GO
SELECT COUNT(*) FROM RECORD
GO

-- Inserindo dados na Tabela RECORD 1000 REGISTRO
INSERT INTO RECORD VALUES ('1 CARREGAMENTO')
GO 2000

--Verificando registros
SELECT COUNT(*) FROM RECORD

--  Criando Backup com Arquivos DIFFERENTIAL (dia 1)
BACKUP DATABASE CLIENTES TO DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_BK-DFF1.DIF' WITH DIFFERENTIAL

-- Inserindo dados na Tabela RECORD 1000 REGISTRO
INSERT INTO RECORD VALUES ('2 CARREGAMENTO')
GO 2000

--  Criando novo Backup com Arquivos DIFFERENTIAL (dia 2)
BACKUP DATABASE CLIENTES TO DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_BK-DFF2.DIF' WITH DIFFERENTIAL

-- Inserindo dados na Tabela RECORD 1000 REGISTRO
INSERT INTO RECORD VALUES ('3 CARREGAMENTO')
GO 2000

--  Criando novo Backup com Arquivos DIFFERENTIAL (dia 3)
BACKUP DATABASE CLIENTES TO DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_BK-DFF3.DIF' WITH DIFFERENTIAL

-- Verificando
USE CLIENTES
SELECT COUNT(*),LOAD  FROM RECORD
GROUP BY LOAD
ORDER BY LOAD

-- DELETANDO REGISTROS, CUIDADO DBA QUANDO FOR DELETAR REGISTROS DE TABELAS SEM WHERE
USE CLIENTES
GO
DELETE FROM RECORD
GO

-- Criando uma nova tabela no banco CLIENTES
USE [CLIENTES]
GO
CREATE TABLE [dbo].[Customer5](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](40) NOT NULL,
	[LastName] [nvarchar](40) NOT NULL,
	[City] [nvarchar](40) NULL,
	[Country] [nvarchar](40) NULL,
	[Phone] [nvarchar](20) NULL,
 CONSTRAINT [PK_CUSTOMER5] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

--lendo o cabecalho dos backups
RESTORE HEADERONLY FROM DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_4_FULL.BAK'
RESTORE HEADERONLY FROM DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_BK-DFF1.DIF'
RESTORE HEADERONLY FROM DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_BK-DFF2.DIF'
RESTORE HEADERONLY FROM DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_BK-DFF3.DIF'

-- RESTAURANDO BACKUP FULL, APOS CRISE NA BASE DE DADOS.
-- OBS IMPORTANTISSIMA. ANTES DE RETORNAR BACKUP FULL, APOS UM DESASTRE NA BASE DE DADOS, 
-- FAÇA UM BACKUP DO LOG PARA TENTAR PEGAR AS ULTIMAS 
-- TRANSACOES REALIZADAS QUE ESTAO NO ARQUIVO DE LOG *.LDF. 
-- ALGUMAS VEZES PODE NAO CONSEGUIR REALIZAR O BACKUP DO LOG SE O LOCAL DISCO
-- ONDE ESTAVA O LDF, ESTIVER CORROMPIDO, MAS DEVE SEMPRE TENTAR ANTES PARA TENTAR RECUPERAR AS ULTIMAS TRANSACOES.

BACKUP LOG CLIENTES TO DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_BK-LOG_TAILLOG.TRN' -- Taillog: backup do "rabo do log"
WITH NO_TRUNCATE -- FUNDAMENTAL COLOCAR ESTA CLAUSULA: depois de ter feito o log, ele não tente limpar o log
GO

-- RESTAURANDO ULTIMO BACKUP FULL REALIZADO
USE MASTER
GO
RESTORE DATABASE CLIENTES FROM DISK='D:\SQLServer\clientes\Backup\teste\CLIENTES_4_FULL.BAK' 
WITH NORECOVERY, STATS
GO

-- RESTAURANDO 3º BACKUP DIFERENTIAL. Nao precisa retornar o DIF1 E DIF2 PORQUE O DIF3 TEM TUDO QUE TINHA NO 
-- DIF1 E DIF2
RESTORE DATABASE CLIENTES FROM DISK = 'D:\SQLServer\clientes\Backup\teste\CLIENTES_BK-DFF3.DIF' 
WITH NORECOVERY, REPLACE, STATS

-- RESTAURANDO TAILLOG
RESTORE LOG CLIENTES FROM DISK = 'D:\SQLServer\clientes\Backup\teste\CLIENTES_BK-LOG_TAILLOG.TRN'
WITH NORECOVERY, STATS

-- DISPONIBILIZANDO O DB
USE MASTER
GO
RESTORE DATABASE CLIENTES WITH RECOVERY

-- Verificando os dados
USE CLIENTES
SELECT COUNT(*), LOAD FROM RECORD
GROUP BY LOAD
ORDER BY LOAD

-- POR QUE A TABELA RECORD FICOU SEM DADOS...

-- FAZENDO BACKUP DE MULTIPLOS ARQUIVOS 
BACKUP DATABASE CLIENTES
TO 
DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_MULTIPLOFIL1_FULL.BAK',
DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_MULTIPLOFIL2_FULL.BAK',
DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_MULTIPLOFIL3_FULL.BAK',
DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_MULTIPLOFIL4_FULL.BAK'
WITH STATS

-- FAZENDO BACKUP DO LOG
BACKUP LOG CLIENTES TO DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_BK-MULTIPLO_LOG1.TRN'

USE master
GO
DROP DATABASE CLIENTES
GO
   
-- RESTORE MULTIPLOS ARQUIVOS
USE MASTER
GO
RESTORE DATABASE CLIENTES
FROM  
DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_MULTIPLOFIL1_FULL.BAK',
DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_MULTIPLOFIL2_FULL.BAK',
DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_MULTIPLOFIL3_FULL.BAK',
DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_MULTIPLOFIL4_FULL.BAK'
WITH STATS, REPLACE, NORECOVERY -- Replace: vai sobrescrever caso já exista o banco Clientes

-- COLOCANDO O BANCO DE DADOS NO AR
USE MASTER
RESTORE DATABASE CLIENTES WITH RECOVERY

-------------------------------------------//-------------------------------------------------------------------------

-- FAZENDO BACKUPS PROTEGIDOS COM CRIPTOGRAFIA  

-- Para fazer o backup criptografado precisa seguir 3 passos:
-- Criar a master key no banco de dados Master.
-- Criar o certificado também no banco de dados Master.
-- Executar o backup usando o Encryption.

-- NOTA IMPORTANTE: DEVE FAZER o backup do certificado para o caso de TER QUE FAZER O RESTORE 
-- do backup em outra instância SQL.

-- 1. Script para cria a Master key 
-- Podemos ter apenas uma master key por banco de dados master
-- Para verificar se já existe consulte a view master.sys.key_encrtyptions
USE Master; 
GO 
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'PA$$123'; 
GO

-- 2. Criar o certificado que devera ser levada para instancia que ira querer subir o backup
-- Para verificar se já existe consulte a view master.sys.certificates

-- Expiry_Date: Data de Expiração do certificado. Caso não seja especificado, o certificado terá 
-- validade de 1 ano após a data de início do certificado.
-- Se você criar o certificado e ele expirar você deverá criar um novo certificado, para não ter problema
-- ao fazer os restore das suas bases de dados.
Use Master
go
CREATE CERTIFICATE CERTBACKUPSQL
WITH
 SUBJECT = 'Certificado do backup base SQL SERVER',
 EXPIRY_DATE = '20241231';
GO

-- APOS CRIAR O CERTIFICADO, REALIZAR O Backup do certificado E GUARDAR LOCAL SEGURO.
-- Será usado para restaurar o backup em outra instância SQL
-- ou no caso de perder o certificado no servidor local.

BACKUP CERTIFICATE CERTBACKUPSQL
TO FILE = 'D:\SQLServer\clientes\Backup\CERTBACKUPSQL.cer' -- LOCAL ONDE SERA ARMAZENADO O CERTIFICADO
WITH PRIVATE KEY (
FILE = 'D:\SQLServer\clientes\Backup\CERTBACKUPSQL.key', -- LOCAL ONDE SERA ARMAZENADO A CHAVE PRIVADA DO CERTIFICADO
ENCRYPTION BY PASSWORD = 'PA$$123') -- Senha utilizada para criptografar a chave privada do certificado.

--3. Script que faz o backup criptografado
BACKUP DATABASE CLIENTES
TO DISK = N'D:\SQLServer\clientes\Backup\CLIENTES_CRIPTOGRAFADO.BAK' 
WITH COMPRESSION, 
STATS = 10,  -- Progresso do Backup (em percentual %);
FORMAT,  -- Formata a mídia de backup.
ENCRYPTION (ALGORITHM = AES_256, -- algoritmo de criptografia
SERVER CERTIFICATE = CERTBACKUPSQL)

-- Neste momento foi criado a Master Key e o certificado, e 
-- criamos o backup do certificado, da chave e do backup do banco de dados CLIENTES

-- E PARA FAZER O RESTORE PARA A MESMA INSTANCIA SQL QUE FOI FEITO O BACKUP? O RESTORE É SIMPLES
-- porque o certificado e a chave ja está na instancia SQL

USE [master]
GO
DROP DATABASE CLIENTES

USE [master]
GO
RESTORE DATABASE CLIENTES 
FROM DISK = N'D:\SQLServer\clientes\Backup\CLIENTES_CRIPTOGRAFADO.BAK' 
GO

-- E PARA FAZER O RESTORE PARA OUTRA INSTANCIA SQL? 
-- Irei simular deletando o certificado e a master key. O mesmo erro ocorrerá em uma instancia sem o certificado.

USE [master]
GO
DROP CERTIFICATE CERTBACKUPSQL -- Primeiro delete o certificado
GO
DROP MASTER KEY -- e depois delete a master key
GO

BACKUP LOG CLIENTES TO DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_BK-LOG_TAILLOG2.TRN'
WITH NO_TRUNCATE -- FUNDAMENTAL COLOCAR ESTA CLAUSULA 
GO
RESTORE DATABASE CLIENTES 
FROM DISK = N'D:\SQLServer\clientes\Backup\CLIENTES_CRIPTOGRAFADO.BAK' 
GO

-- Ao tentar realizar o restore do backup em outra instância sem utilizar o certificado, 
-- recebemos o seguinte erro:
-- Msg 33111, Level 16, State 3, Line 82
-- Cannot find server certificate with thumbprint '0x0F79FA70533930362B23388937B9A60B01722E44'.
-- Msg 3013, Level 16, State 1, Line 82
-- RESTORE DATABASE is terminating abnormally.

-- Por isso é fundamental salvar e manter seguro o certificado, 
-- a Master Key e sua senha. Sem estes arquivos o restore do backup mesmo que seja íntegro, 
-- não poderá ser feito, mesmo que seja na mesma instância sql que foi feito o backup.

-- Para realizar o restore de forma correta, devemos:

-- 1. Criar uma Master Key na NOVA instância SQL destino:
Use master
go
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'PA$$123' -- NAO PRECISA SER A MESMA SENHA DA MASTER KEY ANTERIOR
GO

-- 2. Após criar a Master Key devemos criar o certificado, a partir do certificado que fizemos o backup.
-- Criar o certificado no servidor de destino.
-- Script para recriar o certificado tendo como base o arquivo gerado no passo 2.
-- Atenção para as cláusulas FROM e DECRYPTION

use master
go
CREATE CERTIFICATE CERTBACKUPSQL
FROM FILE = N'D:\SQLServer\clientes\Backup\CERTBACKUPSQL.cer'
WITH PRIVATE KEY ( 
FILE = N'D:\SQLServer\clientes\Backup\CERTBACKUPSQL.key',
DECRYPTION BY PASSWORD = 'PA$$123')  -- ATENCAO PARA A CLAUSULA DECRYPTION E USAR A MESMA SENHA QUANDO CRIOU MASTER KEY

-- Para verificar as informações do certificado podemos utilizar a 
-- view “sys.certificates”. Segue abaixo o resultado:
SELECT * 
FROM sys.certificates
WHERE name = 'CERTBACKUPSQL'

-- Com o certificado importado, agora podemos fazer o restore da database sem problemas.
BACKUP LOG CLIENTES TO DISK = 'D:\SQLServer\clientes\Backup\CLIENTES_BK-LOG_TAILLOG2.TRN'
WITH NO_TRUNCATE -- FUNDAMENTAL COLOCAR ESTA CLAUSULA 
GO

USE [master]
RESTORE DATABASE CLIENTES 
FROM DISK = N'D:\SQLServer\clientes\Backup\CLIENTES_CRIPTOGRAFADO.BAK' 
GO
