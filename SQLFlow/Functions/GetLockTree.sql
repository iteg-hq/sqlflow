CREATE FUNCTION internal.GetLockTree (@RootLockCode NVARCHAR(50))
RETURNS TABLE
AS
RETURN
WITH parent AS (
  SELECT LockCode
  FROM internal.Lock
  --WITH (TABLOCKX, HOLDLOCK)
  WHERE LockCode = @RootLockCode
  UNION ALL
  SELECT child.LockCode
  FROM internal.Lock AS child
  INNER JOIN parent
    ON parent.LockCode = child.ParentLockCode
  )
SELECT LockCode
FROM parent
;