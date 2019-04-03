CREATE PROCEDURE flow_test.TestSetup
AS
EXEC flow.AddType 'Test:TestFlow', @ExecutionGroupCode='System';

EXEC flow.DropActions 'Test:TestFlow';

EXEC flow.AddAction 'Test:TestFlow.New.Start', 'Running';
EXEC flow.AddAction 'Test:TestFlow.Running.Complete', 'Complete';
EXEC flow.AddAction 'Test:TestFlow.Running.Fail', 'Failed';
EXEC flow.AddAction 'Test:TestFlow.Failed.Rollback', 'RollbackRunning';
EXEC flow.AddAction 'Test:TestFlow.RollbackRunning.Complete', 'RollbackCompleted';
EXEC flow.AddAction 'Test:TestFlow.RollbackCompleted.Restart', 'Running';

EXEC flow.SetStatusProcedure 'Test:TestFlow.Running', '$(DatabaseName).flow_test.FailOnce'
EXEC flow.SetStatusProcedure 'Test:TestFlow.RollbackRunning', '$(DatabaseName).flow_test.RollStuffBack'

GO

CREATE PROCEDURE flow_test.Test
AS
DECLARE @FlowID INT;
EXEC flow.NewFlow 'Test:TestFlow', @FlowID OUTPUT;
;
