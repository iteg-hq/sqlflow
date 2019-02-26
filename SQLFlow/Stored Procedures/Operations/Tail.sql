CREATE PROCEDURE flow.Tail @rv BINARY(8) = NULL
AS
SET NOCOUNT, XACT_ABORT ON;
IF @rv IS NULL
SELECT @rv = MIN(rv)
FROM (
    SELECT
        rv
      , ROW_NUMBER() OVER (ORDER BY rv DESC) AS n
    FROM flow.LogEntry
  ) AS t
WHERE n <= 101
;

SELECT [rv], [LogLevelCode], [LogLevelID], [EntryTimestamp], [FormattedEntryText], [ServerProcessID], [FlowID], [StatusCode], [UserName], [ServerName]
FROM flow.LogEntry
WHERE rv > @rv
ORDER BY rv;
