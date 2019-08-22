CREATE PROCEDURE flow_test.TestSetup
AS
EXEC dbo.AddType 'Test:TestFlow', @ExecutionGroupCode='System';

EXEC dbo.DropActions 'Test:TestFlow';

EXEC dbo.AddAction 'Test:TestFlow.New.Start', 'Running';
EXEC dbo.AddAction 'Test:TestFlow.Running.Complete', 'Complete';
EXEC dbo.AddAction 'Test:TestFlow.Running.Fail', 'Failed';
EXEC dbo.AddAction 'Test:TestFlow.Failed.Rollback', 'RollbackRunning';
EXEC dbo.AddAction 'Test:TestFlow.RollbackRunning.Complete', 'RollbackCompleted';
EXEC dbo.AddAction 'Test:TestFlow.RollbackCompleted.Restart', 'Running';

EXEC dbo.SetStatusProcedure 'Test:TestFlow.Running', '$(DatabaseName).flow_test.FailOnce'
EXEC dbo.SetStatusProcedure 'Test:TestFlow.RollbackRunning', '$(DatabaseName).flow_test.RollStuffBack'

GO

CREATE PROCEDURE flow_test.Test
AS
DECLARE @FlowID INT;
EXEC dbo.NewFlow 'Test:TestFlow', @FlowID OUTPUT;
;
