IF OBJECT_ID('API.InviteClose', 'P') IS NULL
BEGIN
    EXEC('CREATE PROC API.InviteClose AS BEGIN RETURN 0 END')
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
-- Закрыть приглашение
ALTER PROC API.InviteClose
    @FundID bigint
   ,@InviteeID bigint
   ,@PersonID bigint
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE
        @InviteID bigint
       ,@InviteStateID bigint
       ,@StateID_Sended bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Sended')
       ,@StateID_Accepted bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Accepted')
       ,@FounderID bigint
       ,@TransitName nvarchar(4000)
       
    SELECT
        @FounderID = f.FounderID
    FROM dbo.TFund f
    WHERE f.ID = @FundID

    DECLARE CUR CURSOR LOCAL STATIC FORWARD_ONLY FOR
        SELECT
            i.ID
           ,o.StateID
        FROM dbo.TInvite i
            JOIN dbo.TObject o ON o.ID = i.ID
        WHERE i.FundID = @FundID
            AND i.InviteeID = @InviteeID
            AND o.StateID IN (@StateID_Sended, @StateID_Accepted)
    
    OPEN CUR
    FETCH NEXT FROM CUR INTO @InviteID, @InviteStateID
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @InviteeID = @PersonID
        BEGIN -- Пользователь сам отклоняет приглашение
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
        END
        ELSE
        BEGIN -- Если отзывает учредитель фонда
            IF @FounderID = @PersonID
            BEGIN
                -- Переводим в Отозван
                EXEC dbo.ObjectStateGo
                    @ID = @InviteID
                   ,@StateName = 'Revoked'
            END
            ELSE
            BEGIN
                EXEC dbo.Error
                    @ProcID = @@PROCID
                   ,@Message = 'Отозвать приглашение может только учредитель фонда ID=%s!'
                   ,@p1 = @FundID
            END
        END
    	   
        FETCH NEXT FROM CUR INTO @InviteID, @InviteStateID
    END
    
    CLOSE CUR
    DEALLOCATE CUR
END
--EXEC API.InviteClose
