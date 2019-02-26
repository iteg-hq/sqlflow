CREATE VIEW flow.FlowStatus
AS 
SELECT
    s.TypeCode
  , s.StatusCode
  , s.RequiredLockCode
  , s.ProcedureName
FROM flow_internals.FlowStatus AS s
--INNER JOIN internals.FlowType AS t
--  ON t.TypeCode = s.TypeCode
;
