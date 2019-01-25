CREATE PROCEDURE flow.AddType
    @TypeCode NVARCHAR(50)
  , @ExecutionGroupCode NVARCHAR(50) = NULL
  , @InitialStatusCode NVARCHAR(200) = NULL
  , @RequiredLockCode NVARCHAR(50) = NULL
  , @ProcedureName NVARCHAR(500) = NULL
AS
SET NOCOUNT, XACT_ABORT ON;

-- Create the flow if it does not exist
IF NOT EXISTS (
    SELECT 1
    FROM internals.FlowType
    WHERE TypeCode = @TypeCode
  )
BEGIN
  INSERT INTO internals.FlowType (TypeCode)
  VALUES (@TypeCode)
  ;
  EXEC flow.Log 'INFO', 'Added new flow type [:1:]', @TypeCode;

  -- If this is a new flow and no initials status code was given, make one up
  -- (an initial status is mandatory).
  SET @InitialStatusCode = COALESCE(@InitialStatusCode, @TypeCode + '.New');
END

-- Create or update the initial status, setting it as initial on the flow type.
IF @InitialStatusCode IS NOT NULL
BEGIN
  EXEC flow.AddStatus
      @StatusCode = @InitialStatusCode
    , @RequiredLockCode = @RequiredLockCode
    , @ProcedureName = @ProcedureName
    , @IsInitial = 1;
END

-- If an execution group was specified, set it.
IF @ExecutionGroupCode IS NOT NULL
  EXEC flow.SetExecutionGroup @TypeCode, @ExecutionGroupCode;
