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

    -- Если пользователь уже получал уведомление, то не делаем повторное приглашение 
    IF EXISTS
    (
        SELECT 1
        FROM dbo.TInvite i
        WHERE i.FundID = @FundID
            AND i.InviteeID = @InviteeID
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
