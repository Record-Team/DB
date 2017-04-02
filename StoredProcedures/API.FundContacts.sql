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
   ,@PersonID bigint
AS
BEGIN
    SET NOCOUNT ON

    DECLARE
        @StateID_Accepted bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Accepted')
       ,@StateID_Sended bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Sended')

    SELECT
        p.ID as PersonID
       ,p.Name as PersonName
       ,ISNULL(inv.Invite, 0) as Invite
    FROM dbo.TPerson p 
        OUTER APPLY
        (
            SELECT TOP (1)
                CAST(1 as bit) as Invite 
            FROM dbo.TInvite i
                JOIN dbo.TObject o ON o.ID = i.ID
                JOIN dbo.TDirectory sd ON sd.ID = o.StateID
            WHERE i.InviteeID = p.ID
                AND i.FundID = @FundID
                AND o.StateID IN (@StateID_Sended, @StateID_Accepted)
            ORDER BY i.ID DESC
        ) inv
    ORDER BY PersonName
END
--EXEC API.FundContacts @FundID = 561345
