CREATE PROCEDURE test.NoProcedureOnMissingStatus
AS
EXEC [$(SQLFlow)].flow.AddType 'NoProcedureOnMissingStatus';
BEGIN TRY
  EXEC [$(SQLFlow)].flow.SetStatusProcedure 'NoProcedureOnMissingStatus', 'BadStatus', 'BadLock';
END TRY
BEGIN CATCH
  RETURN 1
END CATCH
RETURN 0;
