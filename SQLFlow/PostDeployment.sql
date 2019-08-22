/*
CREATE USER [GRITLAPTOP02\SQLFlow];
ALTER ROLE SQLFlowUser ADD MEMBER [GRITLAPTOP02\SQLFlow];
*/

-- Log Levels
--------------------
IF NOT EXISTS ( SELECT 1 FROM internal.LogLevel )
INSERT INTO internal.LogLevel (
    LogLevelID
  , LogLevelCode
  , EchoToOutput
  )
VALUES
    (10, 'TRACE', 0)
  , (11, 'ENTER', 0)
  , (12, 'LEAVE', 0)
  , (20, 'DEBUG', 0)
  , (30, 'INFO',  1)
  , (40, 'WARN',  1)
  , (50, 'ERROR', 1)
;

GO

EXEC flow.HousekeepingSetup;

/*
EXEC flow_test.SimpleSetup;
EXEC flow_test.AsyncSetup;
EXEC flow_test.RerunSetup;
EXEC flow_test.FailureSetup;
EXEC flow_test.TestSetup;
*/
