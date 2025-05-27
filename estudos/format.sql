/* -- FORMAT -- */

-- Usando com dados de tempo
declare @data_teste datetime = '20250630'

select	format(@data_teste, 'd', 'en-US') -- 'd': traz a data no formato americano
select	format(@data_teste, 'D', 'en-US') -- 'D': traz a data no formato americano por extenso
select	format(@data_teste, 'd', 'pt-BR') -- 'd': traz a data no formato brasileiro
select	format(@data_teste, 'D', 'pt-BR') -- 'D': traz a data no formato brasileiro por extenso

SELECT	FORMAT(CAST('07:35' AS TIME), N'hh\.mm'); --> returns 07.35
SELECT	FORMAT(CAST('07:35' AS TIME), N'hh\:mm'); --> returns 07:35

/*
select	convert(datetime, FORMAT(DATEADD(month, 7, @data_exp), 'yyyyMM' + '21')) -- altera a data para 21/07/2026
select	convert(datetime, convert(varchar(8), dateadd(month, 1, @data_exp), 121) + '30') -- altera a data para 30/01/2026

select	convert(datetime, FORMAT(DATEADD(month, 0, GETDATE()), 'yyyyMM' + '10')) -- não altera o mês e muda o dia para 10
select	convert(datetime, convert(varchar(8), dateadd(month, 1, GETDATE()), 121) + '30') -- altera a data para 30/06/2026
*/

declare @data_exp	datetime = '20251231',
		@d			int = 15

--select	convert(datetime, format(@data_exp, 'yyyyMM' + RIGHT(convert(varchar(8), day(getdate()), 103), 2)))
--select	convert(datetime, format(@data_exp, 'yyyyMM' + RIGHT('0' + convert(varchar(10), @d), 2)))


select	case 
			when day(@data_exp) > 28 and MONTH(@data_exp) = 2
				then convert(datetime, format(dateadd(month, 0, @data_exp), 'yyyyMM' + '28'))
			when day(@data_exp) > 30 and MONTH(@data_exp) in (4,6,9,11)
				then convert(datetime, format(dateadd(month, 0, @data_exp), 'yyyyMM' + '30'))
			else convert(datetime, FORMAT(dateadd(month, 1, @data_exp), 'yyyyMM' + right('0' + convert(varchar(10), day(@data_exp)), 2)))
		end