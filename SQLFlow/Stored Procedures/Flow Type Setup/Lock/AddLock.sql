CREATE PROCEDURE dbo.AddLock
    @LockCode NVARCHAR(50)
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC dbo.Log 'TRACE', 'AddLock [:1:]', @LockCode;

IF @LockCode IN ( SELECT LockCode FROM internal.Lock ) RETURN;

DECLARE @ParentLockCode NVARCHAR(200) = internal.GetParent(@LockCode);

IF @ParentLockCode IS NULL 
BEGIN
  -- If the lock has no parent, insert it
  INSERT INTO internal.Lock (
      LockCode
    , ParentLockCode 
    , LockLevel
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
  IF NOT EXISTS ( SELECT LockCode FROM dbo.Lock WHERE LockCode = @ParentLockCode)
    EXEC dbo.AddLock @ParentLockCode;

  -- Finally, create the child lock.
  INSERT INTO internal.Lock (
      LockCode
    , ParentLockCode 
    , LockLevel
    , HeldByFlowID
    )
  SELECT
      @LockCode
    , LockCode
    , LockLevel+1
    , HeldByFlowID
  FROM dbo.Lock
  WHERE LockCode = @ParentLockCode
  ;
END

EXEC dbo.Log 'INFO', 'Added lock [:1:]', @LockCode;
