CREATE PROCEDURE Main
    @ExecutionGroupCode NVARCHAR(100) = 'Ungrouped'
  , @ActionCode NVARCHAR(50) = 'Start'
  , @SortOrder INT = 1
AS
SET NOCOUNT, XACT_ABORT ON;
-- (No logging, since this SP could be called very often)
-- Execute next, and keep going until
DECLARE @RC INT;
EXEC @RC = ExecuteNext @ExecutionGroupCode, @ActionCode, @SortOrder
WHILE @RC = 0
  EXEC @RC = ExecuteNext @ExecutionGroupCode, @ActionCode, @SortOrder
