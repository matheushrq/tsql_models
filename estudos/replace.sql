declare 
	@str varchar(max) = 'Esse é um teste com replace'

select	@str
select	replace(@str, 'replace', 'replace no sql server')