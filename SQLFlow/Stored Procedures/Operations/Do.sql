CREATE PROCEDURE flow.Do
    @FlowID INT
  , @ActionCode NVARCHAR(50)
  , @RecursionLevel INT = 0
AS
SET NOCOUNT, XACT_ABORT ON;
EXEC internal.UpdateContext @FlowID;

/*
 * Performs an action
 */
EXEC flow.Log 'TRACE', 'Do [:1:], [:2:], [:3:]', @FlowID, @ActionCode, @RecursionLevel;

DECLARE @StatusCode NVARCHAR(200);
DECLARE @ResultingStatusCode NVARCHAR(200);
DECLARE @Autocomplete BIT;
DECLARE @NextRecursionLevel INT = @RecursionLevel+1;


EXEC flow.Log 'DEBUG', 'Performing action: [:1:]', @ActionCode;

-- Check that the action exists
IF @ActionCode NOT IN ( SELECT ActionCode FROM flow.FlowAction WHERE FlowID = @FlowID )
BEGIN
  EXEC flow.Log 'ERROR', 'Invalid action: [:1:]', @ActionCode;
  EXEC internal.UpdateContext @FlowID=NULL;
  THROW 51000, 'Invalid action', 1;
END

-- Get the resulting status and wether or not the new status has Autocomplete set
SELECT
    @ResultingStatusCode = ResultingStatusCode
  , @Autocomplete = Autocomplete
FROM flow.FlowAction
WHERE FlowID = @FlowID
  AND ActionCode = @ActionCode
;

-- Try changing the status (Fails if the status requires a lock and the lock is taken)
BEGIN TRY
  EXEC internal.SetStatus @FlowID, @ResultingStatusCode;
END TRY
BEGIN CATCH
  -- If anything goes wrong in the status transition, call Do recursively to perform the Fail action.
  -- No failure chaining: If Failing throws an exception, that exception is unhandled
  EXEC flow.Do @FlowID, 'Fail', @NextRecursionLevel;
  RETURN;
END CATCH

-- If the status has Autocomplete set, call Do recursively to perform the Complete action to
-- progress to the next state.

IF @Autocomplete = 1
BEGIN
  EXEC flow.Log 'TRACE', 'Autocompleting';
  EXEC flow.Do @FlowID, 'Complete', @NextRecursionLevel;
END

EXEC flow.Log 'TRACE', 'Leaving flow.Do [:1:];', @RecursionLevel;
