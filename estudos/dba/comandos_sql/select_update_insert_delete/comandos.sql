/*==================================================================================
Curso: SQL SERVER 2019
https://www.udemy.com/course/draft/3957796/?referralCode=FB10D369E786D9FE8A48

Instrutor: Sandro Servino
https://www.linkedin.com/in/sandroservino/?originalSubdomain=pt
https://filiado.wixsite.com/sandroservino
==================================================================================*/


-------------------------------
------ SELECTS
-------------------------------

SELECT FirstName, LastName, City
  FROM Customer
GO

SELECT *
  FROM Customer
GO

SELECT Id, FirstName, LastName, City, Country, Phone
  FROM Customer
 WHERE Country = 'Sweden'
GO

SELECT CompanyName, ContactName, City, Country
  FROM Supplier
 ORDER BY CompanyName
GO

SELECT CompanyName, ContactName, City, Country
  FROM Supplier
 ORDER BY CompanyName DESC
GO

SELECT FirstName, LastName, City, Country
  FROM Customer
 ORDER BY Country, City
GO

-- SELECT TOP
-- Problem: List the top 10 most expensive products ordered by price

SELECT TOP 10 Id, ProductName, UnitPrice, Package
  FROM Product
 ORDER BY UnitPrice DESC


-- SQL SELECT DISTINCT
--Problem: List all unique supplier countries in alphabetical order.

SELECT DISTINCT Country
  FROM Supplier
ORDER BY COUNTRY


-- SQL MAX and MIN
-- Problem: Find the cheapest product

SELECT MIN(UnitPrice)
  FROM Product

--Problem: Find the largest order placed in 2014

SELECT MAX(TotalAmount)
  FROM [Order]
 WHERE YEAR(OrderDate) = 2014


-- SQL SELECT COUNT, SUM, and AVG

SELECT COUNT(Id)
  FROM Customer

SELECT SUM(TotalAmount)
  FROM [Order]
 WHERE YEAR(OrderDate) = 2013

SELECT AVG(TotalAmount) as media
  FROM [Order]


-- SQL WHERE AND, OR, NOT Clause

SELECT Id, FirstName, LastName, City, Country
  FROM Customer
 WHERE FirstName = 'Thomas' AND LastName = 'Hardy'

SELECT Id, FirstName, LastName, City, Country
  FROM Customer
 WHERE Country = 'Spain' OR Country = 'France'

 SELECT Id, FirstName, LastName, City, Country
  FROM Customer
 WHERE NOT Country = 'USA'

 -- The SQL WHERE IN
-- Problem: List all suppliers from the USA, UK, OR Japan
SELECT Id, CompanyName, City, Country
  FROM Supplier
 WHERE Country IN ('USA', 'UK', 'Japan')

-- Problem: List all products that are not exactly $10, $20, $30, $40, or $50
SELECT Id, ProductName, UnitPrice
  FROM Product
 WHERE UnitPrice NOT IN (10,20,30,40,50)

-- Problem: List all orders that are  between $50 and $15000
SELECT Id, OrderDate, CustomerId, TotalAmount
  FROM [Order]
 WHERE  (TotalAmount >= 50 AND TotalAmount <= 15000)
 ORDER BY TotalAmount DESC

 -- Problem: List all orders that are not between $50 and $15000
SELECT Id, OrderDate, CustomerId, TotalAmount
  FROM [Order]
 WHERE NOT (TotalAmount >= 50 AND TotalAmount <= 15000)
 ORDER BY TotalAmount DESC

-- SQL WHERE BETWEEN
-- Problem: List all products between $10 and $20
SELECT Id, ProductName, UnitPrice
  FROM Product
 WHERE UnitPrice BETWEEN 10 AND 20
 ORDER BY UnitPrice

SELECT Id, ProductName, UnitPrice
  FROM Product
 WHERE UnitPrice NOT BETWEEN 5 AND 100
 ORDER BY UnitPrice

--Problem: Get the number of orders and amount sold between Jan 1, 2013 and Jan 31, 2013.
SELECT COUNT(Id), SUM(TotalAmount)
  FROM [Order]
 WHERE OrderDate BETWEEN '1/1/2013' AND '1/31/2013'

-- SQL WHERE LIKE
-- Problem: List all products with names that start with 'Ca'
SELECT Id, ProductName, UnitPrice, Package
  FROM Product
 WHERE ProductName LIKE 'Ca%'

-- Problem: List all products that start with 'Cha' or 'Chan' and have one more character.
SELECT Id, ProductName, UnitPrice, Package
  FROM Product
 WHERE ProductName LIKE 'Cha_' OR ProductName LIKE 'Chan_'

-- SQL WHERE IS NULL
-- Problem: List all suppliers that have no fax number
SELECT Id, CompanyName, Phone, Fax 
  FROM Supplier
 WHERE Fax IS NULL

-- Problem: List all suppliers that do have a fax number
SELECT Id, CompanyName, Phone, Fax 
  FROM Supplier
 WHERE Fax IS NOT NULL

-- SQL GROUP BY
--Problem: List the number of customers in each country.
SELECT  Country , COUNT(Id)
  FROM Customer
 GROUP BY Country

-- SQL Alias
-- Problem: List total customers in each country. Display results with easy to understand column headers.
SELECT COUNT(C.Id) AS TotalCustomers, C.Country AS Nation
  FROM Customer C
 GROUP BY C.Country

 -- Problem: List the number of customers in each country sorted high to low
SELECT COUNT(Id) as numberclients, Country 
  FROM Customer
 GROUP BY Country
 ORDER BY COUNT(Id) DESC


-- INNER JOIN	

