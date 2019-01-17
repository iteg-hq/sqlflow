USE SQLFlow;



EXEC flow.AddType @TypeCode='CRM';
EXEC flow.AddAction 'CRM.New.Start', 'Downloading';
EXEC flow.AddAction 'CRM.Downloading.Fail', 'DownloadFailed';
EXEC flow.AddAction 'CRM.Downloading.Complete', 'DownloadCompleted';



select * from flow.Flow

SELECT *
FROM flow.LogEntry
WHERE flowID = 5





-- Set up a new flow
EXEC flow.AddType @TypeCode='Test';

-- Add some status transitions (the statuses will be added as needed)
EXEC flow.AddAction 'Test.New.Start', 'Running';
EXEC flow.AddAction 'Test.Running.Fail', 'Failed';
EXEC flow.AddAction 'Test.Running.Complete', 'Completed';

-- try it, manually
DECLARE @FlowID INT
EXEC flow.NewFlow 'Test', @FlowID OUTPUT
EXEC flow.Do @FlowID, 'Start';
EXEC flow.Do @FlowID, 'Complete';

GO

-- Create a table
CREATE TABLE flow.Seq (
    Number INT NOT NULL PRIMARY KEY
  , FlowID INT NOT NULL
  )

GO
-- ...and a procedure to load the table
CREATE PROCEDURE flow.LoadSeq @FlowID INT
AS
DECLARE @Number INT = flow.GetParameterValue(@FlowID, 'Number')
EXEC flow.Log 'INFO', 'Inserting number :1:...', @Number;
INSERT INTO flow.Seq (Number, FlowID) VALUES (@Number, @FlowID)
EXEC flow.Log 'INFO', 'Done, completing';
EXEC flow.Do @FlowID, 'Complete'; 
;

GO

-- Register the procedure with Running state
EXEC flow.SetStatusProcedure @StatusCode='Test.Running', @ProcedureName='flow.LoadSeq';

GO


-- Load the value 1, manually
DECLARE @FlowID INT
EXEC flow.NewFlow 'Test', @FlowID OUTPUT
EXEC flow.SetName @FlowID, 'Number = ', 1
EXEC flow.SetParameter @FlowID, 'Number', 1
EXEC flow.Do @FlowID, 'Start';
-- flow.LoadSeq Completes the flow when it's done.

GO

-- Wrap flow initiation in a procedure
CREATE PROCEDURE flow.Test @Number INT
AS
DECLARE @FlowID INT
EXEC flow.NewFlow 'Test', @FlowID OUTPUT
EXEC flow.SetName @FlowID, 'Number = ', @Number
EXEC flow.SetParameter @FlowID, 'Number', @Number
EXEC flow.Do @FlowID, 'Start';

GO

-- Try it out
EXEC flow.Test 2
EXEC flow.Test 2
EXEC flow.Test 3

GO

-- Something went wrong, we need to roll back.
-- Put the rollback in a procedure
CREATE PROCEDURE flow.RollbackTest @FlowID INT
AS
DELETE flow.Seq WHERE FlowID = @FlowID;  
EXEC flow.Log 'INFO', 'Rolled back Seq';
EXEC flow.Do @FlowID, 'Complete'

GO

-- ...add some actions for rollback
EXEC flow.AddAction 'Test.Failed.Rollback', 'RollbackRunning';
EXEC flow.AddAction 'Test.Completed.ForceRollback', 'RollbackRunning';
EXEC flow.AddAction 'Test.RollbackRunning.Complete', 'RollbackCompleted';

-- ...and for disposing of rolled-back flows
EXEC flow.AddAction 'Test.RollbackCompleted.Restart', 'Running';
EXEC flow.AddAction 'Test.RollbackCompleted.Cancel', 'Cancelled';

-- Register the rollback procedure with RollbackRunning
EXEC flow.SetStatusProcedure 'Test.RollbackRunning', 'flow.RollbackTest';

GO

-- Now, we can roll back 5 and 4, cancel 4 and rerun 5
EXEC flow.Do 5, 'ForceRollback' -- #3
EXEC flow.Do 4, 'Rollback' -- #2, failed run
EXEC flow.Do 4, 'Cancel'
EXEC flow.Do 5, 'Restart'

SELECT *
FROM flow.Flow

-- Next, let's try to prevent good flows from piling up on bad ones, by using a lock

-- First, break it again
EXEC flow.Test 3

SELECT * FROM flow.Flow

-- Add a lock to the Failed and Running statuses.
-- From now on, only one flow may be in either of these statuses.
EXEC flow.SetStatusLock 'Test.Failed', 'TestLock'
EXEC flow.SetStatusLock 'Test.Running', 'TestLock'

SELECT * FROM flow.Flow
SELECT * FROM flow.AcquiredLock

-- New flow - can't start
EXEC flow.Test 4

-- Nope, won't start
EXEC flow.Do 7, 'Start'

-- Handle the blocking flow
EXEC flow.Do 6, 'Rollback'
EXEC flow.Do 6, 'Cancel'

-- Starts
EXEC flow.Do 7, 'Start'


SELECT * FROM flow.Flow
