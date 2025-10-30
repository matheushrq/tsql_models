/* estruturas de repetição */

declare @cont int = 0

while @cont < 10
begin
    SELECT  ProductKey,
            EnglishProductName
    FROM    DimProduct
    WHERE   ProductKey = @cont

    SET @cont = @cont + 1
END