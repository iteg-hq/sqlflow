CREATE PROCEDURE flow.Notify @FlowID INT
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  DECLARE @StatusCode NVARCHAR(50)
  DECLARE @Name NVARCHAR(50)
  EXEC flow.Log 'DEBUG', 'Notifying...';

  SELECT
      @StatusCode = StatusCode
    , @Name = [Name]
  FROM flow.Flow
  WHERE FlowID = @FlowID
  ;

  EXEC flow.Log 'ERROR', 'Flow :1: (:2:) has terminated unexpectedly with status code :3:.'
    , @FlowID
    , @Name
    , @StatusCode


/*
SELECT
  'Error message from SQLFlow' AS 'text'
  , (
    SELECT
        FormattedEntryText AS 'title'
      , DATEDIFF(ss, '1970-01-01 00:00:00', GETUTCDATE()) AS 'ts'
      , '#123456' AS 'color'
    FROM flow.LogEntry
    WHERE FlowID = 1
      AND LogLevelCode = 'ERROR'
    FOR JSON PATH
  ) AS 'attachments'
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER 


*/
END