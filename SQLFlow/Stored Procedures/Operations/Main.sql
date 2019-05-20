CREATE PROCEDURE flow.Main
    @ExecutionGroupCode NVARCHAR(100) = 'Ungrouped'
  , @ActionCode NVARCHAR(50) = 'Start'
  , @SortOrder INT = 1
AS
SET NOCOUNT, XACT_ABORT ON;

-- No logging to TRACE, since this SP is meant to be called very often.
DECLARE @FlowID INT;
DECLARE @StatusCode NVARCHAR(50);
  
EXEC flow_internals.UpdateContext @FlowID=NULL;
  
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

IF @FlowID IS NULL
  RETURN;

EXEC flow_internals.UpdateContext @FlowID;

UPDATE flow_internals.Flow
SET ExecutionStartedAt = SYSDATETIME()
WHERE FlowID = @FlowID
;

EXEC flow.Do @FlowID, @ActionCode;

-- Get and report the resulting status code
SELECT @StatusCode = StatusCode
FROM flow.Flow
WHERE FlowID = @FlowID
;

EXEC flow.Log 'INFO', 'Flow execution done. Final status: [:1:].', @StatusCode;

UPDATE flow_internals.Flow
SET ExecutionStoppedAt = SYSDATETIME()
WHERE FlowID = @FlowID
;

EXEC flow_internals.UpdateContext @FlowID=NULL;
