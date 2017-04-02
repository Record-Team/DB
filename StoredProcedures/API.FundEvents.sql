IF OBJECT_ID('API.FundEvents', 'P') IS NULL
BEGIN
    EXEC('CREATE PROC API.FundEvents AS BEGIN RETURN 0 END')
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
-- Последние события в фонде
ALTER PROC API.FundEvents
    @FundID bigint
AS
BEGIN
    SET NOCOUNT ON

    DECLARE
        @StateID_Accepted bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Accepted')
       ,@StateID_Processed bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeTransfer', NULL, 'State', 'Processed')
       ,@StateID_Opened bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeFund', NULL, 'State', 'Opened')

    SELECT
        e.Moment
       ,IIF(tr.TargetStateID = @StateID_Opened, 'Открытие фонда', 'Закрытие фонда') as [Message]
    FROM dbo.TEvent e
        JOIN dbo.TEventTransit et ON et.EventID = e.EventID
        JOIN dbo.TTransit tr ON tr.ID = et.TransitID
    WHERE e.ObjectID = @FundID
        AND (tr.SourceStateID = @StateID_Opened OR tr.TargetStateID = @StateID_Opened)
    UNION ALL
    SELECT
        e.Moment
       ,IIF(tr.TargetStateID = @StateID_Accepted, p.Name + ' вступил в фонд', p.Name + ' покинул фонд') as [Message]
    FROM dbo.TInvite i
        JOIN dbo.TObject o ON o.ID = i.ID
        JOIN dbo.TPerson p ON p.ID = i.InviteeID
        JOIN dbo.TEvent e ON e.ObjectID = o.ID
        JOIN dbo.TEventTransit et ON et.EventID = e.EventID
        JOIN dbo.TTransit tr ON tr.ID = et.TransitID
    WHERE i.FundID = @FundID
        AND (tr.SourceStateID = @StateID_Accepted OR tr.TargetStateID = @StateID_Accepted)
    UNION ALL
    SELECT
        e.Moment
       ,IIF(tr.Income = 1, 'Поступило ' + CAST(tr.Amount as nvarchar(10)) + ' ' + cd.Name + ' от ' + acct.Title, 'Вывод ' + CAST(tr.Amount as nvarchar(10)) + ' ' + cd.Name + ' в пользу ' + acct.Title) as [Message]
    FROM dbo.TAccount a
        CROSS APPLY
        (
            SELECT
                tr.ID
               ,CAST(1 as bit) as Income
               ,tr.SourceID as AccountID
               ,tr.Amount
            FROM dbo.TTransfer tr
            WHERE tr.TargetID = a.ID
            UNION ALL
            SELECT
                tr.ID
               ,CAST(0 as bit) as Income
               ,tr.TargetID as AccountID
               ,tr.Amount
            FROM dbo.TTransfer tr
            WHERE tr.SourceID = a.ID
        ) tr
        JOIN dbo.TObject tro ON tro.ID = tr.ID
        JOIN dbo.TAccount acc ON acc.ID = tr.AccountID
        JOIN dbo.TDirectory cd ON cd.ID = acc.CurrencyID
        OUTER APPLY dbo.ObjectTitleList(acc.OwnerID) as acct
        JOIN dbo.TEvent e ON e.ObjectID = tro.ID
        JOIN dbo.TEventTransit et ON et.EventID = e.EventID
        JOIN dbo.TTransit tra ON tra.ID = et.TransitID
    WHERE a.OwnerID = @FundID
        AND tro.StateID = @StateID_Processed
        AND tra.TargetStateID = @StateID_Processed
    ORDER BY Moment DESC
END
--EXEC API.FundEvents @FundID = 561345
