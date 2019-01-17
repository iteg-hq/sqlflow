CREATE PROCEDURE internals.AcquireLock
    @FlowID INT
  , @RootLockCode NVARCHAR(200)
AS
BEGIN TRANSACTION
  CREATE TABLE #tree (LockCode NVARCHAR(200) PRIMARY KEY, LockLevel INT NOT NULL);

  EXEC internals.ReleaseLock @FlowID;

  ;WITH tree AS (
      SELECT LockCode, 0 AS LockLevel
      FROM flow.Lock
      WITH (TABLOCKX, HOLDLOCK)
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

  DECLARE @UnavailableLockCode NVARCHAR(200)

  SELECT TOP 1 @UnavailableLockCode = l.LockCode
  FROM flow.Lock AS l
  INNER JOIN #tree AS t
    ON t.LockCode = l.LockCode
  WHERE HeldByFlowID != @FlowID
  ORDER BY t.LockLevel

  IF @UnavailableLockCode != ''
  BEGIN
    ROLLBACK TRANSACTION
    EXEC flow.Log 'ERROR', 'Could not acquire lock :1:, :2: is already held', @RootLockCode, @UnavailableLockCode;
    THROW 51000, 'Could not acquire lock', 1;
  END

  UPDATE l
  SET HeldByFlowID = @FlowID
  FROM internals.Lock AS l
  INNER JOIN #tree AS t
    ON t.LockCode = l.LockCode

  EXEC flow.Log 'DEBUG', 'Acquired lock :1: (and children, :2: in all)', @RootLockCode, @@ROWCOUNT;

COMMIT TRANSACTION
