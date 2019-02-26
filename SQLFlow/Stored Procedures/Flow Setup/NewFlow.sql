CREATE PROCEDURE flow.NewFlow
    @TypeCode NVARCHAR(20)
  , @FlowID INT OUTPUT
AS
SET NOCOUNT, XACT_ABORT ON;
EXEC flow_internals.UpdateContext @FlowID;

EXEC flow.Log 'TRACE', 'NewFlow [:1:], [:2:]', @TypeCode, @FlowID;
  
DECLARE @InitialStatus NVARCHAR(200);

SELECT @InitialStatus = InitialStatusCode 
FROM flow_internals.FlowType
WHERE TypeCode = @TypeCode
;

IF @TypeCode NOT IN ( SELECT TypeCode FROM flow_internals.FlowType )
BEGIN
  EXEC flow.Log 'ERROR', 'Unknown flow type: :1:', @TypeCode;
  THROW 51000, 'Unknown flow type code', 1;
END 

-- Create new instance
INSERT INTO flow_internals.Flow (
    ExecutionGroupCode
  , TypeCode
  )
SELECT
    ExecutionGroupCode
  , @TypeCode
FROM flow_internals.FlowType
WHERE TypeCode = @TypeCode
;

-- Store the ID in an output variable and update the session context
SET @FlowID = SCOPE_IDENTITY();
EXEC flow_internals.UpdateContext @FlowID;

-- Log the ID, so that it shows up in the log even if you're not seeing the FlowID column
EXEC flow.Log 'INFO', 'Created new FlowID: :1:', @FlowID;

-- Change status to New
EXEC flow_internals.SetStatus @FlowID, @InitialStatus;


