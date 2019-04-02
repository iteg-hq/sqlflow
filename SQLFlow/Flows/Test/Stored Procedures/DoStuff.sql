CREATE PROCEDURE flow_test.DoStuff @FlowID INT
AS
EXEC [$(SQLFlow)].flow.Log 'INFO', 'Doing stuff';
;
