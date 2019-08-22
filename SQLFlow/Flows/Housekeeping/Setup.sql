CREATE PROCEDURE dbo.HousekeepingSetup
AS

EXEC dbo.AddType
    @TypeCode = 'SQLFlow:Housekeeping'
  , @ExecutionGroupCode = 'System'
  ;

EXEC dbo.DropActions 'SQLFlow:Housekeeping';

EXEC dbo.AddAction 'SQLFlow:Housekeeping', 'New',     'Start',    'Running';
EXEC dbo.AddAction 'SQLFlow:Housekeeping', 'Running', 'Fail',     'Failed'
EXEC dbo.AddAction 'SQLFlow:Housekeeping', 'Running', 'Complete', 'Completed';

EXEC dbo.SetStatusProcedure 'SQLFlow:Housekeeping', 'Running', @ProcedureName='internal.HousekeepingRunning';
EXEC dbo.SetStatusProcedure 'SQLFlow:Housekeeping', 'Failed',  @ProcedureName='internal.HousekeepingFailed', @Autocomplete=0;

GO

CREATE PROCEDURE internal.Housekeeping
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  DECLARE @FlowID INT;
  EXEC dbo.NewFlow 'SQLFlow:Housekeeping', @FlowID OUTPUT
  EXEC dbo.SetParameterValue @FlowID, 'LogRetentionPeriodInDays', 30; -- Hardcoded
  EXEC dbo.Do @FlowID, 'Start';
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
  EXEC dbo.Log 'WARN', 'Housekeeping failed';
  -- Notify someone!
END
