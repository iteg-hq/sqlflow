CREATE PROCEDURE test.ExecutionGroupDefault
AS
EXEC [$(SQLFlow)].flow.AddType 'ExecutionGroupDefault';
IF EXISTS (
    SELECT 1
    FROM [$(SQLFlow)].flow.FlowType
    WHERE TypeCode = 'ExecutionGroupDefault'
      AND ExecutionGroupCode = 'Ungrouped'
  )
  RETURN 1
RETURN 0
  