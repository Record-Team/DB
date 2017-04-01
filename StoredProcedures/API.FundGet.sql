IF OBJECT_ID('API.FundGet', 'P') IS NULL
BEGIN
    EXEC('CREATE PROC API.FundGet AS BEGIN RETURN 0 END')
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
ALTER PROC API.FundGet
    @FundID bigint
   ,@PersonID bigint
AS
BEGIN
    SET NOCOUNT ON

    DECLARE
        @TypeID_AccountFund bigint = dbo.TypeIDByName('AccountFund');

    SELECT
        f.ID as FundID
       ,f.FounderID
       ,otl.Title as FounderTitle
       ,f.Caption as FundCaption
       ,f.[Description] as FundDescription
       ,CAST(atrin.Amount as nvarchar(10)) + ' ' + cd.Name as FundAmount
       ,CAST(NULLIF(ISNULL(atrin.Amount, 0) - ISNULL(atrout.Amount, 0), 0) as nvarchar(10)) + ' ' + cd.Name as FundBalance
    FROM dbo.TFund f
        OUTER APPLY dbo.ObjectTitleList(f.FounderID) otl
        LEFT JOIN dbo.TAccount a
            JOIN dbo.TObject ao ON a.ID = ao.ID AND ao.TypeID = @TypeID_AccountFund
            JOIN dbo.TDirectory cd ON cd.ID = a.CurrencyID
            OUTER APPLY
            (
                SELECT TOP (1)
                    SUM(at.Amount) as Amount
                FROM dbo.TTransfer at
                WHERE at.TargetID = ao.ID
            ) atrin
            OUTER APPLY
            (
                SELECT TOP (1)
                    SUM(at.Amount) as Amount
                FROM dbo.TTransfer at
                WHERE at.SourceID = ao.ID
            ) atrout
        ON a.OwnerID = f.ID
        OUTER APPLY
        (
            SELECT
            FROM dbo.TInvite i
            WHERE 
        )
    WHERE f.ID = @FundID
END
--EXEC API.FundGet
