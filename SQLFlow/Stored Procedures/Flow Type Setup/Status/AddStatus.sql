CREATE PROCEDURE dbo.AddStatus
    @TypeCode NVARCHAR(200)
  , @StatusCode NVARCHAR(200)
  , @RequiredLockCode NVARCHAR(50) = NULL
  , @ProcedureName NVARCHAR(500) = NULL
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC dbo.Log 'TRACE', 'AddStatus [:1:], [:2:], [:3:], [:4:]', @TypeCode, @StatusCode, @RequiredLockCode, @ProcedureName;

IF NOT EXISTS (
  SELECT 1
  FROM internal.FlowType
  WHERE TypeCode = @TypeCode
  )
BEGIN
  EXEC dbo.Log 'ERROR', 'AddStatus: Flow type [:1:] does not exist', @TypeCode;
  THROW 51000, 'Flow type does not exist', 1;
END

-- Add the status, if needed
IF NOT EXISTS (
  SELECT 1
  FROM internal.FlowStatus AS s
  WHERE TypeCode = @TypeCode
    AND StatusCode = @StatusCode
  )
BEGIN
  INSERT INTO internal.FlowStatus (
      TypeCode
    , StatusCode
    )
  VALUES (
      @TypeCode
    , @StatusCode
    )
  ;
  EXEC dbo.Log 'INFO', 'Added new flow status: [:1:]',  @StatusCode;
END

-- Update the required lock, if specified
IF @RequiredLockCode != ''
  EXEC dbo.SetStatusLock @TypeCode, @StatusCode, @RequiredLockCode;

-- Update the procedure, if specified
IF @ProcedureName != ''
  EXEC dbo.SetStatusProcedure @TypeCode, @StatusCode, @ProcedureName;
