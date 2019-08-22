CREATE PROCEDURE dbo.SetStatusLock
    @TypeCode NVARCHAR(200)
  , @StatusCode NVARCHAR(200)
  , @RequiredLockCode NVARCHAR(255)
  , @Retroactive BIT = 0
AS
SET NOCOUNT, XACT_ABORT ON;
-- Make the successful acquisition of a lock a precondition for entering into a status.
-- Note: By default, any existing flows already in the status will not need to acquire the lock.
-- To require this, set @Retroactive to 1

EXEC dbo.Log 'TRACE', 'SetStatusLock [:1:], [:2:], [:3:]', @StatusCode, @TypeCode, @RequiredLockCode;

-- Fail if the status does not exist
IF NOT EXISTS (
    SELECT 1
    FROM internal.FlowStatus
    WHERE TypeCode = @TypeCode
      AND StatusCode = @StatusCode
  )
BEGIN
  EXEC dbo.Log 'ERROR', 'Invalid status [:1:]', @StatusCode;
  THROW 51000, 'Invalid status', 1
END

-- If the status already has the lock, exit.
IF EXISTS (
    SELECT 1
    FROM internal.FlowStatus
    WHERE TypeCode = @TypeCode
      AND StatusCode = @StatusCode
      AND NOT EXISTS ( SELECT RequiredLockCode EXCEPT SELECT @RequiredLockCode )
  )
  RETURN

-- If the lock does not exist, add it.
IF NOT EXISTS (
    SELECT 1
    FROM internal.Lock
    WHERE LockCode = @RequiredLockCode
  )
  EXEC dbo.AddLock @RequiredLockCode;

-- If the requirement applies to existing flows...
IF @Retroactive = 1
BEGIN
  -- ...find a FlowID that has the status.
  DECLARE @FlowID INT;

  SELECT TOP 1 @FlowID = FlowID
  FROM internal.Flow
  WHERE TypeCode = @TypeCode
    AND StatusCode = @StatusCode

  -- If there's a flow with the status...
  IF @FlowID IS NOT NULL
  BEGIN
    -- ...make sure it's the only one...
    IF EXISTS (
        SELECT 1
        FROM internal.Flow
        WHERE TypeCode = @TypeCode
          AND StatusCode = @StatusCode
          AND FlowID != @FlowID
      )
    BEGIN
      EXEC dbo.Log 'ERROR', 'More than one flow in status [:1:]', @StatusCode;
      THROW 51000, 'More than one flow in status, status is not lockable.', 1;
    END
    -- ...and let it acquire the lock, if possible.
    EXEC internal.AcquireLock @FlowID, @RequiredLockCode;
  END
END

-- Update the status.
UPDATE internal.FlowStatus
SET RequiredLockCode = @RequiredLockCode
WHERE TypeCode = @TypeCode
  AND StatusCode = @StatusCode
;

-- Log if the status 
IF @@ROWCOUNT > 0
  EXEC dbo.Log 'INFO', 'Lock [:1:] now required by status [:2:.:3:]', @RequiredLockCode, @TypeCode, @StatusCode;
