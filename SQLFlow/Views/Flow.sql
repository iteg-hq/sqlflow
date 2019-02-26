CREATE VIEW flow.Flow
AS 
SELECT
    f.FlowID
  , f.ExecutionGroupCode AS ExecutionGroupCode
  , t.TypeCode
  , f.StatusCode
  , ( SELECT COUNT(*) FROM flow_internals.Lock AS l WHERE l.HeldByFlowID = f.FlowID ) AS LockCount
  , s.ProcedureName
  , fail.ResultingStatusCode AS FailureStatusCode
  , fail.ResultingStatusCode AS SuccessStatusCode
  , s.Autocomplete
  , start_.ResultingStatusCode AS StartStatusCode
  , f.CreatedAt
  , f.ExecutedAt
FROM flow_internals.Flow AS f
INNER JOIN flow_internals.FlowStatus AS s
  ON s.StatusCode = f.StatusCode
INNER JOIN flow_internals.FlowType AS t
  ON t.TypeCode = s.TypeCode
LEFT JOIN flow_internals.FlowAction AS fail
  ON  fail.StatusCode = s.StatusCode
  AND fail.ActionCode = 'Fail'
LEFT JOIN flow_internals.FlowAction AS complete
  ON  fail.StatusCode = s.StatusCode
  AND fail.ActionCode = 'Complete'
LEFT JOIN flow_internals.FlowAction AS start_
  ON  fail.StatusCode = s.StatusCode
  AND fail.ActionCode = 'Start'
;
