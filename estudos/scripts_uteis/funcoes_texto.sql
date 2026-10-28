use AdventureWorks2025
go

/* -- FUNÇÕES DE TEXTO -- */

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

use StackOverflow2010
select	upper(left(name, 1)) + lower(SUBSTRING(name, 2, len(name))) name,
		count(*) qtd
from	Badges
where	right(name, 1) = '8'
group	by name
order	by name

-- LOWER - Converte todos os caracteres para minúsculo
select	lower(JobTitle) letras_minusculas,	-- minusculo
		JobTitle							-- normal
from	AdventureWorks2022.HumanResources.Employee

-- UPPER - Converte todos os caracteres para maiúsculo
select	UPPER(JobTitle) letras_maiusculas,	-- maiúsculo
		JobTitle							-- normal
from	AdventureWorks2022.HumanResources.Employee