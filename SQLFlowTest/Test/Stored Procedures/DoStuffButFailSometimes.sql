CREATE PROCEDURE dbo.DoStuffButFailSometimes @FlowID INT
AS
EXEC dbo.DoStuff @FlowID;
-- Only succeed every third second ;-)
IF DATEPART(SECOND, GETDATE()) % 3 > 0
  DECLARE @DivisionByZero INT = 1/0;
;
