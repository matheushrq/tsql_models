SELECT 	Getdate() data_hora -- retorna a data e hora atual do sistema

--FUNCAO DE DATA E HORA PARTES

--RETORNA O DIA/Mes/Ano
SELECT	Getdate() data_hora,
		Datename (day, Getdate()) DIA_N,
		datename (month, Getdate()) MES_N,
		datename (year, Getdate()) ANO_N

--RETORNA O DIA/Mes/Ano
SELECT 	Datepart (day, Getdate()) DIA_P,
		Datepart (month, Getdate()) MES_P,
		Datepart (year, Getdate()) ANO_P

--RETORNA O DIA/Mes/Ano
SELECT 	Day (Getdate()) DIA,
		Month (Getdate()) MES,
		year (Getdate()) ANO

--RETONAR DATA HORA COM 7 ARGUMENTOS
SELECT 	DATETIMEFROMPARTS (2017,11,30,3,45,59,1) HORA

--FUNCOES DATA E HORA DO SISTEMA
SELECT 	Sysdatetime () exSysdatetime
SELECT 	Sysdatetimeoffset () exSysdatetimeoffset
SELECT 	Sysutcdatetime () exSysutcdatetime
SELECT 	CURRENT_TIMESTAMP exCURRENT_TIMESTAMP
SELECT 	Getdate () exGetdate
SELECT 	Getutcdate () exGetutcdate

use basebackup
go

create	table #teste_data(
	data_teste smalldatetime
)

insert	into #teste_data (data_teste) values ('2025-02-28')
select	* from #teste_data

select	month(data_teste) from #teste_data

select	case
			when day(t.data_teste) = 28
			then dateadd(day, 1, t.data_teste) -- tem que mudar para 01/03/2025
		else 'erro'
		end
from	#teste_data t

/* ------------------------------------------------------------------------------------------------ */

declare @data_exp datetime = '20251231'

select	convert(smalldatetime, FORMAT(DATEADD(month, 7, @data_exp), 'yyyyMM' + '21')) -- altera a data para 21/07/2026
select	convert(smalldatetime, convert(varchar(8), dateadd(month, 1, @data_exp), 121) + '30') -- altera a data para 30/01/2026

select	convert(smalldatetime, FORMAT(DATEADD(month, 0, GETDATE()), 'yyyyMM' + '10')) -- não altera o mês e muda o dia para 10
select	convert(smalldatetime, convert(varchar(8), dateadd(month, 1, GETDATE()), 121) + '30') -- altera a data para 30/06/2026


declare @data smalldatetime = '20250629'

select	case
			when day(@data) = 30 and MONTH(@data) in (4,6,9,11)
			then DATEADD(DAY, 1, @data) -- aumenta 1 dia
			--then convert(datetime2, convert(varchar(8), dateadd(month, 0, @data), 121) + '1')
		else @data
		end



declare @x datetime = '20250305'

select	data_teste = case
						when day(@x) > 28 and month(@x) = 2
							then convert(datetime, format(dateadd(month, 0, @x), 'yyyyMM' + '28'))
						when day(@x) = 30 and month(@x) in (4,6,9,11)
							then convert(datetime, format(dateadd(month, 0, @x), 'yyyyMM' + '30'))
						else convert(datetime, format(dateadd(month, 1, @x), 'yyyyMM' + right('0' + convert(varchar(10), day(@x)), 2)))
						--convert(datetime, convert(varchar(10), dateadd(month, 1, @x) + day(@x)))
					 end

/* -- fixando uma data personalizada -- */
declare	@ano		int = 2025,
		@mes		int = 11,
		@dia		int = 18,
		@data_final	datetime = '20240507'

select	data_final		= cast(@data_final as smalldatetime),
		data_atualizada = case 
							  when day(@data_final) > 28 and month(@data_final) = 2
								 then convert(smalldatetime, format(dateadd(month, 0, @data_final), 'yyyyMM' + '28'))
							  when day(@data_final) > 30 and month(@data_final) in (4,6,9,11)
								 then convert(smalldatetime, format(dateadd(month, 0, @data_final), 'yyyyMM' + '30'))
							  else convert(smalldatetime, convert(varchar(10), @ano) + convert(varchar(10), @mes) + right('0' + convert(varchar(10), @dia), 2))
						  end