/*==================================================================================
ATIVIDADES ROTINEIRAS BÁSICAS DO DBA
CHECK INTEGRIDADE DAS BASES DE DADOS - DBCC CHECKDB

Como administradores de banco de dados (DBAs), todos nós sabemos o quão importante é 
executar o ‘Database Console Command (DBCC) CHECKDB’ regularmente para verificar a 
integridade física e lógica de objetos de banco de dados, relações de índice e outras
verificações estruturais. A falha de qualquer uma dessas verificações relatará erros
de consistência como parte do comando do console do banco de dados.

O melhor método para reparar erros no banco de dados, relatado por DBCC CHECKDB, é
executar o último backup válido conhecido, conforme recomendado pela Microsoft. 
No entanto, se o backup não estiver disponível (ou se o backup estiver danificado), 
você pode tentar acessar o banco de dados em modo single user e executar o 
comando DBCC CHECKDB COM OPCOES DE REPACAO.
==================================================================================*/

-- Rode este comando, preferencialmente, todo o dia fora do horário comercial, através 
-- de um job automatico, que sera ensinado para 
-- checar a integridade logica e fisica (disco) do banco de dados e se houver
-- alguma mensagem de erro, verificar a mensagem e se necessário buscar de forma imediata a
-- restauracao do ultimo backup full
-- diferencial e ultimo log (tail log).

USE MASTER
GO
DBCC CHECKDB (CLIENTES)

-- Se náo conseguir recuperar Backup ou náo existir backup, rodar estes passos nesta ordem
-- para tentar corrigir o banco de dados

-- 1. RECUPERACAO SEM PERDA DE DADOS

USE MASTER
GO
ALTER DATABASE CLIENTES SET SINGLE_USER
WITH ROLLBACK IMMEDIATE; 
go

-- REPAIR_REBUILD: A opção REPAIR_REBUILD ajuda a reparar o banco de dados sem qualquer perda de dados. 
-- Ele pode ser usado para reparar linhas ausentes em índices não clusterizados e para reconstruir um índice.

DBCC CHECKDB (N'CLIENTES', REPAIR_REBUILD) WITH ALL_ERRORMSGS, NO_INFOMSGS; 
GO

-- Rodar novamente o DBCC CHECKDB para verificar se os erros sumiram.
USE MASTER
GO
DBCC CHECKDB (CLIENTES)

-- Caso o problema continue e náo tenha como recuperar o backup a segunda opcao seria tentar o outro comando 
-- dbcc de reparacao, mas este comando pode levar a perda de dados. O ideal é tentar realizar um backup antes
-- da base de dados, ou criar uma nova base de dados e tentar exportar todos os objetos possiveis para esta nova 
-- base de dados. EXISTEM AINDA SOLUCOES DE TERCEIROS QUE PODEM SER COMPRADAS PARA TENTAR RECUPERAR O BANCO. 
-- PESQUISE NA INTERNT OU MESMO CONTRATAR EMPRESAS ESPECIALIZADAS PARA RECUPERAR DE DISCOS E ARQUIVOS.

-- Caso o problema tenha sido resolvido, faça backup full imediato e backup do log e libere o banco de dados para uso

USE MASTER
GO
ALTER DATABASE CLIENTES SET MULTI_USER
GO

--2. RECUPERACAO COM POSSIBILIDADE DE PERDA DE DADOS

USE MASTER
GO
ALTER DATABASE CLIENTES SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE;
go

DBCC CHECKDB (N'CLIENTES', REPAIR_ALLOW_DATA_LOSS) WITH ALL_ERRORMSGS, NO_INFOMSGS; 
GO

-- Rodar novamente o DBCC CHECKDB para verificar se os erros sumiram.
USE MASTER
GO
DBCC CHECKDB (CLIENTES)

-- Caso o problema tenha sido resolvido e as mensagens desapareceram liberar o banco para imediato
-- e realizar backup full e do log de forma imediata. Caso contrário buscar solucoes de terceiros
-- e empresas especializadas em recuperacoes de discos e arquivos. Existem varias no mercado.

-- Liberando o banco para uso
USE MASTER
GO
ALTER DATABASE CLIENTES SET MULTI_USER
GO

---------------------------------- // VAMOS SIMULAR UM BANCO CORROMPIDO?

USE MASTER
GO
DROP DATABASE IF EXISTS SUSPECTDB 
GO
CREATE DATABASE SUSPECTDB
GO

USE SUSPECTDB
GO

CREATE TABLE [dbo].[CLIENTETB](
	[id] [int] NULL,
	[nome] [varchar](100) NULL
) ON [PRIMARY]
GO

INSERT INTO CLIENTETB VALUES (1, 'Maria')
INSERT INTO CLIENTETB VALUES (2, 'Joao')
INSERT INTO CLIENTETB VALUES (3, 'RUI VELHO')


-- Abra uma transação, execute o update abaixo e não efetue o Commit, deixe a transação aberta.

USE SUSPECTDB
GO

BEGIN TRAN
UPDATE CLIENTETB SET NOME = 'RUI NOVO' WHERE ID = 3
CHECKPOINT


-- Abra o task manager dentro da vm e encerre o servico do SQL Server (SQL SERVER Windows NT - 64 BITS), com isso iremos simular um crash no servidor.

-- Edite o arquivo de LOG do banco de dados, alterando algum dado e salve
-- Inicie novamente o serviço do SQL SERVER e abra o SSMS
-- Verifique o STATUS DO BANCO DE DADOS SUSPECTDB

-- Rode o sequinte SQL e veja o resultado
USE MASTER
GO
SELECT DATABASEPROPERTYEX (N'SUSPECTDB', N'STATUS') AS N'Status'
GO

-- Agora vamos tentar recuperar com os passoa abaixo nesta ordem>
-- 1. SEM PERDA DE DADOS

USE MASTER
GO

ALTER DATABASE SUSPECTDB SET SINGLE_USER
go
DBCC CHECKDB (N'SUSPECTDB', REPAIR_REBUILD) WITH ALL_ERRORMSGS, NO_INFOMSGS; 
GO

-- Rodar novamente o DBCC CHECKDB para verificar se os erros sumiram.
USE MASTER
GO
DBCC CHECKDB (SUSPECTDB)

-- Liberando o banco para uso e devera fazer backup full e log de forma imediata
USE MASTER
GO
ALTER DATABASE SUSPECTDB SET MULTI_USER
GO

-- Cao a mensagem de erro continue tentar recuperar com a segunda opcao de recuperacao
-- do banco de dados, mas lembrando que esta opcao podera perder dados.

-- 2. PODENDO TER PERDA DE DADOS
USE MASTER
GO
ALTER DATABASE SUSPECTDB SET EMERGENCY
go
ALTER DATABASE SUSPECTDB SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE;
go

DBCC CHECKDB (N'SUSPECTDB', REPAIR_ALLOW_DATA_LOSS) WITH ALL_ERRORMSGS, NO_INFOMSGS; 
GO 2

-- Rodar novamente o DBCC CHECKDB para verificar se os erros sumiram.
USE MASTER
GO
DBCC CHECKDB (SUSPECTDB)

-- Liberando o banco para uso e devera fazer backup full e log de forma imediata
USE MASTER
GO
ALTER DATABASE SUSPECTDB SET MULTI_USER
WITH ROLLBACK IMMEDIATE -- caso o banco não volte para o multi_user, rodar com essa cláusula
GO

use SUSPECTDB
go

select	* from CLIENTETB -- testando a alteração feita
