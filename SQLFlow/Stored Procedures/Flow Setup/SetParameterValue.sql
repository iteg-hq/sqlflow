CREATE PROCEDURE flow.SetParameterValue
    @FlowID INT
  , @Name NVARCHAR(50)
  , @Value NVARCHAR(MAX)
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC flow.Log 'TRACE', 'SetParameterValue [:1:], [:2:], [:3:]', @FlowID, @Name, @Value;
  
IF @FlowID NOT IN ( SELECT @FlowID FROM flow_internals.Flow )
BEGIN
  EXEC flow.Log 'ERROR', 'Invalid FlowID :1:', @FlowID
END

EXEC flow.Log 'DEBUG', 'Parameter :1: set to :2:', @Name, @Value;

UPDATE flow_internals.FlowParameter
SET ParameterValue = @Value
WHERE FlowID = @FlowID
  AND ParameterName = @Name
;

IF @@ROWCOUNT = 0
  INSERT INTO flow_internals.FlowParameter (
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
