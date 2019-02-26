CREATE PROCEDURE flow_internals.ShowOrphans
AS
CREATE TABLE #reachable ( StatusCode NVARCHAR(50) NOT NULL PRIMARY KEY )

INSERT INTO #reachable ( StatusCode )
SELECT DISTINCT InitialStatusCode
FROM flow_internals.FlowType

WHILE @@ROWCOUNT > 0
  INSERT INTO #reachable ( StatusCode )
  SELECT a.ResultingStatusCode
  FROM flow_internals.FlowAction AS a
  INNER JOIN #reachable AS r
    ON r.StatusCode = a.StatusCode
  EXCEPT
  SELECT StatusCode
  FROM #reachable

SELECT *
FROM flow.FlowStatus
WHERE StatusCode NOT IN ( SELECT StatusCode FROM #reachable )

DROP TABLE #reachable;
