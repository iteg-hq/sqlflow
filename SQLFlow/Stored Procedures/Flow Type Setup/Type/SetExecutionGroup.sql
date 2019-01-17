CREATE PROCEDURE flow.SetExecutionGroup
    @TypeCode NVARCHAR(50)
  , @ExecutionGroupCode NVARCHAR(50)
AS
SET NOCOUNT, XACT_ABORT ON;

IF NOT EXISTS (
    SELECT TypeCode
    FROM internals.FlowType
    WHERE TypeCode = @TypeCode
  )
  THROW 51000, 'Flow does not exist', 1;

UPDATE internals.FlowType
SET ExecutionGroupCode = @ExecutionGroupCode
WHERE TypeCode = @TypeCode
;
