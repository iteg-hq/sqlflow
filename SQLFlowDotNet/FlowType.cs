using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SQLFlow
{
    public class FlowType
    {
        private readonly FlowDatabase db;

        public string TypeCode;
        public string ExecutionGroupCode { get => db.GetExecutionGroupByTypeCode(TypeCode); }
        public Status InitialStatus { get => db.GetInitialStatusByTypeCode(TypeCode); }

        internal FlowType(FlowDatabase flowDatabase, string typeCode)
        {
            db = flowDatabase;
            TypeCode = typeCode;
        }

    }
}
