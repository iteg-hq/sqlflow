CREATE PROCEDURE flow_test.SimpleSetup
AS
EXEC flow.AddType 'Test:Simple';

EXEC flow.DropActions 'Test:Simple';

EXEC flow.AddAction 'Test:Simple.New.Start', 'Running';
EXEC flow.AddAction 'Test:Simple.Running.Complete', 'Complete';
EXEC flow.SetStatusProcedure 'Test:Simple.Running', '$(DatabaseName).flow_test.DoStuff'

GO

CREATE PROCEDURE flow_test.Simple
AS
DECLARE @FlowID INT;
-- Create a flow and start it yourself.
-- [DoStuffAndComplete] will start immediately, running as you.
-- It will do stuff and then complete the flow.
EXEC flow.NewFlow 'Test:Simple', @FlowID OUTPUT;
EXEC flow.Do @FlowID, 'Start';
