/* 
	RTRIM e LTRIM
	
	Pra que serve? Remo��o de espa�os em branco � direita (RTRIM) e � esquerda (LTRIM)
	- RTRIM: right
	- LTRIM: left
*/

declare @str varchar(max) = '          teste'

-- exibindo o teste normalmente, sem formata��o
select	@str

-- Removendo os espa�os � esquerda
select	LTRIM(@str)

-- Removendo os espa�os � direita
select	LTRIM(@str)

-- Removendo os espa�os de ambos os lados
select	LTRIM(RTRIM(@str))