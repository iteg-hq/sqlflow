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
  , le.StatusCode
  , le.UserName
  , @@SERVERNAME AS ServerName
  , '['+ @@SERVERNAME +']' +
    '['+ CAST(EntryTimestamp AS NVARCHAR(26)) +']' +
    '['+ COALESCE(StatusCode, 'no status') +']' +
    ' '+ FormattedEntryText AS LogLine
FROM internals.LogEntry AS le
INNER JOIN internals.LogLevel AS ll
  ON ll.LogLevelID = le.LogLevelID
;

GO

GRANT SELECT ON flow.LogEntry TO LogViewer
;
