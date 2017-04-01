IF OBJECT_ID('API.Funds', 'P') IS NOT NULL
BEGIN
    DROP PROC API.Funds
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
CREATE PROC API.Funds
    @PersonID bigint = 561220
AS
BEGIN
    SET NOCOUNT ON;

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
       ,'1000 руб.' as FundAmount
    FROM Funds ff
        JOIN dbo.TFund f ON f.ID = ff.FundID
        OUTER APPLY dbo.ObjectTitleList(f.FounderID) otl
    ORDER BY f.ID
END
--EXEC API.Funds @PersonID = 561220
