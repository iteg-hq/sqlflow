CREATE PROCEDURE flow_test.AsyncSetup
AS
EXEC AddType 'Test:Async', @ExecutionGroupCode='System';

EXEC DropActions 'Test:Async';

EXEC AddAction 'Test:Async.New.Start', 'Running';
EXEC AddAction 'Test:Async.Running.Complete', 'Complete';

-- Rollback
EXEC AddAction 'Test:Async.Complete.Rollback', 'WaitingForRollback';
EXEC AddAction 'Test:Async.WaitingForRollback.Start', 'RollingBack';
EXEC AddAction 'Test:Async.RollingBack.Complete', 'RollbackCompleted';

-- Restart
EXEC AddAction 'Test:Async.RollbackCompleted.Restart', 'Running';

EXEC SetStatusProcedure 'Test:Async.Running', '$(DatabaseName).flow_test.DoStuff'
EXEC SetStatusProcedure 'Test:Async.RollingBack', '$(DatabaseName).flow_test.RollStuffBack'

GO

CREATE PROCEDURE flow_test.Async
AS
-- Create the flow - the 
DECLARE @FlowID INT;
EXEC NewFlow 'Test:Async', @FlowID OUTPUT;
