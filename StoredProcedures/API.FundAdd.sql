IF OBJECT_ID('API.FundAdd', 'P') IS NULL
BEGIN
    EXEC('CREATE PROC API.FundAdd AS BEGIN RETURN 0 END')
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
-- Добавление фонда
ALTER PROC API.FundAdd
    @FundID bigint = NULL OUTPUT
   ,@FundTypeID bigint
   ,@FundCaption nvarchar(4000)
   ,@FundDescription nvarchar(max) = NULL
   ,@PersonID bigint
   ,@CurrencyID bigint = NULL
AS
BEGIN
    SET NOCOUNT ON

    SET @CurrencyID = ISNULL(@CurrencyID, dbo.DirectoryIDByName(NULL, 'Currency', 'RUB'))

    BEGIN TRAN

    EXEC dbo.FundSet
        @ID = @FundID OUTPUT
       ,@TypeID = @FundTypeID
       ,@StateID = NULL
       ,@FounderID = @PersonID
       ,@Caption = @FundCaption
       ,@Description = @FundDescription

    -- Добавляем счет фонду
    EXEC dbo.AccountSet
        @ID = NULL
       --,@TypeID
       ,@TypeName = 'AccountFund'
       --,@StateID
       ,@CurrencyID = @CurrencyID
       ,@OwnerID = @FundID

    EXEC dbo.ObjectTransitExec
        @ID = @FundID
       ,@TransitName = 'FundOpen'

    COMMIT
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
