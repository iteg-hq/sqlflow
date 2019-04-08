CREATE VIEW flow.AcquiredLock
AS
SELECT DISTINCT
    f.FlowID
  , l.LockCode
FROM flow_internals.Flow AS f
INNER JOIN flow_internals.Lock AS l
  ON l.HeldByFlowID = f.FlowID
;
