IF OBJECT_ID('API.InviteReject', 'P') IS NULL
BEGIN
    EXEC('CREATE PROC API.InviteReject AS BEGIN RETURN 0 END')
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
-- Отклонить приглашение
ALTER PROC API.InviteReject
    @FundID bigint
   ,@PersonID bigint
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE
        @InviteID bigint
       ,@InviteStateID bigint
       ,@StateID_Sended bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Sended')
       ,@StateID_Accepted bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Accepted')
       
    DECLARE CUR CURSOR LOCAL STATIC FORWARD_ONLY FOR
        SELECT
            i.ID
           ,o.StateID
        FROM dbo.TInvite i
            JOIN dbo.TObject o ON o.ID = i.ID
        WHERE i.FundID = @FundID
            AND i.InviteeID = @PersonID
            AND o.StateID IN (@StateID_Sended, @StateID_Accepted)
    
    OPEN CUR
    FETCH NEXT FROM CUR INTO @InviteID, @InviteStateID
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Если инвайт в состоянии Отправлен - переводим в Отклонен
        IF @InviteStateID = @StateID_Sended
        BEGIN
            EXEC dbo.ObjectTransitExec
                @ID = @InviteID
               ,@TransitName = 'InviteReject'
        END

        -- Если инвайт в состоянии Принят - переводим в Закрыт
        IF @InviteStateID = @StateID_Accepted
        BEGIN
            EXEC dbo.ObjectTransitExec
                @ID = @InviteID
               ,@TransitName = 'InviteClose'
        END
    	   
        FETCH NEXT FROM CUR INTO @InviteID, @InviteStateID
    END
    
    CLOSE CUR
    DEALLOCATE CUR
END
--EXEC API.InviteReject
