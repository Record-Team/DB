IF OBJECT_ID('API.PersonRegistration', 'P') IS NOT NULL
BEGIN
    DROP PROC API.PersonRegistration
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
CREATE PROC API.PersonRegistration
    @PersonID bigint = NULL OUTPUT
   ,@Identifier nvarchar(4000)
   ,@FirstName nvarchar(4000) = NULL
   ,@MiddleName nvarchar(4000) = NULL
   ,@LastName nvarchar(4000) = NULL
AS
BEGIN
    SET NOCOUNT ON

    DECLARE
        @TypeID_PersonLogin bigint = dbo.TypeIDByName('PersonLogin')

    --IF LEN(LTRIM(RTRIM(@Identifier))) = 0
    --BEGIN
    --    EXEC 
    --END

    IF EXISTS
    (
        SELECT 1
        FROM dbo.TObject o
            JOIN dbo.TPersonIdentifier i ON i.ID = o.ID
        WHERE o.TypeID = @TypeID_PersonLogin
            AND i.[Identifier] = @Identifier
    )
    BEGIN
        EXEC dbo.Error
            @ProcID = @@PROCID
           ,@Message = 'Логин %s уже зарегистрирован!'
           ,@p1 = @Identifier
    END

    BEGIN TRAN

    EXEC dbo.PersonSet
        @ID = @PersonID OUTPUT
       --,@TypeID = 
       ,@TypeName = 'Person'
       ,@StateID = NULL
       ,@FirstName = @FirstName
       ,@MiddleName = @MiddleName
       ,@LastName = @LastName

    EXEC dbo.[PersonIdentifierSet]
        @ID = NULL
       ,@TypeName = 'PersonLogin'
       --,@StateID = 
       ,@PersonID = @PersonID
       ,@Identifier = @Identifier

    COMMIT
END
/*
DECLARE @PersonID bigint

EXEC API.PersonRegistration
    @PersonID = @PersonID OUT
   ,@Identifier = 'iivanov'
   ,@FirstName = 'Иван'
   ,@MiddleName = 'Иванович'
   ,@LastName = 'Иванов'

SELECT @PersonID as [@PersonID]
*/