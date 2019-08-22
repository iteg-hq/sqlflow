CREATE PROCEDURE flow_test.AsyncSetup
AS
EXEC dbo.AddType 'Test:Async', @ExecutionGroupCode='System';

EXEC dbo.DropActions 'Test:Async';

EXEC dbo.AddAction 'Test:Async.New.Start', 'Running';
EXEC dbo.AddAction 'Test:Async.Running.Complete', 'Complete';

-- Rollback
EXEC dbo.AddAction 'Test:Async.Complete.Rollback', 'WaitingForRollback';
EXEC dbo.AddAction 'Test:Async.WaitingForRollback.Start', 'RollingBack';
EXEC dbo.AddAction 'Test:Async.RollingBack.Complete', 'RollbackCompleted';

-- Restart
EXEC dbo.AddAction 'Test:Async.RollbackCompleted.Restart', 'Running';

EXEC dbo.SetStatusProcedure 'Test:Async.Running', '$(DatabaseName).flow_test.DoStuff'
EXEC dbo.SetStatusProcedure 'Test:Async.RollingBack', '$(DatabaseName).flow_test.RollStuffBack'

GO

CREATE PROCEDURE flow_test.Async
AS
-- Create the flow - the 
DECLARE @FlowID INT;
EXEC dbo.NewFlow 'Test:Async', @FlowID OUTPUT;
