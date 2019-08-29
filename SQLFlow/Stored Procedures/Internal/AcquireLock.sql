CREATE PROCEDURE flow_internals.AcquireLock
    @FlowID INT
  , @RootLockCode NVARCHAR(200)
AS
SET NOCOUNT, XACT_ABORT ON;
EXEC flow_internals.UpdateContext @FlowID;
EXEC flow.Log 'TRACE', 'AcquireLock [:1:], [:2:]', @FlowID, @RootLockCode;

-- Check if the lock is held by the flow.
IF EXISTS (
    SELECT 1
    FROM flow_internals.Lock AS l
    WHERE LockCode = @RootLockCode
      AND HeldByFlowID = @FlowID
  )
BEGIN
  EXEC flow.Log 'TRACE', 'Lock [:1:] already held.', @RootLockCode, @@ROWCOUNT;
  RETURN
END
-- If not, try acquiring it.
BEGIN TRANSACTION
  CREATE TABLE #tree (LockCode NVARCHAR(200) PRIMARY KEY, LockLevel INT NOT NULL);

  EXEC flow_internals.ReleaseLock @FlowID;
  -- Root lock and children - if any one of these is held, the lock cannot be acquired
  ;WITH tree AS (
      SELECT LockCode, 0 AS LockLevel
      FROM flow.Lock
      WITH (TABLOCKX, HOLDLOCK) -- Locks the lock table
      WHERE LockCode = @RootLockCode
      UNION ALL
      SELECT child.LockCode, tree.LockLevel+1
      FROM flow.Lock AS child
      INNER JOIN tree
        ON tree.LockCode = child.ParentLockCode
    )
  INSERT INTO #tree (LockCode, LockLevel)
  SELECT LockCode, LockLevel
  FROM tree

  DECLARE @UnavailableLockCode NVARCHAR(200);
  DECLARE @HeldBy INT;

  SELECT TOP 1
      @UnavailableLockCode = l.LockCode
    , @HeldBy = HeldByFlowID
  FROM flow.Lock AS l
  INNER JOIN #tree AS t
    ON t.LockCode = l.LockCode
  WHERE HeldByFlowID != @FlowID
  ORDER BY t.LockLevel

  IF @UnavailableLockCode != ''
  BEGIN
    ROLLBACK TRANSACTION
    EXEC flow.Log 'ERROR', 'Could not acquire lock [:1:], :2: is already held by :3:', @RootLockCode, @UnavailableLockCode, @HeldBy;
    THROW 51000, 'Could not acquire lock', 1;
  END

  UPDATE l
  SET HeldByFlowID = @FlowID
  FROM flow_internals.Lock AS l
  INNER JOIN #tree AS t
    ON t.LockCode = l.LockCode

  EXEC flow.Log 'TRACE', 'Acquired lock [:1:] (and children, :2: in all)', @RootLockCode, @@ROWCOUNT;

COMMIT TRANSACTION
