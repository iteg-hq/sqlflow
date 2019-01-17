CREATE PROCEDURE flow.ResetFlowType
    @TypeCode NVARCHAR(50)
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  
  -- Delete all actions
  DELETE internals.FlowAction
  WHERE StatusCode IN (
      SELECT StatusCode
      FROM internals.FlowStatus
      WHERE TypeCode = @TypeCode
    )
  ;

  -- Reset procedures and locks
  UPDATE internals.FlowStatus
  SET ProcedureName = NULL
    , RequiredLockCode = NULL
  WHERE TypeCode = @TypeCode
  ;

END