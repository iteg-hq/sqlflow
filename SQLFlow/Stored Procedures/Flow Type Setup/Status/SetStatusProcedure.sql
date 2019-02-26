CREATE PROCEDURE flow.SetStatusProcedure
    @StatusCode NVARCHAR(50)
  , @ProcedureName NVARCHAR(255)
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC flow.Log 'TRACE', 'SetStatusProcedure [:1:], [:2:]', @StatusCode, @ProcedureName;

DECLARE @Exists 
BIT = 0;
DECLARE @CurrentProcedureName NVARCHAR(255)

SELECT 
    @Exists = 1
  , @CurrentProcedureName = ProcedureName
FROM flow_internals.FlowStatus
WHERE StatusCode = @StatusCode

-- Fail if the status does not exist
IF @Exists = 0
BEGIN
  EXEC flow.Log 'ERROR', 'Invalid status [:1:]', @StatusCode;
  THROW 51000, 'Invalid status', 1
END

IF @CurrentProcedureName = @ProcedureName RETURN;

IF 'EXECUTE' NOT IN ( SELECT permission_name FROM fn_my_permissions(@ProcedureName, 'OBJECT') )
BEGIN
  EXEC flow.Log 'WARN', 'Non-existent status procedure [:1:]', @ProcedureName;
  THROW 51000, 'Invalid procedure', 1;
END

UPDATE flow_internals.FlowStatus
SET ProcedureName = @ProcedureName
WHERE StatusCode = @StatusCode
;

EXEC flow.Log 'INFO', 'Using procedure [:1:] for status [:2:]', @ProcedureName, @StatusCode;
