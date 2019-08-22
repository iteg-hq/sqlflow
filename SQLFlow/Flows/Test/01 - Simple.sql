CREATE PROCEDURE flow_test.SimpleSetup
AS
EXEC AddType 'Test:Simple';

EXEC DropActions 'Test:Simple';

EXEC AddAction 'Test:Simple.New.Start', 'Running';
EXEC AddAction 'Test:Simple.Running.Complete', 'Complete';
EXEC SetStatusProcedure 'Test:Simple.Running', '$(DatabaseName).flow_test.DoStuff'

GO

CREATE PROCEDURE flow_test.Simple
AS
DECLARE @FlowID INT;
-- Create a flow and start it yourself.
-- [DoStuffAndComplete] will start immediately, running as you.
-- It will do stuff and then complete the 
EXEC NewFlow 'Test:Simple', @FlowID OUTPUT;
EXEC Do @FlowID, 'Start';
