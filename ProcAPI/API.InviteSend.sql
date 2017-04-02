IF OBJECT_ID('API.InviteSend', 'P') IS NULL
BEGIN
    EXEC('CREATE PROC API.InviteSend AS BEGIN RETURN 0 END')
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
-- Отправка приглашения
ALTER PROC API.InviteSend
    @FundID bigint
   ,@InviteeID bigint
   ,@PersonID bigint
AS
BEGIN
    SET NOCOUNT ON

    DECLARE 
        @InviteID bigint
       ,@StateID_Sended bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Sended')
       ,@StateID_Accepted bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Accepted')
       ,@StateID_Rejected bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Rejected')
       ,@FounderID bigint
       ,@FundStateID bigint
       ,@StateID_Finished bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeFund', NULL, 'State', 'Finished')

    SELECT
        @FounderID = f.FounderID
       ,@FundStateID = o.StateID
    FROM dbo.TFund f
        JOIN dbo.TObject (NOLOCK) o ON o.ID = f.ID
    WHERE f.ID = @FundID

    -- Фонд закрыт
    IF @FundStateID = @StateID_Finished
    BEGIN
        EXEC dbo.Error
            @ProcID = @@PROCID
           ,@Message = 'Фонд ID=%s закрыт'
           ,@p1 = @FundID
    END

    -- Если пользовать пытается отправить приглашение самому себе или учредителю
    IF @InviteeID = @PersonID
        OR @InviteeID = @FounderID
    BEGIN
        RETURN 0
    END

    -- Если пользователь уже получил приглашение, то не делаем повторное
    IF EXISTS
    (
        SELECT 1
        FROM dbo.TInvite (NOLOCK) i
            JOIN dbo.TObject (NOLOCK) o ON o.ID = i.ID
        WHERE i.FundID = @FundID
            AND i.InviteeID = @InviteeID
            AND o.StateID IN (@StateID_Sended, @StateID_Accepted, @StateID_Rejected)
    )
    BEGIN
        RETURN 0
    END

    BEGIN TRAN

    EXEC dbo.InviteSet
        @ID = @InviteID OUTPUT
       --,@TypeID = NULL
       ,@TypeName = 'Invite'
       --,@StateID = NULL
       ,@FundID = @FundID
       ,@InviteeID = @InviteeID
       ,@ReferrerID = @PersonID

    -- Отправить приглашение
    EXEC dbo.ObjectTransitExec
        @ID = @InviteID
       ,@TransitName = 'InviteSend'

    COMMIT
END
/*
EXEC API.InviteSend
    @FundID = 561345
   ,@InviteeID = 561401
   ,@PersonID = 561220
*/
