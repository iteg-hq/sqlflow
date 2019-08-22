CREATE PROCEDURE flow_test.DoStuff @FlowID INT
AS
EXEC dbo.Log 'INFO', 'Doing stuff';
;
