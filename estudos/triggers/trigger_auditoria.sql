/* -- TRIGGER --*/

if exists (select top 1 1 from sys.objects where object_id = OBJECT_ID(N'[dbo].[produto_auditoria]') and type in (N'U'))
begin
	drop table dbo.produto_auditoria
end
go

create table produto_auditoria
(
	id int identity primary key,
	productid int not null,
	englishproductname nvarchar(50) not null,
	spanishproductname nvarchar(50) not null,
	frenchproductname nvarchar(50) not null,
	finishedgoodsflag bit,
	color nvarchar(30) not null,
	listprice money not null,
	updatedat datetime not null,
	operation char(3) not null,
	check(operation = 'INS' or operation = 'DEL')
)

/*
	Função dessa trigger: se eu inserir ou deletar qualquer dado da tabela DimProduct, as alterações irão automaticamente
	para a tabela produto_auditoria, informando a alteração que foi realizada.
*/

create trigger dbo.trg_produto_auditoria
on dbo.DimProduct
after insert, delete
as
begin
	set nocount on
	insert into produto_auditoria(
		productid,
		englishproductname,
		spanishproductname,
		frenchproductname,
		finishedgoodsflag,
		color,
		listprice,
		updatedat,
		operation
	)
	select
		i.ProductKey,
		EnglishProductName,
		SpanishProductName,
		FrenchProductName,
		FinishedGoodsFlag,
		Color,
		ListPrice,
		getdate(),
		'INS'
	from
		inserted i
	union all
	select
		d.ProductKey,
		EnglishProductName,
		SpanishProductName,
		FrenchProductName,
		FinishedGoodsFlag,
		Color,
		ListPrice,
		getdate(),
		'DEL'
	from
		deleted d
end
go

-- Habilitando a trigger na tabela
alter table dbo.DimProduct enable trigger trg_produto_auditoria
go

-- TESTANDO A TRIGGER
insert into DimProduct(
	EnglishProductName,
	SpanishProductName,
	FrenchProductName,
	FinishedGoodsFlag,
	Color,
	ListPrice
)
values(
	'TupperWare Bottle',
	'Botella TupperWare',
	'Bouteille TupperWare',
	1,
	'Purple',
	27.15
)

-- Validando a tabela de auditoria
select	* from DimProduct where EnglishProductName like '%Tupper%'
select	* from produto_auditoria

-- Desabilitar ou habilitar uma trigger
disable trigger all on DimProduct
enable trigger all on DimProduct

-- Deletar uma trigger
drop trigger if exists trg_produto_auditoria
