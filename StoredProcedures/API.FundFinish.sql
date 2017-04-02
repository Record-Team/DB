IF OBJECT_ID('API.FundFinish', 'P') IS NULL
BEGIN
    EXEC('CREATE PROC API.FundFinish AS BEGIN RETURN 0 END')
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
ALTER PROC API.FundFinish
    @FundID bigint
   ,@PersonID bigint
AS
BEGIN
    SET NOCOUNT ON

    DECLARE
        @FundStateID bigint
       ,@FounderID bigint
       ,@StateID_Opened bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeFund', NULL, 'State', 'Opened')

    SELECT
        @FundStateID = o.StateID
       ,@FounderID = f.FounderID
    FROM dbo.TFund f
        JOIN dbo.TObject (NOLOCK) o ON o.ID = f.ID
    WHERE f.ID = @FundID

    IF @FounderID <> @PersonID
    BEGIN
        EXEC dbo.Error
            @ProcID = @@PROCID
           ,@Message = 'Фонд ID=%s может закрыть только учредитель ID=%s'
           ,@p1 = @FundID
           ,@p2 = @FounderID
    END
    
    IF @FundStateID <> @StateID_Opened
    BEGIN
        EXEC dbo.Error
            @ProcID = @@PROCID
           ,@Message = 'Фонд ID=%s находится в неподходящем состоянии для закрытия'
           ,@p1 = @FundID
    END

    EXEC dbo.ObjectStateGo
        @ID = @FundID
       ,@StateName = 'Finished'
END
--EXEC API.FundFinish
