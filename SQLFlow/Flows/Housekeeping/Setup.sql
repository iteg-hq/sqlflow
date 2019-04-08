CREATE PROCEDURE flow.HousekeepingSetup
AS

EXEC flow.AddType
    @TypeCode = 'SQLFlow:Housekeeping'
  , @ExecutionGroupCode = 'System'
  ;

EXEC flow.DropActions 'SQLFlow:Housekeeping';

EXEC flow.AddAction 'SQLFlow:Housekeeping', 'New',     'Start',    'Running';
EXEC flow.AddAction 'SQLFlow:Housekeeping', 'Running', 'Fail',     'Failed'
EXEC flow.AddAction 'SQLFlow:Housekeeping', 'Running', 'Complete', 'Completed';

EXEC flow.SetStatusProcedure 'SQLFlow:Housekeeping', 'Running', @ProcedureName='flow_internals.HousekeepingRunning';
EXEC flow.SetStatusProcedure 'SQLFlow:Housekeeping', 'Failed',  @ProcedureName='flow_internals.HousekeepingFailed', @Autocomplete=0;

GO

CREATE PROCEDURE flow_internals.Housekeeping
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  DECLARE @FlowID INT;
  EXEC flow.NewFlow 'SQLFlow:Housekeeping', @FlowID OUTPUT
  EXEC flow.SetParameterValue @FlowID, 'LogRetentionPeriodInDays', 30; -- Hardcoded
  EXEC flow.Do @FlowID, 'Start';
END

GO

CREATE PROCEDURE flow_internals.HousekeepingRunning @FlowID INT
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  EXEC flow_internals.DeleteOldLogEntries @FlowID;
END

GO
CREATE PROCEDURE flow_internals.HousekeepingFailed @FlowID INT
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  EXEC flow.Log 'WARN', 'Housekeeping failed';
  -- Notify someone!
END
