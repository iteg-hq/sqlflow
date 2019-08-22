CREATE PROCEDURE dbo.SetParameterValue
    @FlowID INT
  , @Name NVARCHAR(50)
  , @Value NVARCHAR(MAX)
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC dbo.Log 'TRACE', 'SetParameterValue [:1:], [:2:], [:3:]', @FlowID, @Name, @Value;
  
IF @FlowID NOT IN ( SELECT @FlowID FROM internal.Flow )
BEGIN
  EXEC dbo.Log 'ERROR', 'Invalid FlowID :1:', @FlowID
END

EXEC dbo.Log 'DEBUG', 'Parameter :1: set to :2:', @Name, @Value;

UPDATE internal.FlowParameter
SET ParameterValue = @Value
WHERE FlowID = @FlowID
  AND ParameterName = @Name
;

IF @@ROWCOUNT = 0
  INSERT INTO internal.FlowParameter (
      FlowID
    , ParameterName
    , ParameterValue
    )
  VALUES (
      @FlowID
    , @Name
    , @Value
    )
  ;
