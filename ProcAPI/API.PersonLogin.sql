IF OBJECT_ID('API.PersonLogin', 'P') IS NOT NULL
BEGIN
    DROP PROC API.PersonLogin
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
CREATE PROC API.PersonLogin
    @Identifier nvarchar(4000)
   ,@PersonID bigint = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON

    DECLARE
        @TypeID_PersonLogin bigint = dbo.TypeIDByName('PersonLogin')

    SELECT TOP (1)
        @PersonID = i.PersonID
    FROM dbo.TObject o
        JOIN dbo.TPersonIdentifier i ON i.ID = o.ID
        JOIN dbo.TPerson p ON p.ID = i.PersonID
    WHERE o.TypeID = @TypeID_PersonLogin
        AND i.Identifier = @Identifier

    IF @PersonID IS NULL
    BEGIN
        EXEC dbo.Error
            @ProcID = @@PROCID
           ,@Message = 'Не найден пользователь с логином %s'
           ,@p1 = @Identifier
    END
END
--EXEC API.PersonLogin
