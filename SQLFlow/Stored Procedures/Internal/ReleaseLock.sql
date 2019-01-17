CREATE PROCEDURE internals.ReleaseLock
    @FlowID INT
AS
UPDATE internals.Lock
SET HeldByFlowID = NULL
WHERE HeldByFlowID = @FlowID
;

EXEC flow.Log 'DEBUG', 'Released :1: locks', @@ROWCOUNT;

