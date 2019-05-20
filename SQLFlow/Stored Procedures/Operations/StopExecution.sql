CREATE PROCEDURE flow.StopExecution @FlowID INT
AS
SET NOCOUNT, XACT_ABORT ON;
UPDATE flow_internals.Flow
SET ExecutionStoppedAt = SYSDATETIME()
WHERE FlowID = @FlowID
;
