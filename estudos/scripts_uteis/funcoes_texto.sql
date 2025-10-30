use AdventureWorks2022
go

/* -- FUN��ES DE TEXTO -- */

-- LEN
select	name,
		len(Name) tamanho
from	Production.Product

select	name,
		min(len(Name)) menor_tamanho
from	Production.Product
group	by Name

select	name,
		max(len(Name)) maior_tamanho
from	Production.Product
group	by Name

-- LEFT
select	name,
		LEFT(name, 9)
from	Production.Product

-- RIGHT
select	name,
		right(Name, 8)
from	Production.Product

-- LOWER - Converte todos os caracteres para min�sculo
select	lower(JobTitle) letras_minusculas,	-- minusculo
		JobTitle							-- normal
from	HumanResources.Employee

-- UPPER - Converte todos os caracteres para mai�sculo
select	UPPER(JobTitle) letras_maiusculas,	-- mai�sculo
		JobTitle							-- normal
from	HumanResources.Employee