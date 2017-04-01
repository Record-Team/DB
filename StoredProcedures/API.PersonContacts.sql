IF OBJECT_ID('API.PersonContacts', 'P') IS NULL
BEGIN
    EXEC('CREATE PROC API.PersonContacts AS BEGIN RETURN 0 END')
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
-- Список контактов персоны
ALTER PROC API.PersonContacts
    @PersonID bigint
AS
BEGIN
    SET NOCOUNT ON

    SELECT
        p.ID as PersonID
       ,p.Name as PersonName
    FROM dbo.TObject o
        JOIN dbo.TPerson p ON p.ID = o.ID
    ORDER BY PersonName
END
--EXEC API.PersonContacts @PersonID = NULL
