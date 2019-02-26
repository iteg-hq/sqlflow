CREATE VIEW flow.Lock
AS 
SELECT
    LockCode
  , ParentLockCode
  , HeldByFlowID
  , LockDepth
FROM flow_internals.Lock