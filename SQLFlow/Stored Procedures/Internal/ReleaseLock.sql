CREATE PROCEDURE internal.ReleaseLock
    @FlowID INT
AS
SET NOCOUNT, XACT_ABORT ON;
EXEC internal.UpdateContext @FlowID;
EXEC dbo.Log 'TRACE', 'ReleaseLock [:1:]', @FlowID;

UPDATE internal.Lock
SET HeldByFlowID = NULL
WHERE HeldByFlowID = @FlowID
;

EXEC dbo.Log 'DEBUG', 'Released :1: locks', @@ROWCOUNT;

