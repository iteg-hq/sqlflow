using System.Net;

public partial class StoredProcedures
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void PostToWebhook(string webhookURL, string body)
    {
        using (WebClient webClient = new WebClient())
        {
            webClient.Headers[HttpRequestHeader.ContentType] = "application/json";
            var result = webClient.UploadString(webhookURL, body);
        }
    }
}
