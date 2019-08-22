CREATE PROCEDURE flow_test.AsyncSetup
AS
EXEC flow.AddType 'Test:Async', @ExecutionGroupCode='System';

EXEC flow.DropActions 'Test:Async';

EXEC flow.AddAction 'Test:Async.New.Start', 'Running';
EXEC flow.AddAction 'Test:Async.Running.Complete', 'Complete';

-- Rollback
EXEC flow.AddAction 'Test:Async.Complete.Rollback', 'WaitingForRollback';
EXEC flow.AddAction 'Test:Async.WaitingForRollback.Start', 'RollingBack';
EXEC flow.AddAction 'Test:Async.RollingBack.Complete', 'RollbackCompleted';

-- Restart
EXEC flow.AddAction 'Test:Async.RollbackCompleted.Restart', 'Running';

EXEC flow.SetStatusProcedure 'Test:Async.Running', '$(DatabaseName).flow_test.DoStuff'
EXEC flow.SetStatusProcedure 'Test:Async.RollingBack', '$(DatabaseName).flow_test.RollStuffBack'

GO

CREATE PROCEDURE flow_test.Async
AS
-- Create the flow - the 
DECLARE @FlowID INT;
EXEC flow.NewFlow 'Test:Async', @FlowID OUTPUT;
