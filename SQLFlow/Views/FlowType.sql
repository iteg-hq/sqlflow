CREATE VIEW flow.FlowType
AS 
SELECT
    TypeCode
  , ExecutionGroupCode
  , InitialStatusCode
FROM flow_internals.FlowType
;
