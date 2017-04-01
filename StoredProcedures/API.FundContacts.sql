IF OBJECT_ID('API.FundContacts', 'P') IS NULL
BEGIN
    EXEC('CREATE PROC API.FundContacts AS BEGIN RETURN 0 END')
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
ALTER PROC API.FundContacts
    @FundID bigint
AS
BEGIN
    SET NOCOUNT ON

    DECLARE
        @StateID_Accepted bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Accepted')
       ,@StateID_Closed bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Closed')

    SELECT
        p.ID as PersonID
       ,p.Name as PersonName
       ,sd.Name as InviteStateName
    FROM dbo.TInvite i
        JOIN dbo.TObject o ON o.ID = i.ID
        JOIN dbo.TPerson p ON p.ID = i.InviteeID
        JOIN dbo.TDirectory sd ON sd.ID = o.StateID
    WHERE i.FundID = @FundID
        AND o.StateID IN (@StateID_Accepted, @StateID_Closed)
    ORDER BY PersonName
END
--EXEC API.FundContacts @FundID = 561345
