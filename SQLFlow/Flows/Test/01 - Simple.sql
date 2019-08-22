CREATE PROCEDURE flow_test.SimpleSetup
AS
EXEC dbo.AddType 'Test:Simple';

EXEC dbo.DropActions 'Test:Simple';

EXEC dbo.AddAction 'Test:Simple.New.Start', 'Running';
EXEC dbo.AddAction 'Test:Simple.Running.Complete', 'Complete';
EXEC dbo.SetStatusProcedure 'Test:Simple.Running', '$(DatabaseName).flow_test.DoStuff'

GO

CREATE PROCEDURE flow_test.Simple
AS
DECLARE @FlowID INT;
-- Create a flow and start it yourself.
-- [DoStuffAndComplete] will start immediately, running as you.
-- It will do stuff and then complete the dbo.
EXEC dbo.NewFlow 'Test:Simple', @FlowID OUTPUT;
EXEC dbo.Do @FlowID, 'Start';
