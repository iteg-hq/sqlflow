CREATE PROCEDURE flow.DropAction
    @ActionCode NVARCHAR(50)
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC flow.Log 'TRACE', 'DropAction [:1:]', @ActionCode;

DELETE flow_internals.FlowAction 
WHERE ActionCode = @ActionCode
;

IF @@ROWCOUNT = 0
  EXEC flow.Log 'WARN', 'Did not drop action [:1:]', @ActionCode;
ELSE
  EXEC flow.Log 'INFO', 'Dropped action [:1:]', @ActionCode;
 