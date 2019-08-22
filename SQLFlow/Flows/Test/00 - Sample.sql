CREATE PROCEDURE flow_test.TestSetup
AS
EXEC AddType 'Test:TestFlow', @ExecutionGroupCode='System';

EXEC DropActions 'Test:TestFlow';

EXEC AddAction 'Test:TestFlow.New.Start', 'Running';
EXEC AddAction 'Test:TestFlow.Running.Complete', 'Complete';
EXEC AddAction 'Test:TestFlow.Running.Fail', 'Failed';
EXEC AddAction 'Test:TestFlow.Failed.Rollback', 'RollbackRunning';
EXEC AddAction 'Test:TestFlow.RollbackRunning.Complete', 'RollbackCompleted';
EXEC AddAction 'Test:TestFlow.RollbackCompleted.Restart', 'Running';

EXEC SetStatusProcedure 'Test:TestFlow.Running', '$(DatabaseName).flow_test.FailOnce'
EXEC SetStatusProcedure 'Test:TestFlow.RollbackRunning', '$(DatabaseName).flow_test.RollStuffBack'

GO

CREATE PROCEDURE flow_test.Test
AS
DECLARE @FlowID INT;
EXEC NewFlow 'Test:TestFlow', @FlowID OUTPUT;
;
