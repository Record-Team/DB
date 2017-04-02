IF OBJECT_ID('[dbo].[ObjectTitleList]') IS NULL
BEGIN
    EXEC('CREATE FUNCTION [dbo].[ObjectTitleList] RETURNS TALBE AS RETURN (SELECT 1 AS ID)')
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
ALTER FUNCTION [dbo].[ObjectTitleList]
(
    @ID bigint
)
RETURNS TABLE
AS RETURN
(
    SELECT TOP (1)
        CASE dt.Name
            WHEN N'ObjectTitleDirectory' THEN (SELECT d.Caption FROM dbo.TDirectory d WHERE d.ID = o.ID)
            WHEN N'ObjectTitleFile' THEN (SELECT f.[FileName] FROM dbo.TFile f WHERE f.ID = o.ID)
            WHEN N'ObjectTitlePerson' THEN (SELECT p.Name FROM dbo.TPerson p WHERE p.ID = o.ID) --WHEN N'ObjectTitlePerson' THEN (SELECT CONCAT(p.LastName, ' ', LEFT(p.FirstName, 1), '.', ISNULL(LEFT(p.MiddleName, 1) + '.', '')) FROM dbo.TPerson p WHERE p.ID = o.ID)
            WHEN N'ObjectTitleFund' THEN (SELECT f.Caption FROM dbo.TFund f WHERE f.ID = o.ID)
            ELSE N'ID=' + CAST(o.ID as nvarchar(32))
        END as Title
    FROM dbo.TObject o
        LEFT JOIN dbo.TObjectType ot ON ot.ID = o.TypeID
        LEFT JOIN dbo.TDirectory dt ON dt.ID = ot.ObjectTitleID
    WHERE o.ID = @ID
)