CREATE PROCEDURE flow.AddType
    @TypeCode NVARCHAR(50)
  , @ExecutionGroupCode NVARCHAR(50) = NULL
  , @InitialStatusCode NVARCHAR(200) = NULL
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC flow.Log 'TRACE', 'AddType [:1:], [:2:], [:3:]', @TypeCode, @ExecutionGroupCode, @InitialStatusCode;

-- Create the flow if it does not exist
IF NOT EXISTS (
    SELECT 1
    FROM internal.FlowType
    WHERE TypeCode = @TypeCode
  )
BEGIN
  INSERT INTO internal.FlowType (TypeCode)
  VALUES (@TypeCode)
  ;
  EXEC flow.Log 'INFO', 'Added new flow type [:1:]', @TypeCode;
END

-- Create or update the initial status. Calling flow.SetInitialStatus
-- guarantees that some initial status code will be set. If @InitialStatusCode
-- is NULL og empty, a default code will be used.
EXEC flow.SetInitialStatus @TypeCode, @InitialStatusCode;

-- If an execution group was specified, set it.
IF @ExecutionGroupCode <> ''
  EXEC flow.SetExecutionGroup @TypeCode, @ExecutionGroupCode;
