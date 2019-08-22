CREATE VIEW flow.Lock
AS 
SELECT
    LockCode
  , ParentLockCode
  , HeldByFlowID
  , LockDepth
FROM internal.Lock
