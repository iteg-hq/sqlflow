CREATE VIEW flow.Lock
AS 
SELECT
    LockCode
  , ParentLockCode
  , HeldByFlowID
  , LockLevel
FROM internal.Lock
