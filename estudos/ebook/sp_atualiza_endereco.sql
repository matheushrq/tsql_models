use ebook
go

create or alter procedure sp_atualiza_endereco(
	@nome_cliente		varchar(50),
	@iidTipoEndereco	int,
	@cLogradouro		varchar(50),
	@nNumero			int,
	@cComplemento		varchar(20),
	@cBairro			varchar(20),
	@cCEP				char(9),
	@dCadastro			datetime,
	@dExclusao			datetime,
	@cd_retorno			int				= null output,
	@nm_retorno			varchar(300)	= null output
)

as
begin
	begin try
		
		declare 
			@iidCliente			int,
			@iidLocalidade		int

		set	@iidCliente			= (select	top 1 tcc.iidCliente
								  from		tCADCliente tcc
								  join		tCADEndereco tce
								  on		tce.iIDCliente = tcc.iIDCliente
								  where		tcc.cNome = @nome_cliente)

		set	@iidLocalidade		= (select	top 1 tcl.iidLocalidade
								  from		tCADLocalidade tcl
								  join		tCADEndereco tce
								  on		tce.iIDLocalidade = tcl.iIDLocalidade
								  join		tCADCliente tcc
								  on		tcc.iIDCliente = tce.iIDCliente
								  where		tcc.cNome = @nome_cliente)

		update	tCADEndereco
		set		iIDCliente		= @iidCliente,
				iIDLocalidade	= @iidLocalidade,
				iIDTipoEndereco	= @iidTipoEndereco,
				cLogradouro		= @cLogradouro,
				nNumero			= @nNumero,
				cComplemento	= @cComplemento,
				cBairro			= @cBairro,
				cCEP			= @cCEP,
				dCadastro		= getdate(),
				dExclusao		= null
	end try
	begin catch
		select	@cd_retorno		= 1,
				@nm_retorno		=	'Procedure: '		+ isnull(object_name(@@PROCID), '') + ' '
								  + 'Erro na proc: '	+ isnull(convert(varchar(100), error_procedure()), '') + ' '
								  + 'Mensagem:'			+ isnull(convert(varchar(300), error_message()), '')
								  + case when isnull(error_line(), 0) <> 0 then 'Linha: - ' + convert(varchar(100), error_line()) else '' end
		return
	end catch
end