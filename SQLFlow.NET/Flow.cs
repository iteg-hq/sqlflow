using System.Data;
using System.Data.SqlClient;

namespace SQLFlow
{

    public class Flow
    {
        private FlowDatabase FlowDatabase;

        public readonly int FlowID;

        public FlowParameters Parameters;

        public Status Status
        {
            get
            {
                return FlowDatabase.GetStatusByFlowID(FlowID);
            }
        }

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
