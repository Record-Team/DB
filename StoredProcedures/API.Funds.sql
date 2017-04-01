﻿IF OBJECT_ID('API.Funds', 'P') IS NULL
BEGIN
    EXEC('CREATE PROC API.Funds AS BEGIN RETURN 1 END')
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
ALTER PROC API.Funds
    @PersonID bigint = 561220
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @TypeID_AccountFund bigint = dbo.TypeIDByName('AccountFund');

    WITH Funds AS
    (
        SELECT
            f.ID as FundID
        FROM dbo.TFund f
        WHERE f.FounderID = @PersonID
        UNION
        SELECT
            i.[FundID]
        FROM dbo.TInvite i
        WHERE i.[InviteeID] = @PersonID
    )
    SELECT
        f.ID as FundID
       ,f.FounderID
       ,otl.Title as FounderTitle
       ,f.Caption as FundCaption
       ,f.[Description] as FundDescription
       ,CAST(atr.Amount as nvarchar(10)) + ' ' + cd.Name as FundAmount
    FROM Funds ff
        JOIN dbo.TFund f ON f.ID = ff.FundID
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
--EXEC API.Funds @PersonID = 561220