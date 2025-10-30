/* -- Wildcards -- */

use ebook
go

-- Percentual (%): Retorna todos que come�am com 'A'
select * from tCADCliente where cNome like 'a%'

-- Underscore (_): Retorna tudo que come�a com 'A' e tem dois caracteres
select * from tCADCliente where cNome like 'a_'

-- Entre colchetes []: Retorna tudo que come�a entre 'A' e 'C'
select * from tCADCliente where cNome like '[a-c]%'

-- H�fen (-): Retorna tudo que come�a entre 'A' e 'F' (usando junto com colchetes para intervalos)
select * from tCADCliente where cNome like '[a-f]%'

-- Exemplos:
-- Localizar tudo que termina com 'dom'
select * from tCADCliente where cNome like '%dom'

-- Localizar tudo que a segunda letra � 'A'
select * from tCADCliente where cNome like '_a%'

-- Localizar tudo que come�a com 'A' ou 'D'
select * from tCADCliente where cNome like '[AD]%'

/* 
	Localizar tudo que N�O come�a com 'A'
	Use o ^ para exce��o, ou seja, diferente do especificado
*/
select * from tCADCliente where cNome like '[^a]%'