/*==============================================================*/
/* VIEWS                                                        */
/* Advantages of views                                          */
/*==============================================================*/

/*
Segurança
Você pode restringir o acesso dos usuários diretamente a uma tabela e permitir que acessem um subconjunto de dados por meio de VIEWS
Por exemplo, você pode permitir que os usuários acessem o nome do cliente, telefone, e-mail por meio de uma visualização,
mas restringi-los para acessar a conta bancária e outras informações confidenciais.

Simplicidade
Um banco de dados relacional pode ter muitas tabelas com relacionamentos complexos, por exemplo, um para um e um para muitos que tornam difícil a navegação.
No entanto, você pode simplificar as consultas complexas com associações e condições usando um conjunto de VIEWS

Consistência
Às vezes, você precisa escrever uma fórmula ou lógica complexa em cada consulta.
Para torná-lo consistente, você pode ocultar a lógica de consultas complexas e cálculos nas VIEWS
*/

SELECT
    *
FROM
customer

-- CRIANDO A VIEW

CREATE VIEW vw_custumerMadrid
AS
SELECT
    *
FROM
customer where city ='Madrid'

-- chamar a view
select * from vw_custumerMadrid

-- chamar a view com where
select   *
FROM vw_custumerMadrid
where phone like '%555%'


-- inserindo dados na tabela atraves da view
insert into vw_custumerMadrid (firstname, lastname, city, country, phone)
values ('sandro', 'servino de madrid', 'Madrid', 'espanha', '9999999')

insert into vw_custumerMadrid (firstname, lastname, city, country, phone)
values ('sandro', 'servino do porto', 'porto', 'portugal', '9999999')

select * from vw_custumerMadrid

SELECT * FROM customer where lastname = 'servino do porto'


-- Deletando dados em tabela atraves da VIEW

delete  from vw_custumerMadrid where lastname = 'servino de madrid'

SELECT * FROM vw_custumerMadrid where lastname = 'servino de madrid'
SELECT * FROM customer where lastname = 'servino de madrid'

BEGIN TRAN
delete from vw_custumerMadrid
where phone like '%555%'


-- View com Join

CREATE VIEW dailysales
AS
SELECT
    year(orderdate) AS y,
    month(orderdate) AS m,
    day(orderdate) AS d,
    p.id,
    productname,
    quantity * i.unitprice AS sales
FROM
    [Order] AS o
INNER JOIN orderitem AS i
    ON o.id = i.orderid
INNER JOIN product AS p
    ON p.id = i.productid;

-- Depois apenas rode

SELECT *  FROM dailysales ORDER BY y, m, d, sales desc;

select y as ano, m as mes, sum(sales) as VendasMes
	from dailysales
	group by y, m
	order by ano asc, mes asc

select y as ano, avg(sales) as VendasmediaANO
	from dailysales
	group by y
	order by ano asc


-- PARA ALTERAR A VIEW ACRESCENTANDO DADOS DO CLIENTE

CREATE OR ALTER VIEW dailysales
AS
SELECT
    year(orderdate) AS y,
    month(orderdate) AS m,
    day(orderdate) AS d,
    p.id,
    productname,
    quantity * i.unitprice AS sales,
    c.FIRSTNAME, 
    c.LASTNAME
FROM
    [Order] AS o
INNER JOIN customer as c
    ON c.id = o.customerid 
INNER JOIN orderitem AS i
    ON o.id = i.orderid
INNER JOIN product AS p
    ON p.id = i.productid;

SELECT *  FROM dailysales ORDER BY y, m, d, sales desc;

SELECT top 5 FirstName + ' ' + LastName , sum(d.sales) FROM dailysales d
group by d.FirstName, d.LastName

-- Deletar dados atraves de view que acessam varias tabelas
delete from dailysales
truncate table dailysales

-- ABRIR VIEWS dailysales POR MEIO GRAFICO

-- PARA DELETAR VIEW

DROP VIEW dailysales


