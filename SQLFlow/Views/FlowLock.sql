CREATE VIEW flow.AcquiredLock
AS
SELECT DISTINCT
    f.FlowID
  , l.LockCode
FROM internal.Flow AS f
INNER JOIN internal.Lock AS l
  ON l.HeldByFlowID = f.FlowID
;
