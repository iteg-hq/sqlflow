CREATE PROCEDURE dbo.DropAction
    @ActionCode NVARCHAR(50)
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC dbo.Log 'TRACE', 'DropAction [:1:]', @ActionCode;

DELETE internal.FlowAction 
WHERE ActionCode = @ActionCode
;

IF @@ROWCOUNT = 0
  EXEC dbo.Log 'WARN', 'Did not drop action [:1:]', @ActionCode;
ELSE
  EXEC dbo.Log 'INFO', 'Dropped action [:1:]', @ActionCode;
 