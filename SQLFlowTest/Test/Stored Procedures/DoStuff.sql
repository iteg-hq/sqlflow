CREATE PROCEDURE dbo.DoStuff @FlowID INT
AS
EXEC [$(SQLFlow)].flow.Log 'INFO', 'Doing stuff';
;
