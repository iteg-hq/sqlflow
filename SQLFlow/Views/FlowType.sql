CREATE VIEW dbo.FlowType
AS 
SELECT
    TypeCode
  , ExecutionGroupCode
  , InitialStatusCode
FROM internal.FlowType
;
