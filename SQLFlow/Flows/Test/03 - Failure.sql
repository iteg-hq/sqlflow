CREATE PROCEDURE flow_test.FailureSetup
AS
EXEC flow.AddType 'Test:Failure', @ExecutionGroupCode='System';

EXEC flow.DropActions 'Test:Failure';

EXEC flow.AddAction 'Test:Failure.New.Start', 'Running';
EXEC flow.AddAction 'Test:Failure.Running.Complete', 'Complete';
EXEC flow.AddAction 'Test:Failure.Running.Fail', 'Failed';
EXEC flow.AddAction 'Test:Failure.Failed.Start', 'Running';

EXEC flow.SetStatusProcedure 'Test:Failure.Running', '$(DatabaseName).flow_test.DoStuffButFailSometimes'

GO

CREATE PROCEDURE flow_test.Failure
AS
DECLARE @FlowID INT;
EXEC flow.NewFlow 'Test:Failure', @FlowID OUTPUT;
;
