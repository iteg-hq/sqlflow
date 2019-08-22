CREATE PROCEDURE flow_test.FailOnce @FlowID INT
AS
EXEC flow_test.DoStuff @FlowID;

IF flow.GetParameterValue(@FlowID, 'Failed') = 'True'
  RETURN
EXEC flow.SetParameterValue @FlowID, 'Failed', 'True';
DECLARE @DivisionByZero INT = 1/0;

