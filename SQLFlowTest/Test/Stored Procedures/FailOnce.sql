CREATE PROCEDURE flow_test.FailOnce @FlowID INT
AS
EXEC flow_test.DoStuff @FlowID;

IF [$(SQLFlow)].flow.GetParameterValue(@FlowID, 'Failed') = 'True'
  RETURN
EXEC [$(SQLFlow)].flow.SetParameterValue @FlowID, 'Failed', 'True';
DECLARE @DivisionByZero INT = 1/0;

