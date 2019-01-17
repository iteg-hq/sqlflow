CREATE PROCEDURE flow.DropStatus
    @StatusCode NVARCHAR(50)
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;

  DELETE internals.FlowStatus
  WHERE StatusCode = @StatusCode
  ;

  EXEC flow.Log 'INFO', 'Deleted :1: rows from FlowStatus', @@ROWCOUNT;
 END