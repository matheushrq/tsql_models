/* estruturas de repetição */

-- while
declare @contador int = 0;

while @contador < 20
BEGIN
    select  ProductKey,
            EnglishProductName,
            Color,
            StandardCost
    FROM    DimProduct
    where   ProductKey = @contador;
    set     @contador = @contador + 1;
END