SELECT OrderNumber, TotalAmount, FirstName, LastName, City, Country
  FROM [Order] JOIN Customer
    ON [Order].CustomerId = Customer.Id

SELECT O.OrderNumber, OrderDate AS Datetime, 
       P.ProductName, I.Quantity, I.UnitPrice 
  FROM [Order] O 
  JOIN OrderItem I ON O.Id = I.OrderId 
  JOIN Product P ON P.Id = I.ProductId
ORDER BY O.OrderNumber

SELECT O.OrderNumber, CONVERT(date,O.OrderDate) AS Date, 
       P.ProductName, I.Quantity, I.UnitPrice 
  FROM [Order] O 
  JOIN OrderItem I ON O.Id = I.OrderId 
  JOIN Product P ON P.Id = I.ProductId
ORDER BY O.OrderNumber

-- Problem: List the total amount ordered for each customer
SELECT SUM(O.TotalAmount) AS SUM, C.FirstName, C.LastName
  FROM [Order] O JOIN Customer C 
    ON O.CustomerId = C.Id
 GROUP BY C.FirstName, C.LastName
 ORDER BY SUM(O.TotalPrice) DESC --  corrigir o nome do campo totalprice paratotalamount

-- LEFT JOIN
-- Problem: List all customers and the total amount they spent irrespective whether they placed any orders or not.

SELECT c.FirstName, c.LastName, c.City, c.Country, o.OrderNumber, o.TotalAmount
  FROM Customer C LEFT JOIN [Order] O
    ON O.CustomerId = C.Id
 ORDER BY TotalAmount


-- RIGHT JOIN
-- Problem: List customers that have not placed orders

SELECT FirstName, LastName, City, Country,  TotalAmount
  FROM [Order] O RIGHT JOIN Customer C
    ON O.CustomerId = C.Id
WHERE TotalAmount IS NULL


-- SQL UNION
-- Problem: List all companies, including suppliers and customers.

SELECT 'Customer' As Type, 
       FirstName + ' ' + LastName AS ContactName, 
       City, Country, Phone
  FROM Customer
UNION
SELECT 'Supplier', 
       ContactName, City, Country, Phone
  FROM Supplier


-- SQL SUBQUERIE
-- Problem: List products with order quantities greater than 100.

SELECT ProductName
  FROM Product P
 WHERE Id IN (SELECT O.ProductId 
                FROM OrderItem O
               WHERE Quantity > 100)


-- Problem: List all customers with their total number of orders

SELECT FirstName, LastName, 
       OrderCount = (SELECT COUNT(O.Id) 
                       FROM [Order] O 
                      WHERE O.CustomerId = C.Id)
  FROM Customer C 


-- SQL HAVING 
-- Problem: List the number of customers in each country, except the USA, sorted high to low. Only include countries with 9 or more customers.
SELECT  Country , COUNT(Id) as qt
  FROM Customer
 WHERE Country <> 'USA'
 GROUP BY Country
HAVING COUNT(Id) >= 9
 ORDER BY COUNT(Id) DESC

-- Problem: List all customer with average orders between $1000 and $1200.
SELECT FirstName, LastName, AVG(TotalAmount) as media
  FROM [Order] O JOIN Customer C ON O.CustomerId = C.Id
 GROUP BY FirstName, LastName
HAVING AVG(TotalAmount) BETWEEN 1000 AND 1200


-- SQL EXISTS SUBQUERIE
-- Problem: Find suppliers with products over $100.

SELECT CompanyName
  FROM Supplier
 WHERE EXISTS
       (SELECT ProductName
          FROM Product
         WHERE Product.SupplierId = Supplier.Id 
           AND UnitPrice > 100)	

-- SQL SELECT INTO 
-- Problem: Copy all suppliers from the USA to a new SupplierUSA table.

SELECT * INTO SupplierUSA
  FROM Supplier
 WHERE Country = 'USA'

 select * from SupplierUSA
 drop table SupplierUSA


-------------------------------
------ UPDATES
-------------------------------

select * from Supplier where Id = 15
UPDATE Supplier
   SET City = 'Oslo', 
       Phone = '(0)1-953530', 
       Fax = '(0)1-953555'
 WHERE Id = 15
GO
select * from Supplier where Id = 15


UPDATE Supplier
   SET City = 'Sydney'
 WHERE Name = 'Pavlova, Ltd.'  -- campo nao reconhecido pelo sql server nesta tabela, pesquisar select * from Supplier
GO
select * from Product

begin tran
UPDATE Product
   SET IsDiscontinued = 0 -- campo eh bit, 0 ou 1
select * from Product

Rollback tran
select * from Product

begin tran
UPDATE Product 
   SET IsDiscontinued = 1, ProductName = 'TESTE'   -- campo eh bit, 0 ou 1
 WHERE UnitPrice = 97.00
 GO
select * from Product

Commit Tran
select * from Product

-------------------------------
------ DELETES
-------------------------------

select * from orderitem
begin tran
DELETE orderitem
select * from orderitem

rollback tran
select * from orderitem
GO

SELECT * INTO neworderitem
  FROM orderitem

TRUNCATE TABLE neworderitem


-------------------------------
------ INSERTS
-------------------------------

INSERT INTO Customer (FirstName, LastName, City, Country, Phone)
VALUES ('Craig', 'Smith', 'New York', 'USA', '1-01-993 2800')
GO

INSERT INTO Customer (FirstName, LastName)
VALUES ('Anita', 'Coats')
GO 5

INSERT INTO Customer (FirstName, LastName, City, Country, Phone)
SELECT LEFT(ContactName, 5), 
       SUBSTRING(ContactName, 11, 100), 
       City, Country, Phone
  FROM Supplier
 WHERE CompanyName = 'Bigfoot Breweries'
GO

