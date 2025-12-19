CREATE OR ALTER PROCEDURE sp_altera_dimemployee(
    @EmployeeKey        INT,
    @FirstName          NVARCHAR(50) = NULL,
    @LastName           NVARCHAR(50) = NULL,
    @MiddleName         NVARCHAR(50) = NULL,
    @Title              NVARCHAR(50) = NULL,
    @HireDate           DATE = NULL,
    @BirthDate          DATE = NULL,
    @EmailAddress       NVARCHAR(100) = NULL
)

/*
    Exemplo de teste
    exec sp_altera_dimemployee
        @EmployeeKey       = 1,
        @FirstName         = 'João',
        @LastName          = 'Silva',
        @BirthDate         = '1985-05-15',
        @HireDate          = '2010-06-01'
*/

AS
BEGIN
    begin try
        UPDATE DimEmployee
        SET
            FirstName    = COALESCE(@FirstName, FirstName),
            LastName     = COALESCE(@LastName, LastName),
            MiddleName   = COALESCE(@MiddleName, MiddleName),
            Title        = COALESCE(@Title, Title),
            HireDate     = COALESCE(@HireDate, HireDate),
            BirthDate    = COALESCE(@BirthDate, BirthDate),
            EmailAddress = COALESCE(@EmailAddress, EmailAddress)
        WHERE EmployeeKey = @EmployeeKey;
    end try
    begin catch
        DECLARE @ErrorMessage   NVARCHAR(4000),
                @ErrorSeverity  INT,
                @ErrorState     INT

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    end catch
END