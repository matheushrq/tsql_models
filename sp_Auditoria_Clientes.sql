CREATE PROCEDURE sp_auditoria_clientes
    @Operacao NVARCHAR(10),
    @Usuario NVARCHAR(100),
    @DadosAntigos NVARCHAR(MAX) = NULL,
    @DadosNovos NVARCHAR(MAX) = NULL
AS
BEGIN
    INSERT INTO log_auditoria (NomeTabela, Operacao, DataOperacao, Usuario, DadosAntigos, DadosNovos)
    VALUES ('Clientes', @Operacao, GETDATE(), @Usuario, @DadosAntigos, @DadosNovos)
END