CREATE PROCEDURE flow.SetStatusProcedure
    @StatusCode NVARCHAR(50)
  , @ProcedureName NVARCHAR(255)
  , @Autocomplete BIT = NULL
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC flow.Log 'TRACE', 'SetStatusProcedure [:1:], [:2:], [:3:]', @StatusCode, @ProcedureName, @Autocomplete;

-- If this status has a procedure and no value is supplied for Autocomplete, assume that we want to
-- Autocomplete. You might want to turn off Autocomplete if the status SP manages the resulting 
-- status transition itself, or simply if the SP is something final, like notifying an operator or
-- reporting success.
IF @ProcedureName <> '' AND @Autocomplete IS NULL
  SET @Autocomplete = 1;

IF NOT EXISTS (
  SELECT 1
  FROM flow_internals.FlowStatus
  WHERE StatusCode = @StatusCode
)
BEGIN
  EXEC flow.Log 'ERROR', 'Invalid status [:1:]', @StatusCode;
  THROW 51000, 'Invalid status', 1
END

-- No change
IF NOT EXISTS (
    SELECT ProcedureName, Autocomplete
    FROM flow_internals.FlowStatus
    WHERE StatusCode = @StatusCode
    EXCEPT
    SELECT @ProcedureName, @Autocomplete
  )
  RETURN;

IF 'EXECUTE' NOT IN ( SELECT permission_name FROM fn_my_permissions(@ProcedureName, 'OBJECT') )
BEGIN
  EXEC flow.Log 'WARN', 'Non-existent status procedure [:1:]', @ProcedureName;
  THROW 51000, 'Invalid procedure', 1;
END

UPDATE flow_internals.FlowStatus
SET ProcedureName = @ProcedureName
  , Autocomplete = @Autocomplete
WHERE StatusCode = @StatusCode
;

EXEC flow.Log 'INFO', 'Using procedure [:1:], Autocomplete [:2:] for status [:3:]', @ProcedureName, @Autocomplete, @StatusCode;
