CREATE TABLE internal.LogEntry (
    rv ROWVERSION
  , UserName NVARCHAR(256) NOT NULL CONSTRAINT DF_LogEntry_UserName DEFAULT(SUSER_NAME())
  , EntryTimestamp DATETIME2(7) NOT NULL CONSTRAINT DF_LogEntry_EntryTimestamp DEFAULT (SYSDATETIME())
  , ServerProcessID SMALLINT NOT NULL CONSTRAINT DF_LogEntry_ServerProcessID DEFAULT (@@SPID)
  , ServerTransactionID INT NOT NULL CONSTRAINT DF_LogEntry_ServerTransactionID DEFAULT (CURRENT_TRANSACTION_ID())
  , FlowID INT NULL CONSTRAINT DF_LogEntry_FlowID DEFAULT (CAST(SESSION_CONTEXT(N'FlowID') AS INT))
  , ExecutionID INT NULL CONSTRAINT DF_LogEntry_ExecutionID DEFAULT (CAST(SESSION_CONTEXT(N'ExecutionID') AS INT))
  , StatusCode NVARCHAR(50) NULL CONSTRAINT DF_LogEntry_StatusCode DEFAULT (CAST(SESSION_CONTEXT(N'StatusCode') AS NVARCHAR(50)))
  , LogLevelID TINYINT NOT NULL
  , FormattedEntryText NVARCHAR(4000) NULL
  -- Entry components
  , RawEntryText NVARCHAR(4000) NOT NULL
  , Value1 NVARCHAR(4000) NULL
  , Value2 NVARCHAR(4000) NULL
  , Value3 NVARCHAR(4000) NULL
  , Value4 NVARCHAR(4000) NULL
  , Value5 NVARCHAR(4000) NULL
  , CONSTRAINT PK_LogEntry PRIMARY KEY (rv)
  , CONSTRAINT FK_LogEntry_LogLevel FOREIGN KEY (LogLevelID) REFERENCES internal.LogLevel (LogLevelID)
  --, CONSTRAINT FK_LogEntry_Flow FOREIGN KEY (FlowID) REFERENCES internal.Flow (FlowID)
  )

