CREATE VIEW dbo.FlowStatus
AS 
SELECT
    s.TypeCode
  , s.StatusCode
  , s.RequiredLockCode
  , s.ProcedureName
  , s.Autocomplete
FROM internal.FlowStatus AS s
--INNER JOIN internals.FlowType AS t
--  ON t.TypeCode = s.TypeCode
;
