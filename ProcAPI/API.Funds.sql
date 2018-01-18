IF OBJECT_ID('API.Funds', 'P') IS NULL
BEGIN
    EXEC('CREATE PROC API.Funds AS BEGIN RETURN 1 END')
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
ALTER PROC API.Funds
    @PersonID bigint
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @TypeID_AccountFund bigint = dbo.TypeIDByName('AccountFund')
       ,@StateID_Finished bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeFund', NULL, 'State', 'Finished')
       ,@StateID_Sended bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Sended')
       ,@StateID_Accepted bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Accepted');

    WITH Funds AS
    (
        SELECT
            f.ID as FundID
        FROM dbo.TFund f
            JOIN dbo.TObject o ON o.Id = f.ID
        WHERE f.FounderID = @PersonID
            AND (o.StateID IS NULL OR o.StateID <> @StateID_Finished) -- Фонд не закрыт
        UNION
        SELECT
            i.[FundID]
        FROM dbo.TInvite i
            JOIN dbo.TObject o ON o.ID = i.ID
        WHERE i.[InviteeID] = @PersonID
            AND o.StateID IN (@StateID_Sended, @StateID_Accepted) -- Приглашение в фонд Отправлено или Принято
    )
    SELECT
        f.ID as FundID
       ,f.FounderID
       ,otl.Title as FounderTitle
       ,f.Caption as FundCaption
       ,f.[Description] as FundDescription
       ,ISNULL(sd.Name, 'Created') as FundStateName
       ,ISNULL(sd.Caption, 'Создан') as FundStateCaption
       ,CAST(atr.Amount as nvarchar(10)) + ' ' + cd.Name as FundAmount
    FROM Funds ff
        JOIN dbo.TFund f ON f.ID = ff.FundID
        JOIN dbo.TObject o ON o.ID = f.ID
        LEFT JOIN dbo.TDirectory sd ON sd.ID = o.StateID
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
            ) atr
        ON a.OwnerID = f.ID    
    ORDER BY f.ID
END
--EXEC API.Funds @PersonID = 561360
