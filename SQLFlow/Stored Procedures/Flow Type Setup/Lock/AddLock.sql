CREATE PROCEDURE flow.AddLock
    @LockCode NVARCHAR(50)
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC flow.Log 'TRACE', 'AddLock [:1:]', @LockCode;

IF @LockCode IN ( SELECT LockCode FROM internal.Lock ) RETURN;

DECLARE @ParentLockCode NVARCHAR(200) = internal.GetParent(@LockCode);

IF @ParentLockCode IS NULL 
BEGIN
  -- If the lock has no parent, insert it
  INSERT INTO internal.Lock (
      LockCode
    , ParentLockCode 
    , LockDepth
    )
  VALUES (
      @LockCode
    , NULL
    , 0
    )
END
ELSE
BEGIN
  -- If the parent doesn't exists, create it.
  IF NOT EXISTS ( SELECT LockCode FROM flow.Lock WHERE LockCode = @ParentLockCode)
    EXEC flow.AddLock @ParentLockCode;

  -- Finally, create the child lock.
  INSERT INTO internal.Lock (
      LockCode
    , ParentLockCode 
    , LockDepth
    , HeldByFlowID
    )
  SELECT
      @LockCode
    , LockCode
    , LockDepth+1
    , HeldByFlowID
  FROM flow.Lock
  WHERE LockCode = @ParentLockCode
  ;
END

EXEC flow.Log 'INFO', 'Added lock [:1:]', @LockCode;
