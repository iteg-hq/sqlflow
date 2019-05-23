CREATE PROCEDURE flow.Main
    @ExecutionGroupCode NVARCHAR(100) = 'Ungrouped'
  , @ActionCode NVARCHAR(50) = 'Start'
  , @SortOrder INT = 1
AS
SET NOCOUNT, XACT_ABORT ON;
-- No logging, since this SP could be called very often.
DECLARE @FlowID INT;
DECLARE @Done INT;
EXEC @Done = flow_internals.GetNext @FlowID OUTPUT, @ExecutionGroupCode, @ActionCode, @SortOrder
WHILE @Done = 0
BEGIN
  EXEC flow.StartExecution @FlowID;
  EXEC flow.Do @FlowID, @ActionCode;
  EXEC flow.StopExecution @FlowID;

  EXEC @Done = flow_internals.GetNext @FlowID OUTPUT, @ExecutionGroupCode, @ActionCode, @SortOrder
END
