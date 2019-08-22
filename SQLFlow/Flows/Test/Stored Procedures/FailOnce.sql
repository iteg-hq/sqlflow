CREATE PROCEDURE flow_test.FailOnce @FlowID INT
AS
EXEC flow_test.DoStuff @FlowID;

IF GetParameterValue(@FlowID, 'Failed') = 'True'
  RETURN
EXEC SetParameterValue @FlowID, 'Failed', 'True';
DECLARE @DivisionByZero INT = 1/0;

