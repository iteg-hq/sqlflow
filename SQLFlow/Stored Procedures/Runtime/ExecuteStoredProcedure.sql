CREATE PROCEDURE flow.ExecuteStoredProcedure
    @FlowID INT
  , @StoredProcedureName NVARCHAR(255)
AS
SET NOCOUNT, XACT_ABORT ON;
/* Execute a named stored procedure, passing the FlowID as the first
 * argument and making sure any errors are logged and rethrown. 
 * Non-zero return codes are promoted to exceptions.
 */

DECLARE @Status INT;
DECLARE @ErrorCode INT;
DECLARE @Message NVARCHAR(4000);
EXEC flow.Log 'TRACE', 'flow.ExecuteStoredProcedure [:1:], [:2:]', @FlowID, @StoredProcedureName;

BEGIN TRY
  -- Call the procedure and capture the error code
  EXEC @ErrorCode = @StoredProcedureName @FlowID = @FlowID
  IF @ErrorCode <> 0
  BEGIN
    EXEC flow.Log 'ERROR', 'Stored procedure returned non-zero';
    THROW 51000, 'Stored procedure returned non-zero', 1;
  END
END TRY
BEGIN CATCH
  EXEC sp_set_session_context N'ExecutionID', NULL;
  -- Save error message components for after rollback
  DECLARE @ErrorNumber INT = ERROR_NUMBER();
  DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
  DECLARE @ErrorState INT = ERROR_STATE();
  DECLARE @ErrorProcedure NVARCHAR(255) = ERROR_PROCEDURE();
  DECLARE @ErrorLine INT = ERROR_LINE();
  DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
  IF @@TRANCOUNT > 0
  BEGIN
    ROLLBACK TRAN;
    EXEC flow.Log 'WARN', 'Rolled back transaction, @@TRANCOUNT is :1:', @@TRANCOUNT
  END
  EXEC flow.Log 'ERROR', ':1:', @ErrorMessage;
  THROW
END CATCH
