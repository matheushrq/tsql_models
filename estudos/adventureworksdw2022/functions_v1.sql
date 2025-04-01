use AdventureWorksDW2022

/* -- Funções -- */
create or alter function FuncDesconto(
	@qt int,
	@precounitario dec(10,2),
	@desconto dec(4,2)
)
returns dec(10,2)
as
begin
	return @qt * @precounitario * (1 - @desconto)
end

-- testando a função
select	dbo.FuncDesconto(10,100,0.1) valorvenda

-- testando a função com instrução SQL
select
	dp.ProductKey,
	sum(dbo.funcDesconto(606, ListPrice, 0.1)) valorvendafinal
from	DimProduct dp
where	dp.ListPrice is not null
group	by ProductKey
order	by valorvendafinal desc

/* -- Variável Table -- */
declare @produto_tabela table
(
	productkey int not null,
	englishproductname varchar(max) not null,
	listprice dec(11,2) not null
)
insert into @produto_tabela
select
	ProductKey,
	EnglishProductName,
	ListPrice
from	DimProduct dp
where	[status] is not null
and		ListPrice is not null

select	* from @produto_tabela
go

create or alter function alimentaTabelaEmployee(
	@salariedflag bit
)
returns @assalariado table(
	employeekey int primary key,
	firstname nvarchar(100),
	lastname nvarchar(100)
)
as
begin
	insert into @assalariado (employeekey, firstname, lastname)
	select employeekey, firstname, lastname from DimEmployee where SalariedFlag = @salariedflag
	return
end
go

select	* from dbo.alimentaTabelaEmployee(0)