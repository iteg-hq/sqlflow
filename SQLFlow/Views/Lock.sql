CREATE VIEW flow.Lock
AS 
SELECT
    LockCode
  , ParentLockCode
  , HeldByFlowID
  , LockDepth
FROM internals.Lock