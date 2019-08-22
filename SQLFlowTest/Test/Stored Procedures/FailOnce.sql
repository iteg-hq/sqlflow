CREATE PROCEDURE dbo.FailOnce @FlowID INT
AS
EXEC dbo.DoStuff @FlowID;

IF [$(SQLFlow)].flow.GetParameterValue(@FlowID, 'Failed') = 'True'
  RETURN
EXEC [$(SQLFlow)].flow.SetParameterValue @FlowID, 'Failed', 'True';
DECLARE @DivisionByZero INT = 1/0;

