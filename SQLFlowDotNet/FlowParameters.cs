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
        private readonly FlowDatabase flowDatabase;
        private readonly int FlowID;

        internal FlowParameters(FlowDatabase flowDatabase, int flowID)
        {
            this.flowDatabase = flowDatabase;
            FlowID = flowID;
        }

        public string this[string parameterName]
        {
            get
            {
                return flowDatabase.GetParameterValue(FlowID, parameterName);
            }
            set
            {
                flowDatabase.SetParameterValue(FlowID, parameterName, value);
            }
        }
    }
}
