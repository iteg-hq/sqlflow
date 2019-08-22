CREATE PROCEDURE HousekeepingSetup
AS

EXEC AddType
    @TypeCode = 'SQLFlow:Housekeeping'
  , @ExecutionGroupCode = 'System'
  ;

EXEC DropActions 'SQLFlow:Housekeeping';

EXEC AddAction 'SQLFlow:Housekeeping', 'New',     'Start',    'Running';
EXEC AddAction 'SQLFlow:Housekeeping', 'Running', 'Fail',     'Failed'
EXEC AddAction 'SQLFlow:Housekeeping', 'Running', 'Complete', 'Completed';

EXEC SetStatusProcedure 'SQLFlow:Housekeeping', 'Running', @ProcedureName='internal.HousekeepingRunning';
EXEC SetStatusProcedure 'SQLFlow:Housekeeping', 'Failed',  @ProcedureName='internal.HousekeepingFailed', @Autocomplete=0;

GO

CREATE PROCEDURE internal.Housekeeping
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  DECLARE @FlowID INT;
  EXEC NewFlow 'SQLFlow:Housekeeping', @FlowID OUTPUT
  EXEC SetParameterValue @FlowID, 'LogRetentionPeriodInDays', 30; -- Hardcoded
  EXEC Do @FlowID, 'Start';
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
  EXEC Log 'WARN', 'Housekeeping failed';
  -- Notify someone!
END
