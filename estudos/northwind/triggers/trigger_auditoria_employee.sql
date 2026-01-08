use northwind
go

if not exists (
	select	top 1 1
	from	sys.objects
	where	type = 'TR'
	and		name = 'trg_insert_employee'
)
BEGIN
	create table dbo.employee_auditoria
	(
		id int identity primary key,
		employeeid int not null,
		lastname nvarchar(40),
		firstname nvarchar(20),
		title nvarchar(60),
		titleofcourtesy nvarchar(50),
		birthdate date,
		updatedat date not null,
		operation char(3) not null,
		check(operation = 'INS' or operation = 'DEL')
	)
END

create or alter trigger dbo.trg_insert_employee
on dbo.employees
after insert, delete
as begin
	set nocount on
	insert into dbo.employee_auditoria(
		employeeid,
		lastname,
		firstname,
		title,
		titleofcourtesy,
		birthdate,
		updatedat,
		operation
	)
	select
		i.EmployeeID,
		LastName,
		FirstName,
		Title,
		TitleOfCourtesy,
		BirthDate,
		getdate(),
		'INS'
	from inserted i
	union all
	select
		d.EmployeeID,
		LastName,
		FirstName,
		Title,
		TitleOfCourtesy,
		BirthDate,
		getdate(),
		'DEL'
	from deleted d
end
go

alter table dbo.employees enable trigger trg_insert_employee
