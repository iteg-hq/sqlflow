CREATE PROCEDURE flow_test.DoStuffButFailSometimes @FlowID INT
AS
EXEC flow_test.DoStuff @FlowID;
-- Only succeed every third second ;-)
IF DATEPART(SECOND, GETDATE()) % 3 = 0
  EXEC [$(SQLFlow)].flow.Do @FlowID, 'Complete';
ELSE
  DECLARE @DivisionByZero INT = 1/0;
;
