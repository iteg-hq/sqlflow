using System.Collections.Generic;

namespace SQLFlow
{
    public class Status
    {
        private readonly FlowDatabase FlowDatabase;
        public string StatusCode;
        public FlowType FlowType;

        public IDictionary<string, Status> Actions
        {
            get => FlowDatabase.GetActionsByStatus(FlowType.TypeCode, StatusCode);
        }

        internal Status(FlowDatabase flowDatabase, FlowType flowType, string statusCode)
        {
            FlowDatabase = flowDatabase;
            FlowType = flowType;
            StatusCode = statusCode;
        }

        public override string ToString()
        {
            return StatusCode;
        }
    }
}
