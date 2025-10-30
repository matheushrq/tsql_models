if not exists (select * from sys.objects where object_id = object_id(N'log_auditoria') and type in (N'U'))
begin
    CREATE TABLE log_auditoria (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    NomeTabela NVARCHAR(100),
    Operacao NVARCHAR(10),
    DataOperacao DATETIME,
    Usuario NVARCHAR(100),
    DadosAntigos NVARCHAR(MAX),
    DadosNovos NVARCHAR(MAX)
);
end