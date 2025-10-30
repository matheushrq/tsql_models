/* 
	RTRIM e LTRIM
	
	Pra que serve? Remoção de espaços em branco à direita (RTRIM) e à esquerda (LTRIM)
	- RTRIM: right
	- LTRIM: left
*/

declare @str varchar(max) = '          teste'

-- exibindo o teste normalmente, sem formatação
select	@str

-- Removendo os espaços à esquerda
select	LTRIM(@str)

-- Removendo os espaços à direita
select	LTRIM(@str)

-- Removendo os espaços de ambos os lados
select	LTRIM(RTRIM(@str))