CREATE PROCEDURE flow.DropAction
    @ActionCode NVARCHAR(50)
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;

  DELETE internals.FlowAction 
  WHERE ActionCode = @ActionCode
  ;

  IF @@ROWCOUNT = 0
    EXEC flow.Log 'WARN', 'Did not drop action [:1:]', @ActionCode;
  ELSE
    EXEC flow.Log 'INFO', 'Dropped action [:1:]', @ActionCode;
 END