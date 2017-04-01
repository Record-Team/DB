IF OBJECT_ID('dbo.FundToOpen', 'P') IS NULL
BEGIN
    EXEC('CREATE PROC dbo.FundToOpen AS BEGIN RETURN 0 END')
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
ALTER PROC dbo.FundToOpen
    @ID bigint
AS
BEGIN
    SET NOCOUNT ON

    DECLARE
        @TypeID_AccountFund bigint = dbo.TypeIDByName('AccountFund')

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.TObject o
            JOIN dbo.TAccount a ON a.ID = o.ID
        WHERE o.TypeID = @TypeID_AccountFund
            AND a.OwnerID = @ID
    )
    BEGIN
        EXEC dbo.Error
            @ProcID = @@PROCID
           ,@Message = 'Для открытия фонда ID=%s необходимо завести счет'
           ,@p1 = @ID
    END
END
