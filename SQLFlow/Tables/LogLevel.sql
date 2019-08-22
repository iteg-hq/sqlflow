CREATE TABLE internal.LogLevel (
    LogLevelID TINYINT NOT NULL
  , LogLevelCode NVARCHAR(10) NOT NULL
  , EchoToOutput BIT NOT NULL
  , CONSTRAINT PK_LogLevel PRIMARY KEY (LogLevelID)
  , CONSTRAINT UQ_LogLevel_LoglevelCode UNIQUE (LogLevelCode)
)
