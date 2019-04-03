namespace SQLFlow
{
    public class Status
    {
        private readonly FlowDatabase FlowDatabase;
        public string StatusCode;

        internal Status(FlowDatabase flowDatabase, string statusCode)
        {
            FlowDatabase = flowDatabase;
            StatusCode = statusCode;
        }

        public override string ToString()
        {
            return StatusCode;
        }
    }
}
