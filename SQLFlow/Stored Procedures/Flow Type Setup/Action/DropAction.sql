CREATE PROCEDURE DropAction
    @ActionCode NVARCHAR(50)
AS
SET NOCOUNT, XACT_ABORT ON;

EXEC Log 'TRACE', 'DropAction [:1:]', @ActionCode;

DELETE internal.FlowAction 
WHERE ActionCode = @ActionCode
;

IF @@ROWCOUNT = 0
  EXEC Log 'WARN', 'Did not drop action [:1:]', @ActionCode;
ELSE
  EXEC Log 'INFO', 'Dropped action [:1:]', @ActionCode;
 