CREATE PROCEDURE flow_test.DoStuffAndComplete @FlowID INT
AS
EXEC flow_test.DoStuff @FlowID;
EXEC [$(SQLFlow)].flow.Do @FlowID, 'Complete'
;
