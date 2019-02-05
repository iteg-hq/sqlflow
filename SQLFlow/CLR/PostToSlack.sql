CREATE PROCEDURE utility.PostToSlack @Message NVARCHAR(200)
AS
DECLARE @JSON NVARCHAR(MAX) = (
    SELECT @Message AS [text]
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
  )

EXEC utility.PostToWebhook '$(WebhookURL)', @JSON;
