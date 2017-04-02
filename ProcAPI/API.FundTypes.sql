IF OBJECT_ID('API.FundTypes', 'P') IS NOT NULL
BEGIN
    DROP PROC API.FundTypes
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
-- Список типов фондов
CREATE PROC API.FundTypes
AS
BEGIN
    SET NOCOUNT ON

    DECLARE
        @FundTypeID bigint = dbo.TypeIDByName('Fund')
       ,@StateID_Formed bigint = dbo.DirectoryIDByOwner(NULL, 'StateSchemeBasic', NULL, 'State', 'Formed')

    SELECT
        d.ID as FundTypeID
       ,d.Caption as FundTypeCaption
       ,d.[Description] as FundTypeDescription
    FROM dbo.TObject o 
        JOIN dbo.TDirectory d ON d.ID = o.ID
        JOIN dbo.TType t ON t.ID = d.ID
    WHERE d.OwnerID = @FundTypeID
        AND o.StateID = @StateID_Formed
END
--EXEC API.FundTypes