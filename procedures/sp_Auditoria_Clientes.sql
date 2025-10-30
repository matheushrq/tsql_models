CREATE OR ALTER PROCEDURE sp_auditoria_clientes
    @NomeTabela     NVARCHAR(100),
    @Operacao       NVARCHAR(10),
    @Usuario        NVARCHAR(100),
    @DadosAntigos   NVARCHAR(MAX)   = NULL,
    @DadosNovos     NVARCHAR(MAX)   = NULL,
    @cd_retorno     INT             = null OUTPUT,
    @nm_retorno     NVARCHAR(4000)  = null OUTPUT
AS
BEGIN
    begin try
        set nocount on

        INSERT INTO log_auditoria (NomeTabela, Operacao, DataOperacao, Usuario, DadosAntigos, DadosNovos)
        VALUES (@NomeTabela, @Operacao, GETDATE(), @Usuario, @DadosAntigos, @DadosNovos);

        if @@ERROR <> 0
        begin
            select  @cd_retorno = 1,
                    @nm_retorno = 'Erro ao inserir log de auditoria.'
        end

        ELSE
        begin
            select  * from log_auditoria where Id = SCOPE_IDENTITY()
        end
    end try
    begin catch
        -- Tratar erros aqui, se necessário
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure, ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
    end catch
END