CREATE VIEW dbo.Lock
AS 
SELECT
    LockCode
  , ParentLockCode
  , HeldByFlowID
  , LockLevel
FROM internal.Lock
