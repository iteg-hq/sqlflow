CREATE PROCEDURE flow.Log
    @LogLevel NVARCHAR(10)
  , @EntryText NVARCHAR(4000)
  , @Value1 NVARCHAR(4000) = NULL
  , @Value2 NVARCHAR(4000) = NULL
  , @Value3 NVARCHAR(4000) = NULL
  , @Value4 NVARCHAR(4000) = NULL
  , @Value5 NVARCHAR(4000) = NULL
  , @FlowID INT = NULL
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;

  DECLARE @EchoToOutput BIT;
  DECLARE @Notify BIT;
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
    , @Notify = Notify
  FROM internals.LogLevel 
  WHERE LogLevelCode = @LogLevel;

  IF @LogLevelID IS NULL
  BEGIN
    IF @LogLevel != 'ERROR'
      EXEC flow.Log 'ERROR', 'Bad loglevel: :1:', @LogLevelID;
    THROW 51000, @LogLevel, 1;
  END
  
  IF @EchoToOutput = 1
    PRINT '[' + @LogLevel + '] ' + @FormattedEntryText;

  INSERT INTO internals.LogEntry (
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

  /*
  IF @Notify = 1
  BEGIN
    DECLARE @Message NVARCHAR(MAX);
    IF '$(NotificationWebhookURL)' LIKE 'https://hooks.slack.com/%'
    BEGIN
      SET @Message = ( SELECT @FormattedEntryText AS 'text' FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )
    END
    EXEC flow.PostToWebhook '$(NotificationWebhookURL)', @Message;
  END
  */
END
