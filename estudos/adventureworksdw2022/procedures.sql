use	AdventureWorksDW2022

/* -- Stored Procedures -- */

create procedure dbo.p_pfa_financeamount
(
	@minamount decimal,
	@maxamount decimal
)
as
begin
	select	ff.OrganizationKey, ff.AccountKey, convert(date, [Date]) dia, ff.Amount from FactFinance ff
	join	DimDepartmentGroup ddg
	on		ddg.DepartmentGroupKey = ff.DepartmentGroupKey
	where	ff.DepartmentGroupKey is not null
	and		ff.Amount >= @minamount
	and		(@maxamount is null or ff.Amount <= @maxamount)
end

exec p_pfa_financeamount 0, 366.1

sp_helptext 'p_pfa_financeamount'

/* -- Declarando variáveis -- */
declare @yeardate smallint = 1970

select	distinct dc.CustomerKey, dc.FirstName, dc.LastName, year(dc.BirthDate) BirthYear, dc.Gender, dg.City, dg.StateProvinceName from DimCustomer dc
join	DimGeography dg
on		dg.GeographyKey = dc.GeographyKey
where	year(dc.BirthDate) = @yeardate
order	by dc.FirstName asc

/* -- Armazenando consultas em variável -- */

set nocount on -- não mostra a quantidade de linhas alteradas/executadas
declare @departmentgroup int
set @departmentgroup = (select top 1 ddg.DepartmentGroupKey from DimDepartmentGroup ddg where ddg.ParentDepartmentGroupKey is not null)

select @departmentgroup
print 'O código de grupo de departamento é: ' + cast(@departmentgroup as varchar(10))

/* -- Acumulando valores em variáveis -- */
declare
	@productname nvarchar(50),
	@listprice decimal(10,2),
	@todosprodutos varchar(max) -- 2GB de armazenamento

set @todosprodutos = ''

select	@todosprodutos = @todosprodutos + [EnglishProductName] + char(10)
from	DimProduct dp

select	@todosprodutos [Nome de todos os produtos]
print @todosprodutos
--join	DimProductSubcategory dpsc
--on		dpsc.ProductSubcategoryKey = dp.ProductSubcategoryKey
--join	DimProductCategory dpc
--on		dpc.ProductCategoryKey = dpsc.ProductCategoryKey

select	distinct top 100 EnglishProductName, ListPrice from DimProduct
where	ListPrice is not null

create procedure sp_produto_preco
(
	@precounitario	smallint,
	@produto_qt		int output -- output: variável de saída
)
as
begin
	select
			EnglishProductName,
			ListPrice
	from	DimProduct
	where	ListPrice = @precounitario

	select	@produto_qt = @@ROWCOUNT -- rowcount é uma variável que conta a quantidade de linhas afetadas pelo select
end

-- chamando a procedure
declare @count int

exec sp_produto_preco @precounitario = 18, @produto_qt = @count output
select @count as 'Produtos Encontrados'

/* -- ELSE IF -- */
declare @vendas int

select	distinct
		dp.EnglishProductName,
		dp.ListPrice
from	DimProduct dp
join	DimProductSubcategory dpsc
on		dpsc.ProductSubcategoryKey = dp.ProductSubcategoryKey
join	DimProductCategory dpc
on		dpc.ProductCategoryKey = dpsc.ProductCategoryKey
where	dp.ListPrice is not null
and		year(dp.StartDate) = 2012

/* -- WHILE -- */
declare @qt int = 1
while @qt <= 5
begin
	print @qt
	set @qt = @qt + 1
end

/* -- BREAK -- */
declare @qt int = 0
while @qt <= 5
begin
	set @qt = @qt + 1
	if @qt > 5
		break
	print @qt
end

create or alter procedure query_top_x(
	@tabela nvarchar(128),
	@topx int,
	@bycolumn nvarchar(128)
)
as
begin
	declare
		@sql nvarchar(max),
		@topxstr nvarchar(max)

	set @topxstr = CONVERT(nvarchar(max), @topx)
	set @sql = N'select top ' + @topxstr +
				' * from ' + @tabela +
				' order by ' + @bycolumn + ' desc'
	
	exec sp_executesql @sql
end

exec query_top_x 'DimCustomer', 100, 'FirstName'

/* -- EVITAR SQL INJECTION (manipulação do banco de dados por meio de ataque hacker) -- */

-- SQL Injection

create table vendasteste (id int)

create or alter procedure sp_vendas (
	@tabela nchar(250)
)
as
begin
	declare @sql nchar(250)
	set @sql = 'select * from ' + @tabela
	exec sp_executesql @sql
end

-- chamando a proc
exec sp_vendas 'dimDate'

-- chamando a proc e alterando
exec sp_vendas 'dimDate;drop table vendasteste'

-- evitando SQL Injection usando QUOTENAME

create or alter procedure sp_leitura_tabelas(
	@schema nvarchar(128),
	@tabela nvarchar(128)
)
as
begin
	declare @sql nvarchar(128)
	set @sql = N'select * from '
				+ quotename(@schema) -- quotename: adiciona delimitadores a uma cadeia de entrada para tornar essa cadeia um identificador delimitado válido do SQL Server.
				+ '.'
				+ QUOTENAME(@tabela)
	exec sp_executesql @sql
end

--exec sp_leitura_tabelas 'dbo', 'DimReseller'

/* -- TRY CATCH -- */
create or alter procedure sp_divide(
	@a decimal,
	@b decimal,
	@c decimal output
)
as
begin
	begin try
		set @c = @a/@b
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
go

-- chamando a proc
declare @r decimal
exec sp_divide 10, 2, @r output
print @r

declare @r decimal
exec sp_divide 10, 0, @r output
print @r