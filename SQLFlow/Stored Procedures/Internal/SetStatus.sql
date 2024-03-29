CREATE PROCEDURE flow_internals.SetStatus
    @FlowID INT
  , @StatusCode NVARCHAR(255)
AS
SET NOCOUNT, XACT_ABORT ON;
EXEC flow_internals.UpdateContext @FlowID;

EXEC flow.Log 'TRACE', 'SetStatus [:1:], [:2:]', @FlowID, @StatusCode;
/*
  * Set the status of a Flow, acquiring any locks and executing 
  * any stored procedures associated with the status.
  * 
  * Fails if:
  *   - The status doesn't exist.
  *   - A required lock cannot be acquired.
  *   - The status procedure fails.
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
  EXEC flow.Log 'TRACE', 'Already in status [:1:]', @StatusCode;
  RETURN;
END

-- If the status is invalid, return
IF @StatusCode NOT IN (
    SELECT s.StatusCode
    FROM flow_internals.FlowStatus AS s
  )
BEGIN
  EXEC flow.Log 'ERROR', 'Invalid status: [:1:]', @StatusCode;
  THROW 51000, 'Invalid status', 1;
END

-- Find the required lock
SELECT @RequiredLockCode = RequiredLockCode
FROM flow_internals.FlowStatus AS fs
INNER JOIN flow_internals.Flow AS f
  ON  f.TypeCode = fs.TypeCode
WHERE FlowID = @FlowID
  AND fs.StatusCode = @StatusCode
;

-- Acquire the lock if possible
IF @RequiredLockCode != ''
BEGIN
  EXEC flow.Log 'TRACE', 'Lock required: [:1:]', @RequiredLockCode;
  EXEC flow_internals.AcquireLock @FlowID, @RequiredLockCode
  EXEC flow.Log 'TRACE', 'Acquired lock [:1:]', @RequiredLockCode;
END
ELSE
BEGIN
  EXEC flow.Log 'TRACE', 'No lock required';
  EXEC flow_internals.ReleaseLock @FlowID;
END

UPDATE flow_internals.Flow
SET StatusCode = @StatusCode
WHERE FlowID = @FlowID
;
-- Put the status code in the session context
EXEC sp_set_session_context N'StatusCode', @StatusCode;


EXEC flow.Log 'INFO', 'Entered status [:1:]', @StatusCode;

SELECT @ProcedureName = ProcedureName 
FROM flow.Flow
WHERE FlowID = @FlowID
;

-- Execute the procedure attached to the new status, if any
-- Fails if the failure action runs and fails
IF @ProcedureName != ''
BEGIN
  EXEC flow.Log 'TRACE', 'Running status procedure';
  EXEC flow.ExecuteStoredProcedure @FlowID, @ProcedureName;
  EXEC flow.Log 'TRACE', 'Completed status procedure';
END

EXEC flow.Log 'TRACE', 'Leaving flow.SetStatus'
