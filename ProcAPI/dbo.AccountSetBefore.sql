IF OBJECT_ID('dbo.AccountSetBefore', 'P') IS NULL
BEGIN
    EXEC('CREATE PROC dbo.AccountSetBefore AS BEGIN RETURN 0 END')
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
ALTER PROC dbo.AccountSetBefore
    @ID bigint OUTPUT
   ,@TypeID bigint
   ,@CurrencyID bigint
   ,@OwnerID bigint
AS
BEGIN
    SET NOCOUNT ON

    SET @ID = IIF(@ID > 0, @ID, NULL)

    IF @ID IS NULL
    BEGIN
        -- Исключаем дублирование счетов
        SELECT TOP (1)
            @ID = a.ID
        FROM dbo.TAccount (NOLOCK) a
            JOIN dbo.TObject o ON o.ID = a.ID
        WHERE a.OwnerID = @OwnerID
            AND a.CurrencyID = @CurrencyID
            AND o.TypeID = @TypeID
    END
END
--EXEC dbo.AccountSetBefore
