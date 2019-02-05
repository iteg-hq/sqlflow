using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SQLFlow
{


    public class FlowParameters
    {
        private readonly FlowDatabase FlowDatabase;
        private readonly int FlowID;

        internal FlowParameters(FlowDatabase flowDatabase, int flowID)
        {
            FlowDatabase = flowDatabase;
            FlowID = flowID;
        }

        public string this[string parameterName]
        {
            get
            {
                return FlowDatabase.GetParameterValue(FlowID, parameterName);
            }
            set
            {
                FlowDatabase.SetParameterValue(FlowID, parameterName, value);
            }
        }
    }
}
