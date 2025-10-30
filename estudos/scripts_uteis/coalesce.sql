use AdventureWorksDW2022
go

select	CustomerKey,
		primeiro_nome = FirstName,
		segundo_nome = coalesce(MiddleName, LastName),
		*
from	DimCustomer

select	CustomerKey,
		nome_completo = (firstName + ' ' + isnull(MiddleName, LastName) + ' . ' + Lastname),
		AddressLine1,
		coalesce(AddressLine2, AddressLine1, 'NA')
from	DimCustomer

select	*
from	DimCustomer
where	CustomerKey = 11002

/* ------------------------------------------------------------------------------------------- */

SET NOCOUNT ON;
GO

USE tempdb;

IF OBJECT_ID('dbo.wages') IS NOT NULL
    DROP TABLE wages;
GO

CREATE TABLE dbo.wages
(
    emp_id TINYINT IDENTITY,
    hourly_wage DECIMAL NULL,
    salary DECIMAL NULL,
    commission DECIMAL NULL,
    num_sales TINYINT NULL
);
GO

INSERT	dbo.wages (hourly_wage, salary, commission, num_sales)
VALUES	(10.00, NULL, NULL, NULL),
		(20.00, NULL, NULL, NULL),
		(30.00, NULL, NULL, NULL),
		(40.00, NULL, NULL, NULL),
		(NULL, 10000.00, NULL, NULL),
		(NULL, 20000.00, NULL, NULL),
		(NULL, 30000.00, NULL, NULL),
		(NULL, 40000.00, NULL, NULL),
		(NULL, NULL, 15000, 3),
		(NULL, NULL, 25000, 2),
		(NULL, NULL, 20000, 6),
		(NULL, NULL, 14000, 4);
GO

SET NOCOUNT OFF;
GO

SELECT CAST (COALESCE (hourly_wage * 40 * 52, salary, commission * num_sales) AS MONEY) AS 'Total Salary'
FROM dbo.wages
ORDER BY 'Total Salary';
GO