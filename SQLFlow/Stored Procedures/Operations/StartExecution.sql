CREATE PROCEDURE flow.StartExecution @FlowID INT
AS
SET NOCOUNT, XACT_ABORT ON;

UPDATE flow_internals.Flow
SET ExecutionStartedAt = SYSDATETIME()
WHERE FlowID = @FlowID;

EXEC flow_internals.UpdateContext @FlowID;
