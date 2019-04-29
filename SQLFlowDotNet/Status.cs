using System.Collections.Generic;

namespace SQLFlow
{
    public class Status
    {
        private readonly FlowDatabase flowDatabase;
        private readonly string flowTypeCode;

        public string StatusCode;
        public FlowType FlowType { get => flowDatabase.GetFlowTypeByCode(flowTypeCode); }

        public IDictionary<string, Status> Actions
        {
            get => flowDatabase.GetActionsByStatus(FlowType.TypeCode, StatusCode);
        }

        internal Status(FlowDatabase flowDatabase, string flowTypeCode, string statusCode)
        {
            this.flowDatabase = flowDatabase;
            this.flowTypeCode = flowTypeCode;
            StatusCode = statusCode;
        }

        public override string ToString()
        {
            return StatusCode;
        }
    }
}
