CREATE PROCEDURE internal.DeleteOldLogEntries @FlowID INT
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;

  EXEC Log 'TRACE', 'Entering DeleteOldLogMessages'
  DECLARE @LogRetentionPeriodInDays INT = CAST(GetParameterValue(@FlowID, 'LogRetentionPeriodInDays') AS INT);

  DECLARE @Cutoff DATETIME2 = DATEADD(DAY, -@LogRetentionPeriodInDays, CURRENT_TIMESTAMP);

  DELETE internal.LogEntry
  WHERE EntryTimestamp < @Cutoff
  ;

  EXEC Log 'INFO', 'Deleted :1: log messages older than :2: (:3: days back)', @@ROWCOUNT, @Cutoff, @LogRetentionPeriodInDays;

  EXEC Log 'TRACE', 'Leaving DeleteOldLogMessages'
END
