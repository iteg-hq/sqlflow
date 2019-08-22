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

EXEC flow.SetStatusProcedure 'SQLFlow:Housekeeping', 'Running', @ProcedureName='internal.HousekeepingRunning';
EXEC flow.SetStatusProcedure 'SQLFlow:Housekeeping', 'Failed',  @ProcedureName='internal.HousekeepingFailed', @Autocomplete=0;

GO

CREATE PROCEDURE internal.Housekeeping
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  DECLARE @FlowID INT;
  EXEC flow.NewFlow 'SQLFlow:Housekeeping', @FlowID OUTPUT
  EXEC flow.SetParameterValue @FlowID, 'LogRetentionPeriodInDays', 30; -- Hardcoded
  EXEC flow.Do @FlowID, 'Start';
END

GO

CREATE PROCEDURE internal.HousekeepingRunning @FlowID INT
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  EXEC internal.DeleteOldLogEntries @FlowID;
END

GO
CREATE PROCEDURE internal.HousekeepingFailed @FlowID INT
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  EXEC flow.Log 'WARN', 'Housekeeping failed';
  -- Notify someone!
END
