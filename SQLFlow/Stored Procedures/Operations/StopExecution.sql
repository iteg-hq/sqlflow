CREATE PROCEDURE dbo.StopExecution @FlowID INT
AS
SET NOCOUNT, XACT_ABORT ON;

DECLARE @StatusCode NVARCHAR(50);

UPDATE internal.Flow
SET ExecutionStoppedAt = SYSDATETIME()
WHERE FlowID = @FlowID;

EXEC internal.UpdateContext @FlowID=NULL;

SELECT @StatusCode = StatusCode
FROM dbo.Flow
WHERE FlowID = @FlowID;

EXEC dbo.Log 'INFO', 'Flow execution done. Final status: [:1:].', @StatusCode;
