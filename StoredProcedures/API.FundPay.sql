IF OBJECT_ID('API.FundPay', 'P') IS NULL
BEGIN
    EXEC('CREATE PROC API.FundPay AS BEGIN RETURN 0 END')
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
ALTER PROC API.FundPay
    @FundID bigint
   ,@PersonID bigint
   ,@CurrencyName bigint = 'RUB'
   ,@Amount money
AS
BEGIN
    SET NOCOUNT ON

    DECLARE
        @CurrencyID bigint = dbo.DirectoryIDByName(NULL, 'Currency', @CurrencyName)
       ,@AccountVirtualDummyID bigint
       ,@AccountPersonalID bigint
       ,@AccountFundID bigint
       ,@TypeID_AccountVirtualDummy bigint = dbo.TypeIDByName('AccountVirtualDummy')
       ,@TypeID_AccountPersonal bigint = dbo.TypeIDByName('AccountPersonal')
       ,@TypeID_AccountFund bigint = dbo.TypeIDByName('AccountFund')
       ,@StateID_Sended bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Sended')
       ,@StateID_Accepted bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeInvite', NULL, 'State', 'Accepted')

    IF @CurrencyID IS NULL
    BEGIN
        EXEC dbo.Error
            @ProcID = @@PROCID
           ,@Message = 'Не удалось определить валюту платежа по имени "%s"'
           ,@p1 = @CurrencyName
    END

    IF @Amount <= 0
    BEGIN
        EXEC dbo.Error
            @ProcID = @@PROCID
           ,@Message = 'Нельзя произвести платеж в фонд ID=%s на нулевую или отрицательную сумму'
           ,@p1 = @FundID
    END

    IF dbo.ObjectStateIs(@FundID, NULL, 'Opened') = 0
    BEGIN
        EXEC dbo.Error
            @ProcID = @@PROCID
           ,@Message = 'Фонд должен быть Открыт'
           ,@p1 = @CurrencyName
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.TInvite i
            JOIN dbo.TObject o ON o.ID = i.ID
        WHERE i.FundID = @FundID
            AND i.InviteeID = @PersonID
            AND o.StateID IN (@StateID_Sended, @StateID_Accepted)
        UNION ALL
        SELECT 1
        FROM dbo.TFund f
        WHERE f.ID = @FundID
            AND f.FounderID = @PersonID
        -- ToDo Публичный фонд
    )
    BEGIN
        EXEC dbo.Error
            @ProcID = @@PROCID
           ,@Message = 'Отсутствует приглашение на участие в фонде ID=%s'
           ,@p1 = @FundID
    END

    -- Определяем счет заглушку
    SELECT TOP (1)
        @AccountVirtualDummyID = a.ID
    FROM dbo.TAccount (NOLOCK) a
        JOIN dbo.TObject o ON o.ID = a.ID
    WHERE a.OwnerID = @PersonID
        AND a.CurrencyID = @CurrencyID
        AND o.TypeID = @TypeID_AccountVirtualDummy

    -- Определяем личный счет персоны
    SELECT TOP (1)
        @AccountPersonalID = a.ID
    FROM dbo.TAccount (NOLOCK) a
        JOIN dbo.TObject o ON o.ID = a.ID
    WHERE a.OwnerID = @PersonID
        AND a.CurrencyID = @CurrencyID
        AND o.TypeID = @TypeID_AccountPersonal

    -- Определяем счет фонда
    SELECT TOP (1)
        @AccountFundID = a.ID
    FROM dbo.TAccount (NOLOCK) a
        JOIN dbo.TObject o ON o.ID = a.ID
    WHERE a.OwnerID = @FundID
        AND a.CurrencyID = @CurrencyID
        AND o.TypeID = @TypeID_AccountFund

    BEGIN TRAN

    -- Если счет-заглушка отсутствует - создаем
    IF @AccountVirtualDummyID IS NULL
    BEGIN
        EXEC dbo.AccountSet
            @ID = @AccountVirtualDummyID OUT
           ,@TypeID = @TypeID_AccountVirtualDummy
           ,@CurrencyID = @CurrencyID
           ,@OwnerID = @PersonID
    END

    -- Если персональный счет отсутствует - создаем
    IF @AccountPersonalID IS NULL
    BEGIN
        EXEC dbo.AccountSet
            @ID = @AccountPersonalID OUT
           ,@TypeID = @TypeID_AccountPersonal
           ,@CurrencyID = @CurrencyID
           ,@OwnerID = @PersonID
    END

    -- Делаем перевод с виртуального счета на личный
    EXEC dbo.TransferSet
        @ID = NULL
       ,@TypeName = 'TransferIncome'
       ,@StateID = NULL
       ,@SourceID = @AccountVirtualDummyID
       ,@TargetID = @AccountPersonalID
       ,@Amount = @Amount
       ,@CurrencyID = @CurrencyID
        


    -- Если счет фонда отсутствует - создаем
    IF @AccountFundID IS NULL
    BEGIN
        EXEC dbo.AccountSet
            @ID = @AccountFundID OUT
           ,@TypeID = @TypeID_AccountFund
           ,@CurrencyID = @CurrencyID
           ,@OwnerID = @FundID
    END

    COMMIT
END
--EXEC API.FundPay
