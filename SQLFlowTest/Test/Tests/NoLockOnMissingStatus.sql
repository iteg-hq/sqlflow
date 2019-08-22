CREATE PROCEDURE test.NoLockOnMissingStatus
AS
EXEC [$(SQLFlow)].flow.AddType 'NoLockOnMissingStatus';
BEGIN TRY
  EXEC [$(SQLFlow)].flow.SetStatusLock 'NoLockOnMissingStatus', 'BadStatus', 'BadLock';
END TRY
BEGIN CATCH
  RETURN 1
END CATCH
RETURN 0;
