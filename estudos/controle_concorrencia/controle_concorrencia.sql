use AdventureWorks2019
go

alter database AdventureWorks2019 set read_committed_snapshot on

alter database AdventureWorks2019 set read_committed_snapshot off

select top 1000 * from Person.Person
where MiddleName is null

begin tran
	update Person.Person set FirstName = 'Matheus' where BusinessEntityID = 3
	select * from Person.Person where BusinessEntityID = 3 -- Roberto

rollback

USE DB_Concorrencia
go

INSERT dbo.Funcionario VALUES (1,'Fernando','Gerente','B',5600.00)
INSERT dbo.Funcionario VALUES (2,'Ana Maria','Diretor','A',7500.00)
INSERT dbo.Funcionario VALUES (3,'Lucia','Gerente','B',5600.00)
INSERT dbo.Funcionario VALUES (4,'Pedro','Operacional','C',2600.00)
INSERT dbo.Funcionario VALUES (5,'Carlos','Diretor','A',7500.00)
INSERT dbo.Funcionario VALUES (6,'Carol','Operacional','C',2600.00)
INSERT dbo.Funcionario VALUES (7,'Luana','Operacional','C',2600.00)
INSERT dbo.Funcionario VALUES (8,'Lula','Diretor','A',7500.00)
INSERT dbo.Funcionario VALUES (9,'Erick','Operacional','C',2600.00)
INSERT dbo.Funcionario VALUES (10,'Joana','Operacional','C',2600.00)
go


/****************************************************************************************
 Hands On 1: READ_COMMITTED padrão  
  - Leitura bloqueia escrita.
*****************************************************************************************/
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
  UPDATE dbo.Funcionario SET Salario = 3000.00 WHERE PK = 10
  SELECT * FROM dbo.Funcionario WHERE PK = 10 -- Salario = 2600.00

  ROLLBACK

-- *** Conexão B ***
SELECT * FROM dbo.Funcionario WHERE PK = 10 -- Salario = 3000.00
