CREATE PROCEDURE flow.SetExecutionGroup
    @TypeCode NVARCHAR(50)
  , @ExecutionGroupCode NVARCHAR(50)
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC flow.Log 'TRACE', 'SetExecutionGroup [:1:], [:2:]', @TypeCode, @ExecutionGroupCode;

IF NOT EXISTS (
    SELECT 1
    FROM flow_internals.FlowType
    WHERE TypeCode = @TypeCode
  )
  THROW 51000, 'Flow type does not exist', 1;
  
-- If no changes are needed, return
IF EXISTS (
    SELECT 1
    FROM flow_internals.FlowType
    WHERE TypeCode = @TypeCode
      AND ExecutionGroupCode = @ExecutionGroupCode    
  )
  RETURN

UPDATE flow_internals.FlowType
SET ExecutionGroupCode = @ExecutionGroupCode
WHERE TypeCode = @TypeCode
;

EXEC flow.Log 'TRACE', 'Set Execution Group to [:2:] on flow type [:1:]', @TypeCode, @ExecutionGroupCode;
