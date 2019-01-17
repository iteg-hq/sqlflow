CREATE PROCEDURE flow.PostToSlack
    @WebhookURL NVARCHAR(1000)
  , @RequestBody NVARCHAR(1000)
AS
EXTERNAL NAME SQLFlow.StoredProcedures.PostToWebhook
;
