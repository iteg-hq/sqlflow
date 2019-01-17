CREATE PROCEDURE flow.SetParameterValue
    @FlowID INT
  , @Name NVARCHAR(50)
  , @Value NVARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  
  IF @FlowID NOT IN ( SELECT @FlowID FROM internals.Flow )
  BEGIN
    EXEC flow.Log 'ERROR', 'Invalid FlowID :1:', @FlowID
  END

  EXEC flow.Log 'DEBUG', 'Parameter :1: set to :2:', @Name, @Value;

  UPDATE internals.FlowParameter
  SET ParameterValue = @Value
  WHERE FlowID = @FlowID
    AND ParameterName = @Name
  ;

  IF @@ROWCOUNT = 0
    INSERT INTO internals.FlowParameter (
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
END
