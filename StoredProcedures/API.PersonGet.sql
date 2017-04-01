IF OBJECT_ID('API.PersonGet', 'P') IS NOT NULL
BEGIN
    DROP PROC API.PersonGet
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
CREATE PROC API.PersonGet
    @PersonID bigint
AS
BEGIN
    SET NOCOUNT ON

    DECLARE
        @TypeID_AccountPersonal bigint = dbo.TypeIDByName('AccountPersonal')

    SELECT
        o.ID as PersonID
       ,p.Name as PersonName
       ,atr.Balance as AccountBalance
    FROM dbo.TObject o
        JOIN dbo.TPerson p ON p.ID = o.ID
        OUTER APPLY
        (
            SELECT
                ISNULL(STUFF(CAST(
                (
                    SELECT
                        ', ' + CAST(SUM(tr.Amount) as nvarchar(10)) + ' ' + cd.Name as [text()]
                    FROM dbo.TObject ao
                        JOIN dbo.TAccount aa ON aa.ID = ao.ID
                        CROSS APPLY
                        (
                            SELECT
                                at.[CurrencyID]
                               ,at.Amount   -- Добавляем
                            FROM dbo.TTransfer at
                            WHERE at.TargetID = ao.ID
                            UNION ALL
                            SELECT
                                at.[CurrencyID]
                               ,-at.Amount  -- Отнимаем
                            FROM dbo.TTransfer at
                            WHERE at.SourceID = ao.ID
                        ) tr
                        JOIN dbo.TDirectory cd ON cd.ID = tr.CurrencyID
                    WHERE ao.TypeID = @TypeID_AccountPersonal
                        AND aa.OwnerID = o.ID
                    GROUP BY cd.Name
                    FOR XML PATH(''), TYPE
                ) AS nvarchar(4000)), 1, 2, ''), '') as Balance
        ) atr
    WHERE p.ID = @PersonID
END
--EXEC API.PersonGet @PersonID = 561220