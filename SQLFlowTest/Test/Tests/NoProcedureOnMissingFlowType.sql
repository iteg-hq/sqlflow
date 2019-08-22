CREATE PROCEDURE test.NoProcedureOnMissingFlowType
AS
BEGIN TRY
  EXEC [$(SQLFlow)].flow.SetStatusProcedure 'BadFlowType', 'BadStatus', 'BadProcedure';
END TRY
BEGIN CATCH
  RETURN 1
END CATCH
RETURN 0;
