--FUNCAO DE DATA E HORA PARTES

--RETORNA O DIA/Mes/Ano
SELECT Getdate() data_hora,
	   Datename (day, Getdate()) DIA_N,
	   datename (month, Getdate()) MES_N,
	   datename (year, Getdate()) ANO_N

--RETORNA O DIA/Mes/Ano
SELECT Datepart (day, Getdate()) DIA_P,
	   Datepart (month, Getdate()) MES_P,
	   Datepart (year, Getdate()) ANO_P

--RETORNA O DIA/Mes/Ano
SELECT Day (Getdate()) DIA,
	   Month (Getdate()) MES,
	   year (Getdate()) ANO

--RETONAR DATA HORA COM 7 ARGUMENTOS
SELECT DATETIMEFROMPARTS (2017,11,30,3,45,59,1) HORA

--FUNCOES DATA E HORA DO SISTEMA
SELECT Sysdatetime () exSysdatetime
SELECT Sysdatetimeoffset () exSysdatetimeoffset
SELECT Sysutcdatetime () exSysutcdatetime
SELECT CURRENT_TIMESTAMP exCURRENT_TIMESTAMP
SELECT Getdate () exGetdate
SELECT Getutcdate () exGetutcdate