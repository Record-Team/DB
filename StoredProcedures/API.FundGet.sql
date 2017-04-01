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
       ,@StateID_Accepted bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Accepted')
       ,@StateID_Sended bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Sended')
       ,@StateID_Opened bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeFund', NULL, 'State', 'Opened')

    SELECT
        f.ID as FundID
       ,f.FounderID
       ,otl.Title as FounderTitle --ToDo FounderName
       ,f.Caption as FundCaption
       ,f.[Description] as FundDescription
       ,ISNULL(sd.Name, 'Created') as FundStateName
       ,ISNULL(sd.Caption, 'Создан') as FundStateCaption
       ,CAST(atrin.Amount as nvarchar(10)) + ' ' + cd.Name as FundAmount
       ,CAST(NULLIF(ISNULL(atrin.Amount, 0) - ISNULL(atrout.Amount, 0), 0) as nvarchar(10)) + ' ' + cd.Name as FundBalance
       ,ISNULL(invall.InviteCount, 0) as InviteCount
       ,CAST(1 as bit) as ButtonFinish
       ,CAST(1 as bit) as ButtonInviteAccept
       ,CAST(1 as bit) as ButtonInviteReject
       ,CAST(1 as bit) as ButtonPay
       --,CAST(IIF(@PersonID = f.FounderID AND o.StateID = @StateID_Opened, 1, 0) as bit) as ButtonFinish
       --,CAST(IIF(invpers.InviteStateID = @StateID_Sended, 1, 0) as bit) as ButtonInviteAccept
       --,CAST(IIF(invpers.InviteStateID IN (@StateID_Sended, @StateID_Accepted), 1, 0) as bit) as ButtonInviteReject
       --,CAST(IIF(o.StateID = @StateID_Opened, 1, 0) as bit) as ButtonPay
    FROM dbo.TFund f
        JOIN dbo.TObject o ON o.ID = f.ID
        LEFT JOIN dbo.TDirectory sd ON sd.ID = o.StateID
        OUTER APPLY dbo.ObjectTitleList(f.FounderID) otl
        LEFT JOIN dbo.TAccount a
            JOIN dbo.TObject ao ON a.ID = ao.ID
                AND ao.TypeID = @TypeID_AccountFund
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
                COUNT(i.ID) as InviteCount
            FROM dbo.TInvite i
                JOIN dbo.TObject o ON o.ID = i.ID
            WHERE i.FundID = f.ID
                AND o.StateID = @StateID_Accepted
        ) invall
        OUTER APPLY
        (
            SELECT TOP (1)
                o.StateID as InviteStateID
            FROM dbo.TInvite i
                JOIN dbo.TObject o ON o.ID = i.ID
            WHERE i.FundID = f.ID
                AND o.StateID IN (@StateID_Sended, @StateID_Accepted)
            ORDER BY i.ID DESC
        ) invpers
    WHERE f.ID = @FundID
END
--EXEC API.FundGet @FundID = 561345, @PersonID = 561220
