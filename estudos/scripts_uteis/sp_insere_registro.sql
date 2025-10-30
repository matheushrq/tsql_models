create or alter procedure sp_insere_registro(
    @NomeTabela     nvarchar(128),
    @Colunas        nvarchar(max),
    @Valores        nvarchar(max) -- valores separados por vírgula
)
as
begin
    begin try
        set nocount on
        
        declare @SQL            nvarchar(max);
        declare @ParamList      nvarchar(max);
        set @ParamList = @Valores;
        set @SQL = N'insert into ' + quotename(@NomeTabela) +
                   N' (' + @Colunas + ') values (' + @ParamList + ')';
        exec sp_executesql @SQL;

        if @@error = 0
        begin
            -- apresenta o registro inserido na tabela
            declare @SelectSQL nvarchar(max);
            set @SelectSQL = N'SELECT * FROM ' + quotename(@NomeTabela) + ' where 1 = 0;'; -- substitua por condição adequada para retornar o registro inserido
            exec(@SelectSQL);
        end
    end try
    begin catch
        select
            error_number()      ErrorNumber,
            error_severity()    ErrorSeverity,
            error_state()       ErrorState,
            error_procedure()   ErrorProcedure,
            error_line()        ErrorLine,
            error_message()     ErrorMessage;
    end catch
end