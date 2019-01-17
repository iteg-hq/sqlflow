CREATE PROCEDURE flow.Main
    @ExecutionGroupCode NVARCHAR(100) = 'Ungrouped'
  , @ActionCode NVARCHAR(50) = 'Start'
  , @SortOrder INT = 1
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;

  DECLARE @FlowID INT;
  EXEC internals.ReleaseFlow;
  
  -- Get the next Flow to run for this Execution Group
  SELECT TOP 1 @FlowID = FlowID
  FROM flow.FlowAction AS a
  WHERE a.ExecutionGroupCode = @ExecutionGroupCode
    AND a.ActionCode = @ActionCode
    AND NOT EXISTS (
      -- The lock the action requires, and all implied (child) locks.
      SELECT LockCode
      FROM internals.GetLockTree(a.RequiredLockCode)
      INTERSECT
      -- All currently (and all implicitly) locks held by other Flows.
      SELECT LockCode
      FROM flow.AcquiredLock
      WHERE FlowID != a.FlowID
    )
  ORDER BY a.FlowID * @SortOrder
  ;

  IF @FlowID IS NULL
  BEGIN
    RETURN;
  END

  -- Put the FlowID in the Session Context, reset the Item Number
  EXEC internals.GrabFlow @FlowID;

  UPDATE internals.Flow SET SessionID = NULL WHERE SessionID = @@SPID;
  UPDATE internals.Flow SET SessionID = @@SPID WHERE FlowID = @FlowID;
  ;

  -- Start the flow
  EXEC flow.Do @FlowID, @ActionCode;

  DECLARE @StatusCode NVARCHAR(50);

  SELECT @StatusCode = StatusCode
  FROM flow.Flow
  WHERE FlowID = @FlowID
  ;

  EXEC flow.Log 'INFO', 'Flow execution done. Final status: [:1:].', @StatusCode;

  EXEC internals.ReleaseFlow;

  UPDATE internals.Flow
  SET SessionID = NULL
  WHERE FlowID = @FlowID
  ;
END
