CREATE PROCEDURE flow.Log
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
FROM flow_internals.LogLevel 
WHERE LogLevelCode = @LogLevel;

IF @LogLevelID IS NULL
BEGIN
  IF @LogLevel != 'ERROR'
    EXEC flow.Log 'ERROR', 'Bad loglevel: :1:', @LogLevelID;
  THROW 51000, @LogLevel, 1;
END

IF @EchoToOutput = 1
  PRINT '[' + COALESCE(CAST(SESSION_CONTEXT(N'FlowID') AS NVARCHAR(10)), 'No FlowID') + '][' + @LogLevel + '] ' + @FormattedEntryText;

INSERT INTO flow_internals.LogEntry (
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

DECLARE @ExecutionID INT = CAST(SESSION_CONTEXT(N'ExecutionID') AS INT)

IF @LogLevel = 'ENTER'
BEGIN
  -- Start an execution log instance
  INSERT INTO flow_internals.Execution (
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

IF @LogLevel = 'LEAVE'
BEGIN
  -- Close an execution log instance
  DECLARE @ParentExecutionID INT;

  UPDATE flow_internals.Execution
  SET ExecutionEndedAt = SYSDATETIME()
  WHERE ExecutionID = @ExecutionID

  SELECT @ParentExecutionID = ParentExecutionID
  FROM flow_internals.Execution
  WHERE ExecutionID = @ExecutionID

  EXEC sp_set_session_context N'ExecutionID', @ParentExecutionID;
END