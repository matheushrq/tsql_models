if OBJECT_ID('tempdb..#tmp_end_date_null', 'U') is not null
begin
	drop table #tmp_end_date_null
end

select	distinct
		ProductKey,
		EnglishProductName,
		EnglishDescription,
		StandardCost,
		ListPrice,
		Size,
		StartDate,
		EndDate
		into #tmp_end_date_null
from	DimProduct
where	EndDate is null
and		EnglishDescription is not null

-- antes: temporária
select	*
from	#tmp_end_date_null

update	tmp
set		EndDate = dateadd(year, 1, dp.StartDate)
from	#tmp_end_date_null tmp
join	DimProduct dp
on		dp.ProductKey = tmp.ProductKey

-- depois: temporária
select	*
from	#tmp_end_date_null

begin tran

-- alterando na tabela física
update	dp
set		EndDate = tmp.EndDate
from	DimProduct dp
join	#tmp_end_date_null tmp
on		dp.ProductKey = tmp.ProductKey
where	dp.EndDate <> tmp.EndDate

-- alterado
select	tmp.*,
		dp.EndDate
from	#tmp_end_date_null tmp
join	DimProduct dp
on		dp.ProductKey = tmp.ProductKey

-- rollback