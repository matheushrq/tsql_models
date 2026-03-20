use ContosoRetailDW

-- soma de totalCost por ProductName

select	distinct
		sum(fs.TotalCost) soma_total,
		dp.ProductName
from	FactSales fs
join	DimProduct dp
on		dp.ProductKey = fs.ProductKey
group	by dp.ProductName
order	by soma_total desc

-- soma de totalCost por StoreName

select	distinct
		sum(fs.TotalCost) soma_total,
		ds.StoreName
from	factSales fs
join	DimStore ds
on		ds.StoreKey = fs.StoreKey
group	by ds.StoreName
order	by soma_total desc

-- soma de UnitPrice por ChannelName
select	distinct
		sum(fs.UnitPrice) soma_unitPrice,
		dc.ChannelName
from	FactSales fs
join	DimChannel dc
on		dc.ChannelKey = fs.channelKey
group	by dc.ChannelName
order	by soma_unitPrice desc

-- soma de SalesAmount por PromotionName
select	distinct
		sum(fs.SalesAmount) soma_SalesAMount,
		dpr.PromotionName
from	FactSales fs
join	DimPromotion dpr
on		dpr.PromotionKey = fs.PromotionKey
group	by dpr.PromotionName
order	by soma_SalesAMount desc

/* ------------------------------------------------------------------------------------ */

select	top 100
		dp.ProductName,
		dp.ClassName,
		dp.[Size],
		fs.DiscountAmount,
		fs.SalesAmount,
		fs.TotalCost,
		case
			when fs.TotalCost > 100000
				then 'Acima da meta'
			when fs.TotalCost < 100000 and fs.TotalCost > 50000
				then 'Dentro da meta'
			when fs.TotalCost < 50000
				then 'Abaixo da meta'
			else 'N/A'
		end Resultado
		--into #tmp_resultados
from	FactSales fs
join	DimProduct dp
on		dp.ProductKey = fs.ProductKey
where	dp.[Size] is not null
order	by fs.TotalCost desc

select	distinct
		dp.ProductName,
		fi.UnitCost,
		dp.[Size],
		dp.BrandName
from	FactInventory fi
join	DimProduct dp
on		dp.ProductKey = fi.ProductKey

/*
select	*
from	#tmp_resultados

select	*
from	#tmp_resultados
where	ClassName = 'Deluxe'
*/

-- sp_helptext 'dbo.p_factsalesquota'