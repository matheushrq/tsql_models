use ebook
go

insert into tMOVPedido (iIDPedido, iIDCliente, iIDLoja, iIDEndereco, iIDStatus, dPedido, dValidade, dEntrega, dCancelado, nNumero, mDesconto)
values (1664976, 12, 81, 49552, 1, getdate(), '20250212', '20250215', null, 15473, 15.00)

insert into tMOVPedido (iIDPedido, iIDCliente, iIDLoja, iIDEndereco, iIDStatus, dPedido, dValidade, dEntrega, dCancelado, nNumero, mDesconto)
values (1664977, 12, 81, 49552, 99, getdate(), '20250212', '20250215', getdate(), 15473, 15.00)

insert into tMOVPedido (iIDPedido, iIDCliente, iIDLoja, iIDEndereco, iIDStatus, dPedido, dValidade, dEntrega, dCancelado, nNumero, mDesconto)
values (1664978, 12, 81, 49552, 99, getdate(), '20250211', '20250220', null, 15473, 15.00)

begin tran
update	tMOVPedido
set		iIDStatus = 1
where	iIDPedido = 1664978

select	* from tMOVPedido
where	iIDPedido = 1664978

commit

select	* from tCADCliente
select	* from tTIPStatus
select	* from tCADLoja

select	* from tCADEndereco
where	iIDCliente = 12