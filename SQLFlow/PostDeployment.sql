/*
Post-Deployment Script Template              
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.    
 Use SQLCMD syntax to include a file in the post-deployment script.      
 Example:      :r .\myfile.sql                
 Use SQLCMD syntax to reference a variable in the post-deployment script.    
 Example:      :setvar TableName MyTable              
               SELECT * FROM [$(TableName)]          
--------------------------------------------------------------------------------------
*/

/*
CREATE USER [GRITLAPTOP02\SQLFlow];
ALTER ROLE SQLFlowUser ADD MEMBER [GRITLAPTOP02\SQLFlow];
*/

-- Log Levels
--------------------
IF NOT EXISTS ( SELECT 1 FROM internals.LogLevel )
INSERT INTO internals.LogLevel (
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

EXEC flow.AddType @TypeCode='System', @InitialStatusCode='System.Uncreatable';

EXEC internals.HousekeepingSetup

-- Flow Types
--------------------
