CREATE VIEW flow.LogEntry
AS 
SELECT
    le.rv
  , ll.LogLevelCode
  , le.LogLevelID
  , le.EntryTimestamp
  , le.FormattedEntryText
  , le.ServerProcessID
  , le.FlowID
  , le.ExecutionID
  , COALESCE(le.StatusCode, '(no status)') AS StatusCode
  , le.UserName
  , @@SERVERNAME AS ServerName
  , '['+ @@SERVERNAME +']' +
    '['+ CAST(EntryTimestamp AS NVARCHAR(26)) +']' +
    '['+ COALESCE(StatusCode, 'no status') +']' +
    ' '+ FormattedEntryText AS LogLine
FROM flow_internals.LogEntry AS le
INNER JOIN flow_internals.LogLevel AS ll
  ON ll.LogLevelID = le.LogLevelID
;
