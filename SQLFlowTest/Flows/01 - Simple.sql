CREATE PROCEDURE flow_test.SimpleSetup
AS
EXEC [$(SQLFlow)].flow.AddType 'Test:Simple';

EXEC [$(SQLFlow)].flow.DropActions 'Test:Simple';

EXEC [$(SQLFlow)].flow.AddAction 'Test:Simple.New.Start', 'Running';
EXEC [$(SQLFlow)].flow.AddAction 'Test:Simple.Running.Complete', 'Complete';
EXEC [$(SQLFlow)].flow.SetStatusProcedure 'Test:Simple.Running', '$(DatabaseName).flow_test.DoStuffAndComplete'

GO

CREATE PROCEDURE flow_test.Simple
AS
DECLARE @FlowID INT;
-- Create a flow and start it yourself.
-- [DoStuffAndComplete] will start immediately, running as you.
-- It will do stuff and then complete the flow.
EXEC [$(SQLFlow)].flow.NewFlow 'Test:Simple', @FlowID OUTPUT;
EXEC [$(SQLFlow)].flow.Do @FlowID, 'Start';
