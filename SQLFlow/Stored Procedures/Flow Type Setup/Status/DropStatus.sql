CREATE PROCEDURE dbo.DropStatus
    @StatusCode NVARCHAR(50)
AS
SET NOCOUNT, XACT_ABORT ON;
EXEC dbo.Log 'TRACE', 'DropStatus [:1:], [:2:], [:3:]', @StatusCode;

DELETE internal.FlowStatus
WHERE StatusCode = @StatusCode
;

EXEC dbo.Log 'INFO', 'Deleted :1: rows from FlowStatus', @@ROWCOUNT;
 