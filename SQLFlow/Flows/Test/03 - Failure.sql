CREATE PROCEDURE flow_test.FailureSetup
AS
EXEC AddType 'Test:Failure', @ExecutionGroupCode='System';

EXEC DropActions 'Test:Failure';

EXEC AddAction 'Test:Failure.New.Start', 'Running';
EXEC AddAction 'Test:Failure.Running.Complete', 'Complete';
EXEC AddAction 'Test:Failure.Running.Fail', 'Failed';
EXEC AddAction 'Test:Failure.Failed.Start', 'Running';

EXEC SetStatusProcedure 'Test:Failure.Running', '$(DatabaseName).flow_test.DoStuffButFailSometimes'

GO

CREATE PROCEDURE flow_test.Failure
AS
DECLARE @FlowID INT;
EXEC NewFlow 'Test:Failure', @FlowID OUTPUT;
;
