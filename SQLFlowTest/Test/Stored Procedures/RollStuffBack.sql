CREATE PROCEDURE flow_test.RollStuffBack @FlowID INT
AS
EXEC [$(SQLFlow)].flow.Log 'INFO', 'Rolling stuff back';
