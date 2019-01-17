CREATE PROCEDURE internals.HousekeepingSetup
AS
EXEC sp_set_session_context N'StatusCode', 'Setup';

EXEC flow.AddType 
    @TypeCode = 'SQLFlow:Housekeeping'
  , @ExecutionGroupCode = 'System'
  ;

EXEC flow.ResetFlowType'SQLFlow:Housekeeping';

EXEC flow.AddAction 'SQLFlow:Housekeeping.New.Start', 'Running';
EXEC flow.AddAction 'SQLFlow:Housekeeping.Running.Fail', 'Failed'
EXEC flow.AddAction 'SQLFlow:Housekeeping.Running.Complete', 'Completed';

EXEC flow.SetStatusProcedure 'SQLFlow:Housekeeping.Running', @ProcedureName='internals.HousekeepingRunning'
EXEC flow.SetStatusProcedure 'SQLFlow:Housekeeping.Failed',  @ProcedureName='internals.HousekeepingFailed';

EXEC sp_set_session_context N'StatusCode', NULL;

GO

CREATE PROCEDURE internals.Housekeeping
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  DECLARE @FlowID INT;
  EXEC flow.NewFlow 'SQLFlow:Housekeeping', @FlowID OUTPUT
  EXEC flow.SetParameterValue @FlowID, 'LogRetentionPeriodInDays', 30; -- Hardcoded
  EXEC flow.Do @FlowID, 'Start';
END

GO

CREATE PROCEDURE internals.HousekeepingRunning @FlowID INT
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  EXEC internals.DeleteOldLogEntries @FlowID;
  EXEC flow.Do @FlowID, 'Complete';
END

GO
CREATE PROCEDURE internals.HousekeepingFailed @FlowID INT
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  EXEC flow.Log 'WARN', 'Housekeeping failed';
  -- Notify someone!
END
