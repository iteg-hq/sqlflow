CREATE VIEW flow.FlowAction
AS
SELECT
    f.FlowID
  , f.ExecutionGroupCode
  , f.StatusCode
  , a.ActionCode
  , a.ResultingStatusCode
  , s2.RequiredLockCode
FROM flow_internals.Flow AS f
INNER JOIN flow_internals.FlowStatus AS s
  ON  s.StatusCode = f.StatusCode
INNER JOIN flow_internals.FlowAction AS a
  ON a.StatusCode = f.StatusCode
INNER JOIN flow_internals.FlowStatus AS s2
  ON  s2.StatusCode = a.ResultingStatusCode
;
