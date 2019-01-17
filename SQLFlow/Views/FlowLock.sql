CREATE VIEW flow.AcquiredLock
AS
SELECT DISTINCT
    f.FlowID
  , l.LockCode
FROM internals.Flow AS f
INNER JOIN internals.Lock AS l
  ON l.HeldByFlowID = f.FlowID
INNER JOIN internals.FlowStatus AS s
  ON s.StatusCode = f.StatusCode
;
