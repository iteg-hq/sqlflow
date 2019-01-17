CREATE VIEW flow.FlowAction
AS
SELECT
    f.FlowID
  , f.ExecutionGroupCode
  , f.StatusCode
  , a.ActionCode
  , a.ResultingStatusCode
  , s2.RequiredLockCode
FROM internals.Flow AS f
INNER JOIN internals.FlowStatus AS s
  ON  s.StatusCode = f.StatusCode
INNER JOIN internals.FlowAction AS a
  ON a.StatusCode = f.StatusCode
INNER JOIN internals.FlowStatus AS s2
  ON  s2.StatusCode = a.ResultingStatusCode
;
