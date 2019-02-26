CREATE PROCEDURE flow.DropActions
    @TypeCode NVARCHAR(50)
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC flow.Log 'TRACE', 'DropActions [:1:], [:2:], [:3:]', @TypeCode;
  
-- Delete all actions
DELETE flow_internals.FlowAction
WHERE StatusCode IN (
    SELECT StatusCode
    FROM flow_internals.FlowStatus
    WHERE TypeCode = @TypeCode
  )
;

-- Reset procedures and locks
UPDATE flow_internals.FlowStatus
SET ProcedureName = NULL
  , RequiredLockCode = NULL
WHERE TypeCode = @TypeCode
;

