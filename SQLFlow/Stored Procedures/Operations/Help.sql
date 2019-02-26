CREATE PROCEDURE flow.Help @FlowID INT
AS
SET NOCOUNT, XACT_ABORT ON;

DECLARE @Exists BIT = 0;
DECLARE @Name NVARCHAR(200);
DECLARE @ExecutionGroupCode NVARCHAR(200);
DECLARE @TypeCode NVARCHAR(200);
DECLARE @StatusCode NVARCHAR(200);
DECLARE @ProcedureName NVARCHAR(200);
DECLARE @ActionCode NVARCHAR(200);
DECLARE @ResultingStatusCode NVARCHAR(200);
DECLARE @LockCode NVARCHAR(200);
DECLARE @LogLine NVARCHAR(MAX);

SELECT
    @Exists = 1
  , @ExecutionGroupCode = COALESCE(ExecutionGroupCode, '(none)')
  , @TypeCode = COALESCE(TypeCode, '(none)')
  , @StatusCode = COALESCE(StatusCode, '(none)')
  , @ProcedureName = COALESCE(ProcedureName, '(none)')
FROM flow.Flow
WHERE FlowID = @FlowID

IF @Exists = 0
BEGIN
  PRINT 'Invalid FlowID: ' + CAST(@FlowID AS NVARCHAR(10));
  RETURN;
END

PRINT 'Type: ' + @TypeCode;
PRINT '';
PRINT 'Status: ' + @StatusCode;
PRINT '';
PRINT 'Actions:'

DECLARE action_cursor CURSOR FOR
SELECT ActionCode, ResultingStatusCode
FROM flow.FlowAction
WHERE FlowID = @FlowID
;

OPEN action_cursor

FETCH NEXT FROM action_cursor INTO @ActionCode, @ResultingStatusCode
IF @@FETCH_STATUS <> 0
  PRINT '  - (None)'

WHILE @@FETCH_STATUS = 0
BEGIN
  PRINT '  - ' + @ActionCode + ' -> [' + @ResultingStatusCode + ']';
  FETCH NEXT FROM action_cursor INTO @ActionCode, @ResultingStatusCode;
END
CLOSE action_cursor
DEALLOCATE action_cursor

PRINT '';
PRINT 'Locks:';

DECLARE lock_cursor CURSOR FOR
SELECT LockCode
FROM flow.AcquiredLock
WHERE FlowID = @FlowID
ORDER BY LockCode
;

OPEN lock_cursor

FETCH NEXT FROM lock_cursor INTO @LockCode
IF @@FETCH_STATUS <> 0
  PRINT '  - (None)';

WHILE @@FETCH_STATUS = 0
BEGIN
  PRINT '  - ' + @LockCode;
  FETCH NEXT FROM lock_cursor INTO @LockCode;
END
CLOSE lock_cursor
DEALLOCATE lock_cursor


PRINT '';
PRINT 'Log tail:';

DECLARE log_cursor CURSOR FOR
SELECT LogLine
FROM flow.LogEntry
WHERE FlowID = @FlowID
  AND rv >= (
      -- Earliest log message to include
      SELECT MIN(rv) 
      FROM (
          -- Top 10 latest messages
          SELECT TOP 10 rv
          FROM flow.LogEntry
          WHERE FlowID = @FlowID
          ORDER BY rv DESC
        ) AS tail
    )
ORDER BY rv ASC

OPEN log_cursor

FETCH NEXT FROM log_cursor INTO @LogLine
IF @@FETCH_STATUS <> 0
  PRINT '(No log messages)';

WHILE @@FETCH_STATUS = 0
BEGIN
  PRINT @LogLine;
  FETCH NEXT FROM log_cursor INTO @LogLine;
END
CLOSE log_cursor
DEALLOCATE log_cursor
