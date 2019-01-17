CREATE PROCEDURE flow.NewFlow
    @TypeCode NVARCHAR(20)
  , @FlowID INT OUTPUT
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;

  DECLARE @InitialStatus NVARCHAR(200);

  SELECT @InitialStatus = InitialStatusCode 
  FROM internals.FlowType
  WHERE TypeCode = @TypeCode
  ;

  IF @TypeCode NOT IN ( SELECT TypeCode FROM internals.FlowType )
  BEGIN
    EXEC flow.Log 'ERROR', 'Unknown flow type: :1:', @TypeCode;
    THROW 51000, 'Unknown flow type code', 1;
  END 

  -- Create new instance
  INSERT INTO internals.Flow (
      [Name]
    , ExecutionGroupCode
    , TypeCode
    )
  SELECT
      @TypeCode
    , ExecutionGroupCode
    , @TypeCode
  FROM internals.FlowType
  WHERE TypeCode = @TypeCode
  ;

  -- Store the ID in an output variable
  SET @FlowID = SCOPE_IDENTITY();

  EXEC internals.GrabFlow @FlowID;

  -- Log the ID, so that it shows up in the log even if you're not seeing the FlowID column
  EXEC flow.Log 'INFO', 'Created new FlowID: :1:', @FlowID;

  -- Change status to New
  EXEC internals.SetStatus @FlowID, @InitialStatus;

  EXEC internals.GrabFlow @FlowID;
END