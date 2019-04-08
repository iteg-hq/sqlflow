/*
CREATE USER [GRITLAPTOP02\SQLFlow];
ALTER ROLE SQLFlowUser ADD MEMBER [GRITLAPTOP02\SQLFlow];
*/

-- Log Levels
--------------------
IF NOT EXISTS ( SELECT 1 FROM flow_internals.LogLevel )
INSERT INTO flow_internals.LogLevel (
    LogLevelID
  , LogLevelCode
  , EchoToOutput
  , Notify
  )
VALUES
    (10, 'TRACE', 0, 0)
  , (20, 'DEBUG', 0, 0)
  , (30, 'INFO',  1, 0)
  , (40, 'WARN',  1, 0)
  , (50, 'ERROR', 1, 1)
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
