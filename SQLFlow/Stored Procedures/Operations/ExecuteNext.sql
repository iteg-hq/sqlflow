CREATE PROCEDURE flow.ExecuteNext
    @ExecutionGroupCode NVARCHAR(100) = 'Ungrouped'
  , @ActionCode NVARCHAR(50) = 'Start'
  , @SortOrder INT = 1
AS
SET NOCOUNT, XACT_ABORT ON;
-- No logging, since this SP could be called very often.
DECLARE @FlowID INT;
DECLARE @RC INT;
-- Try getting the next FlowID.
EXEC @RC = internal.GetNext @FlowID OUTPUT, @ExecutionGroupCode, @ActionCode, @SortOrder
-- If we got one, execute it.
IF @RC = 0
BEGIN
  EXEC flow.StartExecution @FlowID;
  EXEC flow.Do @FlowID, @ActionCode;
  EXEC flow.StopExecution @FlowID;
END
RETURN @RC