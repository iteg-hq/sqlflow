CREATE PROCEDURE flow.DropActions
    @TypeCode NVARCHAR(50)
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC flow.Log 'TRACE', 'DropActions [:1:], [:2:], [:3:]', @TypeCode;
  
-- Delete all actions
DELETE flow_internals.FlowAction
WHERE TypeCode = @TypeCode
;

EXEC flow.Log 'INFO', 'Dropped :1: actions on type :2:', @@ROWCOUNT, @TypeCode;


-- Reset procedures and locks
UPDATE flow_internals.FlowStatus
SET ProcedureName = NULL
  , RequiredLockCode = NULL
WHERE TypeCode = @TypeCode
;

