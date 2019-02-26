CREATE PROCEDURE flow.AddStatus
    @StatusCode NVARCHAR(200)
  , @RequiredLockCode NVARCHAR(50) = NULL
  , @ProcedureName NVARCHAR(500) = NULL
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC flow.Log 'TRACE', 'AddStatus [:1:], [:2:], [:3:]', @StatusCode, @RequiredLockCode, @ProcedureName;

DECLARE @TypeCode NVARCHAR(200) = flow_internals.GetParent(@StatusCode);

IF NOT EXISTS (
  SELECT 1
  FROM flow_internals.FlowType
  WHERE TypeCode = @TypeCode
  )
BEGIN
  EXEC flow.Log 'ERROR', 'AddStatus: Flow type [:1:] does not exist', @TypeCode;
  THROW 51000, 'Flow type does not exist', 1;
END

-- Add the type, if needed
IF NOT EXISTS (
  SELECT 1
  FROM flow_internals.FlowStatus AS s
  WHERE StatusCode = @StatusCode
  )
BEGIN
  INSERT INTO flow_internals.FlowStatus (
      TypeCode
    , StatusCode
    )
  VALUES (
      @TypeCode
    , @StatusCode
    )
  ;
  EXEC flow.Log 'INFO', 'Added new flow status: [:1:]',  @StatusCode;
END

-- Update the required lock, if specified
IF @RequiredLockCode != ''
  EXEC flow.SetStatusLock @StatusCode, @RequiredLockCode;

-- Update the procedure, if specified
IF @ProcedureName != ''
  EXEC flow.SetStatusProcedure @StatusCode, @ProcedureName;
