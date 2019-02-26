CREATE PROCEDURE flow.SetStatusLock
    @StatusCode NVARCHAR(50)
  , @RequiredLockCode NVARCHAR(255)
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC flow.Log 'TRACE', 'SetStatusLock [:1:], [:2:]', @StatusCode, @RequiredLockCode;

-- Fail if the status does not exist
IF NOT EXISTS (
    SELECT 1
    FROM flow_internals.FlowStatus
    WHERE StatusCode = @StatusCode
  )
BEGIN
  EXEC flow.Log 'ERROR', 'Invalid status [:1:]', @StatusCode;
  THROW 51000, 'Invalid status', 1
END

-- If the status already has the lock, exit.
IF EXISTS (
    SELECT 1
    FROM flow_internals.FlowStatus
    WHERE StatusCode = @StatusCode
      AND NOT EXISTS ( SELECT RequiredLockCode EXCEPT SELECT @RequiredLockCode )
  )
  RETURN

-- If it does not exist, add it.
IF NOT EXISTS (
    SELECT 1
    FROM flow_internals.Lock
    WHERE LockCode = @RequiredLockCode
  )
  EXEC flow.AddLock @RequiredLockCode;




-- Find a FlowID that has the status
DECLARE @FlowID INT;

SELECT TOP 1 @FlowID = FlowID
FROM flow_internals.Flow
WHERE StatusCode = @StatusCode

-- If there's a flow with the status...
IF @FlowID IS NOT NULL
BEGIN
  -- Make sure it's the only one...
  IF EXISTS (
      SELECT 1
      FROM flow_internals.Flow
      WHERE StatusCode = @StatusCode
        AND FlowID != @FlowID
    )
  BEGIN
    EXEC flow.Log 'ERROR', 'More than one flow in status [:1:]', @StatusCode;
    THROW 51000, 'More than one flow in status, status is not lockable.', 1;
  END
  -- And let it acquire the lock
  EXEC flow_internals.AcquireLock @FlowID, @RequiredLockCode;
END

-- Update the status.
UPDATE fs
SET RequiredLockCode = @RequiredLockCode
FROM flow_internals.FlowStatus AS fs
WHERE fs.StatusCode = @StatusCode
;

-- Log if the status 
IF @@ROWCOUNT > 0
  EXEC flow.Log 'INFO', 'Lock [:1:] now required by status [:2:]', @RequiredLockCode, @StatusCode;
