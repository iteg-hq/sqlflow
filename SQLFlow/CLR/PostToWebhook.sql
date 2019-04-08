CREATE PROCEDURE flow.PostToWebhook @WebhookURL NVARCHAR(MAX), @Body NVARCHAR(MAX)
AS EXTERNAL NAME SQLFlow.StoredProcedures.PostToWebhook
;