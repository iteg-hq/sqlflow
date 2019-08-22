CREATE PROCEDURE internal.SetStatus
    @FlowID INT
  , @StatusCode NVARCHAR(255)
AS
SET NOCOUNT, XACT_ABORT ON;
EXEC internal.UpdateContext @FlowID;

EXEC Log 'TRACE', 'SetStatus [:1:], [:2:]', @FlowID, @StatusCode;
EXEC Log 'DEBUG', 'Entering status [:1:]', @StatusCode;
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
    FROM Flow
    WHERE FlowID = @FlowID
      AND StatusCode = @StatusCode
  )
BEGIN
  EXEC Log 'INFO', 'Already in status [:1:]', @StatusCode;
  RETURN;
END

-- If the status is invalid, return
IF @StatusCode NOT IN (
    SELECT s.StatusCode
    FROM internal.FlowStatus AS s
  )
BEGIN
  EXEC Log 'ERROR', 'Invalid status: [:1:]', @StatusCode;
  THROW 51000, 'Invalid status', 1;
END

-- Find the required lock
SELECT @RequiredLockCode = RequiredLockCode
FROM internal.FlowStatus AS fs
INNER JOIN internal.Flow AS f
  ON  f.TypeCode = fs.TypeCode
WHERE FlowID = @FlowID
  AND fs.StatusCode = @StatusCode
;

-- Acquire the lock if possible
IF @RequiredLockCode != ''
BEGIN
  EXEC Log 'DEBUG', 'Lock required: [:1:]', @RequiredLockCode;
  EXEC internal.AcquireLock @FlowID, @RequiredLockCode
  EXEC Log 'INFO', 'Acquired lock [:1:]', @RequiredLockCode;
END
ELSE
BEGIN
  EXEC Log 'DEBUG', 'No lock required';
  EXEC internal.ReleaseLock @FlowID;
END

UPDATE internal.Flow
SET StatusCode = @StatusCode
WHERE FlowID = @FlowID
;
-- Put the status code in the session context
EXEC sp_set_session_context N'StatusCode', @StatusCode;


EXEC Log 'INFO', 'Entered status [:1:]', @StatusCode;

SELECT @ProcedureName = ProcedureName 
FROM Flow
WHERE FlowID = @FlowID
;

-- Execute the procedure attached to the new status, if any
-- Fails if the failure action runs and fails
IF @ProcedureName != ''
BEGIN
  EXEC Log 'DEBUG', 'Running status procedure';
  EXEC ExecuteStoredProcedure @FlowID, @ProcedureName;
  EXEC Log 'TRACE', 'Completed status procedure';
END

EXEC Log 'TRACE', 'Leaving SetStatus'
