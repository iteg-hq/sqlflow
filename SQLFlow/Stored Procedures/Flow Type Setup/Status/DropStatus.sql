CREATE PROCEDURE flow.DropStatus
    @StatusCode NVARCHAR(50)
AS
SET NOCOUNT, XACT_ABORT ON;
EXEC flow.Log 'TRACE', 'DropStatus [:1:], [:2:], [:3:]', @StatusCode;

DELETE flow_internals.FlowStatus
WHERE StatusCode = @StatusCode
;

EXEC flow.Log 'INFO', 'Deleted :1: rows from FlowStatus', @@ROWCOUNT;
 