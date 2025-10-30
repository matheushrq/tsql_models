/* -- Wildcards -- */

use ebook
go

-- Percentual (%): Retorna todos que começam com 'A'
select * from tCADCliente where cNome like 'a%'

-- Underscore (_): Retorna tudo que começa com 'A' e tem dois caracteres
select * from tCADCliente where cNome like 'a_'

-- Entre colchetes []: Retorna tudo que começa entre 'A' e 'C'
select * from tCADCliente where cNome like '[a-c]%'

-- Hífen (-): Retorna tudo que começa entre 'A' e 'F' (usando junto com colchetes para intervalos)
select * from tCADCliente where cNome like '[a-f]%'

-- Exemplos:
-- Localizar tudo que termina com 'dom'
select * from tCADCliente where cNome like '%dom'

-- Localizar tudo que a segunda letra é 'A'
select * from tCADCliente where cNome like '_a%'

-- Localizar tudo que começa com 'A' ou 'D'
select * from tCADCliente where cNome like '[AD]%'

/* 
	Localizar tudo que NÃO começa com 'A'
	Use o ^ para exceção, ou seja, diferente do especificado
*/
select * from tCADCliente where cNome like '[^a]%'