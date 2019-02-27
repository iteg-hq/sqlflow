CREATE PROCEDURE flow_test.AsyncSetup
AS
EXEC [$(SQLFlow)].flow.AddType 'Test:Async', @ExecutionGroupCode='System';

EXEC [$(SQLFlow)].flow.DropActions 'Test:Async';

EXEC [$(SQLFlow)].flow.AddAction 'Test:Async.New.Start', 'Running';
EXEC [$(SQLFlow)].flow.AddAction 'Test:Async.Running.Complete', 'Complete';

-- Rollback
EXEC [$(SQLFlow)].flow.AddAction 'Test:Async.Complete.Rollback', 'WaitingForRollback';
EXEC [$(SQLFlow)].flow.AddAction 'Test:Async.WaitingForRollback.Start', 'RollingBack';
EXEC [$(SQLFlow)].flow.AddAction 'Test:Async.RollingBack.Complete', 'RollbackCompleted';

-- Restart
EXEC [$(SQLFlow)].flow.AddAction 'Test:Async.RollbackCompleted.Restart', 'Running';

EXEC [$(SQLFlow)].flow.SetStatusProcedure 'Test:Async.Running', '$(DatabaseName).flow_test.DoStuff'
EXEC [$(SQLFlow)].flow.SetStatusProcedure 'Test:Async.RollingBack', '$(DatabaseName).flow_test.RollStuffBack'

GO

CREATE PROCEDURE flow_test.Async
AS
-- Create the flow - the 
DECLARE @FlowID INT;
EXEC [$(SQLFlow)].flow.NewFlow 'Test:Async', @FlowID OUTPUT;
