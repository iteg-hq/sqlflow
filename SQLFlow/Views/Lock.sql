CREATE VIEW Lock
AS 
SELECT
    LockCode
  , ParentLockCode
  , HeldByFlowID
  , LockDepth
FROM internal.Lock
