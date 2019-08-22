CREATE PROCEDURE flow_test.FailureSetup
AS
EXEC dbo.AddType 'Test:Failure', @ExecutionGroupCode='System';

EXEC dbo.DropActions 'Test:Failure';

EXEC dbo.AddAction 'Test:Failure.New.Start', 'Running';
EXEC dbo.AddAction 'Test:Failure.Running.Complete', 'Complete';
EXEC dbo.AddAction 'Test:Failure.Running.Fail', 'Failed';
EXEC dbo.AddAction 'Test:Failure.Failed.Start', 'Running';

EXEC dbo.SetStatusProcedure 'Test:Failure.Running', '$(DatabaseName).flow_test.DoStuffButFailSometimes'

GO

CREATE PROCEDURE flow_test.Failure
AS
DECLARE @FlowID INT;
EXEC dbo.NewFlow 'Test:Failure', @FlowID OUTPUT;
;
