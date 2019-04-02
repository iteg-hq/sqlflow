CREATE PROCEDURE flow_test.TestSetup
AS
EXEC [$(SQLFlow)].flow.AddType 'Test:TestFlow', @ExecutionGroupCode='System';

EXEC [$(SQLFlow)].flow.DropActions 'Test:TestFlow';

EXEC [$(SQLFlow)].flow.AddAction 'Test:TestFlow.New.Start', 'Running';
EXEC [$(SQLFlow)].flow.AddAction 'Test:TestFlow.Running.Complete', 'Complete';
EXEC [$(SQLFlow)].flow.AddAction 'Test:TestFlow.Running.Fail', 'Failed';
EXEC [$(SQLFlow)].flow.AddAction 'Test:TestFlow.Failed.Rollback', 'RollbackRunning';
EXEC [$(SQLFlow)].flow.AddAction 'Test:TestFlow.RollbackRunning.Complete', 'RollbackCompleted';
EXEC [$(SQLFlow)].flow.AddAction 'Test:TestFlow.RollbackCompleted.Restart', 'Running';

EXEC [$(SQLFlow)].flow.SetStatusProcedure 'Test:TestFlow.Running', '$(DatabaseName).flow_test.FailOnce'
EXEC [$(SQLFlow)].flow.SetStatusProcedure 'Test:TestFlow.RollbackRunning', '$(DatabaseName).flow_test.RollStuffBack'

GO

CREATE PROCEDURE flow_test.Test
AS
DECLARE @FlowID INT;
EXEC [$(SQLFlow)].flow.NewFlow 'Test:TestFlow', @FlowID OUTPUT;
;
