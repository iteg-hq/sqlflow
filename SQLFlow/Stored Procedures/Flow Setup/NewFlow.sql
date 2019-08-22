CREATE PROCEDURE NewFlow
    @TypeCode NVARCHAR(200)
  , @FlowID INT OUTPUT
AS
SET NOCOUNT, XACT_ABORT ON;
EXEC internal.UpdateContext @FlowID;

EXEC Log 'TRACE', 'NewFlow [:1:], [:2:]', @TypeCode, @FlowID;
  
DECLARE @InitialStatus NVARCHAR(200);

SELECT @InitialStatus = InitialStatusCode 
FROM internal.FlowType
WHERE TypeCode = @TypeCode
;

IF @TypeCode NOT IN ( SELECT TypeCode FROM internal.FlowType )
BEGIN
  EXEC Log 'ERROR', 'Unknown flow type: :1:', @TypeCode;
  THROW 51000, 'Unknown flow type code', 1;
END 

-- Create new instance
INSERT INTO internal.Flow (
    ExecutionGroupCode
  , TypeCode
  )
SELECT
    ExecutionGroupCode
  , @TypeCode
FROM internal.FlowType
WHERE TypeCode = @TypeCode
;

-- Store the ID in an output variable and update the session context
SET @FlowID = SCOPE_IDENTITY();
EXEC internal.UpdateContext @FlowID;

-- Log the ID, so that it shows up in the log even if you're not seeing the FlowID column
EXEC Log 'INFO', 'Created new FlowID: :1:', @FlowID;

-- Change status to New
EXEC internal.SetStatus @FlowID, @InitialStatus;

DECLARE @Autocomplete BIT;

SELECT @Autocomplete = Autocomplete
FROM internal.FlowStatus
WHERE TypeCode = @TypeCode
  AND StatusCode = @InitialStatus;
;

IF @Autocomplete = 1
  EXEC Do @FlowID, 'Complete';

GO