IF OBJECT_ID('API.InviteAccept', 'P') IS NULL
BEGIN
    EXEC('CREATE PROC API.InviteAccept AS BEGIN RETURN 0 END')
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
-- Принять приглашение
ALTER PROC API.InviteAccept
    @FundID bigint
   ,@PersonID bigint
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE
        @InviteID bigint
       ,@StateID_Sended bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Sended')
       
    SELECT
        @InviteID = i.ID
    FROM dbo.TInvite (NOLOCK) i
        JOIN dbo.TObject (NOLOCK) o ON o.ID = i.ID
    WHERE i.FundID = @FundID
        AND i.InviteeID = @PersonID
        AND o.StateID = @StateID_Sended

    IF @InviteID IS NULL
    BEGIN
        RETURN 0 --EXEC dbo.Error?
    END

    EXEC dbo.ObjectTransitExec
        @ID = @InviteID
       ,@TransitName = 'InviteAccept'
END
--EXEC API.InviteAccept
