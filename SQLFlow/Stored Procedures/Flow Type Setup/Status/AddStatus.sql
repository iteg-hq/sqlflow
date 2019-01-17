CREATE PROCEDURE flow.AddStatus
    @StatusCode NVARCHAR(200)
  , @RequiredLockCode NVARCHAR(50) = NULL
  , @ProcedureName NVARCHAR(500) = NULL
  , @IsInitial BIT = NULL
AS
SET NOCOUNT, XACT_ABORT ON;

DECLARE @TypeCode NVARCHAR(200) = internals.GetParent(@StatusCode);

IF NOT EXISTS (
  SELECT 1
  FROM internals.FlowType
  WHERE TypeCode = @TypeCode
  )
BEGIN
  EXEC flow.Log 'ERROR', 'Flow type :1: does not exist', @TypeCode;
  THROW 51000, 'Flow type does not exist', 1;
END
-- Update the code of the required lock
IF NOT EXISTS (
  SELECT 1
  FROM internals.FlowStatus AS s
  WHERE StatusCode = @StatusCode
  )
BEGIN
  INSERT INTO internals.FlowStatus (
      TypeCode
    , StatusCode
    , RequiredLockCode
    , ProcedureName
    )
  VALUES (
      @TypeCode
    , @StatusCode
    , @RequiredLockCode 
    , @ProcedureName
    )
  ;
  EXEC flow.Log 'INFO', 'Added new flow status: [:1:]',  @StatusCode;
END

IF @IsInitial = 1
BEGIN
  UPDATE internals.FlowType
  SET InitialStatusCode = @StatusCode
  WHERE TypeCode = @TypeCode
  ;
  EXEC flow.Log 'INFO', 'Status [:1:] set as initial status of flow type [:2:]',  @StatusCode, @TypeCode;
END

IF @RequiredLockCode != '' EXEC flow.SetStatusLock @StatusCode, @RequiredLockCode;

IF @ProcedureName != '' EXEC flow.SetStatusProcedure @StatusCode, @ProcedureName;
