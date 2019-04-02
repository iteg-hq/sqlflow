CREATE PROCEDURE flow_test.FailureSetup
AS
EXEC [$(SQLFlow)].flow.AddType 'Test:Failure', @ExecutionGroupCode='System';

EXEC [$(SQLFlow)].flow.DropActions 'Test:Failure';

EXEC [$(SQLFlow)].flow.AddAction 'Test:Failure.New.Start', 'Running';
EXEC [$(SQLFlow)].flow.AddAction 'Test:Failure.Running.Complete', 'Complete';
EXEC [$(SQLFlow)].flow.AddAction 'Test:Failure.Running.Fail', 'Failed';
EXEC [$(SQLFlow)].flow.AddAction 'Test:Failure.Failed.Start', 'Running';

EXEC [$(SQLFlow)].flow.SetStatusProcedure 'Test:Failure.Running', '$(DatabaseName).flow_test.DoStuffButFailSometimes'

GO

CREATE PROCEDURE flow_test.Failure
AS
DECLARE @FlowID INT;
EXEC [$(SQLFlow)].flow.NewFlow 'Test:Failure', @FlowID OUTPUT;
;
