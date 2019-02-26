CREATE PROCEDURE flow_internals.ReleaseLock
    @FlowID INT
AS
SET NOCOUNT, XACT_ABORT ON;
EXEC flow_internals.UpdateContext @FlowID;
EXEC flow.Log 'TRACE', 'ReleaseLock [:1:]', @FlowID;

UPDATE flow_internals.Lock
SET HeldByFlowID = NULL
WHERE HeldByFlowID = @FlowID
;

EXEC flow.Log 'DEBUG', 'Released :1: locks', @@ROWCOUNT;

