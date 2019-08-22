CREATE PROCEDURE Log
    @LogLevel NVARCHAR(10)
  , @EntryText NVARCHAR(4000)
  , @Value1 NVARCHAR(4000) = NULL
  , @Value2 NVARCHAR(4000) = NULL
  , @Value3 NVARCHAR(4000) = NULL
  , @Value4 NVARCHAR(4000) = NULL
  , @Value5 NVARCHAR(4000) = NULL
AS
SET NOCOUNT, XACT_ABORT ON;

DECLARE @EchoToOutput BIT;
DECLARE @FormattedEntryText NVARCHAR(4000) = @EntryText
SET @FormattedEntryText = REPLACE(@FormattedEntryText, ':1:', COALESCE(@Value1, 'NULL'));
SET @FormattedEntryText = REPLACE(@FormattedEntryText, ':2:', COALESCE(@Value2, 'NULL'));
SET @FormattedEntryText = REPLACE(@FormattedEntryText, ':3:', COALESCE(@Value3, 'NULL'));
SET @FormattedEntryText = REPLACE(@FormattedEntryText, ':4:', COALESCE(@Value4, 'NULL'));
SET @FormattedEntryText = REPLACE(@FormattedEntryText, ':5:', COALESCE(@Value5, 'NULL'));

DECLARE @LogLevelID TINYINT
SELECT
    @LogLevelID = LogLevelID 
  , @EchoToOutput = EchoToOutput
FROM internal.LogLevel 
WHERE LogLevelCode = @LogLevel;

IF @LogLevelID IS NULL
BEGIN
  IF @LogLevel != 'ERROR'
    EXEC Log 'ERROR', 'Bad loglevel: :1:', @LogLevelID;
  THROW 51000, @LogLevel, 1;
END

IF @EchoToOutput = 1
  PRINT '[' + COALESCE(CAST(SESSION_CONTEXT(N'FlowID') AS NVARCHAR(10)), 'No FlowID') + '][' + @LogLevel + '] ' + @FormattedEntryText;

DECLARE @ExecutionID INT = CAST(SESSION_CONTEXT(N'ExecutionID') AS INT)

-- If the log level is ENTER, start a new execution that will include this entry.
IF @LogLevel = 'ENTER'
BEGIN
  -- Start an execution log instance
  INSERT INTO internal.Execution (
      ParentExecutionID
    , ExecutableName
    , ExecutionStartedAt
    )
  VALUES (
      @ExecutionID
    , @FormattedEntryText
    , SYSDATETIME()
    )
  SET @ExecutionID = SCOPE_IDENTITY();

  EXEC sp_set_session_context N'ExecutionID', @ExecutionID;
END

INSERT INTO internal.LogEntry (
    LogLevelID
  , FormattedEntryText
  , RawEntryText
  , Value1
  , Value2
  , Value3
  , Value4
  , Value5
  )
VALUES (
    @LogLevelID
  , @FormattedEntryText
  , @EntryText
  , @Value1
  , @Value2
  , @Value3
  , @Value4
  , @Value5
  )
;
  -- If the log level is LEAVE, end the current execution after logging this entry
IF @LogLevel = 'LEAVE'
BEGIN
  -- Close an execution log instance
  DECLARE @ParentExecutionID INT;

  UPDATE internal.Execution
  SET ExecutionEndedAt = SYSDATETIME()
  WHERE ExecutionID = @ExecutionID

  SELECT @ParentExecutionID = ParentExecutionID
  FROM internal.Execution
  WHERE ExecutionID = @ExecutionID

  EXEC sp_set_session_context N'ExecutionID', @ParentExecutionID;
END