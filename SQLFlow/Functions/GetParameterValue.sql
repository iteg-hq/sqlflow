CREATE FUNCTION flow.GetParameterValue (
    @FlowID INT
  , @Name NVARCHAR(100)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
  DECLARE @ParameterValue NVARCHAR(MAX);

  SELECT @ParameterValue = ParameterValue
  FROM internal.FlowParameter
  WHERE FlowID = @FlowID 
    AND ParameterName = @Name
  ;
  
  RETURN @ParameterValue; -- Will return NULL if the parameter is not defined for the flow
END
