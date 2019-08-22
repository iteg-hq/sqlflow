CREATE PROCEDURE SetInitialStatus
    @TypeCode NVARCHAR(50)
  , @InitialStatusCode NVARCHAR(50)
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC Log 'TRACE', 'SetInitialStatus [:1:], [:2:]', @TypeCode, @InitialStatusCode;

-- If the flow type does not exist, fail
IF NOT EXISTS (
    SELECT 1
    FROM internal.FlowType
    WHERE TypeCode = @TypeCode
  )
  THROW 51000, 'Flow type does not exist', 1;

-- Default value, if needed
IF @InitialStatusCode IS NULL OR @InitialStatusCode = ''
  SET @InitialStatusCode = 'New';

-- If no changes are needed, return
IF EXISTS (
    SELECT 1
    FROM internal.FlowType
    WHERE TypeCode = @TypeCode
      AND InitialStatusCode = @InitialStatusCode    
  )
  RETURN

-- Add the status (if it does not already exists)
EXEC AddStatus @TypeCode, @InitialStatusCode;

-- Update
UPDATE internal.FlowType
SET InitialStatusCode = @InitialStatusCode
WHERE TypeCode = @TypeCode
;

EXEC Log 'INFO', 'Set initial itatus to [:2:] on flow type [:1:]', @TypeCode, @InitialStatusCode;
