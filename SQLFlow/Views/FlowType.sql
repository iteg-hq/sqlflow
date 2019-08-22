CREATE VIEW flow.FlowType
AS 
SELECT
    TypeCode
  , ExecutionGroupCode
  , InitialStatusCode
FROM internal.FlowType
;
