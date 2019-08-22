CREATE PROCEDURE flow_test.FailOnce @FlowID INT
AS
EXEC flow_test.DoStuff @FlowID;

IF dbo.GetParameterValue(@FlowID, 'Failed') = 'True'
  RETURN
EXEC dbo.SetParameterValue @FlowID, 'Failed', 'True';
DECLARE @DivisionByZero INT = 1/0;

