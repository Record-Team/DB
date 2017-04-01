IF OBJECT_ID('dbo.InviteSetBefore', 'P') IS NULL
BEGIN
    EXEC('CREATE PROC dbo.InviteSetBefore AS BEGIN RETURN 0 END')
END
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--------- Framework "Record" (R.Valiullin mailto:vrafael@mail.ru) ---------
ALTER PROC dbo.InviteSetBefore
    @ID bigint OUTPUT
   ,@StateID bigint
   ,@FundID bigint
   ,@InviteeID bigint
   ,@ReferrerID bigint
AS
BEGIN
    SET NOCOUNT ON

    SELECT TOP (1)
        @ID = i.ID
       ,@StateID = o.StateID
       ,@ReferrerID = i.ReferrerID
    FROM dbo.TInvite (NOLOCK) i
        JOIN dbo.TObject (NOLOCK) o ON o.ID = i.ID
    WHERE i.FundID = @FundID
        AND i.InviteeID = @InviteeID
END
