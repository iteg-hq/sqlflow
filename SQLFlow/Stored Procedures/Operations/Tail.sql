CREATE PROCEDURE flow.Tail
    @rv BINARY(8) = NULL
AS
SET NOCOUNT, XACT_ABORT ON;

-- Return 100 rows from the tail end of the file or (if a revision timestamp is passed) the tail after that revision timestamp.
IF @rv IS NULL
  SELECT rv, LogLevelCode, LogLevelID, EntryTimestamp, FormattedEntryText, ServerProcessID, FlowID, ExecutionID, StatusCode, UserName, ServerName
  FROM (
      SELECT TOP 100 rv, LogLevelCode, LogLevelID, EntryTimestamp, FormattedEntryText, ServerProcessID, FlowID, ExecutionID, StatusCode, UserName, ServerName
      FROM flow.LogEntry
      ORDER BY rv DESC
    ) AS t
  ORDER BY rv;
ELSE
  SELECT rv, LogLevelCode, LogLevelID, EntryTimestamp, FormattedEntryText, ServerProcessID, FlowID, ExecutionID, StatusCode, UserName, ServerName
  FROM flow.LogEntry
  WHERE rv > @rv
  ORDER BY rv;
