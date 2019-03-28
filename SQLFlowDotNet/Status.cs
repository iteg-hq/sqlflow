namespace SQLFlow
{
    public class Status
    {
        private readonly FlowDatabase FlowDatabase;
        private readonly string StatusCode;

        internal Status(FlowDatabase flowDatabase, string statusCode)
        {
            FlowDatabase = flowDatabase;
            StatusCode = statusCode;
        }
    }
}
