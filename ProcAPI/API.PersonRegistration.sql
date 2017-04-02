IF OBJECT_ID('API.PersonRegistration', 'P') IS NULL
BEGIN
    EXEC('CREATE PROC API.PersonRegistration AS BEGIN RETURN 0 END')
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
ALTER PROC API.PersonRegistration
    @PersonID bigint = NULL OUTPUT
   ,@PersonName nvarchar(4000)
   ,@Identifier nvarchar(4000)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE
        @TypeID_PersonLogin bigint = dbo.TypeIDByName('PersonLogin')

    IF LEN(LTRIM(RTRIM(@Identifier))) = 0
    BEGIN
        EXEC dbo.Error
            @ProcID = @@PROCID
           ,@Message = 'Запрещено регистрироваться по пустому идентификатору!'
    END

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

    SET @PersonName = ISNULL(@PersonName, @Identifier) -- Если имя не указано, используем логин

    BEGIN TRAN

    EXEC dbo.PersonSet
        @ID = @PersonID OUTPUT
       --,@TypeID = 
       ,@TypeName = 'Person'
       ,@StateID = NULL
       ,@Name = @PersonName

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
   ,@PersonName = 'Иван'

SELECT @PersonID as [@PersonID]
*/