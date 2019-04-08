using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace SQLFlow
{

    public class Flow
    {
        private FlowDatabase FlowDatabase;

        public readonly int FlowID;
        public FlowParameters Parameters;
        public Status Status { get => FlowDatabase.GetStatusByFlowID(FlowID); }
        public FlowType FlowType { get => FlowDatabase.GetFlowTypeByFlowID(FlowID); }

        public IDictionary<string, Status> Actions { get => FlowDatabase.GetActionsByStatus(Status.FlowType.TypeCode, Status.StatusCode); }

        public Flow(FlowDatabase flowDatabase, int flowID)
        {
            FlowDatabase = flowDatabase;
            FlowID = flowID;
            Parameters = new FlowParameters(flowDatabase, FlowID);
        }

        public void Do(string actionCode)
        {
            FlowDatabase.Do(FlowID, actionCode);
        }
    }
}
