using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SQLFlow
{
    public class FlowType
    {
        private readonly FlowDatabase FlowDatabase;

        public string TypeCode;
        public string ExecutionGroupCode { get; }
        public Status InitialStatus { get; set; }

        internal FlowType(FlowDatabase flowDatabase, string typeCode)
        {
            FlowDatabase = flowDatabase;
            TypeCode = typeCode;
        }

    }
}
