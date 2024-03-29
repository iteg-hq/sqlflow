CREATE FUNCTION flow_internals.GetLockTree (@RootLockCode NVARCHAR(50))
RETURNS TABLE
AS
RETURN
WITH parent AS (
  SELECT LockCode, 0 AS LockLevel
  FROM flow_internals.Lock
  --WITH (TABLOCKX, HOLDLOCK)
  WHERE LockCode = @RootLockCode
  UNION ALL
  SELECT child.LockCode, parent.LockLevel+1
  FROM flow_internals.Lock AS child
  INNER JOIN parent
    ON parent.LockCode = child.ParentLockCode
  )
SELECT LockCode
FROM parent
;