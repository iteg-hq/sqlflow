CREATE PROCEDURE flow.Tail
    @LogLevelCode NVARCHAR(10) = 'INFO'
  , @rv BINARY(8) = NULL
AS
SET NOCOUNT, XACT_ABORT ON;

DECLARE @LogLevelID TINYINT;
SELECT @LogLevelID = LogLevelID
FROM flow_internals.LogLevel
WHERE LogLevelCode = @LogLevelCode
;

-- Cap the number of entries returned to 100.
-- Get the latest 101 entries - the rv of the earliest of these is the last entry we don't want to see.
-- That leaves 100 entries, max. (Note: If there are less that 100 relevant entries, we never show the first one)
IF @rv IS NULL
SELECT @rv = MIN(rv)
FROM (
    SELECT
        rv
      , ROW_NUMBER() OVER (ORDER BY rv DESC) AS n
    FROM flow.LogEntry
    WHERE LogLevelID >= @LogLevelID
  ) AS t
WHERE n <= 101
;

SELECT [rv], [LogLevelCode], [LogLevelID], [EntryTimestamp], [FormattedEntryText], [ServerProcessID], [FlowID], [StatusCode], [UserName], [ServerName]
FROM flow.LogEntry
WHERE rv > @rv
  AND LogLevelID >= @LogLevelID
ORDER BY rv;
