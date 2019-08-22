CREATE PROCEDURE flow_test.DoStuff @FlowID INT
AS
EXEC flow.Log 'INFO', 'Doing stuff';
;
