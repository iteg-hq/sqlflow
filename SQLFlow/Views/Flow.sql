CREATE VIEW flow.Flow
AS 
SELECT
    f.FlowID
  , f.[Name]
  , f.ExecutionGroupCode AS ExecutionGroupCode
  , t.TypeCode
  , f.StatusCode
  , ( SELECT COUNT(*) FROM internals.Lock AS l WHERE l.HeldByFlowID = f.FlowID ) AS LockCount
  , s.ProcedureName
  , fail.ResultingStatusCode AS FailureStatusCode
  , start_.ResultingStatusCode AS StartStatusCode
  , f.CreatedAt
  , f.ExecutedAt
FROM internals.Flow AS f
INNER JOIN internals.FlowStatus AS s
  ON s.StatusCode = f.StatusCode
INNER JOIN internals.FlowType AS t
  ON t.TypeCode = s.TypeCode
LEFT JOIN internals.FlowAction AS fail
  ON  fail.StatusCode = s.StatusCode
  AND fail.ActionCode = 'Fail'
LEFT JOIN internals.FlowAction AS start_
  ON  fail.StatusCode = s.StatusCode
  AND fail.ActionCode = 'Start'
;
