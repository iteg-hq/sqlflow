CREATE PROCEDURE test.NoLockOnMissingFlowType
AS
BEGIN TRY
  EXEC [$(SQLFlow)].flow.SetStatusLock 'BadFlowType', 'BadStatus', 'BadLock';
END TRY
BEGIN CATCH
  RETURN 1
END CATCH
RETURN 0;
