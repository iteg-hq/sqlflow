CREATE PROCEDURE test.DefaultExecutionGroup
AS
EXEC [$(SQLFlow)].flow.AddType 'DefaultInitialStatus';
IF EXISTS (
    SELECT 1
    FROM [$(SQLFlow)].flow.FlowType
    WHERE TypeCode = 'DefaultInitialStatus'
      AND InitialStatusCode = 'New'
  )
  RETURN 1
RETURN 0
  