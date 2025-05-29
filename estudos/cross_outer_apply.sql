use basebackup
go

DROP TABLE IF EXISTS #LeftTable;
CREATE TABLE #LeftTable(
    Id INT,
    Name NVARCHAR(10)
)

INSERT	INTO #LeftTable (Id, Name)
VALUES	(1, 'Red'), (2, 'Green'), (3, 'Blue'), (4, 'Yellow'), (5, 'Purple');


DROP TABLE IF EXISTS #RightTable;
CREATE TABLE #RightTable(
    Id INT,
    ReferenceId INT,
    Name NVARCHAR(10)
)

INSERT	INTO #RightTable (Id, ReferenceId, Name)
VALUES	(1, 1, 'Dog'), (2, 1, 'Cat'), (3, 2, 'Bird'), (4, 4, 'Horse'), (5, 3, 'Bear'), (6, 1, 'Deer');


-- CROSS APPLY
SELECT	L.Name,
		R.Name
FROM	#LeftTable L
CROSS	APPLY (SELECT	Name
			   FROM		#RightTable R
			   WHERE	R.ReferenceId = L.Id) R

-- INNER JOIN
SELECT	L.Name,
		R.Name
FROM	#LeftTable L
JOIN	#RightTable R
ON		R.ReferenceId = L.Id;

-- SQL OUTER APPLY
SELECT	L.Name,
		R.Name
FROM	#LeftTable L
OUTER	APPLY (SELECT Name 
			   FROM	#RightTable R 
			   WHERE R.ReferenceId = L.Id) R;

-- LEFT OUTER JOIN
SELECT	L.Name,
		R.Name
FROM	#LeftTable L
LEFT	OUTER JOIN #RightTable R
ON		R.ReferenceId = L.Id;

-- CROSS APPLY with a Table Expression
SELECT	*
FROM	#LeftTable L
CROSS	APPLY (SELECT	TOP 2
						R.Name
				FROM	#RightTable R
				WHERE	R.ReferenceId = L.Id
				ORDER	BY R.Id DESC) R


/* --------------------------------------------------------------------------- */

use northwind
go

-- cross apply
select	e.EmployeeID,
		e.FirstName,
		e.LastName,
		e.City,
		aux.OrderID
from	Employees e
cross	apply (select max(o.OrderID) orderID from orders o 
			   where o.EmployeeID = e.EmployeeID) aux

-- outer apply
select	od.OrderID,
		od.Quantity,
		od.UnitPrice,
		aux.OrderDate,
		aux.ShipRegion
from	[Order Details] od
outer	apply (select * from orders o
			   where o.OrderID = od.OrderID) aux