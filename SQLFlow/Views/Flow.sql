CREATE VIEW flow.Flow
AS 
SELECT
    f.FlowID
  , f.ExecutionGroupCode AS ExecutionGroupCode
  , f.TypeCode
  , f.StatusCode
  , ( SELECT COUNT(*) FROM internal.Lock AS l WHERE l.HeldByFlowID = f.FlowID ) AS LockCount
  , s.ProcedureName
  , fail.ResultingStatusCode AS FailureStatusCode
  , complete.ResultingStatusCode AS SuccessStatusCode
  , s.Autocomplete
  , start_.ResultingStatusCode AS StartStatusCode
  , f.CreatedAt
  , f.ExecutionStartedAt
  , f.ExecutionStoppedAt
  , DATEDIFF(SECOND, f.ExecutionStartedAt, f.ExecutionStoppedAt) AS ExecutionDurationInSeconds
FROM internal.Flow AS f
--INNER JOIN internal.FlowType AS t
--  ON t.TypeCode = f.TypeCode
INNER JOIN internal.FlowStatus AS s
  ON  s.TypeCode = f.TypeCode
  AND s.StatusCode = f.StatusCode
LEFT JOIN internal.FlowAction AS fail
  ON  fail.TypeCode = s.TypeCode
  AND fail.StatusCode = s.StatusCode
  AND fail.ActionCode = 'Fail'
LEFT JOIN internal.FlowAction AS complete
  ON  complete.TypeCode = s.TypeCode
  AND complete.StatusCode = s.StatusCode
  AND complete.ActionCode = 'Complete'
LEFT JOIN internal.FlowAction AS start_
  ON  start_.TypeCode = s.TypeCode
  AND start_.StatusCode = s.StatusCode
  AND start_.ActionCode = 'Start'
;
