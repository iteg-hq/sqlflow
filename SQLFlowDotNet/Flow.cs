using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace SQLFlow
{
    public class Flow
    {
        private readonly FlowDatabase flowDatabase;

        public readonly int FlowID;
        public FlowParameters Parameters;
        public Status Status { get => flowDatabase.GetStatusByFlowID(FlowID); }
        public FlowType FlowType { get => flowDatabase.GetFlowTypeByFlowID(FlowID); }

        public void Log(LogLevel logLevel, string message, object value1 = null, object value2 = null) => flowDatabase.AddLogEntry(FlowID, logLevel, message, value1, value2);

        public IDictionary<string, Status> Actions { get => flowDatabase.GetActionsByStatus(Status.FlowType.TypeCode, Status.StatusCode); }

        public Flow(FlowDatabase flowDatabase, int flowID)
        {
            this.flowDatabase = flowDatabase;
            FlowID = flowID;
            Parameters = new FlowParameters(flowDatabase, FlowID);
        }

        public void Do(string actionCode)
        {
            flowDatabase.Do(FlowID, actionCode);
        }
    }
}
