CREATE PROCEDURE utility.PostToSlack @Message NVARCHAR(200)
AS
DECLARE @JSON NVARCHAR(MAX) = (
    SELECT [text]
    FROM ( SELECT @Message AS [text] ) AS message
    FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
  )
EXEC utility.PostToWebhook '$(WebhookURL)', @JSON;
