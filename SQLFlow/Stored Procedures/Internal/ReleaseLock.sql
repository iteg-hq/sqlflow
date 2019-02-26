CREATE PROCEDURE flow_internals.ReleaseLock
    @FlowID INT
AS
UPDATE flow_internals.Lock
SET HeldByFlowID = NULL
WHERE HeldByFlowID = @FlowID
;

EXEC flow.Log 'DEBUG', 'Released :1: locks', @@ROWCOUNT;

