CREATE VIEW FlowAction
AS
SELECT
    f.FlowID
  , f.ExecutionGroupCode
  , f.StatusCode
  , a.ActionCode
  , a.ResultingStatusCode
  , s2.RequiredLockCode
  , s2.ProcedureName
  , s2.Autocomplete AS Autocomplete
FROM internal.Flow AS f
INNER JOIN internal.FlowStatus AS s
  ON  s.TypeCode = f.TypeCode
  AND s.StatusCode = f.StatusCode
INNER JOIN internal.FlowAction AS a
  ON  a.TypeCode = f.TypeCode
  AND a.StatusCode = f.StatusCode
INNER JOIN internal.FlowStatus AS s2
  ON  s2.TypeCode = f.TypeCode
  AND s2.StatusCode = a.ResultingStatusCode
;
