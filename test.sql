USE SQLFlow;

-- Set up a new flow
EXEC flow.AddType @TypeCode='Test';

-- Add some actions:
EXEC flow.AddAction 'Test.New.Start', 'Running';
EXEC flow.AddAction 'Test.Running.Fail', 'Failed';
EXEC flow.AddAction 'Test.Running.Complete', 'Completed';


-- try it
DECLARE @FlowID INT
EXEC flow.NewFlow 'Test', @FlowID OUTPUT
EXEC flow.Do @FlowID, 'Start';
EXEC flow.Do @FlowID, 'Complete';

GO

-- Do some stuff and complete when we're done running
CREATE PROCEDURE flow.DoStuff @FlowID INT
AS
EXEC flow.Log 'INFO', 'Doing stuff';
EXEC flow.Do @FlowID, 'Complete';
;

GO

-- Register the procedure with Running state
EXEC flow.SetStatusProcedure @StatusCode='Test.Running', @ProcedureName='flow.DoStuff';

GO

-- Try it out
DECLARE @FlowID INT
EXEC flow.NewFlow 'Test', @FlowID OUTPUT
EXEC flow.Do @FlowID, 'Start';
GO

-- Wrap flow initiation in a procedure
CREATE PROCEDURE flow.Test
AS
DECLARE @FlowID INT
EXEC flow.NewFlow 'Test', @FlowID OUTPUT

GO

-- Try it out
EXEC flow.Test
EXEC flow.Test
EXEC flow.Test

GO

-- Try using flow.Main to process the queue
EXEC flow.Main 'Ungrouped';

GO

-- 
ALTER OR CREATE PROCEDURE flow.Test @Number INT
AS
DECLARE @FlowID INT
EXEC flow.NewFlow 'Test', @FlowID OUTPUT
IF SQLFlow.flow.Ge



-- Put the rollback in a procedure, completing when we're done
CREATE PROCEDURE flow.RollbackTest @FlowID INT
AS
EXEC flow.Log 'INFO', 'Rolling back stuff';
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
