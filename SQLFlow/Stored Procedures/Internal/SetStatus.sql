CREATE PROCEDURE internals.SetStatus
    @FlowID INT
  , @StatusCode NVARCHAR(255)
AS
SET NOCOUNT, XACT_ABORT ON;
EXEC flow.Log 'TRACE', 'Entering flow.SetStatus'
EXEC flow.Log 'DEBUG', 'Entering status :1:', @StatusCode;
/*
  * Set the status of a Flow, acquiring any locks and executing 
  * any stored procedures associated with the flow.
  * 
  * Fails if:
  *   - The status doesn't exist
  *   - A required lock cannot be acquired
  *   - The status procedure fails
  */
DECLARE @RequiredLockCode NVARCHAR(50);
DECLARE @ProcedureName NVARCHAR(500);

-- If we're already there, return
IF EXISTS (
    SELECT 1
    FROM flow.Flow
    WHERE FlowID = @FlowID
      AND StatusCode = @StatusCode
  )
BEGIN
  EXEC flow.Log 'INFO', 'Already in status :1:', @StatusCode;
  RETURN;
END

-- If the status is invalid, return
IF @StatusCode NOT IN (
    SELECT s.StatusCode
    FROM internals.FlowStatus AS s
  )
BEGIN
  EXEC flow.Log 'ERROR', 'Invalid status: :1:', @StatusCode;
  THROW 51000, 'Invalid status', 1;
END

-- Find the required lock
SELECT @RequiredLockCode = RequiredLockCode
FROM internals.FlowStatus
WHERE StatusCode = @StatusCode
;

-- Acquire the lock if possible
IF @RequiredLockCode != ''
BEGIN
  EXEC flow.Log 'DEBUG', 'Lock required: [:1:]', @RequiredLockCode;
  EXEC internals.AcquireLock @FlowID, @RequiredLockCode
  EXEC flow.Log 'INFO', 'Acquired lock [:1:]', @RequiredLockCode;
END
ELSE
BEGIN
  EXEC flow.Log 'DEBUG', 'No lock required';
  EXEC internals.ReleaseLock @FlowID;
END

-- Put the status code in the session context
EXEC sp_set_session_context N'StatusCode', @StatusCode;

UPDATE internals.Flow
SET StatusCode = @StatusCode
WHERE FlowID = @FlowID
;

EXEC flow.Log 'INFO', 'Entered status [:1:]', @StatusCode;

SELECT @ProcedureName = ProcedureName 
FROM flow.Flow
WHERE FlowID = @FlowID
;

-- Execute the procedure attached to the new status, if any
-- Fails if the failure action runs and fails
IF @ProcedureName != ''
BEGIN
  EXEC flow.Log 'DEBUG', 'Running status procedure';
  EXEC flow.ExecuteStoredProcedure @FlowID, @ProcedureName;
  EXEC flow.Log 'TRACE', 'Completed status procedure';
END

EXEC flow.Log 'TRACE', 'Leaving flow.SetStatus'
