IF OBJECT_ID('API.FundAdd', 'P') IS NOT NULL
BEGIN
    DROP PROC API.FundAdd
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
-- Добавление фонда
CREATE PROC API.FundAdd
    @FundID bigint = NULL OUTPUT
   ,@FundTypeID bigint
   ,@FundCaption nvarchar(4000)
   ,@FundDescription nvarchar(max) = NULL
   ,@PersonID bigint
AS
BEGIN
    SET NOCOUNT ON

    EXEC dbo.FundSet
        @ID = @FundID OUTPUT
       ,@TypeID = @FundTypeID
       ,@StateID = NULL
       ,@FounderID = @PersonID
       ,@Caption = @FundCaption
       ,@Description = @FundDescription
END
/*
DECLARE @FundID bigint

EXEC API.FundAdd
    @FundID = @FundID OUT
   ,@FundTypeID = 561277
   ,@FundCaption = '@FundCaption'
   ,@FundDescription = '@FundDescription'
   ,@PersonID = 561360

SELECT @FundID as [@FundID]
*/
