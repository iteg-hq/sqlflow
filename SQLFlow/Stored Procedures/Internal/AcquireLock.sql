CREATE PROCEDURE internal.AcquireLock
    @FlowID INT
  , @RootLockCode NVARCHAR(200)
AS
SET NOCOUNT, XACT_ABORT ON;
EXEC internal.UpdateContext @FlowID;
EXEC Log 'TRACE', 'AcquireLock [:1:], [:2:]', @FlowID, @RootLockCode;

-- Check if the lock is held by the 
IF EXISTS (
    SELECT 1
    FROM internal.Lock AS l
    WHERE LockCode = @RootLockCode
      AND HeldByFlowID = @FlowID
  )
BEGIN
  EXEC Log 'DEBUG', 'Lock [:1:] already held.', @RootLockCode, @@ROWCOUNT;
  RETURN
END
-- If not, try acquiring it.
BEGIN TRANSACTION
  CREATE TABLE #tree (LockCode NVARCHAR(200) PRIMARY KEY, LockLevel INT NOT NULL);
  -- Release any locks already held
  EXEC internal.ReleaseLock @FlowID;
  -- Root lock and children - if any one of these is held, the lock cannot be acquired

  DECLARE @UnavailableLockCode NVARCHAR(200);
  DECLARE @HeldBy INT;

  SELECT TOP 1
      @UnavailableLockCode = l.LockCode
    , @HeldBy = HeldByFlowID
  FROM internal.Lock AS l
  INNER JOIN internal.GetLockTree(@RootLockCode) AS t
    ON t.LockCode = l.LockCode
  WHERE HeldByFlowID != @FlowID
  ORDER BY t.LockLevel

  IF @UnavailableLockCode != ''
  BEGIN
    ROLLBACK TRANSACTION
    EXEC Log 'ERROR', 'Could not acquire lock [:1:], :2: is already held by :3:', @RootLockCode, @UnavailableLockCode, @HeldBy;
    THROW 51000, 'Could not acquire lock', 1;
  END

  UPDATE l
  SET HeldByFlowID = @FlowID
  FROM internal.Lock AS l
  INNER JOIN #tree AS t
    ON t.LockCode = l.LockCode

  EXEC Log 'DEBUG', 'Acquired lock [:1:] (and children, :2: in all)', @RootLockCode, @@ROWCOUNT;

COMMIT TRANSACTION
