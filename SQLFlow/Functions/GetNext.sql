CREATE PROCEDURE flow_internals.GetNext
    @FlowID INT OUTPUT
  , @ExecutionGroupCode NVARCHAR(100) = 'Ungrouped'
  , @ActionCode NVARCHAR(50) = 'Start'
  , @SortOrder INT = 1
AS
SET @FlowID = NULL;

-- Get the next action to run for this Execution Group where all required locks are available.
SELECT TOP 1 @FlowID = FlowID
FROM flow.FlowAction AS a
WHERE a.ExecutionGroupCode = @ExecutionGroupCode
  AND a.ActionCode = @ActionCode
  AND NOT EXISTS (
    -- The lock that the action requires, and all implied (child) locks.
    SELECT LockCode
    FROM flow_internals.GetLockTree(a.RequiredLockCode)
    INTERSECT
    -- All currently (and all implicitly) locks held by other Flows.
    SELECT LockCode
    FROM flow.AcquiredLock
    WHERE FlowID != a.FlowID
  )
ORDER BY a.FlowID * @SortOrder
;

IF @FlowID IS NULL RETURN 1
ELSE RETURN 0
