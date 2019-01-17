CREATE PROCEDURE flow.Do
    @FlowID INT
  , @ActionCode NVARCHAR(50)
AS
SET NOCOUNT, XACT_ABORT ON;
EXEC internals.GrabFlow @FlowID;
EXEC flow.Log 'TRACE', 'Entering flow.Do;'
EXEC flow.Log 'DEBUG', 'Performing action: :1:', @ActionCode;

DECLARE @StatusCode NVARCHAR(200);
DECLARE @FailureStatusCode NVARCHAR(200);
DECLARE @ResultingStatusCode NVARCHAR(200);
  
-- Check that the action exists
IF @ActionCode NOT IN ( SELECT ActionCode FROM flow.FlowAction WHERE FlowID = @FlowID )
BEGIN
  EXEC flow.Touch @FlowID;
  EXEC flow.Log 'ERROR', 'Invalid action: :1:', @ActionCode;
  EXEC internals.ReleaseFlow;
  THROW 51000, 'Invalid action', 1;
END

-- Get the resulting status
SELECT @ResultingStatusCode = ResultingStatusCode
FROM flow.FlowAction
WHERE FlowID = @FlowID
  AND ActionCode = @ActionCode
;

-- Try changing the status (Fails if the status requires a lock and the lock is taken)
BEGIN TRY
  EXEC internals.SetStatus @FlowID, @ResultingStatusCode;
END TRY
BEGIN CATCH
  SELECT
      @StatusCode = StatusCode
    , @FailureStatusCode = FailureStatusCode
  FROM flow.Flow
  WHERE FlowID = @FlowID
  ;

  IF @FailureStatusCode IS NULL
  BEGIN
    EXEC flow.Log 'ERROR', 'Undefined failure status on status code [:1:]', @StatusCode;
    THROW 51000, 'Invalid action', 1;
  END

  IF @FailureStatusCode = @StatusCode
  BEGIN
    EXEC flow.Log 'INFO', 'Already in failure status.', @StatusCode;
    RETURN;
  END
    
  -- Exception handling
  EXEC flow.Log 'ERROR', 'Entering failure status', @FailureStatusCode;
  EXEC internals.SetStatus @FlowID, @FailureStatusCode
  -- No failure chaining: If entering the failure status throws an exception, that exception is unhandled
END CATCH

EXEC flow.Touch @FlowID;

