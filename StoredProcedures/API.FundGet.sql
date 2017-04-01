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
        @TypeID_AccountFund bigint = dbo.TypeIDByName('AccountFund')
       ,@StateID_Rejected bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Rejected')

    SELECT
        f.ID as FundID
       ,f.FounderID
       ,otl.Title as FounderTitle
       ,f.Caption as FundCaption
       ,f.[Description] as FundDescription
       ,CAST(atrin.Amount as nvarchar(10)) + ' ' + cd.Name as FundAmount
       ,CAST(NULLIF(ISNULL(atrin.Amount, 0) - ISNULL(atrout.Amount, 0), 0) as nvarchar(10)) + ' ' + cd.Name as FundBalance
       ,ISNULL(inv.InviteCount, 0) as InviteCount
       ,ISNULL(inv.InviteRejected, 0) as InviteRejected
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
                COUNT(i.ID) as [InviteCount]
               ,SUM(IIF(o.StateID = @StateID_Rejected, 1, 0)) as InviteRejected
            FROM dbo.TInvite i
                JOIN dbo.TObject o ON o.ID = i.ID
            WHERE i.FundID = f.ID
                AND o.StateID IS NOT NULL
        ) inv
    WHERE f.ID = @FundID
END
--EXEC API.FundGet @FundID = 561345, @PersonID = 561220
