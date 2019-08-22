CREATE PROCEDURE StartExecution @FlowID INT
AS
SET NOCOUNT, XACT_ABORT ON;

UPDATE internal.Flow
SET ExecutionStartedAt = SYSDATETIME()
WHERE FlowID = @FlowID;

EXEC internal.UpdateContext @FlowID;
