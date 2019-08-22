CREATE PROCEDURE test.InvalidActionFails
AS
EXEC [$(SQLFlow)].flow.AddType 'InvalidActionFails';
DECLARE @FlowID INT;
EXEC [$(SQLFlow)].flow.NewFlow 'InvalidActionFails', @FlowID OUTPUT;
BEGIN TRY
  EXEC [$(SQLFlow)].flow.Do @FlowID, 'Start';
END TRY
BEGIN CATCH
  RETURN 1
END CATCH
RETURN 0;
