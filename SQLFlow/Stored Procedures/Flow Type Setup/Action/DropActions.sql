CREATE PROCEDURE flow.DropActions
    @TypeCode NVARCHAR(50)
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC flow.Log 'TRACE', 'DropActions [:1:], [:2:], [:3:]', @TypeCode;
  
-- Delete all actions
DELETE internal.FlowAction
WHERE TypeCode = @TypeCode
;

EXEC flow.Log 'INFO', 'Dropped :1: actions on type :2:', @@ROWCOUNT, @TypeCode;


-- Reset procedures and locks
UPDATE internal.FlowStatus
SET ProcedureName = NULL
  , RequiredLockCode = NULL
  , Autocomplete = 0
WHERE TypeCode = @TypeCode
;

